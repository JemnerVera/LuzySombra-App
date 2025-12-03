# 📋 Instrucciones para Actualizar Tablas

## 🔄 Tablas que DEBEN ELIMINARSE y RECREARSE

### 1. `evalImagen.dispositivo` ⚠️

**Razón:** Se agregaron nuevos campos y se modificaron constraints:
- ✅ Nuevos campos: `apiKeyHash`, `apiKeyPlain`, `activationCode`, `activationCodeExpires`, `operarioNombre`, `fechaAsignacion`, `fechaRevocacion`
- ✅ Se eliminó constraint UNIQUE de `apiKey`
- ✅ Nuevo índice: `IX_Dispositivo_ApiKeyHash`
- ✅ Nuevo índice: `IX_Dispositivo_ActivationCode`

**⚠️ IMPORTANTE:** Si esta tabla tiene datos, hacer backup antes de eliminar.

**Scripts a ejecutar:**
```sql
-- 1. Eliminar tabla (si existe)
DROP TABLE IF EXISTS evalImagen.dispositivo;
GO

-- 2. Recrear tabla con nuevos campos
-- Ejecutar: scripts/01_tables/07_evalImagen.Dispositivo.sql
```

---

## 🆕 Tablas NUEVAS (crear por primera vez)

### 1. `evalImagen.intentoLogin` ✨

**Razón:** Tabla nueva para rate limiting y auditoría de intentos de login.

**Script a ejecutar:**
```sql
-- Ejecutar: scripts/01_tables/10_evalImagen.IntentoLogin.sql
```

---

## ✅ Tablas que NO necesitan cambios

Las siguientes tablas **NO** fueron modificadas y **NO** necesitan recrearse:
- ✅ `evalImagen.analisisImagen`
- ✅ `evalImagen.umbralLuz`
- ✅ `evalImagen.loteEvaluacion`
- ✅ `evalImagen.alerta`
- ✅ `evalImagen.mensaje`
- ✅ `evalImagen.contacto`
- ✅ `evalImagen.mensajeAlerta`
- ✅ `evalImagen.usuarioWeb`

---

## 📝 Orden de Ejecución Recomendado

### Opción 1: Si `Dispositivo` NO tiene datos importantes

```sql
-- 1. Eliminar tabla Dispositivo
DROP TABLE IF EXISTS evalImagen.dispositivo;
GO

-- 2. Recrear Dispositivo con nuevos campos
-- Ejecutar: scripts/01_tables/07_evalImagen.Dispositivo.sql

-- 3. Crear nueva tabla IntentoLogin
-- Ejecutar: scripts/01_tables/10_evalImagen.IntentoLogin.sql
```

### Opción 2: Si `Dispositivo` TIENE datos importantes

```sql
-- 1. BACKUP de datos existentes
SELECT * INTO evalImagen.dispositivo_BACKUP 
FROM evalImagen.dispositivo;
GO

-- 2. Eliminar tabla Dispositivo
DROP TABLE evalImagen.dispositivo;
GO

-- 3. Recrear Dispositivo con nuevos campos
-- Ejecutar: scripts/01_tables/07_evalImagen.Dispositivo.sql

-- 4. Migrar datos del backup (si es necesario)
-- NOTA: Los campos nuevos (apiKeyHash, etc.) quedarán NULL
-- Deberás regenerar las API keys desde la UI

-- 5. Crear nueva tabla IntentoLogin
-- Ejecutar: scripts/01_tables/10_evalImagen.IntentoLogin.sql

-- 6. (Opcional) Eliminar backup después de verificar
-- DROP TABLE evalImagen.dispositivo_BACKUP;
```

---

## 🔍 Verificación

Después de ejecutar los scripts, verificar:

```sql
-- Verificar que Dispositivo tiene los nuevos campos
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'evalImagen' 
  AND TABLE_NAME = 'Dispositivo'
ORDER BY ORDINAL_POSITION;
GO

-- Verificar que IntentoLogin existe
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'evalImagen' 
  AND TABLE_NAME = 'IntentoLogin';
GO

-- Verificar índices de Dispositivo
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'evalImagen' 
  AND t.name = 'Dispositivo'
  AND i.name IS NOT NULL;
GO
```

---

## ⚠️ Notas Importantes

1. **API Keys:** Después de recrear `Dispositivo`, todos los dispositivos necesitarán regenerar su API key desde la UI de gestión de dispositivos.

2. **Índices:** Los scripts crean automáticamente los índices necesarios.

3. **Constraints:** El constraint `UQ_Dispositivo_ApiKey` fue eliminado porque ahora usamos `apiKeyHash` en lugar de `apiKey` para autenticación.

4. **Datos existentes:** Si tienes dispositivos registrados, considera hacer un backup antes de eliminar la tabla.

