# 📱 Gestión de Dispositivos AgriQR en SQL Server

## 📋 Resumen

Las **apiKeys** de los dispositivos Android ahora se guardan en SQL Server en la tabla `image.Dispositivo`, en lugar de estar en variables de entorno. Esto permite mejor gestión, auditoría y control de dispositivos.

---

## 🗄️ Estructura de la Tabla

### Tabla: `image.Dispositivo`

```sql
CREATE TABLE image.Dispositivo (
    dispositivoID INT IDENTITY(1,1) PRIMARY KEY,
    deviceId NVARCHAR(100) NOT NULL UNIQUE,      -- ID único del dispositivo
    apiKey NVARCHAR(255) NOT NULL UNIQUE,        -- API Key para autenticación
    nombreDispositivo NVARCHAR(200) NULL,        -- Nombre descriptivo
    modeloDispositivo NVARCHAR(100) NULL,        -- Modelo del dispositivo
    versionApp NVARCHAR(50) NULL,                 -- Versión de la app
    activo BIT NOT NULL DEFAULT 1,               -- Si está activo
    fechaRegistro DATETIME DEFAULT GETDATE(),
    ultimoAcceso DATETIME NULL,                  -- Último login exitoso
    statusID INT DEFAULT 1,
    -- ... campos de auditoría
);
```

---

## 🔄 Flujo de Autenticación

### 1. **Login del Dispositivo**

```
App Android (AgriQR)
  ↓
POST /api/auth/login
{
  "deviceId": "device-001",
  "apiKey": "agriqr-device-001-secret-key-2024"
}
  ↓
Backend consulta SQL Server:
SELECT * FROM image.Dispositivo
WHERE deviceId = 'device-001'
  AND apiKey = 'agriqr-device-001-secret-key-2024'
  AND statusID = 1
  ↓
Si encuentra el dispositivo:
  ✅ Verifica que activo = 1
  ✅ Actualiza ultimoAcceso = GETDATE()
  ✅ Genera JWT token
  ✅ Retorna token al dispositivo
```

### 2. **Validación en el Código**

```typescript
// backend/src/routes/auth.ts

// 1. Validar credenciales contra BD
const device = await validateDeviceCredentials(deviceId, apiKey);

// 2. Verificar que esté activo
if (!device.activo) {
  return res.status(403).json({ error: 'Device is disabled' });
}

// 3. Actualizar último acceso
await updateLastAccess(device.dispositivoID);

// 4. Generar JWT token
const token = jwt.sign({ deviceId }, jwtSecret, { expiresIn: '24h' });
```

---

## 📝 Gestión de Dispositivos

### Insertar Nuevo Dispositivo

```sql
INSERT INTO image.Dispositivo (
    deviceId,
    apiKey,
    nombreDispositivo,
    modeloDispositivo,
    versionApp,
    activo
) VALUES (
    'device-004',
    'agriqr-device-004-secret-key-2024',  -- ⚠️ Generar clave única y segura
    'Tablet Campo 4',
    'Samsung Galaxy Tab A8',
    '1.0.0',
    1
);
```

### Deshabilitar Dispositivo

```sql
-- Deshabilitar dispositivo (no podrá hacer login)
UPDATE image.Dispositivo
SET activo = 0,
    fechaModificacion = GETDATE()
WHERE deviceId = 'device-001';
```

### Habilitar Dispositivo

```sql
-- Habilitar dispositivo
UPDATE image.Dispositivo
SET activo = 1,
    fechaModificacion = GETDATE()
WHERE deviceId = 'device-001';
```

### Cambiar API Key

```sql
-- Si se compromete una apiKey, cambiarla
UPDATE image.Dispositivo
SET apiKey = 'nueva-api-key-segura-2024',
    fechaModificacion = GETDATE()
WHERE deviceId = 'device-001';
```

### Ver Dispositivos Activos

```sql
SELECT 
    dispositivoID,
    deviceId,
    nombreDispositivo,
    modeloDispositivo,
    versionApp,
    activo,
    fechaRegistro,
    ultimoAcceso
FROM image.Dispositivo
WHERE statusID = 1
ORDER BY ultimoAcceso DESC;
```

---

## 🔐 Generar API Keys Seguras

### Opción 1: Usar UUID

```bash
# Generar UUID v4 (32 caracteres hexadecimales)
uuidgen
# Ejemplo: 550e8400-e29b-41d4-a716-446655440000
```

### Opción 2: Usar OpenSSL

```bash
# Generar 32 bytes aleatorios en hexadecimal (64 caracteres)
openssl rand -hex 32
# Ejemplo: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

### Opción 3: Usar Generador Online

- https://www.uuidgenerator.net/
- https://randomkeygen.com/

### Formato Recomendado

```
agriqr-{deviceId}-{random-hex}-{year}
Ejemplo: agriqr-device-001-a1b2c3d4e5f6-2024
```

---

## ✅ Ventajas de Usar SQL Server

### Antes (Variables de Entorno)
- ❌ Cambiar apiKeys requiere modificar código y redeploy
- ❌ No hay auditoría de accesos
- ❌ No se puede deshabilitar un dispositivo sin redeploy
- ❌ No hay historial de logins

### Ahora (SQL Server)
- ✅ Agregar/eliminar dispositivos sin cambiar código
- ✅ Auditoría completa (último acceso, fecha registro)
- ✅ Deshabilitar dispositivos instantáneamente
- ✅ Cambiar apiKeys sin redeploy
- ✅ Ver qué dispositivos están activos
- ✅ Tracking de versiones de app

---

## 🚀 Pasos para Implementar

### 1. Ejecutar Scripts SQL

```sql
-- 1. Crear tabla
-- Ejecutar: scripts/01_tables/07_image.Dispositivo.sql

-- 2. Insertar dispositivos de ejemplo
-- Ejecutar: scripts/04_modifications/04_insert_dispositivos_ejemplo.sql
```

### 2. Configurar Dispositivos en Producción

```sql
-- Para cada dispositivo Android, insertar registro:
INSERT INTO image.Dispositivo (
    deviceId,
    apiKey,  -- ⚠️ Generar clave única y segura
    nombreDispositivo,
    activo
) VALUES (
    'device-001',
    'agriqr-device-001-a1b2c3d4e5f6-2024',
    'Tablet Campo 1',
    1
);
```

### 3. Configurar en App Android

En la app Android (AgriQR), configurar:

```kotlin
class AppConfig {
    companion object {
        const val DEVICE_ID = "device-001"  // Debe coincidir con BD
        const val API_KEY = "agriqr-device-001-a1b2c3d4e5f6-2024"  // Debe coincidir con BD
    }
}
```

### 4. Probar Login

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "device-001",
    "apiKey": "agriqr-device-001-a1b2c3d4e5f6-2024"
  }'
```

---

## 📊 Consultas Útiles

### Ver Todos los Dispositivos

```sql
SELECT 
    dispositivoID,
    deviceId,
    nombreDispositivo,
    modeloDispositivo,
    versionApp,
    activo,
    fechaRegistro,
    ultimoAcceso,
    CASE 
        WHEN ultimoAcceso IS NULL THEN 'Nunca'
        WHEN DATEDIFF(DAY, ultimoAcceso, GETDATE()) = 0 THEN 'Hoy'
        WHEN DATEDIFF(DAY, ultimoAcceso, GETDATE()) = 1 THEN 'Ayer'
        ELSE CAST(DATEDIFF(DAY, ultimoAcceso, GETDATE()) AS VARCHAR) + ' días'
    END AS tiempoDesdeUltimoAcceso
FROM image.Dispositivo
WHERE statusID = 1
ORDER BY ultimoAcceso DESC;
```

### Dispositivos Inactivos (nunca han hecho login)

```sql
SELECT *
FROM image.Dispositivo
WHERE statusID = 1
  AND ultimoAcceso IS NULL
ORDER BY fechaRegistro DESC;
```

### Dispositivos Deshabilitados

```sql
SELECT *
FROM image.Dispositivo
WHERE statusID = 1
  AND activo = 0
ORDER BY fechaModificacion DESC;
```

---

## ⚠️ Seguridad

1. **API Keys Únicas**: Cada dispositivo debe tener una apiKey única
2. **No Compartir**: Nunca compartir apiKeys entre dispositivos
3. **Rotación**: Cambiar apiKeys periódicamente o si se sospecha compromiso
4. **Deshabilitar**: Si un dispositivo se pierde, deshabilitarlo inmediatamente
5. **Auditoría**: Revisar `ultimoAcceso` para detectar actividad sospechosa

---

## 🔄 Migración desde Variables de Entorno

Si ya tenías dispositivos configurados con `VALID_API_KEYS` en `.env`:

1. **Extraer apiKeys del .env**:
   ```bash
   VALID_API_KEYS=device1-key,device2-key,device3-key
   ```

2. **Insertar en SQL Server**:
   ```sql
   INSERT INTO image.Dispositivo (deviceId, apiKey, nombreDispositivo, activo)
   VALUES 
       ('device-001', 'device1-key', 'Dispositivo 1', 1),
       ('device-002', 'device2-key', 'Dispositivo 2', 1),
       ('device-003', 'device3-key', 'Dispositivo 3', 1);
   ```

3. **Eliminar VALID_API_KEYS del .env** (ya no es necesario)

---

## 📝 Resumen

- ✅ **apiKeys en SQL Server**: Mejor gestión y control
- ✅ **Auditoría**: Tracking de accesos y actividad
- ✅ **Flexibilidad**: Agregar/eliminar dispositivos sin redeploy
- ✅ **Seguridad**: Deshabilitar dispositivos instantáneamente
- ✅ **Escalabilidad**: Fácil agregar nuevos dispositivos

