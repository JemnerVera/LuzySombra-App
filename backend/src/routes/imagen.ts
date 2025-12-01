import express, { Request, Response } from 'express';
import { query } from '../lib/db';

const router = express.Router();

/**
 * GET /api/imagen/:id
 * Obtiene la imagen procesada (thumbnail) desde SQL Server
 */
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const analisisID = parseInt(req.params.id);
    
    if (!analisisID || isNaN(analisisID)) {
      return res.status(400).json({
        error: 'ID de análisis inválido'
      });
    }

    console.log(`🖼️ Obteniendo imagen para análisis ID: ${analisisID}`);

    const result = await query<{ processedImageUrl: string | null }>(`
      SELECT processedImageUrl 
      FROM evalImagen.AnalisisImagen 
      WHERE analisisID = @analisisID 
        AND statusID = 1
    `, { analisisID });

    if (result.length === 0 || !result[0].processedImageUrl) {
      return res.status(404).json({
        error: 'Imagen no encontrada'
      });
    }

    const imageBase64 = result[0].processedImageUrl;
    
    // Si es Base64 con prefijo data:image, extraer solo los datos
    const base64Data = imageBase64.includes(',') 
      ? imageBase64.split(',')[1] 
      : imageBase64;

    // Determinar tipo MIME (asumir JPEG por defecto)
    const mimeType = imageBase64.startsWith('data:image/jpeg') || 
                     imageBase64.startsWith('data:image/jpg')
      ? 'image/jpeg'
      : imageBase64.startsWith('data:image/png')
      ? 'image/png'
      : 'image/jpeg'; // Default

    // Convertir Base64 a Buffer y retornar como imagen
    const imageBuffer = Buffer.from(base64Data, 'base64');
    
    res.setHeader('Content-Type', mimeType);
    res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    res.send(imageBuffer);

  } catch (error) {
    console.error('❌ Error obteniendo imagen:', error);
    res.status(500).json({
      error: 'Error obteniendo imagen',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

