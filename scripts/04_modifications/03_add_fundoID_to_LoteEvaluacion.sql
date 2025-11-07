-- =====================================================
-- SCRIPT: Agregar fundoID y sectorID a image.LoteEvaluacion
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Modificación
-- Propósito: Agregar fundoID y sectorID a image.LoteEvaluacion para optimizar el match con image.Contacto
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas:
--      - image.LoteEvaluacion (ALTER TABLE - agregar columnas fundoID y sectorID)
--   ✅ Índices:
--      - IDX_LoteEvaluacion_FundoID (NONCLUSTERED)
--   ✅ Stored Procedures:
--      - image.sp_CalcularLoteEvaluacion (actualizar para poblar fundoID y sectorID)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.LoteEvaluacion (tabla debe existir)
--   ⚠️  Requiere: GROWER.LOT, GROWER.STAGE, GROWER.FARMS (tablas existentes)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear image.LoteEvaluacion
-- 
-- RAZÓN:
--   Optimizar el match con image.Contacto que filtra por fundoID.
--   Evita hacer JOINs en cada consulta para obtener el fundoID del lote.
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  AGREGAR fundoID Y sectorID A image.LoteEvaluacion';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- Paso 1: Agregar columnas fundoID y sectorID
-- =====================================================
PRINT '=== Paso 1: Agregar columnas fundoID y sectorID ===';

-- Verificar si las columnas ya existen
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('image.LoteEvaluacion') 
    AND name = 'fundoID'
)
BEGIN
    ALTER TABLE image.LoteEvaluacion
    ADD fundoID CHAR(4) NULL;
    
    PRINT '[OK] Columna fundoID agregada';
END
ELSE
BEGIN
    PRINT '[INFO] Columna fundoID ya existe';
END
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('image.LoteEvaluacion') 
    AND name = 'sectorID'
)
BEGIN
    ALTER TABLE image.LoteEvaluacion
    ADD sectorID INT NULL;
    
    PRINT '[OK] Columna sectorID agregada';
END
ELSE
BEGIN
    PRINT '[INFO] Columna sectorID ya existe';
END
GO

-- =====================================================
-- Paso 2: Agregar Foreign Keys
-- =====================================================
PRINT '';
PRINT '=== Paso 2: Agregar Foreign Keys ===';

IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE name = 'FK_LoteEvaluacion_Farm' 
    AND parent_object_id = OBJECT_ID('image.LoteEvaluacion')
)
BEGIN
    ALTER TABLE image.LoteEvaluacion
    ADD CONSTRAINT FK_LoteEvaluacion_Farm 
    FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID);
    
    PRINT '[OK] Foreign key FK_LoteEvaluacion_Farm agregada';
END
ELSE
BEGIN
    PRINT '[INFO] Foreign key FK_LoteEvaluacion_Farm ya existe';
END
GO

IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE name = 'FK_LoteEvaluacion_Stage' 
    AND parent_object_id = OBJECT_ID('image.LoteEvaluacion')
)
BEGIN
    ALTER TABLE image.LoteEvaluacion
    ADD CONSTRAINT FK_LoteEvaluacion_Stage 
    FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID);
    
    PRINT '[OK] Foreign key FK_LoteEvaluacion_Stage agregada';
END
ELSE
BEGIN
    PRINT '[INFO] Foreign key FK_LoteEvaluacion_Stage ya existe';
END
GO

-- =====================================================
-- Paso 3: Crear índice en fundoID (para optimizar match con Contacto)
-- =====================================================
PRINT '';
PRINT '=== Paso 3: Crear índice en fundoID ===';

IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IDX_LoteEvaluacion_FundoID' 
    AND object_id = OBJECT_ID('image.LoteEvaluacion')
)
BEGIN
    CREATE NONCLUSTERED INDEX IDX_LoteEvaluacion_FundoID 
    ON image.LoteEvaluacion(fundoID, statusID)
    WHERE statusID = 1;
    
    PRINT '[OK] Índice IDX_LoteEvaluacion_FundoID creado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_LoteEvaluacion_FundoID ya existe';
END
GO

-- =====================================================
-- Paso 4: Actualizar registros existentes con fundoID y sectorID
-- =====================================================
PRINT '';
PRINT '=== Paso 4: Actualizar registros existentes ===';

UPDATE le
SET 
    le.fundoID = RTRIM(f.farmID),  -- RTRIM para quitar espacios en CHAR(4)
    le.sectorID = s.stageID
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE le.fundoID IS NULL OR le.sectorID IS NULL;

DECLARE @RegistrosActualizados INT = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosActualizados AS VARCHAR) + ' registros actualizados con fundoID y sectorID';
GO

-- =====================================================
-- Paso 5: Verificar resultados
-- =====================================================
PRINT '';
PRINT '=== Paso 5: Verificar resultados ===';

SELECT 
    COUNT(*) AS TotalRegistros,
    SUM(CASE WHEN fundoID IS NOT NULL THEN 1 ELSE 0 END) AS ConFundoID,
    SUM(CASE WHEN sectorID IS NOT NULL THEN 1 ELSE 0 END) AS ConSectorID,
    SUM(CASE WHEN fundoID IS NULL AND sectorID IS NULL THEN 1 ELSE 0 END) AS SinDatos
FROM image.LoteEvaluacion
WHERE statusID = 1;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ACTUALIZACIÓN COMPLETADA';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'PRÓXIMOS PASOS:';
PRINT '  1. Actualizar el SP sp_CalcularLoteEvaluacion para poblar fundoID y sectorID';
PRINT '  2. Ejecutar: EXEC image.sp_CalcularLoteEvaluacion @ForzarRecalculo = 1;';
PRINT '     para recalcular todos los registros y poblar los campos';
PRINT '';
GO

