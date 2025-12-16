# 🗑️ Archivos a Depurar - Análisis

## ✅ Archivos que SÍ se usan (MANTENER)

### Backend:
- ✅ `backend/src/routes/imagen.ts` - Se usa en frontend (`/api/imagen`)
- ✅ `backend/src/routes/test-db.ts` - Útil para debugging (mantener por ahora)

### Scripts:
- ✅ `scripts/08_demo/` - Scripts de demo útiles para pruebas
- ✅ `scripts/07_utilities/generar_usuario_admin.ts` - Script TypeScript completo
- ✅ `scripts/07_utilities/03_verificar_schemas_tablas.sql` - Útil para verificación

---

## ❌ Archivos REDUNDANTES (ELIMINAR)

### 1. Scripts duplicados:
- ❌ `scripts/07_utilities/generar_hash_password.js`
  - **Razón:** Redundante con `generar_usuario_admin.ts` que es más completo
  - **Acción:** Eliminar

### 2. Archivos de prueba/dataset:
- ❌ `dataset/` (carpeta completa)
  - **Razón:** Datos de prueba que ya no se usan
  - **Contenido:** `anotaciones/foto1.json`, `anotaciones/foto2.json`, `imagenes/foto1.jpg`, `imagenes/foto2.jpg`
  - **Acción:** Eliminar carpeta completa

### 3. Documentación obsoleta:
- ❌ `AgroMigiva_Estándares-de-Codificación-de-Bases-de.txt`
  - **Razón:** Documento de estándares, ya existe `docs/ESTANDARES_CODIFICACION_BD_MIGIVA.md`
  - **Acción:** Eliminar (o mover a `docs/` si contiene información única)

---

## ⚠️ Archivos a REVISAR (Decisión del usuario)

### 1. `dbschema/ddl/` (carpeta completa)
- **Propósito:** Scripts DDL simplificados para importar en DbSchema
- **Pregunta:** ¿Se usa DbSchema para visualizar el esquema?
- **Opciones:**
  - **MANTENER** si se usa DbSchema regularmente
  - **ELIMINAR** si no se usa DbSchema (los scripts completos están en `scripts/01_tables/`)

### 2. `backend/src/routes/test-db.ts`
- **Propósito:** Ruta de prueba para verificar conexión a BD
- **Pregunta:** ¿Se necesita en producción?
- **Opciones:**
  - **MANTENER** si es útil para debugging
  - **ELIMINAR** si solo es para desarrollo local

### 3. `scripts/06_tests/01_test_vwc_CianamidaFenologia.sql`
- **Propósito:** Test de la vista
- **Pregunta:** ¿Se ejecuta regularmente?
- **Opciones:**
  - **MANTENER** si es útil para validar la vista
  - **ELIMINAR** si ya no se usa

---

## 📊 Resumen

### Archivos a eliminar definitivamente:
1. `scripts/07_utilities/generar_hash_password.js`
2. `dataset/` (carpeta completa)

### Archivos a revisar:
1. `dbschema/ddl/` (carpeta completa)
2. `backend/src/routes/test-db.ts`
3. `scripts/06_tests/01_test_vwc_CianamidaFenologia.sql`
4. `AgroMigiva_Estándares-de-Codificación-de-Bases-de.txt`

---

## ✅ Archivos Eliminados

1. ✅ `scripts/07_utilities/generar_hash_password.js` - **ELIMINADO** (redundante)
2. ✅ `dataset/` (carpeta completa) - **ELIMINADO** (datos de prueba)
3. ✅ `dbschema/` (carpeta completa) - **ELIMINADO** (no se usa DbSchema)
4. ✅ `scripts/06_tests/` (carpeta completa) - **ELIMINADO** (tests no usados)

---

## ✅ Archivos Eliminados de `docs/`

1. ✅ `docs/FLUJO_COMPLETO_ALERTAS_MENSAJES.md` - **ELIMINADO** (obsoleto, reemplazado por `FLUJO_ALERTAS.md`)
2. ✅ `docs/MIGRACION_STORED_PROCEDURES.md` - **ELIMINADO** (migración ya completada)
3. ✅ `docs/EXPLICACION_MEJORAS_PENDIENTES.md` - **ELIMINADO** (mejoras ya implementadas)

---

## ⚠️ Archivos Restantes a Revisar

### 1. `backend/scripts/generar_hash_password.js`
- **Ubicación:** `backend/scripts/generar_hash_password.js`
- **Estado:** Diferente del eliminado en `scripts/07_utilities/`
- **Pregunta:** ¿Se usa este script? ¿Es necesario mantenerlo?

### 2. `backend/src/routes/test-db.ts`
- **Propósito:** Ruta de prueba para verificar conexión a BD
- **Pregunta:** ¿Se necesita en producción o solo para desarrollo?
- **Recomendación:** Mantener si es útil para debugging, eliminar si solo es para desarrollo local

### 3. `AgroMigiva_Estándares-de-Codificación-de-Bases-de.txt`
- **Propósito:** Documento de estándares
- **Pregunta:** ¿Contiene información única o está obsoleto?
- **Nota:** Ya existe `docs/ESTANDARES_CODIFICACION_BD_MIGIVA.md`

