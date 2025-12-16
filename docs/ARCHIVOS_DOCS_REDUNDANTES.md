# 🗑️ Análisis de Documentación Redundante en `docs/`

## ❌ Archivos OBSOLETOS (Eliminar)

### 1. `FLUJO_COMPLETO_ALERTAS_MENSAJES.md`
- **Razón:** Versión antigua del flujo de alertas
- **Evidencia:**
  - Usa nombres antiguos: `evalImagen.Analisis_Imagen`, `sp_CalcularLoteEvaluacion`, `trg_LoteEvaluacion_Alerta`
  - Los nombres actuales son: `evalImagen.analisisImagen`, `usp_evalImagen_calcularLoteEvaluacion`, `trg_loteEvaluacionAlerta_AF_IU`
- **Reemplazo:** `FLUJO_ALERTAS.md` (más actualizado y detallado)
- **Acción:** ✅ ELIMINAR

### 2. `MIGRACION_STORED_PROCEDURES.md`
- **Razón:** La migración ya se completó
- **Evidencia:**
  - Dice "Estado actual: Solo `evalImagen.sp_CalcularLoteEvaluacion` está implementado como SP"
  - Pero ya existen 7 SPs en `scripts/03_stored_procedures/`:
    - `01_sp_calcularLoteEvaluacion.sql`
    - `02_sp_insertAnalisisImagen.sql`
    - `03_sp_getFieldData.sql`
    - `04_sp_validateDeviceAndUpdateAccess.sql`
    - `05_sp_getDeviceForAuth.sql`
    - `06_sp_registrarIntentoLogin.sql`
    - `07_sp_checkRateLimit.sql`
- **Acción:** ✅ ELIMINAR

### 3. `EXPLICACION_MEJORAS_PENDIENTES.md`
- **Razón:** Las mejoras ya se implementaron
- **Evidencia:**
  - Habla de "Autenticación de Usuarios Web" como pendiente
  - Pero ya existe:
    - `frontend/src/components/UsuariosManagement.tsx`
    - `backend/src/services/userService.ts`
    - `backend/src/routes/usuarios.ts`
    - Tabla `evalImagen.usuarioWeb`
- **Reemplazo:** `MEJORAS_RECOMENDADAS.md` (más actualizado, menciona que muchas mejoras ya están implementadas)
- **Acción:** ✅ ELIMINAR

---

## ⚠️ Archivos a REVISAR (Posiblemente redundantes)

### 4. `USO_MAST_USERS.md`
- **Razón:** Podría estar obsoleto si ya no se usa `MAST.USERS`
- **Evidencia:**
  - No se encontraron referencias a `MAST.USERS` en el código backend actual
  - El sistema ahora usa `evalImagen.usuarioWeb` para usuarios web
  - `MAST.USERS` solo se menciona en el documento pero no en el código
- **Pregunta:** ¿Se sigue usando `MAST.USERS` para auditoría?
- **Acción:** ⚠️ REVISAR - Si no se usa, eliminar

### 5. `EXPLICACION_TABLAS_ALERTAS.md`
- **Razón:** Podría ser redundante con otros documentos
- **Evidencia:**
  - `SCHEMA_EVALIMAGEN.md` ya explica las tablas del sistema
  - `FLUJO_ALERTAS.md` también explica cómo funcionan las tablas en el flujo
- **Pregunta:** ¿Tiene información única que no está en otros documentos?
- **Acción:** ⚠️ REVISAR - Comparar contenido con `SCHEMA_EVALIMAGEN.md`

### 6. `ESTRUCTURA_BD_PRODUCCION.md` vs `SCHEMA_EVALIMAGEN.md`
- **Razón:** Ambos explican la estructura de la BD
- **Evidencia:**
  - `ESTRUCTURA_BD_PRODUCCION.md`: Explica tablas externas (`GROWER.*`, `MAST.*`)
  - `SCHEMA_EVALIMAGEN.md`: Explica el schema `evalImagen` completo
- **Pregunta:** ¿Son complementarios o redundantes?
- **Acción:** ⚠️ REVISAR - Verificar si hay solapamiento significativo

---

## ✅ Archivos ÚTILES (Mantener)

- ✅ `FLUJO_ALERTAS.md` - Flujo actualizado y detallado
- ✅ `MEJORAS_RECOMENDADAS.md` - Lista de mejoras (actualizado)
- ✅ `SCHEMA_EVALIMAGEN.md` - Documentación completa del schema
- ✅ `INTEGRACION_BURRO.md` - Documentación de integración
- ✅ `CONFIGURACION_RESEND.md` - Configuración de email
- ✅ `ARQUITECTURA_BACKEND_SP.md` - Arquitectura del backend
- ✅ `ESTANDARES_CODIFICACION_BD_MIGIVA.md` - Estándares de codificación
- ✅ Otros archivos de configuración y guías

---

## 📊 Resumen

### Archivos a eliminar definitivamente:
1. ✅ `FLUJO_COMPLETO_ALERTAS_MENSAJES.md` - Obsoleto
2. ✅ `MIGRACION_STORED_PROCEDURES.md` - Migración completada
3. ✅ `EXPLICACION_MEJORAS_PENDIENTES.md` - Mejoras ya implementadas

### Archivos a revisar:
1. ⚠️ `USO_MAST_USERS.md` - Verificar si se usa `MAST.USERS`
2. ⚠️ `EXPLICACION_TABLAS_ALERTAS.md` - Verificar redundancia
3. ⚠️ `ESTRUCTURA_BD_PRODUCCION.md` - Verificar solapamiento con `SCHEMA_EVALIMAGEN.md`

