-- =====================================================
-- SCRIPT: Verificar plantId en tablas existentes
-- Propósito: Verificar si un plantId existe en las tablas
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

DECLARE @plantId VARCHAR(50) = '00805221';

PRINT '========================================';
PRINT 'Verificando plantId: ' + @plantId;
PRINT '========================================';
PRINT '';

-- 1. Verificar en GROWER.PLANT
PRINT '1. GROWER.PLANT:';
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PLANT' AND schema_id = SCHEMA_ID('GROWER'))
BEGIN
    -- Mostrar estructura de la tabla
    PRINT '   Tabla existe. Estructura:';
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'PLANT'
    ORDER BY ORDINAL_POSITION;
    
    -- Buscar el plantId
    PRINT '';
    PRINT '   Buscando plantId:';
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT TOP 5 * FROM GROWER.PLANT WHERE plantID = ''' + @plantId + '''';
    EXEC sp_executesql @sql;
END
ELSE
BEGIN
    PRINT '   Tabla NO existe';
END
PRINT '';

-- 2. Verificar en evalAgri.evaluacionPlagaEnfermedad
PRINT '2. evalAgri.evaluacionPlagaEnfermedad:';
SELECT TOP 5 
    ep.evaluacionPlagaEnfermedadID,
    ep.lotID,
    ep.Planta,
    ep.Hilera,
    ep.Fecha,
    ep.estadoID
FROM evalAgri.evaluacionPlagaEnfermedad ep
WHERE ep.Planta = @plantId
ORDER BY ep.Fecha DESC;
PRINT '';

-- 3. Verificar en image.Analisis_Imagen
PRINT '3. image.Analisis_Imagen:';
SELECT TOP 5 
    ai.analisisID,
    ai.lotID,
    ai.planta,
    ai.hilera,
    ai.fechaCreacion,
    ai.statusID
FROM image.Analisis_Imagen ai
WHERE ai.planta = @plantId
ORDER BY ai.fechaCreacion DESC;
PRINT '';

-- 4. Mostrar lotes disponibles (para referencia)
PRINT '4. Lotes disponibles (primeros 10):';
SELECT TOP 10
    l.lotID,
    l.name as lote,
    s.stage as sector,
    f.Description as fundo,
    g.businessName as empresa
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
WHERE l.statusID = 1
ORDER BY l.lotID;
PRINT '';

PRINT '========================================';
PRINT 'Verificación completada';
PRINT '========================================';

