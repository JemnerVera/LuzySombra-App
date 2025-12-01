import { useState, useCallback } from 'react';

/**
 * Hook para cachear imágenes y evitar recargas innecesarias
 */
export const useImageCache = () => {
  const [cache, setCache] = useState<Map<string, string>>(new Map());

  const getCachedImage = useCallback((url: string): string | null => {
    return cache.get(url) || null;
  }, [cache]);

  const setCachedImage = useCallback((url: string, dataUrl: string) => {
    setCache(prev => {
      const newCache = new Map(prev);
      // Limitar el tamaño del caché a 50 imágenes
      if (newCache.size >= 50) {
        const firstKey = newCache.keys().next().value;
        newCache.delete(firstKey);
      }
      newCache.set(url, dataUrl);
      return newCache;
    });
  }, []);

  const preloadImage = useCallback((url: string): Promise<string> => {
    return new Promise((resolve, reject) => {
      // Verificar si ya está en caché
      const cached = getCachedImage(url);
      if (cached) {
        resolve(cached);
        return;
      }

      const img = new Image();
      img.onload = () => {
        // Convertir a data URL para cachear
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.drawImage(img, 0, 0);
          const dataUrl = canvas.toDataURL('image/jpeg', 0.8);
          setCachedImage(url, dataUrl);
          resolve(dataUrl);
        } else {
          resolve(url);
        }
      };
      img.onerror = reject;
      img.src = url;
    });
  }, [getCachedImage, setCachedImage]);

  const clearCache = useCallback(() => {
    setCache(new Map());
  }, []);

  return {
    getCachedImage,
    setCachedImage,
    preloadImage,
    clearCache,
    cacheSize: cache.size
  };
};

