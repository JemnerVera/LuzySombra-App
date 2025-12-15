# Integración del "Burro" (Carro Mecánico) con LuzSombra

## 📋 Contexto Actual

### Sistema Actual: AgriQR + LuzSombra
- **AgriQR (App móvil)**: 
  - Se autentica con `deviceId` + `apiKey` → obtiene JWT token
  - Sube fotos a `/api/photos/upload` con `plantId` (ID de planta)
  - El backend busca automáticamente: empresa, fundo, sector, lote desde el `plantId`

- **LuzSombra (Webapp)**:
  - Sube fotos a `/api/procesar-imagen` con datos completos (empresa, fundo, sector, lote, hilera, planta)
  - Procesa y guarda en `evalImagen.analisisImagen`

### Endpoint Existente para Móviles
```
POST /api/photos/upload
Headers:
  Authorization: Bearer <JWT_TOKEN>
Body (multipart/form-data):
  - file: archivo de imagen
  - plantId: ID de la planta (ej: "00805221")
  - timestamp: fecha/hora ISO 8601 (opcional)
```

---

## 🚜 Opciones de Integración para el "Burro"

### **Opción 1: API REST Directa (Recomendada) ⭐**

**Descripción**: El burro envía fotos directamente a la API de LuzSombra usando el mismo endpoint que AgriQR.

**Ventajas**:
- ✅ Reutiliza infraestructura existente
- ✅ Mismo flujo de procesamiento que AgriQR
- ✅ Autenticación segura con JWT
- ✅ Búsqueda automática de información desde `plantId`
- ✅ Implementación rápida (solo configurar dispositivo)

**Requisitos**:
1. Registrar el "burro" como dispositivo en `evalImagen.dispositivo`
2. Obtener `deviceId` y `apiKey` (generar QR code)
3. El burro debe tener capacidad de hacer HTTP POST requests
4. El burro debe conocer el `plantId` de cada foto

**Flujo**:
```
1. Burro toma foto → conoce plantId
2. Burro hace login: POST /api/auth/login { deviceId, apiKey }
3. Burro recibe JWT token
4. Burro sube foto: POST /api/photos/upload { file, plantId, timestamp }
5. Backend procesa automáticamente y guarda en BD
```

**Implementación**:
- Crear dispositivo "BURRO_001" en la webapp
- Configurar el burro con el `deviceId` y `apiKey`
- El burro implementa cliente HTTP (REST API)

---

### **Opción 2: Integración vía Archivos (Watch Folder)**

**Descripción**: El burro guarda fotos en una carpeta compartida/cloud, y un servicio de LuzSombra las procesa automáticamente.

**Ventajas**:
- ✅ No requiere cambios en el burro (si ya guarda archivos)
- ✅ Procesamiento asíncrono
- ✅ Puede procesar lotes de fotos

**Desventajas**:
- ⚠️ Requiere servicio adicional (monitor de carpeta)
- ⚠️ Necesita mapear nombre de archivo → plantId
- ⚠️ Latencia (no es en tiempo real)

**Requisitos**:
1. Carpeta compartida/cloud accesible desde el servidor
2. Convención de nombres: `{plantId}_{timestamp}.jpg`
3. Servicio Node.js que monitorea la carpeta
4. Mapeo de nombre de archivo → plantId

**Flujo**:
```
1. Burro guarda foto: BURRO_001/00805221_2025-12-15_14-30-00.jpg
2. Servicio detecta nuevo archivo
3. Servicio extrae plantId del nombre
4. Servicio llama a /api/photos/upload (con autenticación)
5. Servicio mueve archivo a "procesado/" o lo elimina
```

**Implementación**:
- Crear servicio `watch-folder-service.ts`
- Usar `chokidar` para monitorear carpeta
- Procesar archivos en batch

---

### **Opción 3: Integración vía Base de Datos**

**Descripción**: El burro inserta registros en una tabla intermedia, y un proceso de LuzSombra los lee y procesa.

**Ventajas**:
- ✅ Desacoplamiento total
- ✅ El burro solo necesita acceso a BD
- ✅ Puede incluir metadata adicional

**Desventajas**:
- ⚠️ Requiere acceso directo a BD desde el burro
- ⚠️ Necesita tabla intermedia
- ⚠️ Proceso de polling adicional

**Requisitos**:
1. Tabla `evalImagen.fotoPendiente`:
   - `fotoID`, `plantId`, `rutaArchivo`, `timestamp`, `estado`, `fechaCreacion`
2. El burro inserta registros en esta tabla
3. Servicio de LuzSombra lee y procesa periódicamente

**Flujo**:
```
1. Burro toma foto → guarda en carpeta
2. Burro inserta: INSERT INTO evalImagen.fotoPendiente (plantId, rutaArchivo, timestamp)
3. Servicio de LuzSombra (cron job) lee registros pendientes
4. Servicio procesa cada foto y actualiza estado
```

**Implementación**:
- Crear tabla `evalImagen.fotoPendiente`
- Crear servicio `foto-processor-service.ts`
- Usar `node-cron` para ejecutar cada X minutos

---

### **Opción 4: Integración Híbrida (API + Metadata)**

**Descripción**: Similar a Opción 1, pero con endpoint específico que acepta metadata adicional del burro.

**Ventajas**:
- ✅ Endpoint optimizado para el burro
- ✅ Puede incluir información adicional (GPS, velocidad, etc.)
- ✅ Mejor trazabilidad

**Requisitos**:
1. Nuevo endpoint: `POST /api/burro/upload`
2. Acepta metadata adicional:
   - `plantId` (requerido)
   - `timestamp` (opcional)
   - `gpsLat`, `gpsLng` (opcional)
   - `velocidad` (opcional)
   - `temperatura` (opcional)
   - `humedad` (opcional)

**Flujo**:
```
1. Burro toma foto con sensores
2. Burro hace login: POST /api/auth/login
3. Burro sube con metadata: POST /api/burro/upload
   { file, plantId, timestamp, gpsLat, gpsLng, velocidad, temperatura, humedad }
4. Backend procesa y guarda todo
```

**Implementación**:
- Crear `backend/src/routes/burro.ts`
- Extender `evalImagen.analisisImagen` con campos adicionales (opcional)
- O crear tabla `evalImagen.metadataBurro` para datos adicionales

---

## 📊 Comparación de Opciones

| Criterio | Opción 1: API REST | Opción 2: Watch Folder | Opción 3: BD | Opción 4: Híbrida |
|----------|-------------------|------------------------|--------------|-------------------|
| **Complejidad** | ⭐⭐ Baja | ⭐⭐⭐ Media | ⭐⭐⭐⭐ Alta | ⭐⭐⭐ Media |
| **Tiempo Real** | ✅ Sí | ❌ No | ❌ No | ✅ Sí |
| **Cambios en Burro** | ⚠️ Requiere HTTP | ✅ Ninguno | ⚠️ Requiere BD | ⚠️ Requiere HTTP |
| **Escalabilidad** | ✅ Alta | ⚠️ Media | ✅ Alta | ✅ Alta |
| **Mantenimiento** | ✅ Bajo | ⚠️ Medio | ⚠️ Alto | ⚠️ Medio |
| **Recomendación** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎯 Recomendación: Opción 1 (API REST Directa)

**Razones**:
1. ✅ Reutiliza código existente (endpoint `/api/photos/upload`)
2. ✅ Mismo flujo que AgriQR (consistencia)
3. ✅ Implementación más rápida
4. ✅ Autenticación segura ya implementada
5. ✅ Búsqueda automática de información desde `plantId`

**Pasos para Implementar**:

1. **Registrar dispositivo en la webapp**:
   - Ir a "Dispositivos" → "Nuevo Dispositivo"
   - Nombre: "BURRO_001" (o el nombre que corresponda)
   - Generar API Key y QR code
   - Guardar `deviceId` y `apiKey`

2. **Configurar el burro**:
   - Instalar cliente HTTP (si no lo tiene)
   - Configurar `deviceId` y `apiKey`
   - Configurar URL del backend: `https://luzsombra-backend.azurewebsites.net/api`

3. **Implementar en el burro** (pseudocódigo):
   ```python
   # 1. Login
   response = requests.post(
       f"{BASE_URL}/auth/login",
       json={"deviceId": DEVICE_ID, "apiKey": API_KEY}
   )
   token = response.json()["token"]
   
   # 2. Subir foto
   with open(foto_path, 'rb') as f:
       files = {'file': f}
       data = {
           'plantId': plant_id,  # El burro debe conocer esto
           'timestamp': datetime.now().isoformat()  # Opcional
       }
       headers = {'Authorization': f'Bearer {token}'}
       
       response = requests.post(
           f"{BASE_URL}/photos/upload",
           files=files,
           data=data,
           headers=headers
       )
   ```

4. **Probar integración**:
   - Tomar foto de prueba con el burro
   - Verificar que aparece en "Historial" de la webapp
   - Verificar que se procesó correctamente

---

## ❓ Preguntas para la Reunión

1. **¿Qué información tiene disponible el burro?**
   - ¿Conoce el `plantId` de cada foto?
   - ¿Tiene GPS integrado?
   - ¿Tiene otros sensores (temperatura, humedad, etc.)?

2. **¿Qué capacidad de comunicación tiene el burro?**
   - ¿Puede hacer HTTP requests (REST API)?
   - ¿Solo puede guardar archivos en carpeta?
   - ¿Tiene acceso a base de datos?

3. **¿Cuál es el flujo de trabajo actual del burro?**
   - ¿Cómo toma las fotos?
   - ¿Cómo identifica la planta?
   - ¿Dónde guarda las fotos actualmente?

4. **¿Requisitos de tiempo real?**
   - ¿Las fotos deben procesarse inmediatamente?
   - ¿O puede haber un delay (batch processing)?

5. **¿Volumen de fotos?**
   - ¿Cuántas fotos por día?
   - ¿Necesita procesamiento en lote?

---

## 📝 Próximos Pasos

1. **Reunión con equipo del burro** → Responder preguntas arriba
2. **Decidir opción de integración** → Basado en capacidades del burro
3. **Implementar solución elegida**
4. **Pruebas de integración**
5. **Despliegue a producción**

---

## 🔗 Referencias

- Endpoint actual: `backend/src/routes/photoUpload.ts`
- Autenticación: `backend/src/routes/auth.ts`
- Procesamiento: `backend/src/services/imageProcessingService.ts`
- Base de datos: `scripts/03_stored_procedures/02_sp_insertAnalisisImagen.sql`

