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

      // 9. Usar información de la planta desde la BD (prioridad sobre filename)
      // Si no hay hilera en plantInfo, intentar extraer del filename como fallback
      const filenameData = parseFilename(file.originalname);
      const finalHilera = plantInfo.hilera || filenameData.hilera || '';
      const finalNumeroPlanta = plantInfo.numero_planta || filenameData.planta || plantId;

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
        modelo_dispositivo: 'AgriQR',
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
 * Función auxiliar: Obtener información completa de planta desde plantId
 * 
 * Estrategia de búsqueda (en orden de prioridad):
 * 1. Buscar en GROWER.PLANT - tabla de plantas con lotID, numberLine (hilera), position (planta)
 * 2. Buscar en evalAgri.evaluacionPlagaEnfermedad - tabla de evaluaciones con Planta, lotID, Hilera
 * 3. Buscar en evalImagen.analisisImagen - análisis previos con ese plantId
 * 
 * Retorna toda la información necesaria para guardar en evalImagen.analisisImagen:
 * - lotID, empresa, fundo, sector, lote, hilera, numero_planta
 */
async function getPlantInfoFromPlantId(plantId: string): Promise<{
  lotID: number;
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  hilera: string;
  numero_planta: string;
} | null> {
  try {
    let lotID: number | null = null;
    let hilera: string = '';
    let numero_planta: string = plantId; // Por defecto usar el plantId como numero_planta

    // ESTRATEGIA 1: Buscar en GROWER.PLANT
    // Estructura real: plantID (int), plantationID (int), numberLine (int), position (int)
    // Necesitamos JOIN con GROWER.PLANTATION para obtener lotID
    try {
      // Convertir plantId string a int (puede venir como "00805221" pero en BD es 805221)
      const plantIdInt = parseInt(plantId, 10);
      
      if (isNaN(plantIdInt)) {
        console.warn(`⚠️ getPlantInfoFromPlantId: plantId "${plantId}" no es un número válido`);
      } else {
        const plantResult = await query<{
          lotID: number;
          numberLine: number | null;
          position: number | null;
        }>(`
          SELECT TOP 1 
            pl.lotID,
            p.numberLine,
            p.position
          FROM GROWER.PLANT p WITH (NOLOCK)
          INNER JOIN GROWER.PLANTATION pl WITH (NOLOCK) ON p.plantationID = pl.plantationID
          WHERE p.plantID = @plantIdInt
            AND p.statusID = 1
            AND pl.statusID = 1
        `, { plantIdInt });

        if (plantResult && plantResult.length > 0) {
          lotID = plantResult[0].lotID;
          hilera = plantResult[0].numberLine?.toString() || '';
          numero_planta = plantResult[0].position?.toString() || plantId;
        }
      }
    } catch (plantError: any) {
      // Si la tabla no existe (error 208) o hay error, continuar silenciosamente
      if (plantError?.number === 208) {
        // Tabla no existe, continuar silenciosamente
      } else {
        console.warn(`⚠️ getPlantInfoFromPlantId: Error buscando en GROWER.PLANT:`, plantError.message);
      }
    }

    // ESTRATEGIA 2: Buscar en evalAgri.evaluacionPlagaEnfermedad
    // Esta tabla tiene columnas: lotID, Planta (plantId), Hilera, estadoID
    if (!lotID) {
      try {
        const evaluationResult = await query<{
          lotID: number;
          Hilera: string | null;
        }>(`
          SELECT TOP 1 
            ep.lotID,
            ep.Hilera
          FROM evalAgri.evaluacionPlagaEnfermedad ep WITH (NOLOCK)
          WHERE ep.Planta = @plantId
            AND ep.estadoID = 1
          ORDER BY ep.Fecha DESC
        `, { plantId });

        if (evaluationResult && evaluationResult.length > 0) {
          lotID = evaluationResult[0].lotID;
          hilera = evaluationResult[0].Hilera || '';
        }
      } catch (evaluationError: any) {
        console.warn(`⚠️ getPlantInfoFromPlantId: Error buscando en evalAgri.evaluacionPlagaEnfermedad:`, evaluationError.message);
      }
    }

    // ESTRATEGIA 3: Buscar en evalImagen.analisisImagen (análisis previos)
    if (!lotID) {
      const analysisResult = await query<{
        lotID: number;
        hilera: string | null;
      }>(`
        SELECT TOP 1 
          ai.lotID,
          ai.hilera
        FROM evalImagen.analisisImagen ai WITH (NOLOCK)
        WHERE ai.planta = @plantId
          AND ai.statusID = 1
        ORDER BY ai.fechaCreacion DESC
      `, { plantId });

      if (analysisResult && analysisResult.length > 0) {
        lotID = analysisResult[0].lotID;
        hilera = analysisResult[0].hilera || '';
      }
    }

    // Si no se encontró lotID con ninguna estrategia
    if (!lotID) {
      console.warn(`⚠️ getPlantInfoFromPlantId: No se encontró lotID para plantId=${plantId}`);
      console.warn(`   Estrategias intentadas:`);
      console.warn(`   1. GROWER.PLANT (tabla puede no existir)`);
      console.warn(`   2. evalAgri.evaluacionPlagaEnfermedad (no hay evaluaciones previas)`);
      console.warn(`   3. evalImagen.analisisImagen (no hay análisis previos)`);
      return null;
    }

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

    const result = {
      lotID,
      empresa: lotInfo[0].empresa,
      fundo: lotInfo[0].fundo,
      sector: lotInfo[0].sector,
      lote: lotInfo[0].lote,
      hilera,
      numero_planta
    };


    return result;
  } catch (error) {
    console.error('❌ Error getting plant info:', error);
    return null;
  }
}

export default router;

