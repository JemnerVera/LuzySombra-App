-- =====================================================
-- SCRIPT: Recalcular Evaluaciones para TODOS los Lotes
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Recalcular evaluaciones para todos los lotes que tienen análisis
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  RECALCULANDO EVALUACIONES PARA TODOS LOS LOTES';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- Verificar cuántos lotes tienen análisis
PRINT '--- Lotes con análisis (antes del recálculo) ---';
SELECT 
    COUNT(DISTINCT lotID) AS totalLotesConAnalisis,
    COUNT(*) AS totalAnalisis
FROM evalImagen.analisisImagen
WHERE statusID = 1;
PRINT '';

-- Verificar cuántas evaluaciones existen
PRINT '--- Evaluaciones existentes (antes del recálculo) ---';
SELECT 
    COUNT(*) AS totalEvaluaciones
FROM evalImagen.loteEvaluacion
WHERE statusID = 1;
PRINT '';

-- Listar lotes con análisis que NO tienen evaluación
PRINT '--- Lotes con análisis SIN evaluación ---';
SELECT DISTINCT
    ai.lotID,
    l.name AS lote,
    s.stage AS sector,
    f.Description AS fundo,
    COUNT(*) AS totalAnalisis
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

-- Ejecutar recálculo para TODOS los lotes
-- IMPORTANTE: Usar un período largo (365 días) para incluir todos los análisis
PRINT '--- Ejecutando recálculo para TODOS los lotes... ---';
EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion 
    @LotID = NULL,  -- NULL = todos los lotes
    @PeriodoDias = 365,  -- 1 año para incluir todos los análisis
    @ForzarRecalculo = 1;
PRINT '';

-- Verificar cuántas evaluaciones existen después
PRINT '--- Evaluaciones existentes (después del recálculo) ---';
SELECT 
    COUNT(*) AS totalEvaluaciones
FROM evalImagen.loteEvaluacion
WHERE statusID = 1;
PRINT '';

-- Listar todas las evaluaciones creadas/actualizadas
PRINT '--- Todas las Evaluaciones ---';
SELECT 
    le.loteEvaluacionID,
    le.lotID,
    l.name AS lote,
    s.stage AS sector,
    f.Description AS fundo,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual,
    le.totalEvaluaciones,
    le.fechaUltimaEvaluacion,
    le.fechaUltimaActualizacion
FROM evalImagen.loteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE le.statusID = 1
ORDER BY le.lotID;
PRINT '';

-- Verificar alertas generadas
PRINT '--- Alertas Generadas ---';
SELECT 
    a.alertaID,
    a.lotID,
    l.name AS lote,
    a.tipoUmbral,
    a.estado,
    a.fechaCreacion
FROM evalImagen.alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
WHERE a.statusID = 1
ORDER BY a.fechaCreacion DESC;
PRINT '';

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ RECÁLCULO COMPLETADO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

GO

