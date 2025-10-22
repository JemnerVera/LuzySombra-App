-- =====================================================
-- Query para obtener fenología agregada por Lote
-- Vista consolidada del estado fenológico actual
-- Base de datos: BD_PACKING_AGROMIGIVA_PRD
-- =====================================================

-- Vista consolidada de fenología por lote (sin grower.grower)
SELECT 
    -- Última fecha de evaluación
    MAX(ep.Fecha) AS UltimaFecha,
    
    -- Jerarquía (usando stage)
    s.growerID AS Empresa,
    s.farmID AS Fundo,
    s.stage AS Sector,
    l.name AS Lote,
    l.lotID,
    
    -- Estado fenológico actual
    ef.EstadoFenologicoNom AS EstadoFenologicoActual,
    ef.EstadoFenologicoId,
    
    -- Días en el estado actual
    DATEDIFF(DAY, 
        MIN(ep.Fecha), 
        MAX(ep.Fecha)
    ) + 1 AS DiasFenologiaActual,
    
    -- Fecha inicio del estado
    MIN(ep.Fecha) AS FechaInicioEstado,
    
    -- Contadores
    COUNT(DISTINCT ep.evaluacionPlagaEnfermedadID) AS TotalEvaluaciones,
    COUNT(DISTINCT CONCAT(ep.Hilera, '-', ep.Planta)) AS TotalPlantasEvaluadas

FROM evalAgri.evaluacionPlagaEnfermedad ep

INNER JOIN evalAgri.EstadoFenologico ef 
    ON ep.EstadoFenologicoId = ef.EstadoFenologicoId

INNER JOIN grower.lot l 
    ON l.lotID = ep.lotID

INNER JOIN grower.stage s 
    ON l.stageID = s.stageID

WHERE ep.estadoID = 1

GROUP BY 
    s.growerID,
    s.farmID,
    s.stage,
    l.name,
    l.lotID,
    ef.EstadoFenologicoNom,
    ef.EstadoFenologicoId

ORDER BY 
    MAX(ep.Fecha) DESC,
    s.growerID,
    s.farmID,
    s.stage,
    l.name;

