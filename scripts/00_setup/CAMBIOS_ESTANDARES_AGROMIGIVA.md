# 📋 Cambios Aplicados para Cumplir Estándares AgroMigiva

## 🔄 Resumen de Cambios

Este documento detalla todos los cambios aplicados a las tablas para cumplir con los estándares de codificación de AgroMigiva.

---

## ✅ Cambios Aplicados

### 1. **Nomenclatura de Tablas**
- **Antes:** PascalCase (ej: `AnalisisImagen`, `Dispositivo`)
- **Después:** LowerCamelCase (ej: `analisisImagen`, `dispositivo`)

**Tablas afectadas:**
- ✅ `AnalisisImagen` → `analisisImagen`
- ✅ `UmbralLuz` → `umbralLuz`
- ✅ `LoteEvaluacion` → `loteEvaluacion`
- ✅ `Alerta` → `alerta`
- ✅ `Mensaje` → `mensaje`
- ✅ `Contacto` → `contacto`
- ✅ `Dispositivo` → `dispositivo`
- ✅ `MensajeAlerta` → `mensajeAlerta`
- ✅ `UsuarioWeb` → `usuarioWeb`
- ✅ `IntentoLogin` → `intentoLogin`

---

### 2. **Nomenclatura de Índices**
- **Antes:** `IX_[nombreTabla]_[columnas]` o `IDX_[nombreTabla]_[columnas]` (sin correlativo)
- **Después:** `IDX_[nombreTabla]_[columnas]_XXX` (con correlativo de 3 dígitos)

**Ejemplos:**
- `IX_Dispositivo_ApiKeyHash` → `IDX_dispositivo_apiKeyHash_001`
- `IX_IntentoLogin_DeviceId_Fecha` → `IDX_intentoLogin_deviceId_fechaIntento_001`
- `IDX_Alerta_LotID` → `IDX_alerta_lotID_estado_statusID_001`

---

### 3. **Nomenclatura de Constraints**
- **Antes:** Sin correlativo (ej: `UQ_Dispositivo_DeviceId`, `FK_Alerta_LOT`)
- **Después:** Con correlativo `_XX` (ej: `UQ_dispositivo_deviceId_01`, `FK_alerta_lot_01`)

**Tipos de constraints corregidos:**
- **Primary Keys:** `PK_[nombreTabla]` (sin cambios, ya correcto)
- **Foreign Keys:** `FK_[nombreTabla]_[tablaReferencia]_XX` (ej: `FK_alerta_lot_01`)
- **Unique:** `UQ_[nombreTabla]_[columna]_XX` (ej: `UQ_dispositivo_deviceId_01`)
- **Check:** `CK_[nombreTabla]_[regla]_XX` (ej: `CK_alerta_estadoValido_01`)
- **Default:** `DF_[nombreTabla]_[columna]_XX` (si aplica)

---

### 4. **Extended Properties**
- **Antes:** `MS_Description` para todo
- **Después:** 
  - Tabla: `MS_TablaDescription`
  - Columnas: `MS_Col1Desc`, `MS_Col2Desc`, `MS_Col3Desc`, etc. (numeradas secuencialmente)

---

## 📝 Estado de Corrección

| Tabla | LowerCamelCase | Índices IDX_ | Constraints _XX | Extended Props | Estado |
|-------|----------------|--------------|-----------------|----------------|--------|
| analisisImagen | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| umbralLuz | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| loteEvaluacion | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| alerta | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| mensaje | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| contacto | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| dispositivo | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| mensajeAlerta | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| usuarioWeb | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |
| intentoLogin | ✅ | ✅ | ✅ | ✅ | **✅ Completado** |

---

## 🔧 Archivos Modificados

### Scripts de Tablas (todos actualizados):
- ✅ `scripts/01_tables/01_evalImagen.analisisImagen.sql`
- ✅ `scripts/01_tables/02_evalImagen.umbralLuz.sql`
- ✅ `scripts/01_tables/03_evalImagen.loteEvaluacion.sql`
- ✅ `scripts/01_tables/04_evalImagen.alerta.sql`
- ✅ `scripts/01_tables/05_evalImagen.mensaje.sql`
- ✅ `scripts/01_tables/06_evalImagen.contacto.sql`
- ✅ `scripts/01_tables/07_evalImagen.dispositivo.sql`
- ✅ `scripts/01_tables/08_evalImagen.mensajeAlerta.sql`
- ✅ `scripts/01_tables/09_evalImagen.usuarioWeb.sql`
- ✅ `scripts/01_tables/10_evalImagen.intentoLogin.sql`

### Scripts Maestros y Referencias (todos actualizados):
- ✅ `scripts/00_setup/00_SCRIPT_MAESTRO_RECREAR_TABLAS.sql` (nombres de tablas actualizados)
- ✅ `scripts/03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql` (referencias actualizadas)
- ✅ `scripts/03_stored_procedures/02_sp_InsertAnalisisImagen.sql` (referencias actualizadas)
- ✅ `scripts/03_stored_procedures/04_sp_ValidateDeviceAndUpdateAccess.sql` (referencias actualizadas)
- ✅ `scripts/03_stored_procedures/05_sp_GetDeviceForAuth.sql` (referencias actualizadas)
- ✅ `scripts/03_stored_procedures/06_sp_RegistrarIntentoLogin.sql` (referencias actualizadas)
- ✅ `scripts/03_stored_procedures/07_sp_CheckRateLimit.sql` (referencias actualizadas)
- ✅ `scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql` (referencias actualizadas)

---

## ✅ Backend Actualizado

**Estado:** ✅ **COMPLETADO**

Todas las referencias en el código TypeScript del backend han sido actualizadas:
- ✅ `backend/src/services/sqlServerService.ts`
- ✅ `backend/src/services/alertService.ts`
- ✅ `backend/src/services/deviceService.ts`
- ✅ `backend/src/services/umbralService.ts`
- ✅ `backend/src/services/contactService.ts`
- ✅ `backend/src/services/userService.ts`
- ✅ `backend/src/services/resendService.ts`
- ✅ `backend/src/routes/auth.ts`
- ✅ `backend/src/routes/dispositivos.ts`
- ✅ `backend/src/routes/notificaciones.ts`
- ✅ `backend/src/routes/photoUpload.ts`
- ✅ `backend/src/routes/imagen.ts`
- ✅ `backend/src/routes/tabla-consolidada-detalle-planta.ts`
- ✅ `backend/src/routes/test-db.ts`

---

## ⚠️ Próximos Pasos

2. **Testing:** Después de aplicar los cambios en la base de datos, probar que todo funcione correctamente:
   - Verificar que los SPs funcionen correctamente
   - Verificar que los triggers se ejecuten correctamente
   - Verificar que el backend pueda conectarse y realizar operaciones

3. **Migración de Datos:** Si hay datos existentes, será necesario:
   - Hacer backup de las tablas antiguas
   - Crear las nuevas tablas con los nombres corregidos
   - Migrar los datos de las tablas antiguas a las nuevas
   - Eliminar las tablas antiguas

---

## 📅 Fecha de Última Actualización

2025-01-XX - **Todas las tablas corregidas según estándares AgroMigiva**

---

## ✅ Resumen Final

**Total de tablas corregidas:** 10/10 (100%)
**Total de stored procedures actualizados:** 7/7 (100%)
**Total de triggers actualizados:** 1/1 (100%)
**Script maestro actualizado:** ✅
**Backend TypeScript actualizado:** ✅ (14 archivos)

**Estado general:** ✅ **COMPLETADO**
