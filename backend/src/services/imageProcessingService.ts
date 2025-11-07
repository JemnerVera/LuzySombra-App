/**
 * Servicio de procesamiento de imágenes - Algoritmo heurístico básico
 * NO requiere TensorFlow - Usa algoritmo simple basado en brillo (brightness threshold)
 */

// Tipo para ImageData compatible con Node.js canvas
interface ImageData {
  data: Uint8ClampedArray;
  width: number;
  height: number;
}

export interface PixelClassificationResult {
  lightPercentage: number;
  shadowPercentage: number;
  processedImageData: string; // Base64 encoded image
  classificationMap: number[][];
}

export class ImageProcessingService {
  /**
   * Clasifica píxeles usando algoritmo heurístico simple
   * Basado en análisis de datos etiquetados (threshold: 130)
   * 
   * Algoritmo:
   * 1. Calcula brillo de cada píxel: brightness = (r + g + b) / 3
   * 2. Compara con threshold: brightness > 130 ? luz : sombra
   * 
   * NO requiere TensorFlow - Algoritmo básico pero efectivo
   */
  async classifyImagePixels(imageData: ImageData): Promise<PixelClassificationResult> {
    try {
      const { data, width, height } = imageData;
      const classificationMap: number[][] = [];
      let lightPixels = 0;
      let shadowPixels = 0;

      console.log(`🔍 Processing image: ${width}x${height} pixels with heuristic algorithm (threshold: 130)`);

      // Initialize classification map
      for (let y = 0; y < height; y++) {
        classificationMap[y] = [];
      }

      // Process image pixel by pixel
      const threshold = 130; // Optimal threshold from labeled data analysis
      
      for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
          const pixelIndex = (y * width + x) * 4;
          const r = data[pixelIndex];
          const g = data[pixelIndex + 1];
          const b = data[pixelIndex + 2];
          
          // Calculate brightness for this pixel
          const brightness = (r + g + b) / 3;
          
          // Simple heuristic classification
          // Threshold 130 was determined from labeled agricultural images
          const classification = brightness > threshold ? 0 : 1; // 0 = light, 1 = shadow
          
          classificationMap[y][x] = classification;
          if (classification === 0) {
            lightPixels++;
          } else {
            shadowPixels++;
          }
        }
      }

      const totalPixels = lightPixels + shadowPixels;
      const lightPercentage = (lightPixels / totalPixels) * 100;
      const shadowPercentage = (shadowPixels / totalPixels) * 100;

      // Create processed image
      const processedImageData = this.createProcessedImage(imageData, classificationMap);

      console.log(`✅ Image processed: ${lightPercentage.toFixed(2)}% light, ${shadowPercentage.toFixed(2)}% shadow`);

      return {
        lightPercentage,
        shadowPercentage,
        processedImageData,
        classificationMap
      };
    } catch (error) {
      console.error('❌ Error classifying pixels:', error);
      throw error;
    }
  }

  /**
   * Crea imagen procesada con colores de clasificación
   */
  private createProcessedImage(imageData: ImageData, classificationMap: number[][]): string {
    try {
      // Import canvas dynamically for Node.js
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const { createCanvas } = require('canvas');
      
      const canvas = createCanvas(imageData.width, imageData.height);
      const ctx = canvas.getContext('2d');
      
      // Create image data for the processed image
      const processedImageData = ctx.createImageData(imageData.width, imageData.height);
      
      // Apply classification colors
      for (let y = 0; y < imageData.height; y++) {
        for (let x = 0; x < imageData.width; x++) {
          const pixelIndex = (y * imageData.width + x) * 4;
          const classification = classificationMap[y]?.[x] || 0;
          
          if (classification === 0) {
            // Light area - green
            processedImageData.data[pixelIndex] = 0;     // R
            processedImageData.data[pixelIndex + 1] = 255; // G
            processedImageData.data[pixelIndex + 2] = 0;   // B
            processedImageData.data[pixelIndex + 3] = 255; // A
          } else {
            // Shadow area - blue
            processedImageData.data[pixelIndex] = 0;     // R
            processedImageData.data[pixelIndex + 1] = 0;   // G
            processedImageData.data[pixelIndex + 2] = 255; // B
            processedImageData.data[pixelIndex + 3] = 255; // A
          }
        }
      }
      
      // Put the processed image data on canvas
      ctx.putImageData(processedImageData, 0, 0);
      
      // Convert to base64
      return canvas.toDataURL('image/png');
    } catch (error) {
      console.error('❌ Error creating processed image:', error);
      // Return a simple placeholder if canvas fails
      return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    }
  }
}

export const imageProcessingService = new ImageProcessingService();

