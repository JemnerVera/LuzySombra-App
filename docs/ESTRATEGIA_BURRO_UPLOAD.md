# Estrategia para Upload de Imágenes desde el Burro

**Fecha:** Diciembre 2025  
**Contexto:** Sistema de captura automática desde Raspberry Pi que toma fotos desde celular

---

## 📋 Contexto Actual

### Flujos Existentes

#### 1. **AgriQR** (`/api/photos/upload`)
- ✅ **Autenticación:** JWT (deviceId + apiKey)
- ✅ **Input:** Imagen + `plantId` (escaneado de QR)
- ✅ **Lógica:** Busca información de planta desde `plantId` → obtiene empresa/fundo/sector/lote
- ✅ **GPS:** Se extrae de EXIF pero NO se usa para determinar ubicación

#### 2. **WebApp** (`/api/procesar-imagen`)
- ⚠️ **Autenticación:** NINGUNA (público)
- ✅ **Input:** Imagen + `empresa`, `fundo`, `sector`, `lote` (seleccionados manualmente)
- ✅ **GPS:** Se extrae de EXIF y se guarda, pero no se usa para determinar ubicación

#### 3. **Burro** (NUEVO - A DEFINIR)
- ❓ **Autenticación:** ¿Qué tipo?
- ✅ **Input:** Solo imagen (con GPS EXIF)
- ❓ **Lógica:** ¿Cómo determinar empresa/fundo/sector/lote desde GPS?
- ✅ **GPS:** Se usará para georeferenciar

---

## 🎯 Requisitos del Burro

1. **No escanea QR** → No tiene `plantId`
2. **No tiene selección manual** → No puede enviar empresa/fundo/sector/lote
3. **Tiene GPS en EXIF** → Única fuente de información de ubicación
4. **Raspberry Pi** → Necesita endpoint accesible
5. **Celular toma fotos** → Las almacena en Raspberry Pi

---

## 🔍 Análisis de Opciones

### **Opción 1: Nuevo Endpoint Dedicado** ✅ **RECOMENDADO**

**Endpoint:** `POST /api/photos/upload-burro` o `POST /api/burro/upload`

#### Ventajas:
- ✅ Separación clara de responsabilidades
- ✅ Autenticación específica (puede usar JWT como AgriQR)
- ✅ Lógica específica para reverse geocoding GPS → empresa/fundo/sector/lote
- ✅ No afecta endpoints existentes
- ✅ Fácil de mantener y debuggear

#### Desventajas:
- ⚠️ Duplicación parcial de código (procesamiento de imagen)
- ⚠️ Requiere nueva lógica de geocoding

#### Implementación:
```typescript
// Estructura similar a /api/photos/upload pero:
// 1. NO requiere plantId
// 2. Requiere GPS (validación)
// 3. Busca empresa/fundo/sector/lote desde GPS
// 4. Usa misma autenticación JWT que AgriQR
```

---

### **Opción 2: Usar Endpoint de AgriQR con Modificaciones** ⚠️ NO RECOMENDADO

**Endpoint:** Modificar `/api/photos/upload`

#### Ventajas:
- ✅ Reutiliza código existente
- ✅ Ya tiene autenticación

#### Desventajas:
- ❌ Requiere `plantId` (burro no lo tiene)
- ❌ Cambiaría comportamiento de endpoint existente (riesgo)
- ❌ Lógica condicional compleja (si plantId → buscar por plantId, si GPS → buscar por GPS)
- ❌ Rompe compatibilidad con AgriQR si no se hace bien

---

### **Opción 3: Usar Endpoint WebApp** ❌ NO RECOMENDADO

**Endpoint:** `/api/procesar-imagen`

#### Ventajas:
- ✅ No requiere autenticación (más simple para burro)

#### Desventajas:
- ❌ **Sin autenticación** (riesgo de seguridad)
- ❌ Requiere empresa/fundo/sector/lote en request (burro no los tiene)
- ❌ No tiene lógica de geocoding GPS → ubicación
- ❌ Endpoint público sin control

---

## 🏆 RECOMENDACIÓN: Opción 1 - Nuevo Endpoint Dedicado

### Justificación:
1. **Seguridad:** Puede usar misma autenticación JWT que AgriQR
2. **Claridad:** Lógica específica y clara para este caso de uso
3. **Mantenibilidad:** No afecta sistemas existentes
4. **Escalabilidad:** Fácil agregar funcionalidades específicas del burro

---

## 📐 Diseño de Solución

### 1. **Nuevo Endpoint: `/api/burro/upload`**

```typescript
POST /api/burro/upload
Headers:
  Authorization: Bearer <JWT_TOKEN>
Body (multipart/form-data):
  - file: imagen (requerido)
  - timestamp: ISO 8601 (opcional, se usa EXIF si no se proporciona)
```

### 2. **Flujo de Procesamiento:**

```
1. Autenticación JWT (mismo que AgriQR)
   ↓
2. Validar archivo
   ↓
3. Extraer GPS desde EXIF (REQUERIDO - si no hay GPS, error)
   ↓
4. Buscar empresa/fundo/sector/lote desde GPS
   (Nueva función: getLocationFromGPS(lat, lng))
   ↓
5. Procesar imagen (mismo algoritmo)
   ↓
6. Guardar en BD (mismo stored procedure)
```

### 3. **Nueva Función: `getLocationFromGPS(lat, lng)`**

**⚠️ IMPORTANTE:** Esta función necesita implementarse. Opciones:

#### **Opción A: Búsqueda por Distancia** (Más Simple)
- Buscar el análisis más cercano con GPS similar
- Usar distancia euclidiana o Haversine
- Problema: Puede fallar si no hay análisis previos cerca

#### **Opción B: Tabla de Polígonos de Lotes** (Más Preciso)
- Requiere tabla con polígonos/límites de cada lote
- Usar STContains o búsqueda espacial de SQL Server
- Problema: Requiere datos geográficos en BD

#### **Opción C: Tabla de Puntos de Referencia** (Intermedio)
- Tabla con puntos centrales de lotes (lat/lng)
- Buscar lote más cercano por distancia
- Problema: Solo funciona si el punto central está cerca

**Recomendación Inicial:** Opción A para MVP, migrar a Opción B si hay polígonos disponibles.

---

## 🔐 Autenticación

### **Usar mismo sistema que AgriQR:**

1. **Registrar el burro como dispositivo:**
   - Crear entrada en `evalImagen.dispositivo`
   - Generar `deviceId` único (ej: "burro_raspberry_01")
   - Generar `apiKey` hasheada
   - Guardar en BD

2. **Login del burro:**
   - `POST /api/auth/login` con `deviceId` y `apiKey`
   - Recibe JWT token (24h validez)

3. **Enviar imágenes:**
   - Header: `Authorization: Bearer <JWT_TOKEN>`
   - Mismo middleware `authenticateToken` que AgriQR

**Ventajas:**
- ✅ Sistema ya existente y probado
- ✅ Rate limiting ya implementado
- ✅ Tracking de dispositivos en BD
- ✅ Logs de acceso

---

## 📝 Implementación Propuesta

### **Paso 1: Crear función de geocoding GPS → ubicación**

```typescript
// backend/src/services/locationService.ts

async function getLocationFromGPS(
  lat: number, 
  lng: number, 
  radiusMeters: number = 100
): Promise<{
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  lotID: number;
  distance: number; // metros
} | null> {
  // Opción A: Buscar análisis más cercano
  // SELECT TOP 1 empresa, fundo, sector, lote, lotID,
  //    distancia en metros
  // FROM evalImagen.analisisImagen
  // WHERE latitud IS NOT NULL AND longitud IS NOT NULL
  // ORDER BY distancia ASC
  
  // Opción B: Si hay polígonos, usar STContains
  // SELECT empresa, fundo, sector, lote, lotID
  // FROM GROWER.LOT
  // WHERE geometry.STContains(geography::Point(@lat, @lng, 4326)) = 1
}
```

### **Paso 2: Crear nuevo endpoint**

```typescript
// backend/src/routes/burro.ts

router.post('/upload',
  authenticateToken, // Mismo que AgriQR
  upload.single('file'),
  async (req: Request, res: Response) => {
    // 1. Validar archivo
    // 2. Extraer GPS (REQUERIDO)
    // 3. Si no hay GPS → error 400
    // 4. getLocationFromGPS(lat, lng)
    // 5. Si no se encuentra ubicación → error 404
    // 6. Procesar imagen (reutilizar código)
    // 7. Guardar en BD (reutilizar código)
  }
);
```

### **Paso 3: Registrar en server.ts**

```typescript
import burroRoutes from './routes/burro';
app.use('/api/burro', burroRoutes);
```

---

## 🚨 Validaciones Necesarias

1. **GPS Requerido:**
   - Si la imagen no tiene GPS EXIF → Error 400
   - Mensaje: "La imagen debe contener información GPS en los metadatos EXIF"

2. **Ubicación Válida:**
   - Si GPS no coincide con ningún lote conocido → Error 404
   - Mensaje: "No se encontró un lote para las coordenadas GPS proporcionadas"

3. **Radio de Búsqueda:**
   - Configurable (ej: 100 metros por defecto)
   - Si hay múltiples lotes cerca, usar el más cercano
   - Log de advertencia si hay múltiples candidatos

---

## 📊 Comparativa de Endpoints

| Característica | AgriQR | WebApp | Burro (Propuesto) |
|---------------|--------|--------|-------------------|
| **Endpoint** | `/api/photos/upload` | `/api/procesar-imagen` | `/api/burro/upload` |
| **Autenticación** | ✅ JWT | ❌ Ninguna | ✅ JWT |
| **Input Requerido** | `plantId` | `empresa/fundo/sector/lote` | Solo imagen |
| **GPS** | Extrae pero no usa | Extrae pero no usa | **REQUERIDO** |
| **Geocoding** | Por `plantId` | Manual | **Por GPS** |
| **Procesamiento** | ✅ Heurístico | ✅ Heurístico | ✅ Heurístico |
| **Guardado BD** | ✅ SP | ✅ SP | ✅ SP |

---

## ✅ Plan de Implementación

### **Fase 1: Función de Geocoding** (2-3 horas)
1. Crear `locationService.ts`
2. Implementar búsqueda por distancia (Opción A)
3. Probar con datos existentes

### **Fase 2: Endpoint del Burro** (2-3 horas)
1. Crear `routes/burro.ts`
2. Implementar validación de GPS
3. Integrar geocoding
4. Reutilizar procesamiento de imagen
5. Reutilizar guardado en BD

### **Fase 3: Testing** (1-2 horas)
1. Probar con imágenes con GPS
2. Probar con imágenes sin GPS
3. Probar con GPS fuera de rango
4. Validar autenticación JWT

### **Fase 4: Documentación** (1 hora)
1. Documentar endpoint en README
2. Ejemplos de uso
3. Cómo registrar dispositivo burro

---

## 🔮 Mejoras Futuras

1. **Geocoding Mejorado:**
   - Migrar a búsqueda por polígonos (Opción B)
   - Requiere datos geográficos en BD

2. **Caché de Geocoding:**
   - Cachear resultados GPS → ubicación
   - Reducir queries a BD

3. **Validación de Distancia:**
   - Configurar distancia máxima aceptable
   - Rechazar si GPS está muy lejos del lote más cercano

4. **Múltiples Candidatos:**
   - Si hay varios lotes cerca, retornar lista
   - Permitir selección manual o usar heurística

---

## ❓ Preguntas Pendientes

1. **¿Hay polígonos/límites de lotes en la BD?**
   - Si sí → Usar Opción B (más preciso)
   - Si no → Usar Opción A (búsqueda por distancia)

2. **¿Qué radio de búsqueda es aceptable?**
   - 50m, 100m, 200m?

3. **¿Qué hacer si no se encuentra ubicación?**
   - Error 404?
   - Guardar con ubicación "Unknown"?
   - Requerir revisión manual?

4. **¿El burro tiene conexión constante a internet?**
   - Si no → Considerar queue/batch upload

---

## 📝 Resumen

✅ **Recomendación:** Crear nuevo endpoint `/api/burro/upload`

✅ **Autenticación:** Mismo sistema JWT que AgriQR

✅ **Geocoding:** Nueva función `getLocationFromGPS()` (implementar búsqueda por distancia inicialmente)

✅ **Validación:** GPS requerido en EXIF

✅ **Reutilización:** Mismo procesamiento de imagen y guardado en BD

---

**Próximo Paso:** Implementar función de geocoding y nuevo endpoint siguiendo esta estrategia.

