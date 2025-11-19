# Endpoints Completos Necesarios en el Web Service

## 🎯 Situación

**Problema:** Azure App Service no puede acceder directamente a SQL Server (requiere VPN).

**Solución:** TODOS los endpoints que consultan la BD deben pasar por el Web Service de IT.

---

## 📋 Lista Completa de Endpoints Necesarios

### **1. Endpoints de Escritura (Inserciones/Updates)**

#### **1.1. POST `/api/luzsombra/photos/upload`**
**Ya documentado** - Subir fotos desde AgriQR

---

### **2. Endpoints de Lectura (Consultas)**

#### **2.1. GET `/api/luzsombra/field-data`**
**¿Qué hace?**
- Obtiene datos jerárquicos para los filtros (Empresa → Fundo → Sector → Lote)
- Usado para poblar los dropdowns en el frontend

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/field-data
X-API-Key: tu-api-key
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
        "fundos": [
          {
            "id": "VAL",
            "nombre": "FDO. VALERIE",
            "sectores": [
              {
                "id": 2260,
                "nombre": "Sector 1",
                "lotes": [
                  {
                    "id": 1022,
                    "nombre": "Lote A"
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
```

**Stored Procedure necesario:**
```sql
-- Obtener jerarquía completa
EXEC image.sp_GetFieldData
```

---

#### **2.2. GET `/api/luzsombra/historial`**
**¿Qué hace?**
- Obtiene historial de procesamientos con paginación
- Filtros: empresa, fundo, sector, lote, fecha

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/historial?page=1&pageSize=20&empresa=AGR&fundo=VAL
X-API-Key: tu-api-key
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
  "data": [
    {
      "analisisID": 123,
      "fundo": "FDO. VALERIE",
      "sector": "Sector 1",
      "lote": "Lote A",
      "fecha": "2024-11-17T10:30:00Z",
      "porcentajeLuz": 45.5,
      "tipoUmbral": "Normal"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

**Stored Procedure necesario:**
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

#### **2.3. GET `/api/luzsombra/tabla-consolidada`**
**¿Qué hace?**
- Obtiene tabla consolidada de evaluaciones por lote
- Filtros: fundo, sector, lote
- Paginación

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/tabla-consolidada?page=1&pageSize=20&fundo=VAL&sector=2260
X-API-Key: tu-api-key
```

**Query Parameters:**
- `page`: número de página
- `pageSize`: registros por página
- `fundo`: filtro por fundo (opcional)
- `sector`: filtro por sector (opcional)
- `lote`: filtro por lote (opcional)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "loteID": 1022,
      "lote": "Lote A",
      "fundo": "FDO. VALERIE",
      "sector": "Sector 1",
      "ultimaEvaluacion": "2024-11-17T10:30:00Z",
      "porcentajeLuz": 45.5,
      "tipoUmbral": "Normal",
      "totalEvaluaciones": 10
    }
  ],
  "total": 50,
  "page": 1,
  "pageSize": 20,
  "totalPages": 3
}
```

**Stored Procedure necesario:**
```sql
EXEC image.sp_GetTablaConsolidada
    @page = 1,
    @pageSize = 20,
    @fundo = 'VAL',
    @sector = 2260,
    @lote = NULL
```

---

#### **2.4. GET `/api/luzsombra/tabla-consolidada/detalle`**
**¿Qué hace?**
- Obtiene detalle histórico de un lote específico
- Muestra evaluaciones por fecha

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/tabla-consolidada/detalle?fundo=VAL&sector=2260&lote=1022
X-API-Key: tu-api-key
```

**Query Parameters:**
- `fundo`: ID del fundo (requerido)
- `sector`: ID del sector (requerido)
- `lote`: ID del lote (requerido)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "fecha": "2024-11-17T10:30:00Z",
      "porcentajeLuz": 45.5,
      "tipoUmbral": "Normal",
      "totalPlantas": 100,
      "plantasEvaluadas": 50
    },
    {
      "fecha": "2024-11-16T10:30:00Z",
      "porcentajeLuz": 42.3,
      "tipoUmbral": "CriticoAmarillo",
      "totalPlantas": 100,
      "plantasEvaluadas": 45
    }
  ]
}
```

**Stored Procedure necesario:**
```sql
EXEC image.sp_GetDetalleHistorial
    @fundo = 'VAL',
    @sector = 2260,
    @lote = 1022
```

---

#### **2.5. GET `/api/luzsombra/tabla-consolidada/detalle-planta`**
**¿Qué hace?**
- Obtiene detalle de plantas evaluadas en una fecha específica
- Muestra información por planta individual

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/tabla-consolidada/detalle-planta?fundo=VAL&sector=2260&lote=1022&fecha=2024-11-17T10:30:00Z
X-API-Key: tu-api-key
```

**Query Parameters:**
- `fundo`: ID del fundo (requerido)
- `sector`: ID del sector (requerido)
- `lote`: ID del lote (requerido)
- `fecha`: Fecha de evaluación (requerido, ISO 8601)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "analisisID": 123,
      "plantID": "00805221",
      "hilera": 58,
      "numeroPlanta": 61,
      "porcentajeLuz": 45.5,
      "tipoUmbral": "Normal",
      "fechaHora": "2024-11-17T10:30:00Z",
      "latitud": -33.4489,
      "longitud": -70.6693
    }
  ]
}
```

**Stored Procedure necesario:**
```sql
EXEC image.sp_GetDetallePlanta
    @fundo = 'VAL',
    @sector = 2260,
    @lote = 1022,
    @fecha = '2024-11-17 10:30:00'
```

---

#### **2.6. GET `/api/luzsombra/imagen/:id`**
**¿Qué hace?**
- Obtiene información de una imagen específica por ID
- Incluye foto, metadata, resultados del análisis

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/imagen/123
X-API-Key: tu-api-key
```

**Response:**
```json
{
  "success": true,
  "data": {
    "analisisID": 123,
    "plantID": "00805221",
    "fotoPath": "base64...",
    "fotoThumbnail": "base64...",
    "porcentajeLuz": 45.5,
    "tipoUmbral": "Normal",
    "fechaHora": "2024-11-17T10:30:00Z",
    "latitud": -33.4489,
    "longitud": -70.6693,
    "fundo": "FDO. VALERIE",
    "sector": "Sector 1",
    "lote": "Lote A"
  }
}
```

**Stored Procedure necesario:**
```sql
EXEC image.sp_GetImagen
    @analisisID = 123
```

---

#### **2.7. GET `/api/luzsombra/estadisticas`**
**¿Qué hace?**
- Obtiene estadísticas generales del sistema
- Total de evaluaciones, alertas, etc.

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/estadisticas
X-API-Key: tu-api-key
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalEvaluaciones": 1500,
    "totalAlertas": 25,
    "alertasCriticas": 10,
    "alertasAdvertencias": 15,
    "ultimaEvaluacion": "2024-11-17T10:30:00Z"
  }
}
```

**Stored Procedure necesario:**
```sql
EXEC image.sp_GetEstadisticas
```

---

### **3. Endpoints de Procesamiento**

#### **3.1. POST `/api/luzsombra/procesar-imagen`**
**¿Qué hace?**
- Procesa una imagen (algoritmo de luz/sombra)
- Guarda en BD
- Usado desde el frontend web

**Request:**
```http
POST https://ws-agromigiva.agricolaandrea.com/api/luzsombra/procesar-imagen
X-API-Key: tu-api-key
Content-Type: multipart/form-data

file=[archivo]
plantId=00805221
fundo=VAL
sector=2260
lote=1022
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

**Stored Procedure necesario:**
```sql
EXEC image.sp_InsertAnalisisImagen
    @plantID = '00805221',
    @fotoPath = '...',
    @fundo = 'VAL',
    @sector = 2260,
    @lote = 1022
```

---

#### **3.2. POST `/api/luzsombra/test-model`**
**¿Qué hace?**
- Procesa una imagen pero NO la guarda en BD
- Solo para testing

**Request:**
```http
POST https://ws-agromigiva.agricolaandrea.com/api/luzsombra/test-model
X-API-Key: tu-api-key
Content-Type: multipart/form-data

file=[archivo]
```

**Response:**
```json
{
  "success": true,
  "porcentajeLuz": 45.5,
  "tipoUmbral": "Normal"
}
```

**Nota:** Este endpoint NO necesita Stored Procedure (no guarda en BD).

---

### **4. Endpoints de Alertas**

#### **4.1. POST `/api/luzsombra/alertas/consolidar`**
**Ya documentado** - Consolidar alertas por fundo

---

#### **4.2. GET `/api/luzsombra/alertas/consolidar`**
**¿Qué hace?**
- Obtiene estadísticas de alertas pendientes por fundo

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/alertas/consolidar
X-API-Key: tu-api-key
```

**Response:**
```json
{
  "success": true,
  "totalAlertas": 10,
  "totalFundos": 2,
  "estadisticasPorFundo": [
    {
      "fundoID": "VAL",
      "totalAlertas": 5
    },
    {
      "fundoID": "CAL",
      "totalAlertas": 5
    }
  ]
}
```

---

#### **4.3. POST `/api/luzsombra/alertas/enviar`**
**¿Qué hace?**
- Envía mensajes pendientes vía Resend
- Procesa mensajes en estado "Pendiente"

**Request:**
```http
POST https://ws-agromigiva.agricolaandrea.com/api/luzsombra/alertas/enviar
X-API-Key: tu-api-key
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

**Nota:** Este endpoint puede llamar a Resend API directamente desde el Web Service, o puede solo actualizar el estado en BD y dejar que Azure procese el envío.

---

### **5. Endpoints de Autenticación (AgriQR)**

#### **5.1. POST `/api/luzsombra/auth/login`**
**¿Qué hace?**
- Autentica dispositivos (AgriQR)
- Valida deviceId y apiKey
- Retorna JWT token

**Request:**
```http
POST https://ws-agromigiva.agricolaandrea.com/api/luzsombra/auth/login
Content-Type: application/json

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

**Stored Procedure necesario:**
```sql
EXEC image.sp_ValidateDevice
    @deviceID = 'device-test-001',
    @apiKey = 'test-api-key-12345'
```

---

### **6. Endpoints de Health Check**

#### **6.1. GET `/api/luzsombra/health`**
**¿Qué hace?**
- Verifica que el Web Service está funcionando
- Verifica conexión a SQL Server

**Request:**
```http
GET https://ws-agromigiva.agricolaandrea.com/api/luzsombra/health
X-API-Key: tu-api-key
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

## 📊 Resumen de Endpoints

| Endpoint | Método | Tipo | Descripción |
|----------|--------|------|-------------|
| `/api/luzsombra/photos/upload` | POST | Escritura | Subir foto desde AgriQR |
| `/api/luzsombra/field-data` | GET | Lectura | Obtener datos jerárquicos para filtros |
| `/api/luzsombra/historial` | GET | Lectura | Obtener historial con paginación |
| `/api/luzsombra/tabla-consolidada` | GET | Lectura | Obtener tabla consolidada |
| `/api/luzsombra/tabla-consolidada/detalle` | GET | Lectura | Detalle histórico de lote |
| `/api/luzsombra/tabla-consolidada/detalle-planta` | GET | Lectura | Detalle de plantas por fecha |
| `/api/luzsombra/imagen/:id` | GET | Lectura | Obtener imagen por ID |
| `/api/luzsombra/estadisticas` | GET | Lectura | Obtener estadísticas |
| `/api/luzsombra/procesar-imagen` | POST | Escritura | Procesar imagen desde web |
| `/api/luzsombra/test-model` | POST | Lectura | Test modelo (no guarda) |
| `/api/luzsombra/alertas/consolidar` | POST | Escritura | Consolidar alertas |
| `/api/luzsombra/alertas/consolidar` | GET | Lectura | Estadísticas de alertas |
| `/api/luzsombra/alertas/enviar` | POST | Escritura | Enviar mensajes |
| `/api/luzsombra/auth/login` | POST | Lectura | Autenticar dispositivo |
| `/api/luzsombra/health` | GET | Lectura | Health check |

**Total: 15 endpoints**

---

## 🔧 Stored Procedures Necesarios

1. `image.sp_InsertAnalisisImagen` - Insertar análisis de imagen
2. `image.sp_GetFieldData` - Obtener datos jerárquicos
3. `image.sp_GetHistorial` - Obtener historial
4. `image.sp_GetTablaConsolidada` - Obtener tabla consolidada
5. `image.sp_GetDetalleHistorial` - Detalle histórico
6. `image.sp_GetDetallePlanta` - Detalle de plantas
7. `image.sp_GetImagen` - Obtener imagen por ID
8. `image.sp_GetEstadisticas` - Obtener estadísticas
9. `image.sp_ConsolidarAlertasPorFundo` - Consolidar alertas
10. `image.sp_ValidateDevice` - Validar dispositivo

---

## 📝 Modificaciones en Tu Código

### **Crear Cliente Web Service Unificado**

**Archivo:** `backend/src/services/webServiceClient.ts`

```typescript
import axios from 'axios';

class WebServiceClient {
  private baseURL: string;
  private apiKey: string;

  constructor() {
    this.baseURL = process.env.WEBSERVICE_URL || 'https://ws-agromigiva.agricolaandrea.com';
    this.apiKey = process.env.WEBSERVICE_API_KEY || '';
  }

  private getAuthHeaders() {
    return {
      'X-API-Key': this.apiKey, // O 'Authorization': `Bearer ${this.apiKey}`
    };
  }

  // Todos los métodos aquí...
  async getFieldData() { /* ... */ }
  async getHistorial(params) { /* ... */ }
  async getConsolidatedTable(params) { /* ... */ }
  // etc.
}

export const webServiceClient = new WebServiceClient();
```

### **Modificar Routes para Usar Web Service**

**Antes:**
```typescript
// backend/src/routes/field-data.ts
router.get('/', async (req, res) => {
  const data = await sqlServerService.getFieldData();
  res.json(data);
});
```

**Después:**
```typescript
// backend/src/routes/field-data.ts
router.get('/', async (req, res) => {
  const data = await webServiceClient.getFieldData();
  res.json(data);
});
```

---

## ✅ Checklist para IT

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

### **Stored Procedures a Crear:**
- [ ] `image.sp_InsertAnalisisImagen`
- [ ] `image.sp_GetFieldData`
- [ ] `image.sp_GetHistorial`
- [ ] `image.sp_GetTablaConsolidada`
- [ ] `image.sp_GetDetalleHistorial`
- [ ] `image.sp_GetDetallePlanta`
- [ ] `image.sp_GetImagen`
- [ ] `image.sp_GetEstadisticas`
- [ ] `image.sp_ConsolidarAlertasPorFundo`
- [ ] `image.sp_ValidateDevice`

---

**Fecha de creación**: 2024-11-17


