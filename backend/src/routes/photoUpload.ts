import express, { Request, Response } from 'express';
import multer from 'multer';
import { authenticateToken } from '../middleware/auth';
import { imageProcessingService } from '../services/imageProcessingService';
import { sqlServerService } from '../services/sqlServerService';
import { parseFilename } from '../utils/filenameParser';
import { extractDateTimeFromImageServer, extractGpsFromImageServer } from '../utils/exif-server';
import { createThumbnail } from '../utils/imageThumbnail';
import { createCanvas, loadImage } from 'canvas';
import { query } from '../lib/db';

const router = express.Router();

// Configurar multer (igual que image-processing.ts)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

/**
 * POST /api/photos/upload
 * Endpoint para subir fotos desde app Android (AgriQR)
 * 
 * Body (multipart/form-data):
 * - file: archivo de imagen
 * - plantId: ID de la planta (ej: "00805221")
 * - timestamp: fecha/hora ISO 8601 (opcional, se usa EXIF si no se proporciona)
 */
router.post('/upload', 
  authenticateToken, // Middleware de autenticación JWT
  upload.single('file'),
  async (req: Request, res: Response) => {
    try {
      // 1. Validar archivo
      if (!req.file) {
        return res.status(400).json({
          error: 'No file provided',
          processed: false
        });
      }

      // 2. Validar plantId
      const { plantId, timestamp } = req.body;
      if (!plantId) {
        return res.status(400).json({
          error: 'plantId is required',
          processed: false
        });
      }

      // 3. Obtener información de la planta desde SQL Server
      const plantInfo = await getPlantInfoFromPlantId(plantId);
      
      if (!plantInfo) {
        return res.status(404).json({
          error: `Plant ID ${plantId} not found in database`,
          processed: false
        });
      }

      const file = req.file;
      const imageBuffer = file.buffer;
      
      // 4. Convertir imagen original a Base64 (igual que image-processing.ts)
      const originalImageBase64 = `data:${file.mimetype || 'image/jpeg'};base64,${imageBuffer.toString('base64')}`;
      
      // 5. Crear thumbnail comprimido de la imagen original
      const originalThumbnail = await createThumbnail(originalImageBase64, 400, 300, 0.5);
      
      // 6. Load image using canvas (igual que image-processing.ts)
      const img = await loadImage(imageBuffer);
      
      // 7. Create canvas and get ImageData
      const canvas = createCanvas(img.width, img.height);
      const ctx = canvas.getContext('2d');
      
      ctx.drawImage(img, 0, 0);
      const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

      // 8. Process with heuristic algorithm (REUTILIZA servicio existente)
      const processingResult = await imageProcessingService.classifyImagePixels(imageDataResult);

      // 9. Extract data from filename (si está disponible)
      const filenameData = parseFilename(file.originalname);
      const finalHilera = filenameData.hilera || '';
      const finalNumeroPlanta = filenameData.planta || plantId; // Usar plantId si no hay en filename

      // 10. Extract date/time from EXIF o usar timestamp proporcionado
      let exifDateTime = null;
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

      // 10.5. Extract GPS coordinates from EXIF
      let gpsCoordinates = null;
      try {
        gpsCoordinates = await extractGpsFromImageServer(imageBuffer, file.originalname);
      } catch (error) {
        // GPS extraction failed, continuar sin GPS
        console.warn(`⚠️ No se pudo extraer GPS de ${file.originalname}`);
      }

      // 11. Crear resultado del procesamiento (igual estructura que image-processing.ts)
      const result = {
        success: true,
        fileName: file.originalname,
        image_name: file.originalname,
        hilera: finalHilera,
        numero_planta: finalNumeroPlanta,
        porcentaje_luz: processingResult.lightPercentage,
        porcentaje_sombra: processingResult.shadowPercentage,
        fundo: plantInfo.fundo,
        sector: plantInfo.sector,
        lote: plantInfo.lote,
        empresa: plantInfo.empresa,
        latitud: gpsCoordinates?.lat || null,
        longitud: gpsCoordinates?.lng || null,
        processed_image: processingResult.processedImageData,
        timestamp: new Date().toISOString(),
        exifDateTime: exifDateTime
      };

      // 12. Crear thumbnail optimizado para guardar en BD
      const thumbnail = await createThumbnail(processingResult.processedImageData, 800, 600, 0.7);

      // 13. Agregar thumbnails al resultado
      const resultWithThumbnail = {
        ...result,
        thumbnail: thumbnail,
        originalThumbnail: originalThumbnail
      };

      // 14. Save to SQL Server (REUTILIZA servicio existente)
      let sqlAnalisisId: number | null = null;
      try {
        sqlAnalisisId = await sqlServerService.saveProcessingResult(resultWithThumbnail);
        console.log(`✅ Foto procesada y guardada: analisisID=${sqlAnalisisId}, plantId=${plantId}`);
      } catch (sqlError) {
        console.error('❌ Error saving to SQL Server:', sqlError);
        return res.status(500).json({
          error: 'Error saving to database',
          message: sqlError instanceof Error ? sqlError.message : 'Unknown error',
          processed: false
        });
      }

      // 15. Retornar respuesta exitosa
      res.json({
        success: true,
        photoId: sqlAnalisisId?.toString() || 'unknown',
        processed: true,
        message: 'Foto procesada y guardada en BD',
        porcentaje_luz: processingResult.lightPercentage,
        porcentaje_sombra: processingResult.shadowPercentage
      });

    } catch (error) {
      console.error('❌ Error processing photo:', error);
      res.status(500).json({
        error: 'Error processing image',
        message: error instanceof Error ? error.message : 'Unknown error',
        processed: false
      });
    }
  }
);

/**
 * Función auxiliar: Obtener información de planta desde plantId
 * Busca el último registro en image.Analisis_Imagen con ese plantId (columna "planta")
 * y obtiene empresa/fundo/sector/lote desde el lotID asociado
 */
async function getPlantInfoFromPlantId(plantId: string): Promise<{
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
} | null> {
  try {
    // Buscar el último análisis con ese plantId (columna "planta")
    const analysisResult = await query<{
      lotID: number;
    }>(`
      SELECT TOP 1 ai.lotID
      FROM image.Analisis_Imagen ai WITH (NOLOCK)
      WHERE ai.planta = @plantId
        AND ai.statusID = 1
      ORDER BY ai.fechaCreacion DESC
    `, { plantId });

    if (!analysisResult || analysisResult.length === 0) {
      console.warn(`⚠️ getPlantInfoFromPlantId: No se encontró análisis previo para plantId=${plantId}`);
      return null;
    }

    const lotID = analysisResult[0].lotID;

    // Obtener empresa/fundo/sector/lote desde lotID
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
        AND l.statusID = 1
        AND s.statusID = 1
        AND f.statusID = 1
        AND g.statusID = 1
    `, { lotID });

    if (!lotInfo || lotInfo.length === 0) {
      console.warn(`⚠️ getPlantInfoFromPlantId: No se encontró información de lote para lotID=${lotID}`);
      return null;
    }

    return lotInfo[0];
  } catch (error) {
    console.error('❌ Error getting plant info:', error);
    return null;
  }
}

export default router;

