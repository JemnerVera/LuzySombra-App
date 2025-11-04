/**
 * Utilidades para crear thumbnails de imágenes optimizadas para SQL Server
 */

/**
 * Crea un thumbnail pequeño desde una imagen Base64
 * @param base64Image - Imagen en formato Base64 (con o sin data:image)
 * @param maxWidth - Ancho máximo del thumbnail (default: 800px)
 * @param maxHeight - Alto máximo del thumbnail (default: 600px)
 * @param quality - Calidad JPEG (0-1, default: 0.7 para balance tamaño/calidad)
 * @returns Base64 del thumbnail optimizado
 */
export async function createThumbnail(
  base64Image: string,
  maxWidth: number = 800,
  maxHeight: number = 600,
  quality: number = 0.7
): Promise<string> {
  try {
    // Limpiar el prefijo data:image si existe
    const base64Data = base64Image.includes(',') 
      ? base64Image.split(',')[1] 
      : base64Image;

    // En Node.js, usar canvas para crear thumbnail
    if (typeof window === 'undefined') {
      const { createCanvas, loadImage } = require('canvas');
      const imageBuffer = Buffer.from(base64Data, 'base64');
      const img = await loadImage(imageBuffer);
      
      // Calcular dimensiones manteniendo aspecto
      let { width, height } = img;
      if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height);
        width = Math.round(width * ratio);
        height = Math.round(height * ratio);
      }
      
      // Crear canvas con dimensiones reducidas
      const canvas = createCanvas(width, height);
      const ctx = canvas.getContext('2d');
      
      // Dibujar imagen redimensionada
      ctx.drawImage(img, 0, 0, width, height);
      
      // Convertir a Base64 con calidad optimizada
      return canvas.toDataURL('image/jpeg', quality);
    } else {
      // En el navegador, usar HTML5 Canvas
      return new Promise((resolve, reject) => {
        const img = new Image();
        img.onload = () => {
          // Calcular dimensiones manteniendo aspecto
          let { width, height } = img;
          if (width > maxWidth || height > maxHeight) {
            const ratio = Math.min(maxWidth / width, maxHeight / height);
            width = Math.round(width * ratio);
            height = Math.round(height * ratio);
          }
          
          // Crear canvas con dimensiones reducidas
          const canvas = document.createElement('canvas');
          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext('2d');
          
          if (!ctx) {
            reject(new Error('No se pudo obtener contexto del canvas'));
            return;
          }
          
          // Dibujar imagen redimensionada
          ctx.drawImage(img, 0, 0, width, height);
          
          // Convertir a Base64 con calidad optimizada
          const thumbnail = canvas.toDataURL('image/jpeg', quality);
          resolve(thumbnail);
        };
        img.onerror = reject;
        img.src = base64Image;
      });
    }
  } catch (error) {
    console.error('❌ Error creating thumbnail:', error);
    // Retornar imagen original si falla
    return base64Image;
  }
}

/**
 * Estima el tamaño de una imagen Base64 en KB
 */
export function estimateBase64Size(base64String: string): number {
  // Remover prefijo data:image si existe
  const base64Data = base64String.includes(',') 
    ? base64String.split(',')[1] 
    : base64String;
  
  // Base64 es ~33% más grande que el binario original
  // Aproximación: (length * 3/4) / 1024 para obtener KB
  return Math.round((base64Data.length * 3) / 4 / 1024);
}

