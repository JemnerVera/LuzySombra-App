// Server-side EXIF extraction for Node.js
// eslint-disable-next-line @typescript-eslint/no-require-imports
const piexif = require('piexifjs');

export interface DateTimeInfo {
  date: string;
  time: string;
}

export interface GpsCoordinates {
  lat: number;
  lng: number;
}

export interface LotIdFromExif {
  lotID: number;
}

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
        
        return { date, time };
      }
    }
  } catch (error) {
    console.warn(`⚠️ Error extracting date from filename ${filename}:`, error);
  }
  return null;
};

// Extract date and time from EXIF data on server-side
export const extractDateTimeFromImageServer = async (file: Buffer, filename: string): Promise<DateTimeInfo | null> => {
  try {
    // Primero intentar extraer desde el nombre del archivo (fallback rápido)
    const filenameDateTime = extractDateTimeFromFilename(filename);
    if (filenameDateTime) {
      return filenameDateTime;
    }

    const binary = file.toString('binary');
    
    // Extract EXIF data
    const exifData = piexif.load(binary);
    
    if (!exifData || !exifData['0th'] || !exifData['Exif']) {
      // Fallback: intentar desde el nombre del archivo
      return extractDateTimeFromFilename(filename);
    }

    // Try different EXIF date fields
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const dateTime = (exifData as any)['0th']?.[piexif.ImageIFD.DateTime];
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const dateTimeOriginal = (exifData as any)['Exif']?.[piexif.ExifIFD.DateTimeOriginal];
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const dateTimeDigitized = (exifData as any)['Exif']?.[piexif.ExifIFD.DateTimeDigitized];
    
    const dateTimeValue = dateTimeOriginal || dateTimeDigitized || dateTime;
    
    if (dateTimeValue && typeof dateTimeValue === 'string') {
      // EXIF date format: "YYYY:MM:DD HH:MM:SS"
      const [datePart, timePart] = dateTimeValue.split(' ');
      if (datePart && timePart) {
        // Convert to more readable format
        const [year, month, day] = datePart.split(':');
        const [hour, minute, second] = timePart.split(':');
        
        const date = `${day}/${month}/${year}`;
        const time = `${hour}:${minute}:${second}`;
        
        return { date, time };
      } else {
        // Fallback: intentar desde el nombre del archivo
        return extractDateTimeFromFilename(filename);
      }
    } else {
      // Fallback: intentar desde el nombre del archivo
      return extractDateTimeFromFilename(filename);
    }
  } catch (error) {
    console.error(`❌ Error processing EXIF date for ${filename}:`, error);
    // Fallback: intentar desde el nombre del archivo
    return extractDateTimeFromFilename(filename);
  }
};

// Extract GPS coordinates from EXIF data on server-side
export const extractGpsFromImageServer = async (file: Buffer, filename: string): Promise<GpsCoordinates | null> => {
  try {
    const binary = file.toString('binary');
    const exifData = piexif.load(binary);
    
    if (!exifData || !exifData.GPS) {
      console.log(`❌ No GPS data found for ${filename}`);
      return null;
    }
    
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const gps = exifData.GPS as any;
    
    if (gps[piexif.GPSIFD.GPSLatitude] && gps[piexif.GPSIFD.GPSLongitude]) {
      // Convert DMS to decimal degrees
      const latArray = gps[piexif.GPSIFD.GPSLatitude];
      const latRef = gps[piexif.GPSIFD.GPSLatitudeRef] || 'N';
      const lonArray = gps[piexif.GPSIFD.GPSLongitude];
      const lonRef = gps[piexif.GPSIFD.GPSLongitudeRef] || 'E';
      
      const lat = (latArray[0][0] / latArray[0][1]) + 
                  (latArray[1][0] / latArray[1][1]) / 60 + 
                  (latArray[2][0] / latArray[2][1]) / 3600;
      const lon = (lonArray[0][0] / lonArray[0][1]) + 
                  (lonArray[1][0] / lonArray[1][1]) / 60 + 
                  (lonArray[2][0] / lonArray[2][1]) / 3600;
      
      const finalLat = latRef === 'S' ? -lat : lat;
      const finalLon = lonRef === 'W' ? -lon : lon;
      
      console.log(`📍 GPS coordinates found for ${filename}: lat=${finalLat}, lng=${finalLon}`);
      return {
        lat: finalLat,
        lng: finalLon
      };
    }
    
    return null;
  } catch (error) {
    console.error(`❌ Error processing EXIF GPS for ${filename}:`, error);
    return null;
  }
};

// Extract lotID from EXIF data on server-side
// El burro almacena lotID en el campo ImageDescription o UserComment
// Formato esperado: "lotID:123" o simplemente "123"
export const extractLotIdFromExifServer = async (file: Buffer, filename: string): Promise<number | null> => {
  try {
    const binary = file.toString('binary');
    const exifData = piexif.load(binary);
    
    if (!exifData || !exifData['0th']) {
      console.log(`❌ No EXIF data found for ${filename}`);
      return null;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const ifd0 = exifData['0th'] as any;
    
    // Buscar lotID en ImageDescription (tag 270) - Campo estándar para metadata personalizada
    const imageDescription = ifd0[piexif.ImageIFD.ImageDescription];
    if (imageDescription) {
      // ImageDescription puede ser string o bytes
      const descStr = typeof imageDescription === 'string' 
        ? imageDescription 
        : (typeof imageDescription === 'object' && imageDescription !== null && 'toString' in imageDescription)
          ? imageDescription.toString()
          : Buffer.from(imageDescription).toString('utf8').replace(/\0/g, '');
      
      // Buscar formato "lotID:123", "lotID=123", "lotID 123" o simplemente "123"
      const lotIdMatch = descStr.match(/lotID[:\s=]*(\d+)/i);
      if (lotIdMatch && lotIdMatch[1]) {
        const lotID = parseInt(lotIdMatch[1], 10);
        if (!isNaN(lotID) && lotID > 0) {
          console.log(`🏷️ lotID found in ImageDescription for ${filename}: ${lotID}`);
          return lotID;
        }
      }
      // Si el campo solo contiene un número, asumir que es el lotID
      const directMatch = descStr.trim().match(/^(\d+)$/);
      if (directMatch && directMatch[1]) {
        const lotID = parseInt(directMatch[1], 10);
        if (!isNaN(lotID) && lotID > 0) {
          console.log(`🏷️ lotID found in ImageDescription (direct number) for ${filename}: ${lotID}`);
          return lotID;
        }
      }
    }

    // Buscar lotID en UserComment (tag 37510) - campo alternativo para metadata personalizada
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const exif = exifData['Exif'] as any;
    if (exif && exif[piexif.ExifIFD.UserComment]) {
      const userComment = exif[piexif.ExifIFD.UserComment];
      // UserComment puede ser string o bytes, convertir a string si es necesario
      const commentStr = typeof userComment === 'string' 
        ? userComment 
        : Buffer.from(userComment).toString('utf8').replace(/\0/g, '');
      
      const lotIdMatch = commentStr.match(/lotID[:\s=]*(\d+)/i);
      if (lotIdMatch && lotIdMatch[1]) {
        const lotID = parseInt(lotIdMatch[1], 10);
        if (!isNaN(lotID) && lotID > 0) {
          console.log(`🏷️ lotID found in UserComment for ${filename}: ${lotID}`);
          return lotID;
        }
      }
      // Si el campo solo contiene un número
      const directMatch = commentStr.trim().match(/^(\d+)$/);
      if (directMatch && directMatch[1]) {
        const lotID = parseInt(directMatch[1], 10);
        if (!isNaN(lotID) && lotID > 0) {
          console.log(`🏷️ lotID found in UserComment (direct number) for ${filename}: ${lotID}`);
          return lotID;
        }
      }
    }

    // Buscar lotID en Artist (tag 315) - alternativa adicional
    const artist = ifd0[piexif.ImageIFD.Artist];
    if (artist) {
      const artistStr = typeof artist === 'string' 
        ? artist 
        : Buffer.from(artist).toString('utf8').replace(/\0/g, '');
      
      const lotIdMatch = artistStr.match(/lotID[:\s=]*(\d+)/i);
      if (lotIdMatch && lotIdMatch[1]) {
        const lotID = parseInt(lotIdMatch[1], 10);
        if (!isNaN(lotID) && lotID > 0) {
          console.log(`🏷️ lotID found in Artist for ${filename}: ${lotID}`);
          return lotID;
        }
      }
    }

    // No log - el frontend puede haber detectado el lotID y lo enviará en el formulario
    return null;
  } catch (error) {
    console.error(`❌ Error extracting lotID from EXIF for ${filename}:`, error);
    return null;
  }
};

