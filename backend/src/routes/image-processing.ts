import express, { Request, Response } from 'express';
import multer from 'multer';
import { createCanvas, loadImage } from 'canvas';
import { sqlServerService } from '../services/sqlServerService';
import { imageProcessingService } from '../services/imageProcessingService';
import { parseFilename } from '../utils/filenameParser';
import { extractDateTimeFromImageServer } from '../utils/exif-server';
import { createThumbnail, estimateBase64Size } from '../utils/imageThumbnail';

const router = express.Router();

// Configurar multer para manejar archivos en memoria
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

router.post('/', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: 'No file provided'
      });
    }

    const { empresa, fundo, sector, lote, hilera, numero_planta, latitud, longitud } = req.body;

    console.log('🚀 Processing image:', req.file.originalname);
    console.log('📋 Data:', { empresa, fundo, sector, lote });

    const file = req.file;
    const imageBuffer = file.buffer;
    
    // Convertir imagen original a Base64
    const originalImageBase64 = `data:${file.mimetype || 'image/jpeg'};base64,${imageBuffer.toString('base64')}`;
    
    // Crear thumbnail comprimido de la imagen original
    console.log('🖼️ Creando thumbnail comprimido de imagen original...');
    const originalThumbnail = await createThumbnail(originalImageBase64, 400, 300, 0.5);
    const originalThumbnailSize = estimateBase64Size(originalThumbnail);
    console.log(`📊 Tamaño thumbnail original: ~${originalThumbnailSize} KB`);
    
    // Load image using canvas (Node.js compatible)
    const img = await loadImage(imageBuffer);
    
    // Create canvas and get ImageData
    const canvas = createCanvas(img.width, img.height);
    const ctx = canvas.getContext('2d');
    
    ctx.drawImage(img, 0, 0);
    const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

    // Process with heuristic algorithm (NO TensorFlow needed)
    console.log('🧠 Procesando imagen con algoritmo heurístico (sin TensorFlow)...');
    const processingResult = await imageProcessingService.classifyImagePixels(imageDataResult);

    // Extract data from filename (if available)
    const filenameData = parseFilename(file.originalname);
    const finalHilera = hilera || filenameData.hilera || '';
    const finalNumeroPlanta = numero_planta || filenameData.planta || '';

    // Extract date/time from EXIF (if available)
    let exifDateTime = null;
    try {
      exifDateTime = await extractDateTimeFromImageServer(imageBuffer, file.originalname);
      if (exifDateTime) {
        console.log(`📅 EXIF date extracted: ${exifDateTime.date} ${exifDateTime.time}`);
      }
    } catch (error) {
      console.log('⚠️ Could not extract EXIF date/time:', error);
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
      fundo: fundo || 'Unknown',
      sector: sector || 'Unknown',
      lote: lote || 'Unknown',
      empresa: empresa || 'Unknown',
      latitud: latitud ? parseFloat(latitud) : null,
      longitud: longitud ? parseFloat(longitud) : null,
      processed_image: processingResult.processedImageData,
      timestamp: new Date().toISOString(),
      exifDateTime: exifDateTime
    };

    // Crear thumbnail optimizado para guardar en BD
    console.log('🖼️ Creando thumbnail optimizado...');
    const originalSize = estimateBase64Size(processingResult.processedImageData);
    console.log(`📊 Tamaño imagen procesada: ~${originalSize} KB`);
    
    const thumbnail = await createThumbnail(processingResult.processedImageData, 800, 600, 0.7);
    const thumbnailSize = estimateBase64Size(thumbnail);
    console.log(`📊 Tamaño thumbnail: ~${thumbnailSize} KB`);

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
        console.log(`✅ Processing result saved to SQL Server (ID: ${sqlAnalisisId})`);
      } catch (sqlError) {
        console.error('⚠️ Error saving to SQL Server:', sqlError);
        if (dataSource === 'sql') {
          throw sqlError;
        }
      }
    }

    console.log('✅ Image processing completed:', result.fileName);

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

export default router;


