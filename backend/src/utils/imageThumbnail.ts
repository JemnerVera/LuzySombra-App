import { createCanvas, loadImage } from 'canvas';

/**
 * Calcula el tamaño estimado de una imagen Base64 en KB
 */
export function estimateBase64Size(base64Image: string): number {
  // Remover el prefijo data:image si existe
  const base64Data = base64Image.includes(',') 
    ? base64Image.split(',')[1] 
    : base64Image;
  
  // Calcular tamaño aproximado en KB
  // Base64 aumenta el tamaño en ~33%, y dividimos por 1024 para KB
  const sizeInBytes = (base64Data.length * 3) / 4;
  const sizeInKB = sizeInBytes / 1024;
  
  return Math.round(sizeInKB);
}

/**
 * Crea un thumbnail de una imagen Base64 manteniendo el aspect ratio
 * @param base64Image - Imagen en formato Base64 (con o sin data:image)
 * @param maxWidth - Ancho máximo del thumbnail
 * @param maxHeight - Alto máximo del thumbnail
 * @param quality - Calidad de compresión (0-1, solo para JPEG)
 * @returns Imagen Base64 del thumbnail
 */
export async function createThumbnail(
  base64Image: string,
  maxWidth: number,
  maxHeight: number,
  quality: number = 0.8
): Promise<string> {
  try {
    // Remover prefijo data:image si existe
    const base64Data = base64Image.includes(',') 
      ? base64Image.split(',')[1] 
      : base64Image;
    
    // Convertir Base64 a Buffer
    const imageBuffer = Buffer.from(base64Data, 'base64');
    
    // Cargar imagen usando canvas (Node.js)
    const img = await loadImage(imageBuffer);
    
    // Calcular dimensiones manteniendo aspect ratio
    let { width, height } = img;
    if (width > maxWidth || height > maxHeight) {
      const ratio = Math.min(maxWidth / width, maxHeight / height);
      width = Math.round(width * ratio);
      height = Math.round(height * ratio);
    }
    
    // Crear canvas con dimensiones calculadas
    const canvas = createCanvas(width, height);
    const ctx = canvas.getContext('2d');
    
    // Dibujar imagen redimensionada
    ctx.drawImage(img, 0, 0, width, height);
    
    // Convertir a Base64
    // Nota: toDataURL en Node.js canvas devuelve PNG por defecto
    // Para JPEG con calidad, necesitaríamos una librería adicional
    return canvas.toDataURL('image/png');
  } catch (error) {
    console.error('❌ Error creating thumbnail:', error);
    throw error;
  }
}

