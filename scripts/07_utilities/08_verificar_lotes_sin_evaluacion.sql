-- =====================================================
-- SCRIPT: Verificar Lotes con Análisis SIN Evaluación
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Identificar lotes que tienen análisis pero no tienen evaluación
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  VERIFICACIÓN: LOTES CON ANÁLISIS SIN EVALUACIÓN';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- Lotes con análisis que NO tienen evaluación
PRINT '--- Lotes con análisis SIN evaluación en loteEvaluacion ---';
SELECT 
    ai.lotID,
    l.name AS lote,
    s.stage AS sector,
    f.Description AS fundo,
    COUNT(*) AS totalAnalisis,
    MIN(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS primeraEvaluacion,
    MAX(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS ultimaEvaluacion,
    AVG(CAST(ai.porcentajeLuz AS FLOAT)) AS luzPromedio,
    MIN(ai.porcentajeLuz) AS luzMin,
    MAX(ai.porcentajeLuz) AS luzMax
FROM evalImagen.analisisImagen ai
INNER JOIN GROWER.LOT l ON ai.lotID = l.lotID
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE ai.statusID = 1
    AND NOT EXISTS (
        SELECT 1 
        FROM evalImagen.loteEvaluacion le
        WHERE le.lotID = ai.lotID
            AND le.statusID = 1
    )
GROUP BY ai.lotID, l.name, s.stage, f.Description
ORDER BY ai.lotID;
PRINT '';

-- Resumen
PRINT '--- Resumen ---';
SELECT 
    (SELECT COUNT(DISTINCT lotID) FROM evalImagen.analisisImagen WHERE statusID = 1) AS totalLotesConAnalisis,
    (SELECT COUNT(*) FROM evalImagen.loteEvaluacion WHERE statusID = 1) AS totalEvaluaciones,
    (SELECT COUNT(DISTINCT ai.lotID) 
     FROM evalImagen.analisisImagen ai
     WHERE ai.statusID = 1
       AND NOT EXISTS (
           SELECT 1 FROM evalImagen.loteEvaluacion le 
           WHERE le.lotID = ai.lotID AND le.statusID = 1
       )
    ) AS lotesSinEvaluacion;
PRINT '';

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  FIN DE VERIFICACIÓN';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'SOLUCIÓN:';
PRINT '  Ejecutar: EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion @LotID = NULL, @ForzarRecalculo = 1;';
PRINT '  O usar el script: scripts/07_utilities/07_recalcular_todos_lotes.sql';
PRINT '';

GO

