# Headers Actualizados - Información de Trazabilidad

## 📋 Template de Header Estándar

Cada script debe tener este header con información de trazabilidad:

```sql
-- =====================================================
-- SCRIPT: [Nombre del Script]
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: [schema]
-- Propósito: [Descripción breve]
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas/Vistas/SPs/Triggers/Índices/Constraints:
--      - [lista de objetos]
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas/Vistas/SPs modificados:
--      - [lista de objetos]
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: [tablas/objetos que deben existir]
-- 
-- ORDEN DE EJECUCIÓN:
--   [número] de [total] - [descripción]
-- 
-- USADO POR:
--   - [descripción de dónde se usa]
-- 
-- =====================================================
```

## 📝 Headers por Archivo

### ✅ `create_table_analisis_imagen_agromigiva.sql` - ACTUALIZADO

**Objetos Creados:**
- Schema: `image`
- Tabla: `image.Analisis_Imagen`
- Índices: 3 (IDX_Analisis_Imagen_FECHA_01, IDX_Analisis_Imagen_LOT_01, IDX_Analisis_Imagen_UBICACION_01)
- Constraints: PK, FK, UQ

**Dependencias:**
- `GROWER.LOT`
- `MAST.USERS`

**Orden:** 1 (primero, crea schema)

---

### 📝 `create_table_umbral_luz.sql` - PENDIENTE

**Objetos Creados:**
- Tabla: `image.UmbralLuz`
- Índices: 3 (IDX_UmbralLuz_VariedadID, IDX_UmbralLuz_Tipo, IDX_UmbralLuz_Rango)
- Constraints: PK, FK, CK

**Dependencias:**
- `GROWER.VARIETY`
- `MAST.USERS`
- Schema `image` (debe existir)

**Orden:** 2 (después de crear schema image)

**Usado por:**
- `image.sp_CalcularLoteEvaluacion` (para clasificar umbrales)
- `image.Alerta` (para generar alertas)

---

### 📝 `create_table_lote_evaluacion.sql` - PENDIENTE

**Objetos Creados:**
- Tabla: `image.LoteEvaluacion`
- Índices: 3 (IDX_LoteEvaluacion_LotID, IDX_LoteEvaluacion_TipoUmbral, IDX_LoteEvaluacion_FechaActualizacion)
- Constraints: PK, FK, UQ, CK

**Dependencias:**
- `GROWER.LOT`
- `GROWER.VARIETY`
- `image.UmbralLuz`
- Schema `image`

**Orden:** 3 (después de UmbralLuz)

**Usado por:**
- `getConsolidatedTable` (query consolidada)
- `image.Alerta` (para generar alertas)
- `image.sp_CalcularLoteEvaluacion` (actualiza esta tabla)

---

### 📝 `create_table_alerta.sql` - PENDIENTE

**Objetos Creados:**
- Tabla: `image.Alerta`
- Índices: 3 (IDX_Alerta_LotID, IDX_Alerta_Estado, IDX_Alerta_TipoUmbral)
- Constraints: PK, FK, CK

**Dependencias:**
- `GROWER.LOT`
- `image.LoteEvaluacion`
- `image.UmbralLuz`
- `GROWER.VARIETY`
- `MAST.USERS`
- `image.Mensaje` (FK circular, se crea después)

**Orden:** 4 (después de LoteEvaluacion y UmbralLuz)

**Usado por:**
- Backend: generación de alertas
- `image.Mensaje` (FK)

---

### 📝 `create_table_mensaje.sql` - PENDIENTE

**Objetos Creados:**
- Tabla: `image.Mensaje`
- Índices: 3 (IDX_Mensaje_AlertaID, IDX_Mensaje_Estado, IDX_Mensaje_ResendMessageID)
- Constraints: PK, FK, CK

**Dependencias:**
- `image.Alerta`
- Schema `image`

**Orden:** 5 (después de Alerta)

**Usado por:**
- Backend: envío de emails vía Resend
- `image.Alerta` (FK desde Alerta.mensajeID)

---

### 📝 `create_view_cianamida_fenologia.sql` - PENDIENTE

**Objetos Creados:**
- Vista: `dbo.vwc_CianamidaFenologia`

**Dependencias:**
- `GROWER.LOT`
- `PPP.PROYECCION`
- `PPP.PROYECCIONDETALLEFITOSANIDAD`
- `PPP.PROGRAMACIONFITOSANIDADDETALLE`
- `PPP.PROGRAMACION`
- `PROPER.PROGRAMACIONFITOSANIDADMOVIMIENTOS`
- `PROPER.PARAMETROS`
- `PPP.ESTADOFENOLOGICO`
- `evalAgri.evaluacionPlagaEnfermedad`
- `evalAgri.EstadoFenologico`

**Orden:** Puede ejecutarse en cualquier momento (no depende de schema image)

**Usado por:**
- `getConsolidatedTable` (query consolidada)

---

### 📝 `create_sp_calcular_lote_evaluacion.sql` - PENDIENTE

**Objetos Creados:**
- Stored Procedure: `image.sp_CalcularLoteEvaluacion`

**Dependencias:**
- `image.Analisis_Imagen`
- `image.LoteEvaluacion`
- `image.UmbralLuz`
- `GROWER.PLANTATION`
- `GROWER.VARIETY`

**Orden:** 6 (después de todas las tablas)

**Usado por:**
- Backend: `saveProcessingResult` (después de insertar análisis)
- Job SQL diario (reconciliación)

---

### 📝 `add_original_image_column.sql` - PENDIENTE

**Objetos Modificados:**
- Tabla: `image.Analisis_Imagen` (agrega columna `originalImageUrl`)

**Dependencias:**
- `image.Analisis_Imagen` (debe existir)

**Orden:** Después de crear `image.Analisis_Imagen`

**Usado por:**
- Backend: `saveProcessingResult` (guarda imagen original)

---

## 🔄 Checklist de Actualización

- [x] `create_table_analisis_imagen_agromigiva.sql`
- [ ] `create_table_umbral_luz.sql`
- [ ] `create_table_lote_evaluacion.sql`
- [ ] `create_table_alerta.sql`
- [ ] `create_table_mensaje.sql`
- [ ] `create_view_cianamida_fenologia.sql`
- [ ] `create_sp_calcular_lote_evaluacion.sql`
- [ ] `add_original_image_column.sql`
- [ ] `delete_analisis_imagen.sql`
- [ ] `verificar_schemas_tablas_existentes.sql`
- [ ] `ejemplo_uso_umbrales_luz.sql`
- [ ] `test_view_cianamida_fenologia.sql`

