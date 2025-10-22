-- =====================================================
-- Query para obtener datos de fenología detallados
-- Por: Hilera y Planta
-- Base de datos: BD_PACKING_AGROMIGIVA_PRD
-- =====================================================

-- Query simplificado para obtener datos de fenología por lote
SELECT 
    -- Información temporal
    CAST(ep.Fecha AS DATE) AS Fecha,
    
    -- Jerarquía organizacional (usando stage directamente)
    s.growerID AS Empresa,
    s.farmID AS Fundo,
    s.stage AS Sector,
    l.name AS Lote,
    
    -- Ubicación específica
    ep.Hilera,
    ep.Planta,
    
    -- Información fenológica
    ef.EstadoFenologicoNom AS EstadoFenologico,
    ef.EstadoFenologicoId,
    
    -- Días de fenología (calculado desde inicio del estado)
    DATEDIFF(DAY, 
        (SELECT MIN(ep2.Fecha) 
         FROM evalAgri.evaluacionPlagaEnfermedad ep2 
         WHERE ep2.lotID = ep.lotID 
           AND ep2.EstadoFenologicoId = ep.EstadoFenologicoId
           AND ep2.estadoID = 1
        ), 
        ep.Fecha
    ) + 1 AS DiasFenologia,
    
    -- Metadatos
    ep.EvaluadorNombre,
    ep.evaluacionPlagaEnfermedadID,
    
    -- Timestamp de actualización
    SYSDATETIMEOFFSET() AT TIME ZONE 'SA Pacific Standard Time' AS FechaActualizacion

FROM evalAgri.evaluacionPlagaEnfermedad ep

-- Joins para obtener jerarquía
INNER JOIN evalAgri.EstadoFenologico ef 
    ON ep.EstadoFenologicoId = ef.EstadoFenologicoId

INNER JOIN grower.lot l 
    ON l.lotID = ep.lotID

INNER JOIN grower.stage s 
    ON l.stageID = s.stageID

-- Filtros
WHERE ep.estadoID = 1  -- Solo registros activos

-- Ordenamiento
ORDER BY 
    ep.Fecha DESC,
    s.growerID,
    s.farmID,
    s.stage,
    l.name,
    ep.Hilera,
    ep.Planta;

