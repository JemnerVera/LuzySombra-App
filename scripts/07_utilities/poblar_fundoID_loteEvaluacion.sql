-- =====================================================
-- SCRIPT: Poblar fundoID y sectorID en LoteEvaluacion
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Actualizar fundoID y sectorID en LoteEvaluacion desde la jerarquía
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  POBLAR fundoID Y sectorID EN LoteEvaluacion';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- Paso 1: Verificar LoteEvaluacion sin fundoID
-- =====================================================
PRINT '=== Paso 1: LoteEvaluacion sin fundoID ===';
SELECT 
    le.loteEvaluacionID,
    le.lotID,
    le.fundoID,
    le.sectorID,
    l.name AS lote,
    s.stage AS sector,
    f.Description AS fundo,
    f.farmID AS farmID_correcto
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
LEFT JOIN GROWER.STAGE s ON l.stageID = s.stageID
LEFT JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE le.fundoID IS NULL
  AND le.statusID = 1
ORDER BY le.loteEvaluacionID;
GO

-- =====================================================
-- Paso 2: Actualizar fundoID y sectorID desde la jerarquía
-- =====================================================
PRINT '';
PRINT '=== Paso 2: Actualizando fundoID y sectorID ===';

UPDATE le
SET 
    le.fundoID = CAST(f.farmID AS CHAR(4)),
    le.sectorID = s.stageID,
    le.fechaUltimaActualizacion = GETDATE()
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE le.fundoID IS NULL
  AND le.statusID = 1
  AND l.statusID = 1
  AND s.statusID = 1
  AND f.statusID = 1;

PRINT '✅ Actualización completada';
PRINT '';
GO

-- =====================================================
-- Paso 3: Verificar actualización
-- =====================================================
PRINT '=== Paso 3: Verificar actualización ===';
SELECT 
    le.loteEvaluacionID,
    le.lotID,
    le.fundoID,
    le.sectorID,
    f.Description AS fundo,
    s.stage AS sector
FROM image.LoteEvaluacion le
LEFT JOIN GROWER.FARMS f ON le.fundoID = f.farmID
LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
WHERE le.loteEvaluacionID IN (2, 4)  -- Los de las alertas
ORDER BY le.loteEvaluacionID;
GO

-- =====================================================
-- Paso 4: Verificar alertas ahora pueden consolidarse
-- =====================================================
PRINT '';
PRINT '=== Paso 4: Verificar alertas pueden consolidarse ===';
SELECT 
    a.alertaID,
    a.lotID,
    a.loteEvaluacionID,
    CAST(COALESCE(le.fundoID, f.farmID) AS VARCHAR) AS fundoID,
    f.Description AS fundo,
    a.tipoUmbral,
    a.estado,
    a.mensajeID,
    CASE 
        WHEN le.loteEvaluacionID IS NULL THEN '❌ No tiene loteEvaluacionID'
        WHEN COALESCE(le.fundoID, f.farmID) IS NULL THEN '❌ No se puede obtener fundoID'
        WHEN a.mensajeID IS NOT NULL THEN '⚠️ Ya tiene mensajeID'
        WHEN a.estado NOT IN ('Pendiente', 'Enviada') THEN '❌ Estado incorrecto'
        ELSE '✅ Lista para consolidar'
    END AS estado_consolidacion
FROM image.Alerta a
INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
LEFT JOIN GROWER.FARMS f ON COALESCE(le.fundoID, s.farmID) = f.farmID
WHERE a.alertaID IN (3, 4)
  AND a.statusID = 1;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  Si ves "✅ Lista para consolidar" en el Paso 4,';
PRINT '  puedes ejecutar el POST /api/alertas/consolidar de nuevo';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

