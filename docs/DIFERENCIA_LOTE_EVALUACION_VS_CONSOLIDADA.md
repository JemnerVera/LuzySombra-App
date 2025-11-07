# Diferencia: `image.LoteEvaluacion` vs Tabla Consolidada

## 🎯 Respuesta Rápida

- **`image.LoteEvaluacion`**: Tabla física que almacena estadísticas por lote (para alertas y consultas rápidas)
- **Tabla Consolidada**: Query dinámica que combina datos de varias fuentes (solo para mostrar en UI)
- **`image.Alerta`**: Trabaja con `image.LoteEvaluacion` (no con la tabla consolidada)

---

## 📊 Comparación Visual

```
┌─────────────────────────────────────────────────────────────┐
│                    image.LoteEvaluacion                      │
│                  (TABLA FÍSICA EN BD)                       │
│                                                              │
│  ┌──────────┬──────────────────┬──────────────┐            │
│  │ lotID    │ porcentajeLuzProm│ tipoUmbral   │            │
│  ├──────────┼──────────────────┼──────────────┤            │
│  │ 1003     │ 22.50            │ Normal       │            │
│  │ 1004     │ 8.50             │ CriticoRojo  │            │
│  │ 1005     │ 28.30            │ CriticoRojo  │            │
│  └──────────┴──────────────────┴──────────────┘            │
│                                                              │
│  ✅ Se guarda en BD                                         │
│  ✅ Se actualiza cuando se procesa imagen                   │
│  ✅ Usada para alertas                                      │
│  ✅ Usada para consultas rápidas                            │
└─────────────────────────────────────────────────────────────┘

                            │
                            │ LEFT JOIN
                            ▼

┌─────────────────────────────────────────────────────────────┐
│                    TABLA CONSOLIDADA                         │
│                (QUERY DINÁMICA - NO SE GUARDA)              │
│                                                              │
│  ┌──────────┬──────────┬──────────┬──────────┬─────────────┐│
│  │ fundo    │ sector   │ lote     │ variedad │ porcentajeLuz││
│  ├──────────┼──────────┼──────────┼──────────┼─────────────┤│
│  │ Fundo A  │ S1       │ Lote 1   │ Rosita   │ 22.50       ││
│  │ Fundo A  │ S1       │ Lote 2   │ NULL     │ 8.50        ││
│  │ Fundo B  │ S2       │ Lote 3   │ Rosita   │ 28.30       ││
│  └──────────┴──────────┴──────────┴──────────┴─────────────┘│
│                                                              │
│  ❌ NO se guarda en BD                                      │
│  ✅ Se calcula cada vez que se consulta                     │
│  ✅ Solo para mostrar en UI                                 │
│  ✅ Combina datos de múltiples fuentes                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Diferencias Clave

| Aspecto | `image.LoteEvaluacion` | Tabla Consolidada |
|---------|------------------------|-------------------|
| **Tipo** | Tabla física en BD | Query dinámica |
| **¿Se guarda?** | ✅ Sí, es una tabla real | ❌ No, es resultado de query |
| **¿Se actualiza?** | ✅ Automáticamente al procesar imagen | ❌ No aplica (se calcula al consultar) |
| **Propósito** | Almacenar estadísticas para alertas y consultas | Mostrar datos combinados en UI |
| **Datos que contiene** | Solo estadísticas de luz/sombra por lote | Fundo, sector, lote, variedad, fenología, estadísticas |
| **Fuente de datos** | Calcula desde `image.Analisis_Imagen` | Combina múltiples tablas/vistas |
| **Performance** | Muy rápido (datos precalculados) | Rápido (usa `image.LoteEvaluacion` precalculada) |
| **Usada para alertas** | ✅ Sí | ❌ No |

---

## 🔗 Relación con `image.Alerta`

### ¿Cuál trabaja con la tabla de alertas?

**`image.LoteEvaluacion`** es la que trabaja con `image.Alerta`.

### Flujo de Generación de Alertas:

```
1. Usuario procesa imagen nueva
   ↓
2. Se guarda en image.Analisis_Imagen
   ↓
3. Se ejecuta sp_CalcularLoteEvaluacion(@lotID)
   ↓
4. Se actualiza image.LoteEvaluacion
   - Calcula nuevo promedio de luz
   - Compara con umbrales
   - Actualiza tipoUmbralActual (Normal/CriticoRojo/CriticoAmarillo)
   ↓
5. Backend verifica si cambió tipoUmbralActual
   ↓
6. Si cambió a CriticoRojo o CriticoAmarillo:
   → Se crea registro en image.Alerta
   ↓
7. Se genera mensaje en image.Mensaje
   ↓
8. Se envía email vía Resend
```

### Ejemplo:

```sql
-- image.LoteEvaluacion tiene:
lotID: 1004
porcentajeLuzPromedio: 8.50
tipoUmbralActual: 'CriticoRojo'  ← Este cambio activa la alerta

-- image.Alerta se crea:
alertaID: 1
lotID: 1004
loteEvaluacionID: 2  ← FK a image.LoteEvaluacion
umbralID: 1          ← FK a image.UmbralLuz
porcentajeLuzEvaluado: 8.50
tipoUmbral: 'CriticoRojo'
severidad: 'Critica'
estado: 'Pendiente'
```

---

## 📊 Estructura de Datos

### `image.LoteEvaluacion` (Tabla Física)

```sql
CREATE TABLE image.LoteEvaluacion (
    loteEvaluacionID INT PRIMARY KEY,
    lotID INT UNIQUE,  -- UNA fila por lote
    
    -- Estadísticas de luz/sombra
    porcentajeLuzPromedio DECIMAL(5,2),
    porcentajeLuzMin DECIMAL(5,2),
    porcentajeLuzMax DECIMAL(5,2),
    porcentajeSombraPromedio DECIMAL(5,2),
    porcentajeSombraMin DECIMAL(5,2),
    porcentajeSombraMax DECIMAL(5,2),
    
    -- Clasificación (para alertas)
    tipoUmbralActual VARCHAR(20),  -- 'CriticoRojo', 'CriticoAmarillo', 'Normal'
    umbralIDActual INT,
    
    -- Fechas
    fechaUltimaEvaluacion DATETIME,
    totalEvaluaciones INT,
    
    -- Período evaluado
    periodoEvaluacionDias INT DEFAULT 30
);
```

**Ejemplo de datos**:
```
| lotID | porcentajeLuzProm | tipoUmbralActual | fechaUltimaEvaluacion |
|-------|-------------------|------------------|----------------------|
| 1003  | 22.50             | Normal           | 2025-01-30 10:30:00  |
| 1004  | 8.50              | CriticoRojo      | 2025-01-30 14:20:00  |
| 1005  | 28.30             | CriticoRojo      | 2025-01-29 16:15:00  |
```

---

### Tabla Consolidada (Query Dinámica)

```sql
-- Query que combina datos:
SELECT 
    lp.fundo,              -- De GROWER.LOT/STAGE/FARMS
    lp.sector,             -- De GROWER.LOT/STAGE
    lp.lote,               -- De GROWER.LOT
    v.name AS variedad,    -- De GROWER.PLANTATION/VARIETY
    cf.estadoFenologico,   -- De vwc_CianamidaFenologia
    cf.diasCianamida,      -- De vwc_CianamidaFenologia
    le.porcentajeLuzPromedio,  -- De image.LoteEvaluacion
    le.porcentajeLuzMin,       -- De image.LoteEvaluacion
    le.porcentajeLuzMax,       -- De image.LoteEvaluacion
    -- ... más estadísticas
FROM LotesPaginados lp
LEFT JOIN vwc_CianamidaFenologia cf ON ...
LEFT JOIN image.LoteEvaluacion le ON ...
LEFT JOIN GROWER.PLANTATION/VARIETY ON ...
```

**Ejemplo de resultado**:
```
| fundo   | sector | lote   | variedad | estadoFenologico | porcentajeLuzProm |
|---------|--------|--------|----------|------------------|-------------------|
| Fundo A | S1     | Lote 1 | Rosita   | Dormancia        | 22.50             |
| Fundo A | S1     | Lote 2 | NULL     | NULL             | 8.50              |
| Fundo B | S2     | Lote 3 | Rosita   | NULL             | 28.30             |
```

**Nota**: Este resultado NO se guarda, solo se muestra en la UI.

---

## 🎯 Usos de Cada Una

### `image.LoteEvaluacion`:

1. **Generación de Alertas** ✅
   - Backend consulta `tipoUmbralActual`
   - Si cambió a CriticoRojo/CriticoAmarillo → crea alerta

2. **Consultas Rápidas** ✅
   - Obtener estadísticas de un lote específico
   - Listar lotes con umbral crítico
   - Dashboard de alertas

3. **Performance** ✅
   - Datos precalculados, muy rápido

### Tabla Consolidada:

1. **Mostrar en UI** ✅
   - Pestaña "Evaluación por lote"
   - Tabla con todos los datos combinados

2. **Filtros y Búsqueda** ✅
   - Filtrar por fundo, sector, lote
   - Paginación

3. **Visualización** ✅
   - Mostrar datos de múltiples fuentes en una sola vista

---

## 🔄 Flujo Completo

```
┌─────────────────────────────────────────────────────────────┐
│  PROCESAR IMAGEN                                            │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│  image.Analisis_Imagen (INSERT)                            │
│  - Guarda evaluación individual                             │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│  sp_CalcularLoteEvaluacion                                  │
│  - Calcula estadísticas del lote                            │
│  - Compara con umbrales                                     │
│  - Actualiza tipoUmbralActual                               │
└─────────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────────┐
│  image.LoteEvaluacion (UPDATE/INSERT)                       │
│  - Guarda estadísticas agregadas                            │
│  - Guarda tipoUmbralActual                                  │
└─────────────────────────────────────────────────────────────┘
                    ↓
         ┌──────────┴──────────┐
         │                     │
         ▼                     ▼
┌──────────────────┐  ┌─────────────────────────────────────┐
│  image.Alerta    │  │  Tabla Consolidada (Query)          │
│                  │  │                                      │
│  - Se crea si    │  │  - Usa image.LoteEvaluacion         │
│    cambió umbral │  │  - Combina con fenología/variedad   │
│  - Usa datos de  │  │  - Muestra en UI                    │
│    LoteEvaluacion│  │                                      │
└──────────────────┘  └─────────────────────────────────────┘
```

---

## 📝 Resumen

| Pregunta | Respuesta |
|----------|-----------|
| **¿Cuál es una tabla física?** | `image.LoteEvaluacion` |
| **¿Cuál se guarda en BD?** | `image.LoteEvaluacion` |
| **¿Cuál es solo una query?** | Tabla Consolidada |
| **¿Cuál trabaja con alertas?** | `image.LoteEvaluacion` |
| **¿Cuál se usa para mostrar en UI?** | Tabla Consolidada |
| **¿Cuál se actualiza automáticamente?** | `image.LoteEvaluacion` |
| **¿Cuál combina múltiples fuentes?** | Tabla Consolidada |
| **¿Cuál almacena estadísticas precalculadas?** | `image.LoteEvaluacion` |

---

## 💡 Analogía

**`image.LoteEvaluacion`** = Un resumen de un libro (guardado en una hoja)
- Se guarda físicamente
- Se actualiza cuando hay cambios
- Se usa para tomar decisiones (alertas)

**Tabla Consolidada** = Un reporte que combina varios resúmenes + información adicional
- No se guarda, se genera cada vez
- Se usa solo para mostrar información
- Combina datos de múltiples fuentes

---

## ✅ Conclusión

- **`image.LoteEvaluacion`**: Tabla física que almacena estadísticas por lote. Se usa para alertas.
- **Tabla Consolidada**: Query dinámica que combina datos de múltiples fuentes. Se usa solo para mostrar en UI.
- **`image.Alerta`**: Trabaja con `image.LoteEvaluacion`, no con la tabla consolidada.

