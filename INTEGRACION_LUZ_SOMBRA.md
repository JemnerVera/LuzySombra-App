# 🔗 Integración de Luz&Sombra con AgriQR

## 📋 Resumen

Este documento explica cómo integrar el endpoint de subida de fotos desde AgriQR (Android) con el procesamiento de imágenes existente en Luz&Sombra.

---

## 🎯 Situación Actual

### Endpoint Existente: `/api/procesar-imagen`
- **Ubicación**: `backend/src/routes/image-processing.ts`
- **Método**: `POST`
- **Input**: 
  - `file`: archivo de imagen
  - `empresa`, `fundo`, `sector`, `lote`, `hilera`, `numero_planta`
  - `latitud`, `longitud` (opcionales)
- **Procesamiento**: 
  - Usa `imageProcessingService.classifyImagePixels()`
  - Guarda en SQL Server con `sqlServerService.saveProcessingResult()`
- **Output**: Resultado del procesamiento con porcentajes de luz/sombra

### Nuevo Endpoint Necesario: `/api/photos/upload`
- **Método**: `POST`
- **Input desde Android**:
  - `file`: archivo de imagen
  - `plantId`: ID de la planta (ej: "00805221")
  - `timestamp`: fecha/hora de captura (ISO 8601)
- **Autenticación**: JWT token (Bearer)
- **Output**: 
  ```json
  {
    "success": true,
    "photoId": "xxx",
    "processed": true,
    "message": "Foto procesada y guardada en BD"
  }
  ```

---

## 🔄 Estrategia de Integración

### Opción A: Reutilizar Servicios Existentes (RECOMENDADO)

**Ventajas:**
- ✅ Reutiliza código existente
- ✅ Mantiene consistencia
- ✅ Menos código nuevo
- ✅ Mismo procesamiento de imágenes

**Desventajas:**
- ⚠️ Necesita mapear `plantId` a `empresa/fundo/sector/lote`

### Opción B: Crear Endpoint Separado

**Ventajas:**
- ✅ Endpoint específico para móvil
- ✅ Más control sobre el flujo

**Desventajas:**
- ❌ Duplica código de procesamiento
- ❌ Más mantenimiento

**Recomendación: Opción A**

---

## 📝 Implementación: Nuevo Endpoint

### Paso 1: Crear Endpoint `/api/photos/upload`

**Archivo**: `backend/src/routes/photoUpload.ts` (NUEVO)

```typescript
import express, { Request, Response } from 'express';
import multer from 'multer';
import { authenticateToken } from '../middleware/auth';
import { imageProcessingService } from '../services/imageProcessingService';
import { sqlServerService } from '../services/sqlServerService';
import { parseFilename } from '../utils/filenameParser';
import { extractDateTimeFromImageServer } from '../utils/exif-server';
import { createThumbnail } from '../utils/imageThumbnail';
import { createCanvas, loadImage } from 'canvas';

const router = express.Router();

// Configurar multer (igual que image-processing.ts)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

/**
 * POST /api/photos/upload
 * Endpoint para subir fotos desde app Android (AgriQR)
 * 
 * Body (multipart/form-data):
 * - file: archivo de imagen
 * - plantId: ID de la planta (ej: "00805221")
 * - timestamp: fecha/hora ISO 8601 (opcional, se usa EXIF si no se proporciona)
 */
router.post('/upload', 
  authenticateToken, // Middleware de autenticación JWT
  upload.single('file'),
  async (req: Request, res: Response) => {
    try {
      // 1. Validar archivo
      if (!req.file) {
        return res.status(400).json({
          error: 'No file provided',
          processed: false
        });
      }

      // 2. Validar plantId
      const { plantId, timestamp } = req.body;
      if (!plantId) {
        return res.status(400).json({
          error: 'plantId is required',
          processed: false
        });
      }

      // 3. Obtener información de la planta desde SQL Server
      // TODO: Crear función para obtener empresa/fundo/sector/lote desde plantId
      const plantInfo = await getPlantInfoFromPlantId(plantId);
      
      if (!plantInfo) {
        return res.status(404).json({
          error: `Plant ID ${plantId} not found in database`,
          processed: false
        });
      }

      const file = req.file;
      const imageBuffer = file.buffer;
      
      // 4. Convertir imagen original a Base64 (igual que image-processing.ts)
      const originalImageBase64 = `data:${file.mimetype || 'image/jpeg'};base64,${imageBuffer.toString('base64')}`;
      
      // 5. Crear thumbnail comprimido de la imagen original
      const originalThumbnail = await createThumbnail(originalImageBase64, 400, 300, 0.5);
      
      // 6. Load image using canvas (igual que image-processing.ts)
      const img = await loadImage(imageBuffer);
      
      // 7. Create canvas and get ImageData
      const canvas = createCanvas(img.width, img.height);
      const ctx = canvas.getContext('2d');
      
      ctx.drawImage(img, 0, 0);
      const imageDataResult = ctx.getImageData(0, 0, canvas.width, canvas.height);

      // 8. Process with heuristic algorithm (REUTILIZA servicio existente)
      const processingResult = await imageProcessingService.classifyImagePixels(imageDataResult);

      // 9. Extract data from filename (si está disponible)
      const filenameData = parseFilename(file.originalname);
      const finalHilera = filenameData.hilera || '';
      const finalNumeroPlanta = filenameData.planta || plantId; // Usar plantId si no hay en filename

      // 10. Extract date/time from EXIF o usar timestamp proporcionado
      let exifDateTime = null;
      if (timestamp) {
        // Usar timestamp proporcionado
        const date = new Date(timestamp);
        exifDateTime = {
          date: date.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric' }),
          time: date.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
        };
      } else {
        // Intentar extraer de EXIF
        try {
          exifDateTime = await extractDateTimeFromImageServer(imageBuffer, file.originalname);
        } catch (error) {
          // EXIF extraction failed, usar fecha actual
          const now = new Date();
          exifDateTime = {
            date: now.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric' }),
            time: now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
          };
        }
      }

      // 11. Crear resultado del procesamiento (igual estructura que image-processing.ts)
      const result = {
        success: true,
        fileName: file.originalname,
        image_name: file.originalname,
        hilera: finalHilera,
        numero_planta: finalNumeroPlanta,
        porcentaje_luz: processingResult.lightPercentage,
        porcentaje_sombra: processingResult.shadowPercentage,
        fundo: plantInfo.fundo,
        sector: plantInfo.sector,
        lote: plantInfo.lote,
        empresa: plantInfo.empresa,
        latitud: null, // TODO: Extraer de EXIF si está disponible
        longitud: null, // TODO: Extraer de EXIF si está disponible
        processed_image: processingResult.processedImageData,
        timestamp: new Date().toISOString(),
        exifDateTime: exifDateTime
      };

      // 12. Crear thumbnail optimizado para guardar en BD
      const thumbnail = await createThumbnail(processingResult.processedImageData, 800, 600, 0.7);

      // 13. Agregar thumbnails al resultado
      const resultWithThumbnail = {
        ...result,
        thumbnail: thumbnail,
        originalThumbnail: originalThumbnail
      };

      // 14. Save to SQL Server (REUTILIZA servicio existente)
      let sqlAnalisisId: number | null = null;
      try {
        sqlAnalisisId = await sqlServerService.saveProcessingResult(resultWithThumbnail);
        console.log(`✅ Foto procesada y guardada: analisisID=${sqlAnalisisId}, plantId=${plantId}`);
      } catch (sqlError) {
        console.error('❌ Error saving to SQL Server:', sqlError);
        return res.status(500).json({
          error: 'Error saving to database',
          message: sqlError instanceof Error ? sqlError.message : 'Unknown error',
          processed: false
        });
      }

      // 15. Retornar respuesta exitosa
      res.json({
        success: true,
        photoId: sqlAnalisisId?.toString() || 'unknown',
        processed: true,
        message: 'Foto procesada y guardada en BD',
        porcentaje_luz: processingResult.lightPercentage,
        porcentaje_sombra: processingResult.shadowPercentage
      });

    } catch (error) {
      console.error('❌ Error processing photo:', error);
      res.status(500).json({
        error: 'Error processing image',
        message: error instanceof Error ? error.message : 'Unknown error',
        processed: false
      });
    }
  }
);

/**
 * Función auxiliar: Obtener información de planta desde plantId
 * TODO: Implementar según estructura de BD
 */
async function getPlantInfoFromPlantId(plantId: string): Promise<{
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
} | null> {
  try {
    // TODO: Consultar SQL Server para obtener empresa/fundo/sector/lote desde plantId
    // Esto depende de cómo esté estructurada tu base de datos
    
    // Ejemplo de query (ajustar según tu esquema):
    /*
    const result = await query<{
      empresa: string;
      fundo: string;
      sector: string;
      lote: string;
    }>(`
      SELECT 
        g.businessName as empresa,
        f.Description as fundo,
        s.stage as sector,
        l.name as lote
      FROM [tabla_plantas] p
      INNER JOIN GROWER.LOT l ON p.lotID = l.lotID
      INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
      INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
      INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
      WHERE p.plantId = @plantId
        AND p.statusID = 1
    `, { plantId });
    
    if (result.length === 0) {
      return null;
    }
    
    return result[0];
    */
    
    // TEMPORAL: Retornar valores por defecto (REEMPLAZAR con query real)
    console.warn(`⚠️ getPlantInfoFromPlantId: Usando valores por defecto para plantId=${plantId}`);
    return {
      empresa: 'Unknown',
      fundo: 'Unknown',
      sector: 'Unknown',
      lote: 'Unknown'
    };
  } catch (error) {
    console.error('❌ Error getting plant info:', error);
    return null;
  }
}

export default router;
```

---

### Paso 2: Crear Middleware de Autenticación

**Archivo**: `backend/src/middleware/auth.ts` (NUEVO)

```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

// Interfaz para el payload del JWT
interface JwtPayload {
  deviceId: string;
  iat?: number;
  exp?: number;
}

/**
 * Middleware de autenticación JWT
 * Verifica que el request tenga un token válido
 */
export function authenticateToken(req: Request, res: Response, next: NextFunction) {
  try {
    // Obtener token del header Authorization
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'No token provided',
        processed: false
      });
    }

    // Verificar token
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const decoded = jwt.verify(token, jwtSecret) as JwtPayload;

    // Agregar información del dispositivo al request
    (req as any).deviceId = decoded.deviceId;

    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(403).json({
        error: 'Invalid token',
        processed: false
      });
    }
    
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(403).json({
        error: 'Token expired',
        processed: false
      });
    }

    return res.status(500).json({
      error: 'Authentication error',
      processed: false
    });
  }
}
```

---

### Paso 3: Crear Endpoint de Autenticación

**Archivo**: `backend/src/routes/auth.ts` (NUEVO)

```typescript
import express, { Request, Response } from 'express';
import jwt from 'jsonwebtoken';

const router = express.Router();

/**
 * POST /api/auth/login
 * Autenticación de dispositivo Android
 * 
 * Body:
 * - deviceId: ID único del dispositivo
 * - apiKey: API key del dispositivo
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { deviceId, apiKey } = req.body;

    if (!deviceId || !apiKey) {
      return res.status(400).json({
        error: 'deviceId and apiKey are required'
      });
    }

    // TODO: Validar deviceId y apiKey contra base de datos
    // Por ahora, validación simple (REEMPLAZAR con validación real)
    const validApiKeys = process.env.VALID_API_KEYS?.split(',') || [];
    if (!validApiKeys.includes(apiKey)) {
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Generar JWT token
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const token = jwt.sign(
      { deviceId },
      jwtSecret,
      { expiresIn: '24h' } // Token válido por 24 horas
    );

    res.json({
      success: true,
      token,
      expiresIn: 86400, // 24 horas en segundos
      deviceId
    });
  } catch (error) {
    console.error('❌ Error in login:', error);
    res.status(500).json({
      error: 'Login error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
```

---

### Paso 4: Registrar Rutas en server.ts

**Archivo**: `backend/src/server.ts` (MODIFICAR)

```typescript
// ... imports existentes ...
import authRoutes from './routes/auth';
import photoUploadRoutes from './routes/photoUpload';

// ... código existente ...

// Rutas
app.use('/api/field-data', fieldDataRoutes);
app.use('/api/historial', historialRoutes);
app.use('/api/procesar-imagen', imageProcessingRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/test-db', testDbRoutes);
app.use('/api/tabla-consolidada', tablaConsolidadaRoutes);
app.use('/api/tabla-consolidada/detalle', tablaConsolidadaDetalleRoutes);
app.use('/api/tabla-consolidada/detalle-planta', tablaConsolidadaDetallePlantaRoutes);
app.use('/api/imagen', imagenRoutes);
app.use('/api/estadisticas', estadisticasRoutes);
app.use('/api/test-model', testModelRouter);
app.use('/api/check-gps-info', checkGpsInfoRouter);

// NUEVAS RUTAS PARA AGRICQR
app.use('/api/auth', authRoutes);
app.use('/api/photos', photoUploadRoutes);

// ... resto del código ...
```

---

### Paso 5: Instalar Dependencias

```bash
cd backend
npm install jsonwebtoken
npm install --save-dev @types/jsonwebtoken
```

---

## 🔍 Puntos Importantes

### 1. Mapeo de plantId a empresa/fundo/sector/lote

**Problema**: La app Android solo envía `plantId`, pero el procesamiento necesita `empresa`, `fundo`, `sector`, `lote`.

**Solución**: Crear función `getPlantInfoFromPlantId()` que consulte SQL Server.

**Pregunta**: ¿Cómo está estructurada tu base de datos? ¿Hay una tabla que relacione `plantId` con `lotID`?

**Opciones**:
- **Opción A**: Si `plantId` está en una tabla de plantas → JOIN con GROWER.LOT
- **Opción B**: Si `plantId` está en el nombre del archivo → Parsear nombre
- **Opción C**: Si `plantId` es parte del `lotID` → Extraer información

### 2. Variables de Entorno Necesarias

Agregar a `.env`:
```env
JWT_SECRET=your-super-secret-key-change-in-production
VALID_API_KEYS=device1-key,device2-key,device3-key
```

En Azure App Service → Configuration → Application Settings:
- `JWT_SECRET`: (encriptado automáticamente)
- `VALID_API_KEYS`: (encriptado automáticamente)

---

## 🚀 ¿Necesitas Deploy Primero?

### Desarrollo Local (NO necesita deploy)

**Puedes desarrollar y probar localmente:**

1. **Backend local**:
   ```bash
   cd backend
   npm run dev
   ```
   - Backend corre en `http://localhost:3001`
   - App Android puede apuntar a `http://TU_IP_LOCAL:3001` (mismo WiFi)

2. **Testing**:
   - Probar endpoints con Postman/curl
   - Probar desde app Android apuntando a IP local
   - Verificar que procesamiento funciona

3. **Ventajas**:
   - ✅ Desarrollo rápido
   - ✅ Debugging fácil
   - ✅ No afecta producción

### Deploy a Azure (Para Producción)

**Solo cuando esté listo:**

1. **Configurar Azure**:
   - Variables de entorno en App Service
   - Azure Key Vault para credenciales SQL
   - CORS configurado para dominio de app Android

2. **Deploy**:
   - Push a repositorio
   - Azure App Service auto-deploy (si está configurado)
   - O deploy manual desde Azure Portal

3. **Testing en Producción**:
   - Probar endpoints en Azure
   - Verificar que procesamiento funciona
   - Verificar que guarda en SQL Server

---

## 📋 Checklist de Implementación

### Backend (Luz&Sombra):

- [ ] Crear `backend/src/routes/auth.ts`
- [ ] Crear `backend/src/middleware/auth.ts`
- [ ] Crear `backend/src/routes/photoUpload.ts`
- [ ] Implementar `getPlantInfoFromPlantId()` (consulta SQL)
- [ ] Registrar rutas en `server.ts`
- [ ] Instalar dependencias (`jsonwebtoken`)
- [ ] Agregar variables de entorno (`.env`)
- [ ] Probar endpoint `/api/auth/login`
- [ ] Probar endpoint `/api/photos/upload` (con Postman)
- [ ] Verificar que procesa imágenes correctamente
- [ ] Verificar que guarda en SQL Server
- [ ] Verificar que retorna `processed: true`

### Azure (Producción):

- [ ] Configurar variables de entorno en App Service
- [ ] Configurar Azure Key Vault (si no está)
- [ ] Configurar CORS para app Android
- [ ] Deploy a Azure
- [ ] Probar endpoints en producción
- [ ] Verificar logs en Azure Portal

---

## 🧪 Testing

### 1. Probar Autenticación

```bash
# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "test-device-001",
    "apiKey": "test-api-key"
  }'

# Debe retornar:
# {
#   "success": true,
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "expiresIn": 86400,
#   "deviceId": "test-device-001"
# }
```

### 2. Probar Subida de Foto

```bash
# Obtener token primero
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Subir foto
curl -X POST http://localhost:3001/api/photos/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test-photo.jpg" \
  -F "plantId=00805221" \
  -F "timestamp=2025-01-15T10:30:00Z"

# Debe retornar:
# {
#   "success": true,
#   "photoId": "123",
#   "processed": true,
#   "message": "Foto procesada y guardada en BD",
#   "porcentaje_luz": 65.5,
#   "porcentaje_sombra": 34.5
# }
```

---

## 🔄 Flujo Completo

```
1. App Android (AgriQR)
   ↓
   POST /api/auth/login
   { deviceId, apiKey }
   ↓
   Backend retorna JWT token
   ↓
2. App Android guarda token en Keystore
   ↓
3. App Android toma foto
   ↓
4. App Android sube foto
   POST /api/photos/upload
   Headers: Authorization: Bearer {token}
   Body: file, plantId, timestamp
   ↓
5. Backend (Luz&Sombra):
   - Valida token JWT
   - Obtiene info de planta (plantId → empresa/fundo/sector/lote)
   - Procesa imagen (imageProcessingService)
   - Guarda en SQL Server (sqlServerService)
   - Retorna { success: true, processed: true }
   ↓
6. App Android elimina foto del dispositivo
```

---

## ❓ Preguntas Pendientes

1. **¿Cómo se relaciona `plantId` con la base de datos?**
   - ¿Hay una tabla de plantas?
   - ¿El `plantId` está en el nombre del archivo?
   - ¿El `plantId` es parte del `lotID`?

2. **¿Necesitas autenticación más compleja?**
   - ¿Usuarios/contraseñas?
   - ¿Azure AD?
   - ¿API keys por dispositivo?

3. **¿Hay GPS en las fotos?**
   - ¿Extraer de EXIF?
   - ¿Enviar desde app Android?

---

## 🚀 Siguiente Paso

**Recomendación**: 
1. Desarrollar localmente primero (NO necesita deploy)
2. Probar endpoints con Postman
3. Integrar con app Android apuntando a IP local
4. Cuando funcione, hacer deploy a Azure

¿Quieres que implemente el código ahora o prefieres revisar primero cómo está estructurada la relación `plantId` → `empresa/fundo/sector/lote` en tu base de datos?

