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

// Extract date and time from EXIF data on server-side
export const extractDateTimeFromImageServer = async (file: Buffer, filename: string): Promise<DateTimeInfo | null> => {
  try {
    const binary = file.toString('binary');
    
    // Extract EXIF data
    const exifData = piexif.load(binary);
    
    if (!exifData || !exifData['0th'] || !exifData['Exif']) {
      console.log(`❌ No EXIF data found for ${filename}`);
      return null;
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
        
        const result: DateTimeInfo = { date, time };
        
        console.log(`📅 Date/Time found for ${filename}: ${date} ${time}`);
        return result;
      } else {
        console.log(`❌ Invalid date format for ${filename}: ${dateTimeValue}`);
        return null;
      }
    } else {
      console.log(`❌ No date/time data found for ${filename}`);
      return null;
    }
  } catch (error) {
    console.error(`❌ Error processing EXIF date for ${filename}:`, error);
    return null;
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

