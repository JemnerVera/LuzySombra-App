import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

/**
 * GET /api/imagen/[id]
 * 
 * Obtiene la imagen procesada (thumbnail) desde SQL Server
 * 
 * @param request - Request object
 * @param context - Context con params.id
 */
export async function GET(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    const params = await context.params;
    const analisisID = parseInt(params.id);
    
    if (!analisisID || isNaN(analisisID)) {
      return NextResponse.json(
        { error: 'ID de análisis inválido' },
        { status: 400 }
      );
    }

    console.log(`🖼️ Obteniendo imagen para análisis ID: ${analisisID}`);

    const result = await query<{ processedImageUrl: string | null }>(`
      SELECT processedImageUrl 
      FROM image.Analisis_Imagen 
      WHERE analisisID = @analisisID 
        AND statusID = 1
    `, { analisisID });

    if (result.length === 0 || !result[0].processedImageUrl) {
      return NextResponse.json(
        { error: 'Imagen no encontrada' },
        { status: 404 }
      );
    }

    const imageBase64 = result[0].processedImageUrl;
    
    // Si es Base64 con prefijo data:image, extraer solo los datos
    const base64Data = imageBase64.includes(',') 
      ? imageBase64.split(',')[1] 
      : imageBase64;

    // Determinar tipo MIME (asumir JPEG por defecto, que es lo que guardamos)
    const mimeType = imageBase64.startsWith('data:image/jpeg') || 
                     imageBase64.startsWith('data:image/jpg')
      ? 'image/jpeg'
      : imageBase64.startsWith('data:image/png')
      ? 'image/png'
      : 'image/jpeg'; // Default

    // Convertir Base64 a Buffer y retornar como imagen
    const imageBuffer = Buffer.from(base64Data, 'base64');
    
    return new NextResponse(imageBuffer, {
      headers: {
        'Content-Type': mimeType,
        'Cache-Control': 'public, max-age=31536000, immutable',
      },
    });

  } catch (error) {
    console.error('❌ Error obteniendo imagen:', error);
    return NextResponse.json(
      { error: 'Error obteniendo imagen' },
      { status: 500 }
    );
  }
}

