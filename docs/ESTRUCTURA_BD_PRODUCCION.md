# Estructura de Base de Datos de Producción

**Base de Datos:** Configurar en `.env.local` (contactar al administrador)  
**Credenciales:** Configurar en `.env.local` (usuario solo lectura recomendado para consultas)

---

## 📊 Schemas Principales

### 1. `grower` - Jerarquía Organizacional y Cultivos

#### Jerarquía de Organización
```
growers (empresa)
  └─ farms (fundo)
      └─ stage (sector)
          └─ lot (lote)
              └─ plantation (plantación - relaciona lote con variedad)
```

#### Tablas de Jerarquía
- **`grower.growers`**: Empresas/Productores
  - Columnas clave: `growerID` (PK, char), `businessName`, `abbreviation`, `region`, `statusID`
- **`grower.farms`**: Fundos
  - Columnas clave: `farmID` (PK, char), `Description`, `statusID`, `farmCode`
- **`grower.stage`**: Sectores
  - Columnas clave: `stageID` (PK, int), `stage` (nombre), `farmID` (FK), `growerID` (FK), `districtID`, `statusID`
  - **Nota importante**: `stage` contiene las FKs `farmID` y `growerID` directamente
- **`grower.lot`**: Lotes
  - Columnas clave: `lotID` (PK, int), `name`, `stageID` (FK), `number`, `statusID`, `creationDate`

#### Tablas de Variedad
- **`grower.variety`**: Variedades de cultivos
  - Columnas: `varietyID`, `name`, `abbreviation`, `cropID`
- **`grower.plantation`**: Plantaciones (relaciona lote con variedad)
  - Columnas: `plantationID`, `lotID`, `varietyID`
- **`grower.varietyGrower`**: Relación variedad-empresa
- **`grower.varietysGrower`**: Variedades por empresa (tabla alternativa)

#### Tabla de Plantas Individuales
- **`grower.plant`**: ⭐ Plantas individuales por plantación
  - Columnas clave:
    - `plantID` (PK, int): ID único de la planta (ej: 805221)
    - `plant` (int): ID alternativo de la planta
    - `plantationID` (FK, int): Referencia a `grower.plantation.plantationID`
    - `numberLine` (int): Número de hilera (ej: 58)
    - `position` (int): Posición en la hilera (ej: 61)
    - `datePlant` (datetime): Fecha de plantación
    - `statusID` (int): Estado (1 = activo)
  - **Relación**: `plant.plantationID` → `plantation.plantationID` → `plantation.lotID` → `lot.lotID`
  - **Uso**: Mapeo de `plantID` (desde QR) a `lotID`, `hilera` y `position`

#### Otras Tablas Relevantes
- `grower.campaign`: Campañas agrícolas
- `grower.crops`: Cultivos
- `grower.cropTypes`: Tipos de cultivo
- `grower.district`: Distritos
- `grower.LoteFenologia`: Fenología por lote
- `grower.material`: Materiales
- `grower.projectedWeek`: Semanas proyectadas
- `grower.sizes`: Calibres
- `grower.sizeGrower`: Calibres por empresa
- `grower.turno`: Turnos
- `grower.unitMeasure`: Unidades de medida

---

### 2. `evalAgri` - Evaluaciones Agrícolas y Fenología

#### Tablas de Fenología
- **`evalAgri.evaluacionPlagaEnfermedad`**: Evaluaciones de fenología
  - Columnas clave: `evaluacionPlagaEnfermedadID`, `lotID`, `EstadoFenologicoId`, `Fecha`, `Hilera`, `Planta`, `estadoID`
  
- **`evalAgri.EstadoFenologico`**: Estados fenológicos
  - Columnas: `EstadoFenologicoId`, `EstadoFenologicoNom`
  - Valores conocidos:
    - `0`: No Aplica
    - `1`: Post Cosecha
    - `2`: Poda
    - `3`: % Brotación
    - `4`: Crecimiento Brote
    - `5`: Flor Cuaja
    - `6`: Crecimiento de Baya
    - `7`: Ablande/Maduración
    - `8`: Cosecha

---

### 3. `phytosanitary` - Fitosanidad y Cianamida

#### Tablas de Cianamida
- **`phytosanitary.lotCyanamideDate`**: ⭐ Fechas de aplicación de cianamida por lote
  - Columnas: `lotCyanamideDate` (ID), `lotID`, `harvestCampaignID`, `date`
  - Cálculo: `DATEDIFF(DAY, date, GETDATE())` para obtener días desde cianamida

- **`phytosanitary.applicationOrderProjectedStageLot`**: Aplicaciones proyectadas
  - Columnas: `dateInitialCyanamide`, `dateFinalCyanamide`, `lotID`

#### Otras Tablas
- `phytosanitary.ActividadCultural`: Actividades culturales
- `phytosanitary.applicationEquipment`: Equipos de aplicación
- `phytosanitary.applicationMethod`: Métodos de aplicación
- `phytosanitary.applicationOrderExecution`: Órdenes ejecutadas
- `phytosanitary.applicationOrderProjected`: Órdenes proyectadas
- `phytosanitary.applicationOrderScheduled`: Órdenes programadas
- `phytosanitary.chemicalGroup`: Grupos químicos
- `phytosanitary.harvestCampaign`: Campañas de cosecha
- `phytosanitary.product`: Productos fitosanitarios
- `phytosanitary.plaguesDiseases`: Plagas y enfermedades
- `phytosanitary.phenologicalCondition`: Condiciones fenológicas
- `phytosanitary.turn`: Turnos

---

### 4. `ppp` - Proyecciones y Plantillas

#### Tablas de Proyección
- **`ppp.proyeccion`**: Proyecciones de producción
  - Columnas: `proyeccionID`, `lotID`, `varietyID`, `campaignID`, `fechaInicioCianamida`, `hectarea`

#### Tablas de Plantillas
- `ppp.plantillaDetalleEvaluacion`: Columna `diasDespuesCianamida`
- `ppp.plantillaDetalleFitosanidad`: Columna `diasDespuesCianamida`
- `ppp.plantillaDetalleLabores`: Columna `diasDespuesCianamida`
- `ppp.plantillaDetalleRiego`: Columna `diasDespuesCianamida`

#### Tablas de Proyección Detalle
- `ppp.proyeccionDetalleEvaluacion`
- `ppp.proyeccionDetalleFitosanidad`
- `ppp.proyeccionDetalleLabores`
- `ppp.proyeccionDetalleRiego`
- `ppp.proyeccionDetalleTotal`

---

## 🔗 Relaciones Clave entre Tablas

### Jerarquía Completa
```sql
grower.growers (empresa)
  growerID → grower.farms.growerID
    farmID → grower.stage.farmID
      stageID → grower.lot.stageID
        lotID → grower.plantation.lotID
          varietyID → grower.variety.varietyID
```

### Lote → Variedad
```sql
grower.lot
  └─ grower.plantation (puente)
      └─ grower.variety
```

### PlantID → Lote (Mapeo para AgriQR)
```sql
grower.plant (plantID: int)
  └─ grower.plantation (plantationID)
      └─ grower.lot (lotID)
          └─ grower.stage (stageID)
              └─ grower.farms (farmID)
                  └─ grower.growers (growerID)
```
**Campos obtenidos desde `plantID`**:
- `lotID`: Desde `plant.plantationID` → `plantation.lotID`
- `hilera`: Desde `plant.numberLine`
- `numero_planta`: Desde `plant.position`
- `empresa/fundo/sector/lote`: Desde jerarquía `lot` → `stage` → `farms` → `growers`

### Lote → Fenología
```sql
grower.lot
  └─ evalAgri.evaluacionPlagaEnfermedad
      └─ evalAgri.EstadoFenologico
```

### Lote → Cianamida
```sql
grower.lot
  └─ phytosanitary.lotCyanamideDate (fecha de aplicación)
```

---

## 📝 Queries de Referencia

### Query 1: Lotes con Variedad
```sql
SELECT
    l.lotID,
    l.name AS LoteNombre,
    s.stage AS SectorNombre,
    f.name AS FundoNombre,
    g.name AS EmpresaNombre,
    v.varietyID,
    v.name AS VarietyNombre,
    v.abbreviation AS VarietyAbrev
FROM grower.lot l
INNER JOIN grower.plantation p ON l.lotID = p.lotID
INNER JOIN grower.variety v ON p.varietyID = v.varietyID
INNER JOIN grower.stage s ON l.stageID = s.stageID
INNER JOIN grower.farms f ON s.farmID = f.farmID
INNER JOIN grower.growers g ON f.growerID = g.growerID
ORDER BY l.name;
```

### Query 2: Fenología por Lote
```sql
SELECT 
    l.lotID,
    l.name AS Lote,
    ef.EstadoFenologicoNom AS EstadoFenologico,
    MAX(ep.Fecha) AS UltimaFecha,
    COUNT(DISTINCT ep.evaluacionPlagaEnfermedadID) AS TotalEvaluaciones
FROM evalAgri.evaluacionPlagaEnfermedad ep
INNER JOIN evalAgri.EstadoFenologico ef 
    ON ep.EstadoFenologicoId = ef.EstadoFenologicoId
INNER JOIN grower.lot l 
    ON l.lotID = ep.lotID
WHERE ep.estadoID = 1
GROUP BY l.lotID, l.name, ef.EstadoFenologicoNom
ORDER BY MAX(ep.Fecha) DESC;
```

### Query 3: Días desde Cianamida
```sql
SELECT
    l.lotID,
    l.name AS LoteNombre,
    lcd.date AS FechaCianamida,
    DATEDIFF(DAY, lcd.date, GETDATE()) AS DiasDesdeCianamida
FROM phytosanitary.lotCyanamideDate lcd
INNER JOIN grower.lot l ON lcd.lotID = l.lotID
ORDER BY lcd.date DESC;
```

### Query 4: Obtener información completa desde plantID (para AgriQR)
```sql
-- Obtener lotID, hilera y position desde plantID
SELECT 
    pl.lotID,
    p.numberLine AS hilera,
    p.position AS numero_planta,
    l.name AS lote,
    s.stage AS sector,
    f.Description AS fundo,
    g.businessName AS empresa
FROM GROWER.PLANT p WITH (NOLOCK)
INNER JOIN GROWER.PLANTATION pl WITH (NOLOCK) ON p.plantationID = pl.plantationID
INNER JOIN GROWER.LOT l WITH (NOLOCK) ON pl.lotID = l.lotID
INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
INNER JOIN GROWER.GROWERS g WITH (NOLOCK) ON s.growerID = g.growerID
WHERE p.plantID = 805221  -- plantID como int (convertir desde string "00805221")
  AND p.statusID = 1
  AND pl.statusID = 1
  AND l.statusID = 1
  AND s.statusID = 1
  AND f.statusID = 1
  AND g.statusID = 1;
```

---

## 🎯 Requerimiento del Usuario Final

### Tabla Consolidada Requerida
**Filtros:**
- Fundo
- Distrito (pendiente de agregar)

**Columnas:**
1. Ranking prioridad
2. Fundo
3. Sector
4. Lote
5. **Variedad** ✅ (de `grower.variety` via `grower.plantation`)
6. **Estado fenológico** ✅ (de `evalAgri.EstadoFenologico`)
7. **Días desde cianamida** ✅ (de `phytosanitary.lotCyanamideDate`)
8. Fecha de última evaluación
9. Min (% Luz) - desde `evalImagen.AnalisisImagen` en [TU_BASE_DE_DATOS]
10. Max (% Luz) - desde `evalImagen.AnalisisImagen` en [TU_BASE_DE_DATOS]
11. Prom (% Luz) - desde `evalImagen.AnalisisImagen` en [TU_BASE_DE_DATOS]
12. Min (% Sombra) - desde `evalImagen.AnalisisImagen` en [TU_BASE_DE_DATOS]
13. Max (% Sombra) - desde `evalImagen.AnalisisImagen` en [TU_BASE_DE_DATOS]
14. Prom (% Sombra) - desde `evalImagen.AnalisisImagen` en [TU_BASE_DE_DATOS]

---

## ⚠️ Notas Importantes

1. **Acceso de Lectura y Escritura**: 
   - Lectura: Usuario `ucser_powerbi_desa` (solo `SELECT`)
   - Escritura: Usuario configurado en `.env.local` (`INSERT`/`UPDATE` en `evalImagen.AnalisisImagen`)

2. **Integración Directa**: 
   - Los análisis de imágenes se guardan directamente en `evalImagen.AnalisisImagen` en la misma base de datos
   - Los `lotID` se obtienen directamente de `GROWER.LOT` usando la jerarquía completa

3. **Estrategia Implementada**:
   - **Queries directos** en la aplicación Node.js
   - Todas las tablas en la misma base de datos `[TU_BASE_DE_DATOS]`
   - Sin necesidad de mapeo o ETL

4. **Campos Pendientes**:
   - `distrito`: No existe en el schema actual
   - Lógica de "Ranking de prioridad"

---

## 📚 Scripts de Investigación Creados

1. `scripts/consultar_variedad_desa.sql` - Investigación inicial de variedades
2. `scripts/investigar_estructura_variedad.sql` - Estructura detallada
3. `scripts/query_lotes_con_variedad.sql` - Query funcional de lotes + variedad
4. `scripts/query_fenologia_agregado.sql` - Fenología agregada por lote
5. `scripts/query_fenologia_detallado.sql` - Fenología detallada
6. `scripts/investigar_cianamida.sql` - Búsqueda de tablas de cianamida
7. `scripts/estructura_cianamida.sql` - Estructura de tablas de cianamida
8. `scripts/query_consolidado_fenologia_variedad.sql` - Consolidado fenología + variedad
9. `scripts/query_consolidado_final.sql` - Query final integrado (requiere corrección)
10. `scripts/verificar_schema_grower.sql` - Verificación de nombres de tablas

---

**Última actualización:** 2025-10-22  
**Versión:** 1.0

