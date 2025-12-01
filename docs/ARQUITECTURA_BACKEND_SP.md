# Arquitectura Backend - Uso de Stored Procedures

## 🎯 Estrategia de Acceso a Base de Datos

**Azure está en la misma nube que SQL Server**, por lo que:
- ✅ Acceso directo a SQL Server sin VPN
- ✅ Sin Web Service intermedio necesario
- ✅ **Stored Procedures** para todas las operaciones de BD

---

## 🔒 Seguridad mediante Stored Procedures

Todas las operaciones de base de datos deben pasar por **Stored Procedures** para:
- Proteger la estructura de la BD
- Centralizar lógica de negocio
- Facilitar auditoría y mantenimiento
- Controlar permisos a nivel de SP

---

## 📋 Stored Procedures Existentes

### **1. `evalImagen.sp_CalcularLoteEvaluacion`**

**Propósito:** Calcular estadísticas agregadas por lote

**Uso actual:**
```typescript
await query(`EXEC evalImagen.sp_CalcularLoteEvaluacion @LotID = @lotID`, { lotID });
```

**Ubicación:** `scripts/03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql`

---

## 🔄 Migración a Stored Procedures

### **Endpoints que deben migrar a SP:**

**Lectura (SELECT):**
1. `GET /api/field-data` → `evalImagen.sp_GetFieldData`
2. `GET /api/historial` → `evalImagen.sp_GetHistorial`
3. `GET /api/tabla-consolidada` → `evalImagen.sp_GetTablaConsolidada`
4. `GET /api/tabla-consolidada/detalle` → `evalImagen.sp_GetDetalleHistorial`
5. `GET /api/tabla-consolidada/detalle-planta` → `evalImagen.sp_GetDetallePlanta`
6. `GET /api/imagen/:id` → `evalImagen.sp_GetImagen`
7. `GET /api/estadisticas` → `evalImagen.sp_GetEstadisticas`

**Escritura (INSERT/UPDATE):**
1. `POST /api/procesar-imagen` → `evalImagen.sp_InsertAnalisisImagen`
2. `POST /api/photo-upload` → `evalImagen.sp_InsertAnalisisImagen`
3. `POST /api/auth/login` → `evalImagen.sp_ValidateDevice`

**Alertas:**
1. `POST /api/alertas/consolidar` → `evalImagen.sp_ConsolidarAlertasPorFundo`
2. `GET /api/alertas` → `evalImagen.sp_GetAlertas`

---

## 📝 Crear Nuevos Stored Procedures

### **Nomenclatura según Reglas Migiva:**

**Formato:** `usp_[Prefijo]_[Acción/Tabla]`

**Ejemplos:**
- `usp_EvalImagen_GetFieldData` - Obtener datos jerárquicos
- `usp_EvalImagen_GetHistorial` - Obtener historial
- `usp_EvalImagen_InsertAnalisisImagen` - Insertar análisis
- `usp_EvalImagen_ValidateDevice` - Validar dispositivo

**O mantener formato actual:**
- `evalImagen.sp_GetFieldData`
- `evalImagen.sp_GetHistorial`
- `evalImagen.sp_InsertAnalisisImagen`

---

## 💻 Uso en Backend

### **Ejemplo: Llamar Stored Procedure**

```typescript
import { executeProcedure } from '../lib/db';

// Llamar SP con parámetros
const result = await executeProcedure('evalImagen.sp_GetFieldData', {
  empresa: 'Agricola Andrea',
  fundo: 'Fundo 1'
});
```

### **Ejemplo: SP con OUTPUT**

```typescript
const result = await executeProcedure('evalImagen.sp_InsertAnalisisImagen', {
  lotID: 123,
  filename: 'imagen.jpg',
  porcentajeLuz: 20.5,
  porcentajeSombra: 79.5
});

const analisisID = result[0]?.analisisID;
```

---

## ✅ Ventajas de Stored Procedures

1. **Seguridad:** No expone estructura de tablas
2. **Performance:** Optimización en servidor SQL
3. **Mantenibilidad:** Lógica centralizada
4. **Auditoría:** Fácil tracking de operaciones
5. **Permisos:** Control granular por SP

---

## 📚 Referencias

- **Scripts SP:** `scripts/03_stored_procedures/`
- **Reglas Migiva:** Ver `Reglas de Tablas.txt`
- **Ejemplo actual:** `backend/src/services/sqlServerService.ts` (línea 399)

---

**Última actualización:** 2025-11-21

