# 📋 Verificación de Cumplimiento con Estándares AgroMigiva

## 🔍 Resumen Ejecutivo

**Fecha de verificación:** 2025-01-XX  
**Estándar de referencia:** `AgroMigiva_Estándares-de-Codificación-de-Bases-de.txt`

### Estado General: ⚠️ **REQUIERE AJUSTES**

La mayoría de los objetos cumplen parcialmente con los estándares, pero hay varios puntos que deben corregirse.

---

## ❌ Problemas Encontrados

### 1. **Nomenclatura de Tablas** ⚠️

**Estándar:** LowerCamelCase (ej: `inspeccionCosechaUvaSupervisor`)  
**Actual:** PascalCase (ej: `AnalisisImagen`, `Dispositivo`)

**Tablas afectadas:**
- `evalImagen.AnalisisImagen` → Debería ser `evalImagen.analisisImagen`
- `evalImagen.Dispositivo` → Debería ser `evalImagen.dispositivo`
- `evalImagen.UmbralLuz` → Debería ser `evalImagen.umbralLuz`
- `evalImagen.LoteEvaluacion` → Debería ser `evalImagen.loteEvaluacion`
- `evalImagen.Alerta` → Debería ser `evalImagen.alerta`
- `evalImagen.Mensaje` → Debería ser `evalImagen.mensaje`
- `evalImagen.Contacto` → Debería ser `evalImagen.contacto`
- `evalImagen.MensajeAlerta` → Debería ser `evalImagen.mensajeAlerta`
- `evalImagen.UsuarioWeb` → Debería ser `evalImagen.usuarioWeb`
- `evalImagen.IntentoLogin` → Debería ser `evalImagen.intentoLogin`

**⚠️ NOTA:** Este cambio es **MUY INVASIVO** y afectaría todo el código backend. Se recomienda **NO cambiar** a menos que el DBA lo requiera explícitamente.

---

### 2. **Nomenclatura de Índices** ❌

**Estándar:** `IDX_[nombreTabla]_[nombreColumnas]_XXX`  
**Actual:** `IX_[nombreTabla]_[nombreColumnas]` (falta `IDX_` y correlativo `_XXX`)

**Ejemplos encontrados:**
- `IX_Dispositivo_ApiKeyHash` → Debería ser `IDX_Dispositivo_apiKeyHash_001`
- `IX_Dispositivo_DeviceId` → Debería ser `IDX_Dispositivo_deviceId_001`
- `IX_Dispositivo_ActivationCode` → Debería ser `IDX_Dispositivo_activationCode_001`
- `IX_IntentoLogin_DeviceId_Fecha` → Debería ser `IDX_IntentoLogin_deviceId_fechaIntento_001`

**Archivos a corregir:**
- `scripts/01_tables/07_evalImagen.Dispositivo.sql`
- `scripts/01_tables/10_evalImagen.IntentoLogin.sql`
- Todos los demás scripts de tablas

---

### 3. **Nomenclatura de Constraints** ⚠️

**Estándar:** Debe incluir correlativo `_XX` al final

**Problemas encontrados:**

#### Unique Constraints:
- `UQ_Dispositivo_DeviceId` → Debería ser `UQ_Dispositivo_deviceId_01`
- `UQ_Contacto_Email` → Debería ser `UQ_Contacto_email_01`

#### Check Constraints:
- `CK_Dispositivo_DeviceId` → Debería ser `CK_Dispositivo_deviceIdMinLen_01`
- `CK_IntentoLogin_DeviceOrUser` → Debería ser `CK_IntentoLogin_deviceOrUser_01`
- `CK_Contacto_Tipo` → Debería ser `CK_Contacto_tipoValido_01`
- `CK_Contacto_Email` → Debería ser `CK_Contacto_emailValido_01`

**Archivos a corregir:**
- Todos los scripts de tablas

---

### 4. **Nomenclatura de Stored Procedures** ❌

**Estándar:** `usp_[PREFIJO]_[Descripcion]` o `usp_[PREFIJO]_[nombreTabla]_ins/upd/del/sel`  
**Actual:** `sp_[Descripcion]` (falta prefijo `usp_` y prefijo del módulo)

**Ejemplos encontrados:**
- `evalImagen.sp_CalcularLoteEvaluacion` → Debería ser `evalImagen.usp_evalImagen_calcularLoteEvaluacion`
- `evalImagen.sp_InsertAnalisisImagen` → Debería ser `evalImagen.usp_evalImagen_analisisImagen_ins`
- `evalImagen.sp_GetFieldData` → Debería ser `evalImagen.usp_evalImagen_obtenerDatosCampo`
- `evalImagen.sp_GetDeviceForAuth` → Debería ser `evalImagen.usp_evalImagen_obtenerDispositivoAuth`
- `evalImagen.sp_RegistrarIntentoLogin` → Debería ser `evalImagen.usp_evalImagen_registrarIntentoLogin`
- `evalImagen.sp_CheckRateLimit` → Debería ser `evalImagen.usp_evalImagen_verificarRateLimit`

**Archivos a corregir:**
- Todos los scripts en `scripts/03_stored_procedures/`

---

### 5. **Parámetros de Stored Procedures** ❌

**Estándar:** 
- `pIn_` para parámetros de entrada
- `pOu_` para parámetros de salida
- `pIO_` para parámetros de entrada/salida

**Actual:** No usan prefijos (ej: `@LotID`, `@PeriodoDias`)

**Ejemplo:**
```sql
-- Actual (INCORRECTO)
CREATE PROCEDURE evalImagen.sp_CalcularLoteEvaluacion
    @LotID INT = NULL,
    @PeriodoDias INT = 30

-- Debería ser (CORRECTO)
CREATE PROCEDURE evalImagen.usp_evalImagen_calcularLoteEvaluacion
    @pIn_lotID INT = NULL,
    @pIn_periodoDias INT = 30
```

**Archivos a corregir:**
- Todos los scripts en `scripts/03_stored_procedures/`

---

### 6. **Variables en Stored Procedures** ❌

**Estándar:** Prefijo `v` (ej: `vPackingNuevo`)  
**Actual:** No usan prefijo (ej: `@FechaInicio`)

**Ejemplo:**
```sql
-- Actual (INCORRECTO)
DECLARE @FechaInicio DATETIME;

-- Debería ser (CORRECTO)
DECLARE @vFechaInicio DATETIME;
```

**Archivos a corregir:**
- Todos los scripts en `scripts/03_stored_procedures/`

---

### 7. **Headers de Stored Procedures** ⚠️

**Estándar:** Debe incluir encabezado completo con:
- Cliente, Sistema, Módulo, Autor, Nombre Objeto, Fecha Creación
- Descripción, Input Parameters, Output Parameters
- Sección de Revisiones con formato `MOD_XXXX`

**Actual:** Headers simplificados sin formato estándar

**Archivos a corregir:**
- Todos los scripts en `scripts/03_stored_procedures/`

---

### 8. **Nomenclatura de Triggers** ⚠️

**Estándar:** `trg_[NNNN]_[Tipo]_[DML]`  
**Actual:** `trg_LoteEvaluacion_Alerta` (falta tipo y DML)

**Ejemplo:**
- `trg_LoteEvaluacion_Alerta` → Debería ser `trg_LoteEvaluacion_AF_IU` (AFTER INSERT, UPDATE)

**Archivos a corregir:**
- `scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql`

---

### 9. **Extended Properties** ⚠️

**Estándar:** 
- Tabla: `MS_TablaDescription`
- Columnas: `MS_Col1Desc`, `MS_Col2Desc`, etc.

**Actual:** Usa `MS_Description` para todo

**Ejemplo:**
```sql
-- Actual (INCORRECTO)
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Descripción...'

-- Debería ser (CORRECTO)
-- Para tabla:
EXEC sys.sp_addextendedproperty 
    @name = N'MS_TablaDescription', 
    @value = N'Descripción de la tabla'

-- Para columnas:
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col1Desc', 
    @value = N'Descripción columna 1'
```

**Archivos a corregir:**
- Todos los scripts de tablas

---

### 10. **SET Statements en Stored Procedures** ✅

**Estándar:** Debe incluir:
```sql
SET NOCOUNT ON;
SET ARITHABORT ON;
SET ANSI_NULLS ON;
SET XACT_ABORT ON;
```

**Estado:** ✅ **CUMPLE** - Los SPs ya incluyen `SET NOCOUNT ON` y algunos incluyen más.

---

### 11. **TRY-CATCH en Stored Procedures** ⚠️

**Estándar:** Debe usar TRY-CATCH para manejo de errores  
**Estado:** ⚠️ **PARCIAL** - Algunos SPs no tienen TRY-CATCH

**Archivos a revisar:**
- `scripts/03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql` (no tiene TRY-CATCH)

---

### 12. **Campos de Auditoría** ✅

**Estándar:** 
- `usuarioCreaID INT`
- `fechaCreacion date` (o `datetime`)
- `usuarioModificaID INT`
- `fechaModificacion date` (o `datetime`)

**Estado:** ✅ **CUMPLE** - Todas las tablas tienen estos campos.

---

## 📊 Resumen por Categoría

| Categoría | Estado | Prioridad |
|-----------|--------|-----------|
| Nomenclatura Tablas | ⚠️ PascalCase vs LowerCamelCase | Baja (muy invasivo) |
| Nomenclatura Índices | ❌ Falta `IDX_` y correlativo | **Alta** |
| Nomenclatura Constraints | ⚠️ Falta correlativo `_XX` | **Alta** |
| Nomenclatura SPs | ❌ Falta `usp_` y prefijo | **Alta** |
| Parámetros SPs | ❌ Falta prefijos `pIn_`, `pOu_` | **Alta** |
| Variables SPs | ❌ Falta prefijo `v` | Media |
| Headers SPs | ⚠️ Formato incompleto | Media |
| Nomenclatura Triggers | ⚠️ Falta tipo y DML | Media |
| Extended Properties | ⚠️ Formato incorrecto | Media |
| SET Statements | ✅ Cumple | - |
| TRY-CATCH | ⚠️ Parcial | Media |
| Campos Auditoría | ✅ Cumple | - |

---

## 🎯 Recomendaciones

### Prioridad Alta (Corregir antes de producción):
1. ✅ Corregir nomenclatura de **índices** (`IX_` → `IDX_` + correlativo)
2. ✅ Corregir nomenclatura de **constraints** (agregar correlativo `_XX`)
3. ✅ Corregir nomenclatura de **Stored Procedures** (`sp_` → `usp_evalImagen_`)
4. ✅ Corregir **parámetros** de SPs (agregar prefijos `pIn_`, `pOu_`)

### Prioridad Media (Mejoras recomendadas):
5. ⚠️ Corregir **variables** en SPs (agregar prefijo `v`)
6. ⚠️ Agregar **headers completos** en SPs según estándar
7. ⚠️ Corregir nomenclatura de **triggers** (agregar tipo y DML)
8. ⚠️ Corregir **extended properties** (usar `MS_TablaDescription` y `MS_ColXDesc`)
9. ⚠️ Agregar **TRY-CATCH** en SPs que no lo tienen

### Prioridad Baja (Solo si DBA lo requiere):
10. ⚠️ Cambiar nomenclatura de **tablas** a LowerCamelCase (muy invasivo, afecta todo el código)

---

## 📝 Notas Importantes

1. **Cambios en tablas:** Cambiar nombres de tablas afectaría TODO el código backend (TypeScript). Solo hacerlo si el DBA lo requiere explícitamente.

2. **Cambios en SPs:** Cambiar nombres de SPs afectaría el código backend, pero es más manejable que cambiar tablas.

3. **Compatibilidad:** Los cambios deben hacerse de forma coordinada entre SQL y backend para evitar errores.

4. **Testing:** Después de cada cambio, probar que el backend sigue funcionando correctamente.

---

## 🔄 Plan de Acción Sugerido

1. **Fase 1:** Corregir índices y constraints (solo SQL, no afecta backend)
2. **Fase 2:** Corregir SPs (requiere actualizar backend también)
3. **Fase 3:** Mejoras de formato (headers, extended properties, etc.)
4. **Fase 4:** (Opcional) Cambiar nomenclatura de tablas si DBA lo requiere

---

**Última actualización:** 2025-01-XX

