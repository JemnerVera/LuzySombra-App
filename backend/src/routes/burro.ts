import express, { Request, Response } from 'express';
import multer from 'multer';
import { authenticateToken } from '../middleware/auth';
import { imageProcessingService } from '../services/imageProcessingService';
import { sqlServerService } from '../services/sqlServerService';
import { parseFilename } from '../utils/filenameParser';
import { extractDateTimeFromImageServer, extractGpsFromImageServer, extractLotIdFromExifServer } from '../utils/exif-server';
import { createThumbnail } from '../utils/imageThumbnail';
import { createCanvas, loadImage } from 'canvas';
import { query } from '../lib/db';

const router = express.Router();

// Configurar multer (igual que otros endpoints)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

/**
 * POST /api/burro/upload
 * Endpoint para subir fotos desde el burro (Raspberry Pi)
 * 
 * El burro debe tener configurado el lotID en los metadatos EXIF de la imagen.
 * Se extrae desde ImageDescription o UserComment en formato "lotID:123" o simplemente "123"
 * 
 * Body (multipart/form-data):
 * - file: archivo de imagen (REQUERIDO)
 * - timestamp: fecha/hora ISO 8601 (opcional, se usa EXIF si no se proporciona)
 * 
 * Headers:
 * - Authorization: Bearer <JWT_TOKEN> (REQUERIDO)
 */
router.post('/upload', 
  authenticateToken, // Middleware de autenticación JWT (mismo que AgriQR)
  upload.single('file'),
  async (req: Request, res: Response) => {
    try {
      // Debug: Log request details
      const headersSafe = { ...req.headers };
      if (headersSafe.authorization) headersSafe.authorization = 'Bearer [REDACTED]';
      
      console.log('📤 [burro/upload] Request recibido:');
      console.log(`   Headers: ${JSON.stringify(headersSafe)}`);
      console.log(`   Content-Type: ${req.headers['content-type']}`);
      console.log(`   Body keys: ${Object.keys(req.body || {})}`);
      console.log(`   File: ${req.file ? `Existe - ${req.file.originalname}, ${req.file.size} bytes` : 'NO EXISTE'}`);
      
      // 1. Validar archivo
      if (!req.file) {
        console.error('❌ [burro/upload] Error: No file provided in request');
        console.error(`   Content-Type recibido: ${req.headers['content-type']}`);
        console.error(`   Body recibido: ${JSON.stringify(req.body)}`);
        return res.status(400).json({
          error: 'No file provided',
          processed: false,
          hint: 'The request must include a file field named "file" in multipart/form-data format'
        });
      }

      const file = req.file;
      const imageBuffer = file.buffer;

      // 2. Extraer lotID desde EXIF (REQUERIDO)
      let lotID: number | null = null;
      try {
        lotID = await extractLotIdFromExifServer(imageBuffer, file.originalname);
      } catch (error) {
        console.error(`❌ Error extracting lotID from EXIF for ${file.originalname}:`, error);
      }

      if (!lotID || lotID <= 0) {
        console.error(`❌ [burro/upload] Error: lotID not found in EXIF for ${file.originalname}`);
        return res.status(400).json({
          error: 'lotID not found in EXIF metadata. The image must contain lotID in ImageDescription or UserComment field.',
          processed: false,
          hint: 'Configure lotID in the burro before taking photos. The lotID should be stored in EXIF ImageDescription field (e.g., "lotID:123" or just "123")',
          filename: file.originalname
        });
      }

      console.log(`🏷️ lotID extracted from EXIF for ${file.originalname}: ${lotID}`);

      // 3. Obtener información de empresa/fundo/sector/lote desde lotID
      const lotInfo = await getLotInfoFromLotId(lotID);
      
      if (!lotInfo) {
        return res.status(404).json({
          error: `Lot ID ${lotID} not found in database or is inactive`,
          processed: false
        });
      }

      // 4. Convertir imagen original a Base64
      const originalImageBase64 = `data:${file.mimetype || 'image/jpeg'};base64,${imageBuffer.toString('base64')}`;
      
      // 5. Crear thumbnail comprimido de la imagen original
      const originalThumbnail = await createThumbnail(originalImageBase64, 400, 300, 0.5);
      
      // 6. Load image using canvas
      const img = await loadImage(imageBuffer);
      
      // 7. Create canvas and get ImageData
      const canvas = createCanvas(img.width, img.height);
      const ctx = canvas.getContext('2d');
      
      ctx.drawImage(img, 0, 0);
      const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

      // 8. Process with heuristic algorithm
      const processingResult = await imageProcessingService.classifyImagePixels(imageDataResult);

      // 9. Extraer hilera y planta del filename si está disponible
      const filenameData = parseFilename(file.originalname);
      const finalHilera = filenameData.hilera || '';
      const finalNumeroPlanta = filenameData.planta || '';

      // 10. Extract date/time from EXIF o usar timestamp proporcionado
      let exifDateTime = null;
      const { timestamp } = req.body;
      if (timestamp) {
        // Usar timestamp proporcionado
        const date = new Date(timestamp);
        exifDateTime = {
          date: date.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric' }),
          time: date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
        };
      } else {
        // Intentar extraer de EXIF
        try {
          exifDateTime = await extractDateTimeFromImageServer(imageBuffer, file.originalname);
        } catch (error) {
          // EXIF extraction failed, usar fecha actual
          const now = new Date();
          exifDateTime = {
            date: now.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric' }),
            time: now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
          };
        }
      }

      // 11. Extract GPS coordinates from EXIF
      let gpsCoordinates = null;
      try {
        gpsCoordinates = await extractGpsFromImageServer(imageBuffer, file.originalname);
      } catch (error) {
        // GPS extraction failed, continuar sin GPS
        console.warn(`⚠️ No se pudo extraer GPS de ${file.originalname}`);
      }

      // 12. Crear resultado del procesamiento
      const result = {
        success: true,
        fileName: file.originalname,
        image_name: file.originalname,
        hilera: finalHilera,
        numero_planta: finalNumeroPlanta,
        porcentaje_luz: processingResult.lightPercentage,
        porcentaje_sombra: processingResult.shadowPercentage,
        fundo: lotInfo.fundo,
        sector: lotInfo.sector,
        lote: lotInfo.lote,
        empresa: lotInfo.empresa,
        latitud: gpsCoordinates?.lat || null,
        longitud: gpsCoordinates?.lng || null,
        processed_image: processingResult.processedImageData,
        timestamp: new Date().toISOString(),
        exifDateTime: exifDateTime
      };

      // 13. Crear thumbnail optimizado para guardar en BD
      const thumbnail = await createThumbnail(processingResult.processedImageData, 800, 600, 0.7);

      // 14. Agregar thumbnails al resultado
      const resultWithThumbnail = {
        ...result,
        thumbnail: thumbnail,
        originalThumbnail: originalThumbnail
      };

      // 15. Save to SQL Server
      let sqlAnalisisId: number | null = null;
      try {
        sqlAnalisisId = await sqlServerService.saveProcessingResult(resultWithThumbnail);
      } catch (sqlError) {
        console.error('❌ Error saving to SQL Server:', sqlError);
        return res.status(500).json({
          error: 'Error saving to database',
          message: sqlError instanceof Error ? sqlError.message : 'Unknown error',
          processed: false
        });
      }

      // 16. Retornar respuesta exitosa
      res.json({
        success: true,
        photoId: sqlAnalisisId?.toString() || 'unknown',
        processed: true,
        message: 'Foto procesada y guardada en BD',
        porcentaje_luz: processingResult.lightPercentage,
        porcentaje_sombra: processingResult.shadowPercentage,
        lotID: lotID,
        empresa: lotInfo.empresa,
        fundo: lotInfo.fundo,
        sector: lotInfo.sector,
        lote: lotInfo.lote
      });

    } catch (error) {
      console.error('❌ Error processing photo from burro:', error);
      res.status(500).json({
        error: 'Error processing image',
        message: error instanceof Error ? error.message : 'Unknown error',
        processed: false
      });
    }
  }
);

/**
 * Función auxiliar: Obtener información completa de lote desde lotID
 * 
 * Retorna empresa/fundo/sector/lote desde el lotID
 */
async function getLotInfoFromLotId(lotID: number): Promise<{
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
} | null> {
  try {
    // NO filtrar por statusID - necesitamos obtener la info aunque esté inactivo
    // porque las tablas de la app se deben llenar correctamente
    const lotInfo = await query<{
      empresa: string;
      fundo: string;
      sector: string;
      lote: string;
    }>(`
      SELECT 
        g.businessName as empresa,
        f.Description as fundo,
        s.stage as sector,
        l.name as lote
      FROM GROWER.LOT l WITH (NOLOCK)
      INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
      INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
      INNER JOIN GROWER.GROWERS g WITH (NOLOCK) ON s.growerID = g.growerID
      WHERE l.lotID = @lotID
    `, { lotID });

    if (!lotInfo || lotInfo.length === 0) {
      console.warn(`⚠️ getLotInfoFromLotId: No se encontró información de lote para lotID=${lotID}`);
      return null;
    }

    const result = {
      empresa: lotInfo[0].empresa,
      fundo: lotInfo[0].fundo,
      sector: lotInfo[0].sector,
      lote: lotInfo[0].lote
    };


    return result;
  } catch (error) {
    console.error('❌ Error getting lot info:', error);
    return null;
  }
}

export default router;
