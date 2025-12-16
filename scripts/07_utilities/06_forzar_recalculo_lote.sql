-- =====================================================
-- SCRIPT: Forzar Recalculo de Evaluación para un Lote
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Forzar el recálculo de evaluación para un lote específico
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Cambiar este valor al lotID que necesites recalcular
DECLARE @lotID INT = 1301;  -- Cambiar según necesidad

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  FORZANDO RECÁLCULO DE EVALUACIÓN PARA LOTID: ' + CAST(@lotID AS VARCHAR(10));
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- Verificar análisis antes del recálculo
PRINT '--- Análisis ANTES del recálculo ---';
SELECT 
    COUNT(*) AS totalAnalisis,
    AVG(CAST(porcentajeLuz AS FLOAT)) AS luzPromedio,
    MIN(porcentajeLuz) AS luzMin,
    MAX(porcentajeLuz) AS luzMax,
    MAX(COALESCE(fechaCaptura, fechaCreacion)) AS fechaUltima
FROM evalImagen.analisisImagen
WHERE lotID = @lotID
    AND statusID = 1;
PRINT '';

-- Verificar evaluación antes del recálculo
PRINT '--- Evaluación ANTES del recálculo ---';
SELECT 
    loteEvaluacionID,
    porcentajeLuzPromedio,
    porcentajeLuzMin,
    porcentajeLuzMax,
    totalEvaluaciones,
    tipoUmbralActual,
    fechaUltimaEvaluacion,
    fechaUltimaActualizacion
FROM evalImagen.loteEvaluacion
WHERE lotID = @lotID
    AND statusID = 1;
PRINT '';

-- Forzar recálculo
PRINT '--- Ejecutando recálculo... ---';
EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion 
    @LotID = @lotID,
    @PeriodoDias = 30,
    @ForzarRecalculo = 1;
PRINT '';

-- Verificar evaluación después del recálculo
PRINT '--- Evaluación DESPUÉS del recálculo ---';
SELECT 
    loteEvaluacionID,
    porcentajeLuzPromedio,
    porcentajeLuzMin,
    porcentajeLuzMax,
    totalEvaluaciones,
    tipoUmbralActual,
    fechaUltimaEvaluacion,
    fechaUltimaActualizacion
FROM evalImagen.loteEvaluacion
WHERE lotID = @lotID
    AND statusID = 1;
PRINT '';

-- Verificar si se generó alerta
PRINT '--- Alertas para el lote ---';
SELECT 
    alertaID,
    tipoUmbral,
    severidad,
    estado,
    fechaCreacion
FROM evalImagen.alerta
WHERE lotID = @lotID
    AND statusID = 1
ORDER BY fechaCreacion DESC;
PRINT '';

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ RECÁLCULO COMPLETADO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

GO

