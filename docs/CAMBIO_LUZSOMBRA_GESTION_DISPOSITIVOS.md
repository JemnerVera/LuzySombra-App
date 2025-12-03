# 🔧 Cambios Necesarios en Luz&Sombra - Gestión Robusta de Dispositivos

## 📋 Contexto

Este documento detalla los cambios necesarios en el backend **Luz&Sombra** para soportar:
1. ✅ **Sistema de QR Code + Activación Temporal** - Para configuración simple de dispositivos
2. ✅ **Gestión de Operarios** - Vinculación dispositivo-operario para revocación rápida
3. ✅ **Mejoras de seguridad ya implementadas** - Rate limiting y API keys hasheadas (verificar)

---

## 🎯 Objetivo

Permitir que los administradores puedan:
- Generar QR Codes para configurar dispositivos fácilmente
- Revocar acceso de dispositivos instantáneamente (si se pierde celular o operario renuncia)
- Rastrear qué operario tiene qué dispositivo
- Reasignar dispositivos rápidamente

---

## 📋 Cambios Requeridos

### **Fase 1: Base de Datos - Campos Adicionales**

#### **1.1. Agregar campos a tabla `evalImagen.Dispositivo`**

```sql
-- Script: scripts/01_tables/07_evalImagen.Dispositivo.sql
-- Los campos de activación ya están incluidos en la creación de la tabla

-- Campos incluidos:
-- activationCode NVARCHAR(255) NULL,
-- activationCodeExpires DATETIME NULL,
-- operarioNombre NVARCHAR(255) NULL,
    fechaAsignacion DATETIME NULL,
    fechaRevocacion DATETIME NULL;

-- Índice para búsqueda rápida por código de activación
CREATE INDEX IX_Dispositivo_ActivationCode 
ON evalImagen.Dispositivo(activationCode) 
WHERE activationCode IS NOT NULL;
```

**Campos nuevos:**
- `activationCode`: Código temporal para activación (NULL cuando no está activo)
- `activationCodeExpires`: Fecha/hora de expiración del código
- `operarioNombre`: Nombre del operario asignado
- `fechaAsignacion`: Cuándo se asignó al operario
- `fechaRevocacion`: Cuándo se revocó el acceso

---

### **Fase 2: Backend - Endpoints Nuevos**

#### **2.1. Endpoint: Generar QR Code**

**Archivo:** `backend/src/routes/dispositivos.ts`

**Endpoint:**
```
POST /api/dispositivos/:id/generate-qr
```

**Requisitos:**
- Requiere permiso: `dispositivos:read` o `dispositivos:write`
- Recibe: `dispositivoID` en params
- Opcionalmente: `operarioNombre` en body para asignar operario

**Funcionalidad:**
1. Verifica que el dispositivo existe y está activo
2. Genera código de activación temporal (32 caracteres aleatorios)
3. Establece expiración (24 horas desde ahora)
4. Si se proporciona `operarioNombre`, asigna al operario
5. Genera QR Code con:
   - `deviceId`
   - `activationCode`
   - `baseUrl` (desde variable de entorno)
6. Retorna QR Code (imagen base64 o URL) y datos

**Código TypeScript:**

```typescript
import QRCode from 'qrcode';
import crypto from 'crypto';

/**
 * POST /api/dispositivos/:id/generate-qr
 * Genera un QR Code con código de activación temporal
 */
router.post('/:id/generate-qr', requirePermission('dispositivos:read'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const { operarioNombre } = req.body;
    const usuarioCreaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    // Obtener dispositivo
    const device = await deviceService.getDeviceById(dispositivoID);
    
    if (!device) {
      return res.status(404).json({
        success: false,
        error: 'Dispositivo no encontrado'
      });
    }

    // Verificar que esté activo
    if (!device.activo) {
      return res.status(400).json({
        success: false,
        error: 'Dispositivo está desactivado'
      });
    }

    // Generar código de activación temporal (32 caracteres)
    const activationCode = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 horas

    // Actualizar dispositivo con código de activación
    await query(`
      UPDATE evalImagen.Dispositivo
      SET activationCode = @activationCode,
          activationCodeExpires = @expiresAt,
          ${operarioNombre ? 'operarioNombre = @operarioNombre,' : ''}
          ${operarioNombre ? 'fechaAsignacion = GETDATE(),' : ''}
          usuarioModificaID = @usuarioModificaID,
          fechaModificacion = GETDATE()
      WHERE dispositivoID = @dispositivoID
        AND statusID = 1
    `, {
      dispositivoID,
      activationCode,
      expiresAt,
      ...(operarioNombre && { operarioNombre }),
      usuarioModificaID: usuarioCreaID
    });

    // Crear objeto con datos para QR
    const baseUrl = process.env.BACKEND_BASE_URL || 'https://tu-backend.azurewebsites.net/api/';
    const qrData = {
      type: 'agriqr-setup',
      version: '1.0',
      baseUrl: baseUrl,
      deviceId: device.deviceId,
      activationCode: activationCode,
      expiresAt: expiresAt.toISOString()
    };

    // Generar QR Code como imagen base64
    const qrCodeBase64 = await QRCode.toDataURL(JSON.stringify(qrData), {
      errorCorrectionLevel: 'M',
      type: 'image/png',
      width: 512
    });

    res.json({
      success: true,
      qrCodeUrl: qrCodeBase64,  // Data URL: "data:image/png;base64,..."
      qrData: qrData,            // Datos para debugging
      expiresAt: expiresAt,
      operarioNombre: operarioNombre || null,
      message: 'QR Code generado exitosamente. Válido por 24 horas.'
    });

  } catch (error) {
    console.error('❌ Error generando QR Code:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});
```

**Dependencia necesaria:**
```bash
npm install qrcode
npm install --save-dev @types/qrcode
```

---

#### **2.2. Endpoint: Activar Dispositivo con Código**

**Archivo:** `backend/src/routes/auth.ts`

**Endpoint:**
```
POST /api/auth/activate
```

**Funcionalidad:**
1. Recibe `deviceId` y `activationCode`
2. Valida que el código existe y no ha expirado
3. Valida que el dispositivo está activo
4. Genera JWT token directamente (sin necesidad de API key)
5. Invalida el código de activación (solo se usa una vez)
6. Actualiza `ultimoAcceso`

**Código TypeScript:**

```typescript
/**
 * POST /api/auth/activate
 * Activa un dispositivo usando código de activación del QR
 */
router.post('/activate', async (req: Request, res: Response) => {
  try {
    const { deviceId, activationCode } = req.body;

    if (!deviceId || !activationCode) {
      return res.status(400).json({
        error: 'deviceId and activationCode are required'
      });
    }

    // Validar código de activación
    const device = await query(`
      SELECT 
        dispositivoID,
        deviceId,
        activationCode,
        activationCodeExpires,
        activo,
        statusID
      FROM evalImagen.Dispositivo
      WHERE deviceId = @deviceId
        AND activationCode = @activationCode
        AND statusID = 1
    `, { deviceId, activationCode });

    if (!device || device.length === 0) {
      return res.status(401).json({
        error: 'Invalid activation code or device ID'
      });
    }

    const deviceInfo = device[0];

    // Verificar que el código no haya expirado
    const now = new Date();
    const expiresAt = new Date(deviceInfo.activationCodeExpires);
    
    if (now > expiresAt) {
      return res.status(401).json({
        error: 'Activation code expired'
      });
    }

    // Verificar que el dispositivo esté activo
    if (!deviceInfo.activo) {
      return res.status(403).json({
        error: 'Device is disabled'
      });
    }

    // Generar JWT token directamente
    const token = signToken(
      { deviceId },
      { expiresIn: '24h' }
    );

    // Invalidar código de activación (solo se usa una vez)
    await query(`
      UPDATE evalImagen.Dispositivo
      SET activationCode = NULL,
          activationCodeExpires = NULL,
          ultimoAcceso = GETDATE()
      WHERE dispositivoID = @dispositivoID
    `, { dispositivoID: deviceInfo.dispositivoID });

    res.json({
      success: true,
      token: token,
      expiresIn: 86400, // 24 horas en segundos
      deviceId: deviceId,
      message: 'Device activated successfully'
    });

  } catch (error) {
    console.error('❌ Error in activation:', error);
    res.status(500).json({
      error: 'Activation error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});
```

---

#### **2.3. Endpoint: Revocar Acceso de Dispositivo**

**Archivo:** `backend/src/routes/dispositivos.ts`

**Endpoint:**
```
PUT /api/dispositivos/:id/revoke
```

**Funcionalidad:**
1. Desactiva el dispositivo (`activo = 0`)
2. Establece `fechaRevocacion`
3. Limpia código de activación si existe

**Código TypeScript:**

```typescript
/**
 * PUT /api/dispositivos/:id/revoke
 * Revoca acceso de un dispositivo (desactiva)
 */
router.put('/:id/revoke', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    // Desactivar dispositivo y revocar acceso
    await query(`
      UPDATE evalImagen.Dispositivo
      SET activo = 0,
          fechaRevocacion = GETDATE(),
          activationCode = NULL,
          activationCodeExpires = NULL,
          usuarioModificaID = @usuarioModificaID,
          fechaModificacion = GETDATE()
      WHERE dispositivoID = @dispositivoID
        AND statusID = 1
    `, { dispositivoID, usuarioModificaID });

    res.json({
      success: true,
      message: 'Acceso revocado exitosamente. El dispositivo ya no podrá autenticarse.'
    });

  } catch (error) {
    console.error('❌ Error revocando acceso:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});
```

---

#### **2.4. Endpoint: Reasignar Dispositivo**

**Archivo:** `backend/src/routes/dispositivos.ts`

**Endpoint:**
```
PUT /api/dispositivos/:id/reassign
```

**Body:**
```json
{
  "operarioNombre": "Juan Pérez"
}
```

**Funcionalidad:**
1. Asigna nuevo operario
2. Actualiza `fechaAsignacion`
3. Limpia `fechaRevocacion` (si había sido revocado)
4. Activa el dispositivo (por si estaba desactivado)

**Código TypeScript:**

```typescript
/**
 * PUT /api/dispositivos/:id/reassign
 * Reasigna dispositivo a otro operario
 */
router.put('/:id/reassign', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const { operarioNombre } = req.body;
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    if (!operarioNombre || operarioNombre.trim().isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'operarioNombre es requerido'
      });
    }

    // Reasignar dispositivo
    await query(`
      UPDATE evalImagen.Dispositivo
      SET operarioNombre = @operarioNombre,
          fechaAsignacion = GETDATE(),
          fechaRevocacion = NULL,
          activo = 1,
          activationCode = NULL,
          activationCodeExpires = NULL,
          usuarioModificaID = @usuarioModificaID,
          fechaModificacion = GETDATE()
      WHERE dispositivoID = @dispositivoID
        AND statusID = 1
    `, { dispositivoID, operarioNombre: operarioNombre.trim(), usuarioModificaID });

    res.json({
      success: true,
      message: `Dispositivo reasignado a ${operarioNombre}. Genera un nuevo QR Code para configurar.`
    });

  } catch (error) {
    console.error('❌ Error reasignando dispositivo:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});
```

---

### **Fase 3: Servicios - Funciones Auxiliares**

#### **3.1. Actualizar `deviceService.ts`**

Agregar métodos auxiliares:

```typescript
// En: backend/src/services/deviceService.ts

/**
 * Obtiene dispositivo por código de activación
 */
async getDeviceByActivationCode(activationCode: string): Promise<{
  dispositivoID: number;
  deviceId: string;
  activo: boolean;
  activationCodeExpires: Date | null;
} | null> {
  try {
    const result = await query(`
      SELECT 
        dispositivoID,
        deviceId,
        activo,
        activationCodeExpires
      FROM evalImagen.Dispositivo
      WHERE activationCode = @activationCode
        AND statusID = 1
    `, { activationCode });

    return result.length > 0 ? result[0] : null;
  } catch (error) {
    console.error('❌ Error obteniendo dispositivo por código:', error);
    return null;
  }
}

/**
 * Limpia código de activación (después de usarse)
 */
async clearActivationCode(dispositivoID: number): Promise<boolean> {
  try {
    await query(`
      UPDATE evalImagen.Dispositivo
      SET activationCode = NULL,
          activationCodeExpires = NULL
      WHERE dispositivoID = @dispositivoID
    `, { dispositivoID });

    return true;
  } catch (error) {
    console.error('❌ Error limpiando código de activación:', error);
    return false;
  }
}
```

---

### **Fase 4: Variables de Entorno**

Agregar a `.env`:

```env
# URL base del backend (para QR Codes)
BACKEND_BASE_URL=https://tu-backend.azurewebsites.net/api/
# O en desarrollo:
# BACKEND_BASE_URL=http://localhost:3001/api/
```

---

## 📋 Resumen de Cambios

### **Base de Datos:**
- [ ] Script SQL para agregar campos a `evalImagen.Dispositivo`
- [ ] Índice para búsqueda por `activationCode`

### **Backend:**
- [ ] Instalar dependencia `qrcode`
- [ ] Endpoint `POST /api/dispositivos/:id/generate-qr`
- [ ] Endpoint `POST /api/auth/activate`
- [ ] Endpoint `PUT /api/dispositivos/:id/revoke`
- [ ] Endpoint `PUT /api/dispositivos/:id/reassign`
- [ ] Actualizar `deviceService.ts` con métodos auxiliares
- [ ] Variable de entorno `BACKEND_BASE_URL`

### **Verificar (Ya deberían estar implementados):**
- [ ] Rate limiting en `/api/auth/login`
- [ ] API keys hasheadas con bcrypt
- [ ] Logging de intentos de login

---

## 🧪 Testing

### **1. Generar QR Code:**
```bash
POST http://localhost:3001/api/dispositivos/1/generate-qr
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "operarioNombre": "Juan Pérez"
}
```

**Respuesta esperada:**
```json
{
  "success": true,
  "qrCodeUrl": "data:image/png;base64,...",
  "qrData": {
    "type": "agriqr-setup",
    "version": "1.0",
    "baseUrl": "http://localhost:3001/api/",
    "deviceId": "device-001",
    "activationCode": "abc123...",
    "expiresAt": "2025-01-16T14:30:00.000Z"
  },
  "expiresAt": "2025-01-16T14:30:00.000Z",
  "operarioNombre": "Juan Pérez"
}
```

### **2. Activar Dispositivo:**
```bash
POST http://localhost:3001/api/auth/activate
Content-Type: application/json

{
  "deviceId": "device-001",
  "activationCode": "abc123..."
}
```

**Respuesta esperada:**
```json
{
  "success": true,
  "token": "eyJhbGc...",
  "expiresIn": 86400,
  "deviceId": "device-001",
  "message": "Device activated successfully"
}
```

### **3. Revocar Acceso:**
```bash
PUT http://localhost:3001/api/dispositivos/1/revoke
Authorization: Bearer {admin_token}
```

### **4. Reasignar Dispositivo:**
```bash
PUT http://localhost:3001/api/dispositivos/1/reassign
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "operarioNombre": "Pedro García"
}
```

---

## 📝 Notas Importantes

1. **Códigos de activación expiran en 24 horas** - Por seguridad
2. **Códigos de activación solo se usan una vez** - Se invalidan después de la activación
3. **Revocación es instantánea** - El dispositivo no podrá autenticarse en el próximo request
4. **QR Codes contienen URL base** - Asegúrate de configurar `BACKEND_BASE_URL` correctamente

---

## 🚀 Orden de Implementación

1. ✅ **Fase 1**: Base de datos (agregar campos)
2. ✅ **Fase 2**: Backend endpoints (generar QR, activar, revocar, reasignar)
3. ✅ **Fase 3**: Servicios auxiliares
4. ✅ **Fase 4**: Variables de entorno
5. ✅ **Testing**: Probar todos los endpoints

---

**¿Preguntas? Consulta con el equipo de desarrollo.**

