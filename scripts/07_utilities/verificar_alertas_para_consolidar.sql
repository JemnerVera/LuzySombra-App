-- =====================================================
-- SCRIPT: Verificar Alertas para Consolidar
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Verificar que las alertas tienen fundoID para consolidar
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Verificar alertas pendientes con información de fundo
-- =====================================================
SELECT 
    a.alertaID,
    a.lotID,
    a.porcentajeLuzEvaluado,
    a.tipoUmbral,
    a.severidad,
    a.estado,
    a.fechaCreacion,
    a.mensajeID,
    le.fundoID,
    le.sectorID,
    f.Description AS fundo,
    s.stage AS sector
FROM image.Alerta a
INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
LEFT JOIN GROWER.FARMS f ON COALESCE(le.fundoID, s.farmID) = f.farmID
WHERE a.alertaID IN (3, 4)  -- Las 2 alertas que tienes
  AND a.statusID = 1
ORDER BY a.alertaID;
GO

-- =====================================================
-- Verificar contactos que recibirían estas alertas
-- =====================================================
PRINT '';
PRINT '=== Contactos que recibirían estas alertas ===';
PRINT '';

-- Para alerta 3 (CriticoAmarillo)
SELECT 
    'Alerta 3 (CriticoAmarillo)' AS Alerta,
    c.nombre,
    c.email,
    c.recibirAlertasAdvertencias,
    c.fundoID,
    c.sectorID
FROM image.Contacto c
WHERE c.activo = 1
  AND c.statusID = 1
  AND c.recibirAlertasAdvertencias = 1
  AND (c.fundoID IS NULL OR c.fundoID IN (
    SELECT COALESCE(le.fundoID, CAST(s.farmID AS VARCHAR))
    FROM image.Alerta a
    INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
    LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
    WHERE a.alertaID = 3
  ));

-- Para alerta 4 (CriticoRojo)
SELECT 
    'Alerta 4 (CriticoRojo)' AS Alerta,
    c.nombre,
    c.email,
    c.recibirAlertasCriticas,
    c.fundoID,
    c.sectorID
FROM image.Contacto c
WHERE c.activo = 1
  AND c.statusID = 1
  AND c.recibirAlertasCriticas = 1
  AND (c.fundoID IS NULL OR c.fundoID IN (
    SELECT COALESCE(le.fundoID, CAST(s.farmID AS VARCHAR))
    FROM image.Alerta a
    INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
    LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
    WHERE a.alertaID = 4
  ));
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  Si ves tu email (jemner.vera@agricolaandrea.com) arriba,';
PRINT '  puedes proceder a consolidar las alertas';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

