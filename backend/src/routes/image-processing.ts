import express, { Request, Response } from 'express';
import multer from 'multer';
import { createCanvas, loadImage } from 'canvas';
import { sqlServerService } from '../services/sqlServerService';
import { imageProcessingService } from '../services/imageProcessingService';
import { parseFilename } from '../utils/filenameParser';
import { extractDateTimeFromImageServer, extractLotIdFromExifServer } from '../utils/exif-server';
import { createThumbnail } from '../utils/imageThumbnail';
import { query } from '../lib/db';
import logger from '../lib/logger';

// Configurar multer para manejar archivos en memoria
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

const router = express.Router();

// Export additional routers for test-model and check-gps-info
export const testModelRouter = express.Router();
export const checkGpsInfoRouter = express.Router();

router.post('/', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No file provided'
      });
    }

    const { empresa, fundo, sector, lote, hilera, numero_planta, latitud, longitud, exifDate, exifTime } = req.body;

    const file = req.file;
    const imageBuffer = file.buffer;

    // Intentar extraer lotID desde EXIF y obtener info del lote automáticamente
    let finalEmpresa = empresa;
    let finalFundo = fundo;
    let finalSector = sector;
    let finalLote = lote;
    let lotID: number | null = null;

    try {
      lotID = await extractLotIdFromExifServer(imageBuffer, file.originalname);
      if (lotID && lotID > 0) {
        logger.debug(`lotID extraído desde EXIF para ${file.originalname}`, { lotID, filename: file.originalname });
        
        // Obtener información del lote desde la BD
        const lotInfo = await getLotInfoFromLotId(lotID);
        if (lotInfo) {
          finalEmpresa = lotInfo.empresa;
          finalFundo = lotInfo.fundo;
          finalSector = lotInfo.sector;
          finalLote = lotInfo.lote;
        } else {
          logger.debug(`No se encontró información de lote para lotID=${lotID}, usando valores del formulario`, { lotID });
        }
      }
    } catch (error) {
      logger.debug(`Error extrayendo lotID desde EXIF para ${file.originalname}`, { error: error instanceof Error ? error.message : 'Unknown error' });
      // Continuar con valores del formulario
    }
    
    // Convertir imagen original a Base64
    const originalImageBase64 = `data:${file.mimetype || 'image/jpeg'};base64,${imageBuffer.toString('base64')}`;
    
    // Crear thumbnail comprimido de la imagen original
    const originalThumbnail = await createThumbnail(originalImageBase64, 400, 300, 0.5);
    
    // Load image using canvas (Node.js compatible)
    const img = await loadImage(imageBuffer);
    
    // Create canvas and get ImageData
    const canvas = createCanvas(img.width, img.height);
    const ctx = canvas.getContext('2d');
    
    ctx.drawImage(img, 0, 0);
    const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

    // Process with heuristic algorithm
    const processingResult = await imageProcessingService.classifyImagePixels(imageDataResult);

    // Extract data from filename (if available)
    const filenameData = parseFilename(file.originalname);
    const finalHilera = hilera || filenameData.hilera || '';
    const finalNumeroPlanta = numero_planta || filenameData.planta || '';

    // Extract date/time from EXIF (priorizar fecha enviada desde frontend)
    let exifDateTime = null;
    
    // Primero intentar usar la fecha EXIF enviada desde el frontend
    if (exifDate && exifTime) {
      exifDateTime = {
        date: exifDate,
        time: exifTime
      };
    } else {
      // Si no se recibió del frontend, intentar extraer del buffer
      try {
        exifDateTime = await extractDateTimeFromImageServer(imageBuffer, file.originalname);
        if (exifDateTime) {
        }
      } catch (error) {
        // EXIF extraction failed, continue without date
      }
    }

    // Create processing result
    const result = {
      success: true,
      fileName: file.originalname,
      image_name: file.originalname,
      hilera: finalHilera,
      numero_planta: finalNumeroPlanta,
      porcentaje_luz: processingResult.lightPercentage,
      porcentaje_sombra: processingResult.shadowPercentage,
      fundo: finalFundo || 'Unknown',
      sector: finalSector || 'Unknown',
      lote: finalLote || 'Unknown',
      empresa: finalEmpresa || 'Unknown',
      latitud: latitud ? parseFloat(latitud) : null,
      longitud: longitud ? parseFloat(longitud) : null,
      processed_image: processingResult.processedImageData,
      timestamp: new Date().toISOString(),
      exifDateTime: exifDateTime
    };

        // Crear thumbnail optimizado para guardar en BD
        const thumbnail = await createThumbnail(processingResult.processedImageData, 800, 600, 0.7);

        // Agregar thumbnails al resultado
        const resultWithThumbnail = {
          ...result,
          thumbnail: thumbnail,
          originalThumbnail: originalThumbnail
        };

        // Save to SQL Server
        const dataSource = process.env.DATA_SOURCE || 'sql';
        let sqlAnalisisId: number | null = null;

        if (dataSource === 'sql' || dataSource === 'hybrid') {
          try {
            sqlAnalisisId = await sqlServerService.saveProcessingResult(resultWithThumbnail);
          } catch (sqlError) {
            console.error('❌ Error saving to SQL Server:', sqlError);
            if (dataSource === 'sql') {
              // Re-lanzar el error para que se maneje en el catch principal
              throw sqlError;
            }
            // Si es hybrid, continuar sin guardar en SQL
          }
        }

    res.json({
      ...result,
      sqlAnalisisId,
      dataSource
    });
  } catch (error) {
    console.error('❌ Error processing image:', error);
    res.status(500).json({
      error: 'Error processing image',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Test model endpoint (doesn't save to DB)
testModelRouter.post('/', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No file provided'
      });
    }

    const file = req.file;
    const imageBuffer = file.buffer;
    
    // Load image using canvas (Node.js compatible)
    const img = await loadImage(imageBuffer);
    
    // Create canvas and get ImageData
    const canvas = createCanvas(img.width, img.height);
    const ctx = canvas.getContext('2d');
    
    ctx.drawImage(img, 0, 0);
    const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

    // Process with heuristic algorithm
    const processingResult = await imageProcessingService.classifyImagePixels(imageDataResult);

    // Convert processed image to base64
    const processedImageData = processingResult.processedImageData;

    res.json({
      success: true,
      fileName: file.originalname,
      porcentaje_luz: processingResult.lightPercentage,
      porcentaje_sombra: processingResult.shadowPercentage,
      processed_image: processedImageData,
      empresa: 'Prueba del Modelo',
      fundo: 'Backend Heuristic',
      hilera: '',
      numero_planta: '',
      latitud: null,
      longitud: null
    });
  } catch (error) {
    console.error('❌ Error testing model:', error);
    res.status(500).json({
      error: 'Error testing model',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Check GPS info from image
checkGpsInfoRouter.post('/', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No file provided'
      });
    }

    const file = req.file;
    const imageBuffer = file.buffer;
    
    // Extract GPS coordinates from EXIF
    try {
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const piexif = require('piexifjs');
      const binary = imageBuffer.toString('binary');
      const exifData = piexif.load(binary);
      
      if (exifData && exifData.GPS) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const gps = exifData.GPS as any;
        
        if (gps[piexif.GPSIFD.GPSLatitude] && gps[piexif.GPSIFD.GPSLongitude]) {
          // Convert DMS to decimal degrees
          const latArray = gps[piexif.GPSIFD.GPSLatitude];
          const latRef = gps[piexif.GPSIFD.GPSLatitudeRef] || 'N';
          const lonArray = gps[piexif.GPSIFD.GPSLongitude];
          const lonRef = gps[piexif.GPSIFD.GPSLongitudeRef] || 'E';
          
          const lat = (latArray[0][0] / latArray[0][1]) + 
                      (latArray[1][0] / latArray[1][1]) / 60 + 
                      (latArray[2][0] / latArray[2][1]) / 3600;
          const lon = (lonArray[0][0] / lonArray[0][1]) + 
                      (lonArray[1][0] / lonArray[1][1]) / 60 + 
                      (lonArray[2][0] / lonArray[2][1]) / 3600;
          
          const finalLat = latRef === 'S' ? -lat : lat;
          const finalLon = lonRef === 'W' ? -lon : lon;
          
          return res.json({
            success: true,
            hasGps: true,
            coordinates: {
              lat: finalLat,
              lng: finalLon
            }
          });
        }
      }
      
      return res.json({
        success: true,
        hasGps: false
      });
    } catch (error) {
      console.error('❌ Error checking GPS info:', error);
      return res.json({
        success: true,
        hasGps: false
      });
    }
  } catch (error) {
    console.error('❌ Error processing GPS check:', error);
    res.status(500).json({
      error: 'Error checking GPS info',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Función auxiliar: Obtener información completa de lote desde lotID
 * (Reutilizada desde burro.ts)
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
      logger.warn(`No se encontró información de lote para lotID=${lotID}`);
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
    logger.error('Error getting lot info', { error: error instanceof Error ? error.message : 'Unknown error' });
    return null;
  }
}

export default router;
