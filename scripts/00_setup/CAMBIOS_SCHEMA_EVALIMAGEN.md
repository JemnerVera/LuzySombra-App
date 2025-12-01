# 📋 Cambios: Schema `image` → `evalImagen`

## ✅ Cambios Realizados

1. **env.example**: Actualizado con nuevas credenciales
   - Usuario: `ucser_luzsombra_desa`
   - Password: `D3s4S3r12`

2. **scripts/01_tables/01_image.Analisis_Imagen.sql**: 
   - Schema: `image` → `evalImagen`
   - Tabla: `Analisis_Imagen` → `AnalisisImagen` (sin guión bajo)
   - Constraints: Ajustados según nomenclatura Migiva

## 🔄 Cambios Pendientes

### Scripts SQL a Actualizar (búsqueda/reemplazo):

**Buscar:** `image.` → **Reemplazar:** `evalImagen.`
**Buscar:** `'image'` → **Reemplazar:** `'evalImagen'`
**Buscar:** `image` (schema) → **Reemplazar:** `evalImagen`

**Tablas a renombrar (quitar guiones bajos):**
- `Analisis_Imagen` → `AnalisisImagen` ✅
- `UmbralLuz` → (sin cambios)
- `LoteEvaluacion` → (sin cambios)
- `Alerta` → (sin cambios)
- `Mensaje` → (sin cambios)
- `Contacto` → (sin cambios)
- `Dispositivo` → (sin cambios)

**Stored Procedures:**
- `image.sp_CalcularLoteEvaluacion` → `evalImagen.sp_CalcularLoteEvaluacion`

**Views:**
- `image.vwc_CianamidaFenologia` → `evalImagen.vwc_CianamidaFenologia`

**Triggers:**
- `trg_LoteEvaluacion_Alerta` → (sin cambios, pero schema cambia)

### Código Backend a Actualizar:

**Archivos TypeScript:**
- `backend/src/services/sqlServerService.ts` - Todas las queries
- `backend/src/services/resendService.ts` - Queries a Mensaje
- `backend/src/services/alertService.ts` - Queries a Alerta, LoteEvaluacion, Contacto
- `backend/src/routes/*.ts` - Todas las rutas que usan queries SQL

**Búsqueda/Reemplazo en código:**
- `image.` → `evalImagen.`
- `image.Analisis_Imagen` → `evalImagen.AnalisisImagen`

## 📝 Nomenclatura según Reglas Migiva

### Constraints:
- **PK:** `PK_[nombreTabla]` (sin guiones bajos)
- **FK:** `FK_[tabla]_[tablaRef]_XX`
- **UQ:** `UQ_[tabla]_[columna]_XX`
- **CK:** `CK_[tabla]_[regla]_XX`
- **DF:** `DF_[tabla]_[columna]_XX`

### Índices:
- `IDX_[tabla]_[columnas]_XXX`

### Stored Procedures:
- `usp_[Prefijo]_[Acción/Tabla]` (ins, upd, del, sel)
- O mantener `sp_` si ya está establecido

## ⚠️ Notas Importantes

1. **Usuario SQL:** 
   - DESA: `ucser_luzsombra_desa`
   - PROD: `ucser_luzSombra` (sin _desa)

2. **Schema:** `evalImagen` (CamelCase, sin guiones bajos)

3. **Tablas:** CamelCase sin guiones bajos (excepto si ya están establecidas)

4. **Ejecutar scripts en orden:**
   - Primero crear schema `evalImagen`
   - Luego crear tablas en orden de dependencias

