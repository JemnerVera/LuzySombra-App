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
        
        console.log(`🔍 EXIF data for ${file.name}:`, { lat, latRef, lon, lonRef });
        
        if (lat && lon && latRef && lonRef && Array.isArray(lat) && Array.isArray(lon)) {
          // Convert GPS coordinates to decimal degrees
          const latDecimal = convertDMSToDD(lat, latRef as string);
          const lonDecimal = convertDMSToDD(lon, lonRef as string);
          
          const coordinates = {
            lat: latDecimal,
            lng: lonDecimal
          };
          
          console.log(`✅ GPS coordinates for ${file.name}:`, coordinates);
          gpsCache.set(cacheKey, coordinates);
          resolve(coordinates);
        } else {
          console.log(`❌ No GPS data found for ${file.name}`);
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

// Extract date and time from EXIF data
export const extractDateTimeFromImage = (file: File): Promise<DateTimeInfo | null> => {
  return new Promise((resolve) => {
    if (typeof window === 'undefined' || !window.EXIF) {
      resolve(null);
      return;
    }

    const cacheKey = `${file.name}_${file.size}_${file.lastModified}_datetime`;
    const dateTimeCache = (window as unknown as { dateTimeCache?: Map<string, DateTimeInfo | null> }).dateTimeCache || new Map<string, DateTimeInfo | null>();
    
    const cached = dateTimeCache.get(cacheKey);
    if (cached !== undefined) {
      resolve(cached);
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
          dateTimeCache.set(cacheKey, null);
          resolve(null);
        } else {
          console.log(`📅 Date extraction for ${file.name}: Not found (all tags returned null/undefined)`);
          dateTimeCache.set(cacheKey, null);
          resolve(null);
        }
      } catch (error) {
        console.error(`❌ Error processing EXIF date for ${file.name}:`, error);
        dateTimeCache.set(cacheKey, null);
        resolve(null);
      }
    });
  });
};

