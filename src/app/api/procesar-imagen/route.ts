import { NextRequest, NextResponse } from 'next/server';
import { googleSheetsService } from '../../../services/googleSheetsService';
import { sqlServerService } from '@/services/sqlServerService';
import { TensorFlowService } from '../../../services/tensorflowService';
import { createCanvas, loadImage } from 'canvas';
import { parseFilename } from '../../../utils/filenameParser';
import { extractDateTimeFromImageServer } from '../../../utils/exif-server';
import { createThumbnail, estimateBase64Size } from '../../../utils/imageThumbnail';

// Singleton instance for server-side TensorFlow
let serverTensorFlowService: TensorFlowService | null = null;

// Configure body size limit for this route
export const config = {
  api: {
    bodyParser: {
      sizeLimit: '10mb', // Increase limit to 10MB
    },
  },
};

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File;
    const empresa = formData.get('empresa') as string;
    const fundo = formData.get('fundo') as string;
    const sector = formData.get('sector') as string;
    const lote = formData.get('lote') as string;
    const hilera = formData.get('hilera') as string;
    const numero_planta = formData.get('numero_planta') as string;
    const latitud = formData.get('latitud') ? parseFloat(formData.get('latitud') as string) : null;
    const longitud = formData.get('longitud') ? parseFloat(formData.get('longitud') as string) : null;

    if (!file) {
      return NextResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      );
    }

    console.log('🚀 Processing image:', file.name);

    // Initialize TensorFlow.js singleton if not already done
    if (!serverTensorFlowService) {
      console.log('🧠 Initializing server-side TensorFlow.js...');
      serverTensorFlowService = new TensorFlowService();
      await serverTensorFlowService.initialize();
      await serverTensorFlowService.createModel();
      await serverTensorFlowService.trainModel();
    }

    // Process image with TensorFlow.js using Node.js canvas
    const imageBuffer = await file.arrayBuffer();
    
    // Load image using canvas (Node.js compatible)
    const img = await loadImage(Buffer.from(imageBuffer));
    
    // Create canvas and get ImageData
    const canvas = createCanvas(img.width, img.height);
    const ctx = canvas.getContext('2d');
    
    ctx.drawImage(img, 0, 0);
    const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

    // Process with TensorFlow.js
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const tfResult = await serverTensorFlowService.classifyImagePixels(imageDataResult as any);

    // Extract data from filename (if available)
    const filenameData = parseFilename(file.name);
    const finalHilera = hilera || filenameData.hilera || '';
    const finalNumeroPlanta = numero_planta || filenameData.planta || '';

    // Extract date/time from EXIF (if available)
    let exifDateTime = null;
    try {
      exifDateTime = await extractDateTimeFromImageServer(file);
      if (exifDateTime) {
        console.log(`📅 EXIF date extracted: ${exifDateTime.date} ${exifDateTime.time}`);
      } else {
        console.log(`⚠️ No EXIF date found for ${file.name}`);
      }
    } catch (error) {
      console.log('⚠️ Could not extract EXIF date/time:', error);
    }

    // Create processing result
    const processingResult = {
      success: true,
      fileName: file.name,
      image_name: file.name,
      hilera: finalHilera,
      numero_planta: finalNumeroPlanta,
      porcentaje_luz: tfResult.lightPercentage,
      porcentaje_sombra: tfResult.shadowPercentage,
      fundo: fundo || 'Unknown',
      sector: sector || 'Unknown',
      lote: lote || 'Unknown',
      empresa: empresa || 'Unknown',
      latitud: latitud || null,
      longitud: longitud || null,
      processed_image: tfResult.processedImageData,
      timestamp: new Date().toISOString(),
      exifDateTime: exifDateTime
    };

    // Crear thumbnail optimizado para guardar en BD (más pequeño y eficiente)
    console.log('🖼️ Creando thumbnail optimizado...');
    const originalSize = estimateBase64Size(tfResult.processedImageData);
    console.log(`📊 Tamaño imagen original: ~${originalSize} KB`);
    
    const thumbnail = await createThumbnail(tfResult.processedImageData, 800, 600, 0.7);
    const thumbnailSize = estimateBase64Size(thumbnail);
    console.log(`📊 Tamaño thumbnail: ~${thumbnailSize} KB (reducción: ${Math.round((1 - thumbnailSize/originalSize) * 100)}%)`);
    
    // Agregar thumbnail al resultado para guardar en BD
    const processingResultWithThumbnail = {
      ...processingResult,
      thumbnail: thumbnail
    };

    // Save to data store (SQL Server and/or Google Sheets)
    const dataSource = process.env.DATA_SOURCE || 'sql'; // 'sql', 'sheets', 'hybrid'
    let sqlAnalisisId: number | null = null;
    let savedToSheets = false;

    // Guardar en SQL Server
    if (dataSource === 'sql' || dataSource === 'hybrid') {
      try {
        sqlAnalisisId = await sqlServerService.saveProcessingResult(processingResultWithThumbnail);
        console.log(`✅ Processing result saved to SQL Server (ID: ${sqlAnalisisId})`);
      } catch (sqlError) {
        console.error('⚠️ Error saving to SQL Server:', sqlError);
        // En modo SQL puro, lanzar error; en híbrido, continuar
        if (dataSource === 'sql') {
          throw sqlError;
        }
      }
    }

    // Guardar en Google Sheets (si es modo sheets o híbrido)
    if (dataSource === 'sheets' || dataSource === 'hybrid') {
      try {
        await googleSheetsService.saveProcessingResult(processingResult);
        savedToSheets = true;
        console.log('✅ Processing result saved to Google Sheets');
      } catch (sheetsError) {
        console.error('⚠️ Error saving to Google Sheets:', sheetsError);
        // En modo sheets puro, lanzar error; en híbrido, continuar
        if (dataSource === 'sheets') {
          throw sheetsError;
        }
      }
    }

    console.log('✅ Image processing completed:', processingResult.fileName);

    return NextResponse.json({
      ...processingResult,
      sqlAnalisisId,
      savedToSheets,
      dataSource
    });
  } catch (error) {
    console.error('❌ Error processing image:', error);
    return NextResponse.json(
      { error: 'Error processing image' },
      { status: 500 }
    );
  }
}

// Helper function to extract data from filename
function extractDataFromFilename(filename: string) {
  // Example: E07_92_H119_P10.jpg
  const match = filename.match(/(\w+)_(\d+)_H(\d+)_P(\d+)\./);
  
  if (match) {
    return {
      hilera: `H${match[3]}`,
      numero_planta: `P${match[4]}`,
      latitud: null,
      longitud: null
    };
  }
  
  return {
    hilera: '',
    numero_planta: '',
    latitud: null,
    longitud: null
  };
}
