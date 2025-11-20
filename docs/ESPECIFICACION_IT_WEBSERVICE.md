# Especificación Técnica para IT - Web Service LuzSombra

## 📋 Resumen

Necesitamos agregar endpoints al Web Service existente de IT para que la aplicación LuzSombra (desplegada en Azure) pueda acceder a SQL Server sin necesidad de VPN.

---

## 🔐 Autenticación

**IT ya tiene un servicio SOAP para autenticación funcionando.**

**Solo necesitamos llamar a la API SOAP desde nuestro código.**

**Información necesaria:**
1. **URL del servicio SOAP:** ¿Cuál es la URL completa?
2. **Método a llamar:** ¿Cómo se llama el método? (Login, Authenticate, etc.)
3. **Credenciales:** ¿Qué credenciales necesito? (usuario/contraseña, API Key, etc.)
4. **Ejemplo de llamada:** ¿Pueden darme un ejemplo de cómo llamarlo?
5. **Token/Respuesta:** ¿Qué retorna? ¿Cómo uso el token en el Web Service? (¿en qué header lo envío?)

---

## 📊 Stored Procedures

**IMPORTANTE:** Los Stored Procedures los diseñamos nosotros (no IT).

**IT solo necesita:**
- Crear los endpoints que llamen a los Stored Procedures
- Los Stored Procedures ya estarán creados en SQL Server

**Proceso:**
1. Nosotros creamos los Stored Procedures en SQL Server
2. Compartimos la especificación de los SP con IT
3. IT crea los endpoints que llamen a esos SP

---

## 🌐 Endpoints Necesarios

### **Total: 15 endpoints**

#### **Endpoints de Escritura (5):**
1. `POST /api/luzsombra/photos/upload` - Subir foto desde AgriQR
2. `POST /api/luzsombra/procesar-imagen` - Procesar imagen desde web
3. `POST /api/luzsombra/alertas/consolidar` - Consolidar alertas
4. `POST /api/luzsombra/alertas/enviar` - Enviar mensajes

#### **Endpoints de Lectura (10):**
1. `GET /api/luzsombra/field-data` - Datos jerárquicos (filtros)
2. `GET /api/luzsombra/historial` - Historial con paginación
3. `GET /api/luzsombra/tabla-consolidada` - Tabla consolidada
4. `GET /api/luzsombra/tabla-consolidada/detalle` - Detalle histórico
5. `GET /api/luzsombra/tabla-consolidada/detalle-planta` - Detalle de plantas
6. `GET /api/luzsombra/imagen/:id` - Obtener imagen por ID
7. `GET /api/luzsombra/estadisticas` - Estadísticas
8. `GET /api/luzsombra/alertas/consolidar` - Estadísticas de alertas
9. `POST /api/luzsombra/auth/login` - Autenticar dispositivo (AgriQR)
10. `GET /api/luzsombra/health` - Health check

---

## 📝 Especificación de Endpoints

### **1. POST `/api/luzsombra/photos/upload`**

**Request:**
```http
POST /api/luzsombra/photos/upload
Content-Type: multipart/form-data
X-SOAP-Token: <token-del-soap>

Body (form-data):
- plantId: "00805221"
- photo: [archivo JPEG]
- timestamp: "2024-11-17T10:30:00Z"
- gps: '{"latitude": -33.4489, "longitude": -70.6693}'
```

**Response:**
```json
{
  "success": true,
  "analisisID": 12345,
  "message": "Foto procesada exitosamente"
}
```

**Stored Procedure:**
```sql
EXEC image.sp_InsertAnalisisImagen
    @plantID = @plantId,
    @fotoPath = @fotoBase64,
    @fechaHora = @timestamp,
    @latitud = @gpsLatitude,
    @longitud = @gpsLongitude
```

---

### **2. GET `/api/luzsombra/field-data`**

**Request:**
```http
GET /api/luzsombra/field-data
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "source": "sql",
  "data": {
    "empresas": [
      {
        "id": "AGR",
        "nombre": "Agrícola Andrea",
        "fundos": [...]
      }
    ]
  }
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetFieldData
```

---

### **3. GET `/api/luzsombra/historial`**

**Request:**
```http
GET /api/luzsombra/historial?page=1&pageSize=20&empresa=AGR&fundo=VAL
X-SOAP-Token: <token-del-soap>
```

**Query Parameters:**
- `page`: número de página (default: 1)
- `pageSize`: registros por página (default: 20)
- `empresa`: filtro por empresa (opcional)
- `fundo`: filtro por fundo (opcional)
- `sector`: filtro por sector (opcional)
- `lote`: filtro por lote (opcional)

**Response:**
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetHistorial
    @page = 1,
    @pageSize = 20,
    @empresa = 'AGR',
    @fundo = 'VAL',
    @sector = NULL,
    @lote = NULL
```

---

### **4. GET `/api/luzsombra/tabla-consolidada`**

**Request:**
```http
GET /api/luzsombra/tabla-consolidada?page=1&pageSize=20&fundo=VAL&sector=2260
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "data": [...],
  "total": 50,
  "page": 1,
  "pageSize": 20,
  "totalPages": 3
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetTablaConsolidada
    @page = 1,
    @pageSize = 20,
    @fundo = 'VAL',
    @sector = 2260,
    @lote = NULL
```

---

### **5. GET `/api/luzsombra/tabla-consolidada/detalle`**

**Request:**
```http
GET /api/luzsombra/tabla-consolidada/detalle?fundo=VAL&sector=2260&lote=1022
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetDetalleHistorial
    @fundo = 'VAL',
    @sector = 2260,
    @lote = 1022
```

---

### **6. GET `/api/luzsombra/tabla-consolidada/detalle-planta`**

**Request:**
```http
GET /api/luzsombra/tabla-consolidada/detalle-planta?fundo=VAL&sector=2260&lote=1022&fecha=2024-11-17T10:30:00Z
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetDetallePlanta
    @fundo = 'VAL',
    @sector = 2260,
    @lote = 1022,
    @fecha = '2024-11-17 10:30:00'
```

---

### **7. GET `/api/luzsombra/imagen/:id`**

**Request:**
```http
GET /api/luzsombra/imagen/123
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "analisisID": 123,
    "plantID": "00805221",
    "fotoPath": "base64...",
    ...
  }
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetImagen
    @analisisID = 123
```

---

### **8. GET `/api/luzsombra/estadisticas`**

**Request:**
```http
GET /api/luzsombra/estadisticas
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalEvaluaciones": 1500,
    "totalAlertas": 25,
    ...
  }
}
```

**Stored Procedure:**
```sql
EXEC image.sp_GetEstadisticas
```

---

### **9. POST `/api/luzsombra/procesar-imagen`**

**Request:**
```http
POST /api/luzsombra/procesar-imagen
Content-Type: multipart/form-data
X-SOAP-Token: <token-del-soap>

Body:
- file: [archivo]
- plantId: "00805221"
- fundo: "VAL"
- sector: "2260"
- lote: "1022"
```

**Response:**
```json
{
  "success": true,
  "analisisID": 123,
  "porcentajeLuz": 45.5,
  "tipoUmbral": "Normal"
}
```

**Stored Procedure:**
```sql
EXEC image.sp_InsertAnalisisImagen
    @plantID = '00805221',
    @fotoPath = '...',
    @fundo = 'VAL',
    @sector = 2260,
    @lote = 1022
```

---

### **10. POST `/api/luzsombra/test-model`**

**Request:**
```http
POST /api/luzsombra/test-model
Content-Type: multipart/form-data
X-SOAP-Token: <token-del-soap>

Body:
- file: [archivo]
```

**Response:**
```json
{
  "success": true,
  "porcentajeLuz": 45.5,
  "tipoUmbral": "Normal"
}
```

**Nota:** Este endpoint NO guarda en BD, solo procesa la imagen.

---

### **11. POST `/api/luzsombra/alertas/consolidar`**

**Request:**
```http
POST /api/luzsombra/alertas/consolidar
Content-Type: application/json
X-SOAP-Token: <token-del-soap>

Body:
{
  "horasAtras": 24
}
```

**Response:**
```json
{
  "success": true,
  "mensajesCreados": 2,
  "message": "Se consolidaron alertas en 2 mensaje(s)"
}
```

**Stored Procedure:**
```sql
EXEC image.sp_ConsolidarAlertasPorFundo
    @horasAtras = 24
```

---

### **12. GET `/api/luzsombra/alertas/consolidar`**

**Request:**
```http
GET /api/luzsombra/alertas/consolidar
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "totalAlertas": 10,
  "totalFundos": 2,
  "estadisticasPorFundo": [...]
}
```

---

### **13. POST `/api/luzsombra/alertas/enviar`**

**Request:**
```http
POST /api/luzsombra/alertas/enviar
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "success": true,
  "exitosos": 2,
  "errores": 0,
  "mensaje": "Procesados 2 mensaje(s): 2 exitoso(s), 0 error(es)"
}
```

**Nota:** Este endpoint puede llamar a Resend API directamente o solo actualizar estado en BD.

---

### **14. POST `/api/luzsombra/auth/login`**

**Request:**
```http
POST /api/luzsombra/auth/login
Content-Type: application/json

Body:
{
  "deviceId": "device-test-001",
  "apiKey": "test-api-key-12345"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600
}
```

**Stored Procedure:**
```sql
EXEC image.sp_ValidateDevice
    @deviceID = 'device-test-001',
    @apiKey = 'test-api-key-12345'
```

---

### **15. GET `/api/luzsombra/health`**

**Request:**
```http
GET /api/luzsombra/health
X-SOAP-Token: <token-del-soap>
```

**Response:**
```json
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2024-11-17T10:30:00Z"
}
```

---

## 📋 Checklist para IT

### **Información Necesaria:**
- [ ] URL del servicio SOAP
- [ ] WSDL del servicio SOAP (si existe)
- [ ] Método de autenticación SOAP
- [ ] Credenciales (usuario/contraseña o API Key)
- [ ] Ejemplo de request XML
- [ ] Ejemplo de response XML
- [ ] Cómo usar el token en el Web Service (header, body, etc.)
- [ ] Tiempo de expiración del token

### **Endpoints a Implementar:**
- [ ] POST `/api/luzsombra/photos/upload`
- [ ] GET `/api/luzsombra/field-data`
- [ ] GET `/api/luzsombra/historial`
- [ ] GET `/api/luzsombra/tabla-consolidada`
- [ ] GET `/api/luzsombra/tabla-consolidada/detalle`
- [ ] GET `/api/luzsombra/tabla-consolidada/detalle-planta`
- [ ] GET `/api/luzsombra/imagen/:id`
- [ ] GET `/api/luzsombra/estadisticas`
- [ ] POST `/api/luzsombra/procesar-imagen`
- [ ] POST `/api/luzsombra/test-model`
- [ ] POST `/api/luzsombra/alertas/consolidar`
- [ ] GET `/api/luzsombra/alertas/consolidar`
- [ ] POST `/api/luzsombra/alertas/enviar`
- [ ] POST `/api/luzsombra/auth/login`
- [ ] GET `/api/luzsombra/health`

### **Stored Procedures:**
- [ ] Nosotros crearemos los Stored Procedures
- [ ] Compartiremos la especificación con IT
- [ ] IT solo necesita llamarlos desde los endpoints

---

## 📞 Contacto

**Para dudas sobre:**
- **Stored Procedures:** Contactar al equipo de desarrollo de LuzSombra
- **Endpoints:** Contactar a IT
- **Autenticación SOAP:** Contactar a IT

---

**Fecha de creación**: 2024-11-17

