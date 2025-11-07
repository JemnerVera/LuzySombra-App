# Explicación: ¿Cómo funciona `image.LoteEvaluacion`?

## 📊 Concepto Principal

**`image.LoteEvaluacion` es una tabla de AGREGACIÓN**: **UNA FILA POR LOTE**

No almacena evaluaciones individuales, sino **estadísticas agregadas** del último período (por defecto 30 días).

---

## 🎨 Diagrama Visual

```
┌─────────────────────────────────────────────────────────────┐
│           image.Analisis_Imagen (Tabla Individual)          │
│  ┌──────────┬─────────┬──────────────┬───────────────┐     │
│  │ analisis │ lotID   │ fechaCaptura │ porcentajeLuz │     │
│  ├──────────┼─────────┼──────────────┼───────────────┤     │
│  │ 1        │ 1003    │ 2025-01-01   │ 20.5          │     │
│  │ 2        │ 1003    │ 2025-01-05   │ 22.3          │     │
│  │ 3        │ 1003    │ 2025-01-10   │ 18.7          │     │
│  │ 4        │ 1003    │ 2025-01-15   │ 25.1          │     │
│  │ 5        │ 1003    │ 2025-01-20   │ 30.5          │     │
│  │ 6        │ 1004    │ 2025-01-02   │ 8.5           │     │
│  │ 7        │ 1004    │ 2025-01-10   │ 9.2           │     │
│  └──────────┴─────────┴──────────────┴───────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ sp_CalcularLoteEvaluacion()
                            │ (Agrega por lotID)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│        image.LoteEvaluacion (Tabla Agregada)                │
│  ┌──────────┬─────────┬───────────────────┬──────────────┐ │
│  │ loteEval │ lotID   │ porcentajeLuzProm │ tipoUmbral   │ │
│  ├──────────┼─────────┼───────────────────┼──────────────┤ │
│  │ 1        │ 1003    │ 21.58             │ Normal       │ │
│  │ 2        │ 1004    │ 8.85              │ CriticoRojo  │ │
│  └──────────┴─────────┴───────────────────┴──────────────┘ │
│                                                              │
│  ⚠️  UNA FILA POR LOTE (UNIQUE constraint en lotID)        │
└─────────────────────────────────────────────────────────────┘
```

**Proceso de Agregación**:
1. Se agrupan todas las evaluaciones por `lotID`
2. Se calculan estadísticas (promedio, min, max, total)
3. Se actualiza la fila existente o se crea una nueva

---

## 🔍 De dónde vienen los datos

Los datos se obtienen de `image.Analisis_Imagen`, que es la tabla que contiene las evaluaciones individuales:

```sql
image.Analisis_Imagen
├── analisisID (PK)
├── lotID (FK)
├── hilera
├── planta
├── porcentajeLuz
├── porcentajeSombra
├── fechaCaptura
└── ...
```

---

## 📈 Ejemplo Visual: Múltiples Fechas en el Mismo Lote

### Escenario: Lote 1003 tiene evaluaciones en diferentes fechas

**Tabla `image.Analisis_Imagen`** (evaluaciones individuales):
```
| analisisID | lotID | fechaCaptura | porcentajeLuz | porcentajeSombra |
|------------|-------|--------------|---------------|------------------|
| 1          | 1003  | 2025-01-01   | 20.5          | 79.5             |
| 2          | 1003  | 2025-01-05   | 22.3          | 77.7             |
| 3          | 1003  | 2025-01-10   | 18.7          | 81.3             |
| 4          | 1003  | 2025-01-15   | 25.1          | 74.9             |
| 5          | 1003  | 2025-01-20   | 30.5          | 69.5             |
| 6          | 1003  | 2025-01-25   | 12.3          | 87.7             |
```

### Al ejecutar `sp_CalcularLoteEvaluacion(@LotID = 1003, @PeriodoDias = 30)`

El stored procedure:

1. **Consulta** todas las evaluaciones del lote 1003 en los últimos 30 días:
   ```sql
   SELECT 
       lotID,
       AVG(porcentajeLuz) AS porcentajeLuzPromedio,
       MIN(porcentajeLuz) AS porcentajeLuzMin,
       MAX(porcentajeLuz) AS porcentajeLuzMax,
       AVG(porcentajeSombra) AS porcentajeSombraPromedio,
       MIN(porcentajeSombra) AS porcentajeSombraMin,
       MAX(porcentajeSombra) AS porcentajeSombraMax,
       COUNT(*) AS totalEvaluaciones,
       MAX(fechaCaptura) AS fechaUltimaEvaluacion,
       MIN(fechaCaptura) AS fechaPrimeraEvaluacion
   FROM image.Analisis_Imagen
   WHERE lotID = 1003
     AND fechaCaptura >= DATEADD(DAY, -30, GETDATE())
   GROUP BY lotID
   ```

2. **Resultado calculado**:
   ```
   porcentajeLuzPromedio = (20.5 + 22.3 + 18.7 + 25.1 + 30.5 + 12.3) / 6 = 21.58%
   porcentajeLuzMin = 12.3%
   porcentajeLuzMax = 30.5%
   porcentajeSombraPromedio = (79.5 + 77.7 + 81.3 + 74.9 + 69.5 + 87.7) / 6 = 78.43%
   porcentajeSombraMin = 69.5%
   porcentajeSombraMax = 87.7%
   totalEvaluaciones = 6
   fechaUltimaEvaluacion = 2025-01-25
   fechaPrimeraEvaluacion = 2025-01-01
   ```

3. **Compara con umbrales**:
   - Promedio: 21.58% → Umbral "Normal" (15% - 25%)

4. **INSERT o UPDATE en `image.LoteEvaluacion`**:
   ```
   | loteEvaluacionID | lotID | porcentajeLuzPromedio | porcentajeLuzMin | porcentajeLuzMax | tipoUmbralActual | totalEvaluaciones | periodoEvaluacionDias |
   |------------------|-------|----------------------|------------------|------------------|------------------|-------------------|----------------------|
   | 1                | 1003  | 21.58                | 12.3             | 30.5             | Normal           | 6                 | 30                   |
   ```

**IMPORTANTE**: Solo hay **UNA FILA** para el lote 1003, con estadísticas agregadas de todas sus evaluaciones.

---

## 🔄 ¿Qué pasa si se agregan nuevas evaluaciones?

### Escenario: Se agrega una nueva evaluación el 2025-01-30

**Nueva evaluación**:
```
| analisisID | lotID | fechaCaptura | porcentajeLuz | porcentajeSombra |
|------------|-------|--------------|---------------|------------------|
| 7          | 1003  | 2025-01-30   | 8.5           | 91.5             |
```

### Al ejecutar `sp_CalcularLoteEvaluacion(@LotID = 1003)`:

1. **Consulta** todas las evaluaciones de los últimos 30 días (ahora 7 evaluaciones):
   - Las 6 anteriores + la nueva = 7 evaluaciones

2. **Recalcula**:
   ```
   porcentajeLuzPromedio = (20.5 + 22.3 + 18.7 + 25.1 + 30.5 + 12.3 + 8.5) / 7 = 19.69%
   porcentajeLuzMin = 8.5%  ← CAMBIÓ (antes era 12.3%)
   porcentajeLuzMax = 30.5%
   totalEvaluaciones = 7
   fechaUltimaEvaluacion = 2025-01-30
   ```

3. **Compara con umbrales**:
   - Promedio: 19.69% → Umbral "Normal" (15% - 25%) ✅ (sigue siendo Normal)
   - **PERO** si el promedio bajara a 9%, cambiaría a "CriticoRojo" → se generaría una alerta

4. **UPDATE** en `image.LoteEvaluacion`:
   ```
   | loteEvaluacionID | lotID | porcentajeLuzPromedio | porcentajeLuzMin | tipoUmbralActual | totalEvaluaciones | fechaUltimaActualizacion |
   |------------------|-------|----------------------|------------------|------------------|-------------------|--------------------------|
   | 1                | 1003  | 19.69                | 8.5              | Normal           | 7                 | 2025-01-30 14:30:00      |
   ```

**La misma fila se actualiza**, no se crea una nueva.

---

## 📅 Manejo de Períodos de Evaluación

### Período por defecto: 30 días

El stored procedure **solo considera evaluaciones de los últimos 30 días**:

```sql
WHERE COALESCE(ai.fechaCaptura, ai.fechaCreacion) >= DATEADD(DAY, -30, GETDATE())
```

### Ejemplo: Evaluaciones antiguas

Si el lote 1003 tiene:
- 5 evaluaciones en enero 2025 (últimos 30 días) ✅ Se incluyen
- 10 evaluaciones en diciembre 2024 (hace más de 30 días) ❌ **NO se incluyen**

**Esto es por diseño**: Solo nos interesa el estado **reciente** del lote para alertas.

### Cambiar el período

Puedes calcular con un período diferente:

```sql
-- Últimos 60 días
EXEC image.sp_CalcularLoteEvaluacion @LotID = 1003, @PeriodoDias = 60;

-- Últimos 7 días
EXEC image.sp_CalcularLoteEvaluacion @LotID = 1003, @PeriodoDias = 7;
```

---

## 🔄 Flujo de Actualización

### Opción 1: Actualización Automática (Recomendada)

Cuando se guarda una nueva evaluación en el backend:

```typescript
// En src/app/api/procesar-imagen/route.ts
1. INSERT INTO image.Analisis_Imagen (...)  // Guardar evaluación individual
2. EXEC image.sp_CalcularLoteEvaluacion(@LotID = lotID)  // Recalcular estadísticas
3. Verificar si cambió tipoUmbralActual
4. Si cambió → Generar alerta
```

**Ventaja**: Siempre actualizado, detecta cambios inmediatamente.

### Opción 2: Actualización Periódica (Job SQL)

Job SQL Server que se ejecuta diariamente:

```sql
-- Ejecutar todas las noches a las 2 AM
EXEC image.sp_CalcularLoteEvaluacion;  -- Recalcula todos los lotes
```

**Ventaja**: No sobrecarga el sistema durante el día.

### Opción 3: Híbrido (Mejor)

- **Backend**: Actualiza el lote específico al guardar (rápido)
- **Job diario**: Recalcula todos los lotes (reconciliación)

---

## 🎯 Resumen

| Aspecto | Explicación |
|---------|-------------|
| **¿Cuántas filas por lote?** | **UNA sola fila por lote** (constraint `UQ_LoteEvaluacion_LOT`) |
| **¿De dónde vienen los datos?** | De `image.Analisis_Imagen` (agregación con `GROUP BY lotID`) |
| **¿Qué pasa con múltiples fechas?** | Se **agregan todas** (promedio, min, max, total) del último período |
| **¿Se crean nuevas filas?** | No, se **actualiza** la fila existente (MERGE) |
| **¿Qué período se considera?** | Últimos 30 días por defecto (configurable) |
| **¿Cuándo se actualiza?** | Al guardar nueva evaluación (backend) o periódicamente (job) |

---

## 📊 Ejemplo Completo: Lotes Diferentes

### Tabla `image.Analisis_Imagen`:
```
| analisisID | lotID | fechaCaptura | porcentajeLuz |
|------------|-------|--------------|---------------|
| 1          | 1003  | 2025-01-01   | 20.5          |
| 2          | 1003  | 2025-01-05   | 22.3          |
| 3          | 1004  | 2025-01-02   | 8.5           |
| 4          | 1004  | 2025-01-10   | 9.2           |
| 5          | 1005  | 2025-01-15   | 28.5          |
```

### Tabla `image.LoteEvaluacion` (después de ejecutar SP):
```
| loteEvaluacionID | lotID | porcentajeLuzPromedio | tipoUmbralActual | totalEvaluaciones |
|------------------|-------|----------------------|------------------|-------------------|
| 1                | 1003  | 21.4                 | Normal           | 2                 |
| 2                | 1004  | 8.85                 | CriticoRojo      | 2                 |
| 3                | 1005  | 28.5                 | CriticoRojo      | 1                 |
```

**Cada lote tiene su propia fila** con estadísticas agregadas.

---

## ⚠️ Puntos Importantes

1. **Constraint UNIQUE en `lotID`**: Garantiza que solo hay una fila por lote
2. **Agregación por período**: Solo considera evaluaciones del último período (30 días por defecto)
3. **Actualización incremental**: Se actualiza cuando hay nuevas evaluaciones, no se crean filas nuevas
4. **Historial de fechas**: Se guarda `fechaPrimeraEvaluacion` y `fechaUltimaEvaluacion` del período
5. **Tracking de cambios**: El campo `fechaUltimaActualizacion` registra cuándo se actualizó por última vez

---

## 🔧 Consultas Útiles

### Ver estadísticas de un lote:
```sql
SELECT * FROM image.LoteEvaluacion WHERE lotID = 1003;
```

### Ver todos los lotes con umbral crítico:
```sql
SELECT 
    le.lotID,
    l.name AS Lote,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual,
    le.totalEvaluaciones,
    le.fechaUltimaEvaluacion
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
WHERE le.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo')
  AND le.statusID = 1;
```

### Ver evaluaciones individuales vs agregadas:
```sql
-- Individuales
SELECT 
    lotID,
    fechaCaptura,
    porcentajeLuz,
    porcentajeSombra
FROM image.Analisis_Imagen
WHERE lotID = 1003
ORDER BY fechaCaptura DESC;

-- Agregadas
SELECT 
    lotID,
    porcentajeLuzPromedio,
    porcentajeLuzMin,
    porcentajeLuzMax,
    totalEvaluaciones,
    periodoEvaluacionDias
FROM image.LoteEvaluacion
WHERE lotID = 1003;
```

