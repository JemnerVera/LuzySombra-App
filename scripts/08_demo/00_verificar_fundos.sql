-- =====================================================
-- SCRIPT: Verificar Fundos Disponibles
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Propósito: Ver qué fundos (farmID) están disponibles para usar en la demo
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '========================================';
PRINT 'Fundos Disponibles (GROWER.FARMS)';
PRINT '========================================';
PRINT '';

SELECT 
    farmID,
    LEN(farmID) AS longitud,
    Description AS nombre,
    statusID,
    CASE 
        WHEN statusID = 1 THEN 'Activo'
        ELSE 'Inactivo'
    END AS estado
FROM GROWER.FARMS
ORDER BY farmID;

PRINT '';
PRINT '========================================';
PRINT 'Fundos Activos (para usar en demo)';
PRINT '========================================';
PRINT '';

SELECT 
    farmID,
    Description AS nombre,
    'Usar este valor en fundoID' AS instruccion
FROM GROWER.FARMS
WHERE statusID = 1
ORDER BY farmID;

PRINT '';
PRINT 'NOTA: farmID es CHAR(4), puede tener espacios.';
PRINT '      Usa RTRIM(farmID) para comparar o asignar.';
GO

