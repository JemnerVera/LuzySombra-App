-- =====================================================
-- SCRIPT: Verificar Fechas de Análisis
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Verificar las fechas de los análisis para entender por qué no se incluyen
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  VERIFICACIÓN DE FECHAS DE ANÁLISIS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

DECLARE @FechaInicio30Dias DATETIME = DATEADD(DAY, -30, GETDATE());
DECLARE @FechaInicio60Dias DATETIME = DATEADD(DAY, -60, GETDATE());
DECLARE @FechaInicio90Dias DATETIME = DATEADD(DAY, -90, GETDATE());

PRINT 'Fechas de referencia:';
PRINT '  Hoy: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '  Hace 30 días: ' + CONVERT(VARCHAR, @FechaInicio30Dias, 120);
PRINT '  Hace 60 días: ' + CONVERT(VARCHAR, @FechaInicio60Dias, 120);
PRINT '  Hace 90 días: ' + CONVERT(VARCHAR, @FechaInicio90Dias, 120);
PRINT '';

-- Análisis por fecha
PRINT '--- Análisis agrupados por fecha (últimos 90 días) ---';
SELECT 
    CONVERT(DATE, COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS fecha,
    COUNT(*) AS totalAnalisis,
    COUNT(DISTINCT ai.lotID) AS lotesUnicos,
    CASE 
        WHEN COALESCE(ai.fechaCaptura, ai.fechaCreacion) >= @FechaInicio30Dias THEN 'Últimos 30 días'
        WHEN COALESCE(ai.fechaCaptura, ai.fechaCreacion) >= @FechaInicio60Dias THEN '31-60 días'
        WHEN COALESCE(ai.fechaCaptura, ai.fechaCreacion) >= @FechaInicio90Dias THEN '61-90 días'
        ELSE 'Más de 90 días'
    END AS periodo
FROM evalImagen.analisisImagen ai
WHERE ai.statusID = 1
GROUP BY CONVERT(DATE, COALESCE(ai.fechaCaptura, ai.fechaCreacion))
ORDER BY fecha DESC;
PRINT '';

-- Análisis que se incluirían con diferentes períodos
PRINT '--- Análisis incluidos según período ---';
SELECT 
    'Últimos 30 días' AS periodo,
    COUNT(*) AS totalAnalisis,
    COUNT(DISTINCT lotID) AS lotesUnicos
FROM evalImagen.analisisImagen
WHERE statusID = 1
    AND COALESCE(fechaCaptura, fechaCreacion) >= @FechaInicio30Dias
UNION ALL
SELECT 
    'Últimos 60 días' AS periodo,
    COUNT(*) AS totalAnalisis,
    COUNT(DISTINCT lotID) AS lotesUnicos
FROM evalImagen.analisisImagen
WHERE statusID = 1
    AND COALESCE(fechaCaptura, fechaCreacion) >= @FechaInicio60Dias
UNION ALL
SELECT 
    'Últimos 90 días' AS periodo,
    COUNT(*) AS totalAnalisis,
    COUNT(DISTINCT lotID) AS lotesUnicos
FROM evalImagen.analisisImagen
WHERE statusID = 1
    AND COALESCE(fechaCaptura, fechaCreacion) >= @FechaInicio90Dias
UNION ALL
SELECT 
    'TODOS (sin filtro de fecha)' AS periodo,
    COUNT(*) AS totalAnalisis,
    COUNT(DISTINCT lotID) AS lotesUnicos
FROM evalImagen.analisisImagen
WHERE statusID = 1;
PRINT '';

-- Detalle de fechas por lote
PRINT '--- Fechas de análisis por lote ---';
SELECT 
    ai.lotID,
    l.name AS lote,
    MIN(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS fechaMasAntigua,
    MAX(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS fechaMasReciente,
    COUNT(*) AS totalAnalisis,
    CASE 
        WHEN MAX(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) >= @FechaInicio30Dias THEN '✅ Incluido (30 días)'
        WHEN MAX(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) >= @FechaInicio60Dias THEN '⚠️ Solo con 60 días'
        WHEN MAX(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) >= @FechaInicio90Dias THEN '⚠️ Solo con 90 días'
        ELSE '❌ Excluido (más de 90 días)'
    END AS estado
FROM evalImagen.analisisImagen ai
INNER JOIN GROWER.LOT l ON ai.lotID = l.lotID
WHERE ai.statusID = 1
GROUP BY ai.lotID, l.name
ORDER BY ai.lotID;
PRINT '';

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  FIN DE VERIFICACIÓN';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

GO

