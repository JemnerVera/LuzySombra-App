// EXIF utilities for GPS extraction

declare global {
  interface Window {
    EXIF: {
      getData: (file: File, callback: (this: File) => void) => void;
      getTag: (file: File, tag: string) => number[] | string | undefined;
    };
  }
}

export interface GpsCoordinates {
  lat: number;
  lng: number;
}

// Cache para evitar extracciones duplicadas
const gpsCache = new Map<string, GpsCoordinates | null>();

export const extractGpsFromImage = (file: File): Promise<GpsCoordinates | null> => {
  return new Promise((resolve) => {
    // Check cache first
    const cacheKey = `${file.name}_${file.size}_${file.lastModified}`;
    if (gpsCache.has(cacheKey)) {
      const cached = gpsCache.get(cacheKey);
      console.log(`📋 Using cached GPS data for ${file.name}:`, cached ? 'Found' : 'Not found');
      resolve(cached || null);
      return;
    }

    // Check if EXIF.js is available
    if (typeof window.EXIF === 'undefined') {
      console.warn('EXIF.js not loaded for file:', file.name);
      gpsCache.set(cacheKey, null);
      resolve(null);
      return;
    }

    // Add timeout to prevent hanging
    const timeout = setTimeout(() => {
      console.warn('GPS extraction timeout for file:', file.name);
      gpsCache.set(cacheKey, null);
      resolve(null);
    }, 5000); // 5 second timeout

    window.EXIF.getData(file, function(this: File) {
      clearTimeout(timeout);
      
      try {
        const lat = window.EXIF.getTag(this, "GPSLatitude");
        const latRef = window.EXIF.getTag(this, "GPSLatitudeRef");
        const lon = window.EXIF.getTag(this, "GPSLongitude");
        const lonRef = window.EXIF.getTag(this, "GPSLongitudeRef");
        
        if (lat && lon && latRef && lonRef && Array.isArray(lat) && Array.isArray(lon)) {
          // Convert GPS coordinates to decimal degrees
          const latDecimal = convertDMSToDD(lat, latRef as string);
          const lonDecimal = convertDMSToDD(lon, lonRef as string);
          
          const coordinates = {
            lat: latDecimal,
            lng: lonDecimal
          };
          
          gpsCache.set(cacheKey, coordinates);
          resolve(coordinates);
        } else {
          gpsCache.set(cacheKey, null);
          resolve(null);
        }
      } catch (error) {
        console.error(`❌ Error processing EXIF for ${file.name}:`, error);
        gpsCache.set(cacheKey, null);
        resolve(null);
      }
    });
  });
};

// Convert DMS (Degrees, Minutes, Seconds) to DD (Decimal Degrees)
const convertDMSToDD = (dms: number[], ref: string): number => {
  let dd = dms[0] + dms[1]/60 + dms[2]/(60*60);
  if (ref === "S" || ref === "W") {
    dd = dd * -1;
  }
  return dd;
};

export interface DateTimeInfo {
  date: string;
  time: string;
}

// Extract lotID from EXIF data using backend (robust method with piexif)
export const extractLotIdFromImage = async (file: File): Promise<number | null> => {
  // Cache para evitar extracciones duplicadas
  const cacheKey = `${file.name}_${file.size}_${file.lastModified}_lotid`;
  const lotIdCache = (window as unknown as { lotIdCache?: Map<string, number | null> }).lotIdCache || new Map<string, number | null>();
  
  const cached = lotIdCache.get(cacheKey);
  if (cached !== undefined) {
    return cached;
  }

  try {
    // Usar backend para extraer lotID (más robusto que EXIF.js)
    // Importar dinámicamente para evitar dependencias circulares
    const { apiService } = await import('../services/api');
    const response = await apiService.extractLotIdFromImage(file);
    
    if (response.success && response.lotID) {
      const lotID = response.lotID;
      lotIdCache.set(cacheKey, lotID);
      (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
      console.log(`✅ [extractLotIdFromImage] lotID found via backend for ${file.name}: ${lotID}`);
      return lotID;
    }
    
    // No se encontró lotID
    lotIdCache.set(cacheKey, null);
    (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
    return null;
  } catch (error) {
    console.error(`❌ Error extracting lotID from EXIF via backend for ${file.name}:`, error);
    lotIdCache.set(cacheKey, null);
    (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
    return null;
  }
};

// Función legacy usando EXIF.js (mantenida por compatibilidad pero no se usa)
export const extractLotIdFromImageLegacy = (file: File): Promise<number | null> => {
  return new Promise((resolve) => {
    if (typeof window === 'undefined' || !window.EXIF) {
      resolve(null);
      return;
    }

    const cacheKey = `${file.name}_${file.size}_${file.lastModified}_lotid`;
    const lotIdCache = (window as unknown as { lotIdCache?: Map<string, number | null> }).lotIdCache || new Map<string, number | null>();
    
    const cached = lotIdCache.get(cacheKey);
    if (cached !== undefined) {
      resolve(cached);
      return;
    }

    const timeoutId = setTimeout(() => {
      console.log(`⏱️ Timeout extracting lotID for ${file.name}`);
      lotIdCache.set(cacheKey, null);
      resolve(null);
    }, 5000); // 5 second timeout
    
    window.EXIF.getData(file, function(this: File) {
      clearTimeout(timeoutId);
      
      try {
        console.log(`🔍 [extractLotIdFromImage] Starting extraction for ${file.name}`);
        
        // Intentar obtener todos los tags disponibles para debugging
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const allTags = (window.EXIF as any).getAllTags ? (window.EXIF as any).getAllTags(this) : null;
        if (allTags) {
          console.log(`📋 [extractLotIdFromImage] All EXIF tags for ${file.name}:`, allTags);
        }
        
        // Buscar lotID en ImageDescription (tag 270)
        // Intentar obtener ImageDescription por nombre y por tag number
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        let imageDescription = (window.EXIF.getTag as any)(this, 'ImageDescription') as string | undefined;
        // Si no funciona, intentar acceder directamente por tag number 270
        if (!imageDescription) {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          imageDescription = (window.EXIF.getTag as any)(this, 270) as string | undefined;
        }
        console.log(`🔍 [extractLotIdFromImage] ImageDescription raw:`, imageDescription, typeof imageDescription);
        
        // Buscar lotID en UserComment (tag 37510)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const userComment = (window.EXIF.getTag as any)(this, 'UserComment') as string | undefined;
        console.log(`🔍 [extractLotIdFromImage] UserComment raw:`, userComment, typeof userComment);
        
        // También intentar obtener UserComment como array de bytes si es necesario
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const userCommentBytes = (window.EXIF.getTag as any)(this, 37510) as any;
        console.log(`🔍 [extractLotIdFromImage] UserComment (tag 37510) raw:`, userCommentBytes, typeof userCommentBytes);
        
        // Buscar lotID en Artist (tag 315)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const artist = (window.EXIF.getTag as any)(this, 'Artist') as string | undefined;
        console.log(`🔍 [extractLotIdFromImage] Artist raw:`, artist, typeof artist);
        
        // Intentar obtener todos los tags que contengan "Comment" o "Description"
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const exifData = (this as any).exifdata;
        if (exifData) {
          console.log(`📋 [extractLotIdFromImage] Full exifdata object keys:`, Object.keys(exifData));
          
          // Buscar lotID en TODOS los campos EXIF disponibles (antes de buscar en campos específicos)
          for (const key in exifData) {
            const value = exifData[key];
            
            // Log específico para campos que son arrays
            if (Array.isArray(value)) {
              console.log(`🔍 [extractLotIdFromImage] Found array field "${key}" with ${value.length} elements:`, value.slice(0, 50));
            }
            
            // Si es string, buscar lotID
            if (typeof value === 'string' && value.trim().length > 0) {
              const lotIdMatch = value.match(/lotID[:\s=]*(\d+)/i);
              if (lotIdMatch && lotIdMatch[1]) {
                const lotID = parseInt(lotIdMatch[1], 10);
                if (!isNaN(lotID) && lotID > 0) {
                  console.log(`✅ [extractLotIdFromImage] lotID found in field "${key}": ${lotID}`);
                  lotIdCache.set(cacheKey, lotID);
                  (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
                  resolve(lotID);
                  return;
                }
              }
              // También buscar si el campo solo contiene un número
              const directMatch = value.trim().match(/^(\d+)$/);
              if (directMatch && directMatch[1]) {
                const lotID = parseInt(directMatch[1], 10);
                if (!isNaN(lotID) && lotID > 0 && lotID < 100000) { // Validación razonable
                  console.log(`✅ [extractLotIdFromImage] lotID found in field "${key}" (direct number): ${lotID}`);
                  lotIdCache.set(cacheKey, lotID);
                  (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
                  resolve(lotID);
                  return;
                }
              }
            }
            // Si es array (como UserComment o ImageDescription), procesarlo
            else if (Array.isArray(value) && value.length > 0) {
              try {
                console.log(`🔍 [extractLotIdFromImage] Processing array field "${key}" with ${value.length} elements`);
                
                // Método 1: UTF-8 (filtrar bytes válidos)
                const utf8Bytes = value.filter(c => c >= 0 && c < 256);
                if (utf8Bytes.length > 0) {
                  const arrayStr = String.fromCharCode(...utf8Bytes).replace(/\0/g, '');
                  console.log(`🔍 [extractLotIdFromImage] Field "${key}" as UTF-8 string (first 100 chars): "${arrayStr.substring(0, 100)}"`);
                  if (arrayStr.length > 0) {
                    const lotIdMatch = arrayStr.match(/lotID[:\s=]*(\d+)/i);
                    if (lotIdMatch && lotIdMatch[1]) {
                      const lotID = parseInt(lotIdMatch[1], 10);
                      if (!isNaN(lotID) && lotID > 0) {
                        console.log(`✅ [extractLotIdFromImage] lotID found in field "${key}" (array UTF-8): ${lotID}`);
                        lotIdCache.set(cacheKey, lotID);
                        (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
                        resolve(lotID);
                        return;
                      }
                    }
                  }
                }
                
                // Método 2: UTF-16LE (cada carácter seguido de 0)
                const utf16Bytes = value.filter((v, i) => i % 2 === 0 && v > 0);
                if (utf16Bytes.length > 0 && utf16Bytes.length !== utf8Bytes.length) {
                  const utf16Str = String.fromCharCode(...utf16Bytes).replace(/\0/g, '');
                  console.log(`🔍 [extractLotIdFromImage] Field "${key}" as UTF-16LE string (first 100 chars): "${utf16Str.substring(0, 100)}"`);
                  if (utf16Str.length > 0) {
                    const lotIdMatch = utf16Str.match(/lotID[:\s=]*(\d+)/i);
                    if (lotIdMatch && lotIdMatch[1]) {
                      const lotID = parseInt(lotIdMatch[1], 10);
                      if (!isNaN(lotID) && lotID > 0) {
                        console.log(`✅ [extractLotIdFromImage] lotID found in field "${key}" (array UTF-16LE): ${lotID}`);
                        lotIdCache.set(cacheKey, lotID);
                        (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
                        resolve(lotID);
                        return;
                      }
                    }
                  }
                }
              } catch (e) {
                console.warn(`⚠️ [extractLotIdFromImage] Error processing array field "${key}":`, e);
              }
            }
          }
        }
        
        console.log(`🔍 [extractLotIdFromImage] EXIF lotID tags summary for ${file.name}:`, {
          ImageDescription: imageDescription,
          UserComment: userComment,
          UserCommentBytes: userCommentBytes,
          Artist: artist,
          hasExifData: !!exifData
        });
        
        // Buscar en ImageDescription
        if (imageDescription && typeof imageDescription === 'string') {
          console.log(`🔍 [extractLotIdFromImage] Checking ImageDescription: "${imageDescription}"`);
          // Buscar formato "lotID:123", "lotID=123", "lotID 123" o simplemente "123"
          const lotIdMatch = imageDescription.match(/lotID[:\s=]*(\d+)/i);
          if (lotIdMatch && lotIdMatch[1]) {
            const lotID = parseInt(lotIdMatch[1], 10);
            if (!isNaN(lotID) && lotID > 0) {
              console.log(`✅ [extractLotIdFromImage] lotID found in ImageDescription for ${file.name}: ${lotID}`);
              lotIdCache.set(cacheKey, lotID);
              (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
              resolve(lotID);
              return;
            }
          }
          // Si el campo solo contiene un número
          const directMatch = imageDescription.trim().match(/^(\d+)$/);
          if (directMatch && directMatch[1]) {
            const lotID = parseInt(directMatch[1], 10);
            if (!isNaN(lotID) && lotID > 0) {
              console.log(`✅ [extractLotIdFromImage] lotID found in ImageDescription (direct number) for ${file.name}: ${lotID}`);
              lotIdCache.set(cacheKey, lotID);
              (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
              resolve(lotID);
              return;
            }
          }
        }
        
        // Buscar en UserComment
        // UserComment puede venir como string o como array de bytes (UTF-16 o UTF-8)
        let userCommentStr: string | null = null;
        
        if (userComment && typeof userComment === 'string') {
          userCommentStr = userComment;
          console.log(`🔍 [extractLotIdFromImage] UserComment is string: "${userCommentStr}"`);
        } else if (userComment && Array.isArray(userComment)) {
          // UserComment viene como array de bytes
          console.log(`🔍 [extractLotIdFromImage] UserComment is array:`, userComment, `length: ${userComment.length}`);
          
          // Intentar diferentes métodos de conversión
          try {
            // Método 1: UTF-16LE (cada carácter seguido de 0)
            // Si hay muchos 0s, probablemente es UTF-16LE
            const hasManyZeros = userComment.filter((v, i) => i % 2 === 1 && v === 0).length > userComment.length / 4;
            
            if (hasManyZeros) {
              // UTF-16LE: tomar solo los bytes pares (índices 0, 2, 4, ...)
              const utf16Chars: number[] = [];
              for (let i = 0; i < userComment.length; i += 2) {
                if (userComment[i] !== 0 || (i + 1 < userComment.length && userComment[i + 1] === 0)) {
                  utf16Chars.push(userComment[i]);
                }
              }
              userCommentStr = String.fromCharCode(...utf16Chars.filter(c => c > 0)).replace(/\0/g, '');
              console.log(`🔍 [extractLotIdFromImage] UserComment converted from UTF-16LE: "${userCommentStr}"`);
            } else {
              // UTF-8: convertir directamente
              userCommentStr = String.fromCharCode(...userComment.filter(c => c > 0)).replace(/\0/g, '');
              console.log(`🔍 [extractLotIdFromImage] UserComment converted from UTF-8: "${userCommentStr}"`);
            }
          } catch (e) {
            console.warn(`⚠️ [extractLotIdFromImage] Error converting UserComment array:`, e);
            // Intentar método alternativo: filtrar ceros y convertir
            try {
              const filtered = userComment.filter((v, i) => v > 0 && (i === 0 || userComment[i - 1] !== 0 || v !== 0));
              userCommentStr = String.fromCharCode(...filtered).replace(/\0/g, '');
              console.log(`🔍 [extractLotIdFromImage] UserComment converted (alternative method): "${userCommentStr}"`);
            } catch (e2) {
              console.warn(`⚠️ [extractLotIdFromImage] Alternative conversion also failed:`, e2);
            }
          }
        } else if (userCommentBytes) {
          // Intentar convertir bytes a string
          if (Array.isArray(userCommentBytes)) {
            userCommentStr = String.fromCharCode(...userCommentBytes.filter(c => c > 0)).replace(/\0/g, '');
            console.log(`🔍 [extractLotIdFromImage] UserCommentBytes converted from bytes: "${userCommentStr}"`);
          } else if (typeof userCommentBytes === 'string') {
            userCommentStr = userCommentBytes;
            console.log(`🔍 [extractLotIdFromImage] UserCommentBytes is string: "${userCommentStr}"`);
          }
        }
        
        // Si aún no tenemos string, intentar procesar el array userComment directamente
        if (!userCommentStr && userComment && Array.isArray(userComment)) {
          console.log(`🔍 [extractLotIdFromImage] Attempting direct array processing for UserComment`);
          // El array parece ser: [85,78,73,67,79,68,69,0,0,108,0,111,0,116,0,73,0,68,0,61,0,52,0,54]
          // Esto es UTF-16LE donde cada carácter ASCII está seguido de 0
          // Formato: "UNICODE\0\0l\0o\0t\0I\0D\0=\04\06" = "UNICODE\0\0lotID=46"
          const chars: number[] = [];
          let skipNext = false;
          
          for (let i = 0; i < userComment.length; i++) {
            if (skipNext) {
              skipNext = false;
              continue;
            }
            
            const val = userComment[i];
            const nextVal = i + 1 < userComment.length ? userComment[i + 1] : null;
            
            // Si el valor es ASCII válido (32-126) y el siguiente es 0, es UTF-16LE
            if (val > 0 && val < 127 && nextVal === 0) {
              chars.push(val);
              skipNext = true; // Saltar el 0 siguiente
            } else if (val > 0 && val < 127 && nextVal !== 0 && nextVal !== null) {
              // Si el siguiente no es 0, podría ser UTF-8 o parte de "UNICODE"
              chars.push(val);
            } else if (val > 0 && val < 127 && nextVal === null) {
              // Último carácter
              chars.push(val);
            }
          }
          
          if (chars.length > 0) {
            userCommentStr = String.fromCharCode(...chars);
            // Remover "UNICODE" del inicio si está presente
            if (userCommentStr.startsWith('UNICODE')) {
              userCommentStr = userCommentStr.substring(7).replace(/^\0+/, ''); // Remover "UNICODE" y ceros iniciales
            }
            console.log(`🔍 [extractLotIdFromImage] UserComment converted (direct processing): "${userCommentStr}"`);
          }
        }
        
        if (userCommentStr) {
          console.log(`🔍 [extractLotIdFromImage] Checking UserComment: "${userCommentStr}"`);
          const lotIdMatch = userCommentStr.match(/lotID[:\s=]*(\d+)/i);
          if (lotIdMatch && lotIdMatch[1]) {
            const lotID = parseInt(lotIdMatch[1], 10);
            if (!isNaN(lotID) && lotID > 0) {
              console.log(`✅ [extractLotIdFromImage] lotID found in UserComment for ${file.name}: ${lotID}`);
              lotIdCache.set(cacheKey, lotID);
              (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
              resolve(lotID);
              return;
            }
          }
          const directMatch = userCommentStr.trim().match(/^(\d+)$/);
          if (directMatch && directMatch[1]) {
            const lotID = parseInt(directMatch[1], 10);
            if (!isNaN(lotID) && lotID > 0) {
              console.log(`✅ [extractLotIdFromImage] lotID found in UserComment (direct number) for ${file.name}: ${lotID}`);
              lotIdCache.set(cacheKey, lotID);
              (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
              resolve(lotID);
              return;
            }
          }
        }
        
        // Buscar en Artist
        if (artist && typeof artist === 'string') {
          const lotIdMatch = artist.match(/lotID[:\s=]*(\d+)/i);
          if (lotIdMatch && lotIdMatch[1]) {
            const lotID = parseInt(lotIdMatch[1], 10);
            if (!isNaN(lotID) && lotID > 0) {
              console.log(`✅ lotID found in Artist for ${file.name}: ${lotID}`);
              lotIdCache.set(cacheKey, lotID);
              (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
              resolve(lotID);
              return;
            }
          }
        }
        
        console.log(`❌ [extractLotIdFromImage] No lotID found in EXIF for ${file.name}`);
        console.log(`📋 [extractLotIdFromImage] Summary - ImageDescription: ${imageDescription}, UserComment: ${userComment || userCommentBytes}, Artist: ${artist}`);
        lotIdCache.set(cacheKey, null);
        (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
        resolve(null);
      } catch (error) {
        console.error(`❌ Error processing EXIF lotID for ${file.name}:`, error);
        lotIdCache.set(cacheKey, null);
        (window as unknown as { lotIdCache: Map<string, number | null> }).lotIdCache = lotIdCache;
        resolve(null);
      }
    });
  });
};

/**
 * Extrae fecha y hora desde el nombre del archivo
 * Formato esperado: YYYYMMDD_HHMMSS (ej: 20260103_110240)
 */
const extractDateTimeFromFilename = (filename: string): DateTimeInfo | null => {
  try {
    // Buscar patrón YYYYMMDD_HHMMSS en el nombre del archivo
    const match = filename.match(/(\d{8})_(\d{6})/);
    if (match) {
      const dateStr = match[1]; // YYYYMMDD
      const timeStr = match[2]; // HHMMSS
      
      const year = dateStr.substring(0, 4);
      const month = dateStr.substring(4, 6);
      const day = dateStr.substring(6, 8);
      
      const hour = timeStr.substring(0, 2);
      const minute = timeStr.substring(2, 4);
      const second = timeStr.substring(4, 6);
      
      // Validar que sean números válidos
      if (parseInt(year) > 2000 && parseInt(year) < 2100 &&
          parseInt(month) >= 1 && parseInt(month) <= 12 &&
          parseInt(day) >= 1 && parseInt(day) <= 31 &&
          parseInt(hour) >= 0 && parseInt(hour) <= 23 &&
          parseInt(minute) >= 0 && parseInt(minute) <= 59 &&
          parseInt(second) >= 0 && parseInt(second) <= 59) {
        
        const date = `${day}/${month}/${year}`;
        const time = `${hour}:${minute}:${second}`;
        
        console.log(`📅 Date/Time extracted from filename for ${filename}: ${date} ${time}`);
        return { date, time };
      }
    }
  } catch (error) {
    console.warn(`⚠️ Error extracting date from filename ${filename}:`, error);
  }
  return null;
};

// Extract date and time from EXIF data
export const extractDateTimeFromImage = (file: File): Promise<DateTimeInfo | null> => {
  return new Promise((resolve) => {
    const cacheKey = `${file.name}_${file.size}_${file.lastModified}_datetime`;
    const dateTimeCache = (window as unknown as { dateTimeCache?: Map<string, DateTimeInfo | null> }).dateTimeCache || new Map<string, DateTimeInfo | null>();
    
    const cached = dateTimeCache.get(cacheKey);
    if (cached !== undefined) {
      resolve(cached);
      return;
    }

    // Primero intentar extraer desde el nombre del archivo (fallback rápido)
    const filenameDateTime = extractDateTimeFromFilename(file.name);
    if (filenameDateTime) {
      dateTimeCache.set(cacheKey, filenameDateTime);
      (window as unknown as { dateTimeCache: Map<string, DateTimeInfo | null> }).dateTimeCache = dateTimeCache;
      console.log(`📅 Using date/time from filename for ${file.name}`);
      resolve(filenameDateTime);
      return;
    }

    // Si no está en el nombre, intentar desde EXIF
    if (typeof window === 'undefined' || !window.EXIF) {
      dateTimeCache.set(cacheKey, null);
      resolve(null);
      return;
    }

    // Leer EXIF directamente desde el archivo (como se hace con GPS)
    // Esto es más confiable que cargar la imagen primero
    const timeoutId = setTimeout(() => {
      console.log(`⏱️ Timeout extracting date/time for ${file.name}`);
      dateTimeCache.set(cacheKey, null);
      resolve(null);
    }, 5000); // 5 second timeout
    
    window.EXIF.getData(file, function(this: File) {
      clearTimeout(timeoutId);
      
      try {
        // Usar 'this' como segundo parámetro para getTag (EXIF.js espera el objeto que tiene los datos EXIF)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const dateTimeOriginal = (window.EXIF.getTag as any)(this, 'DateTimeOriginal') as string | undefined;
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const dateTimeDigitized = (window.EXIF.getTag as any)(this, 'DateTimeDigitized') as string | undefined;
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const dateTime = (window.EXIF.getTag as any)(this, 'DateTime') as string | undefined;
        
        // Debug: Log todos los valores obtenidos
        console.log(`🔍 EXIF date tags for ${file.name}:`, {
          DateTimeOriginal: dateTimeOriginal,
          DateTimeDigitized: dateTimeDigitized,
          DateTime: dateTime
        });
        
        // Try different EXIF date fields (prioridad: Original > Digitized > DateTime)
        const dateTimeValue = dateTimeOriginal || dateTimeDigitized || dateTime;
        
        if (dateTimeValue && typeof dateTimeValue === 'string') {
          // Validar que el formato sea correcto (no debe ser el nombre del archivo)
          // EXIF date format: "YYYY:MM:DD HH:MM:SS" (con dos puntos como separador de fecha)
          if (dateTimeValue.includes(':')) {
            const [datePart, timePart] = dateTimeValue.split(' ');
            if (datePart && timePart && datePart.split(':').length === 3) {
              // Convert to more readable format
              const [year, month, day] = datePart.split(':');
              const [hour, minute, second] = timePart.split(':');
              
              // Validar que sean números válidos
              if (year && month && day && hour && minute && second) {
                const date = `${day}/${month}/${year}`;
                const time = `${hour}:${minute}:${second}`;
                
                const result: DateTimeInfo = { date, time };
                
                // Cache the result
                dateTimeCache.set(cacheKey, result);
                (window as unknown as { dateTimeCache: Map<string, DateTimeInfo | null> }).dateTimeCache = dateTimeCache;
                
                console.log(`📅 Date/Time found for ${file.name}: ${date} ${time}`);
                resolve(result);
                return;
              }
            }
          }
          
          // Si llegamos aquí, el formato no es válido
          console.log(`❌ Invalid date format for ${file.name}: ${dateTimeValue} (expected format: YYYY:MM:DD HH:MM:SS)`);
          
          // Fallback: intentar extraer desde el nombre del archivo
          const filenameDateTime = extractDateTimeFromFilename(file.name);
          if (filenameDateTime) {
            console.log(`📅 Using date/time from filename (fallback) for ${file.name}`);
            dateTimeCache.set(cacheKey, filenameDateTime);
            (window as unknown as { dateTimeCache: Map<string, DateTimeInfo | null> }).dateTimeCache = dateTimeCache;
            resolve(filenameDateTime);
            return;
          }
          
          dateTimeCache.set(cacheKey, null);
          resolve(null);
        } else {
          console.log(`📅 Date extraction for ${file.name}: Not found (all tags returned null/undefined)`);
          
          // Fallback: intentar extraer desde el nombre del archivo
          const filenameDateTime = extractDateTimeFromFilename(file.name);
          if (filenameDateTime) {
            console.log(`📅 Using date/time from filename (fallback) for ${file.name}`);
            dateTimeCache.set(cacheKey, filenameDateTime);
            (window as unknown as { dateTimeCache: Map<string, DateTimeInfo | null> }).dateTimeCache = dateTimeCache;
            resolve(filenameDateTime);
            return;
          }
          
          dateTimeCache.set(cacheKey, null);
          resolve(null);
        }
      } catch (error) {
        console.error(`❌ Error processing EXIF date for ${file.name}:`, error);
        
        // Fallback: intentar extraer desde el nombre del archivo
        const filenameDateTime = extractDateTimeFromFilename(file.name);
        if (filenameDateTime) {
          console.log(`📅 Using date/time from filename (fallback after error) for ${file.name}`);
          dateTimeCache.set(cacheKey, filenameDateTime);
          (window as unknown as { dateTimeCache: Map<string, DateTimeInfo | null> }).dateTimeCache = dateTimeCache;
          resolve(filenameDateTime);
          return;
        }
        
        dateTimeCache.set(cacheKey, null);
        resolve(null);
      }
    });
  });
};

