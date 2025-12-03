-- =====================================================
-- SCRIPT: Test de Vista vwc_Cianamida_fenologia
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Test / Verificación
-- Propósito: Ejecutar query con la misma lógica que tendrá la vista
-- para verificar que los datos son correctos antes de crear la vista
-- Vista: vwc_Cianamida_fenologia (estándar: vwc_[Modulo]_[nombreLowerCamelCase] para vistas compuestas)
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno (solo consultas SELECT de prueba)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno (solo lectura)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere las mismas tablas que vwc_Cianamida_fenologia:
--      - GROWER.LOT
--      - PPP.PROYECCION
--      - PPP.PROYECCIONDETALLEFITOSANIDAD
--      - PPP.PROGRAMACIONFITOSANIDADDETALLE
--      - PPP.PROGRAMACION
--      - PROPER.PROGRAMACIONFITOSANIDADMOVIMIENTOS
--      - PROPER.PARAMETROS
--      - PPP.ESTADOFENOLOGICO
--      - evalAgri.evaluacionPlagaEnfermedad
--      - evalAgri.EstadoFenologico
-- 
-- ORDEN DE EJECUCIÓN:
--   Ejecutar ANTES de crear la vista para validar lógica
-- 
-- CONTENIDO:
--   - Query de prueba con límite de 50 registros
--   - Misma lógica que la vista vwc_Cianamida_fenologia
--   - Útil para debugging y validación
-- 
-- NOTA: Este es un script de TEST, no crea objetos de producción
-- 
-- =====================================================

-- Query de prueba (límite de 50 registros para revisión rápida)
WITH CianamidaData AS (
    -- Query de cianamida proporcionado por PROD - Solo la más reciente por lote
    -- Incluye estado fenológico desde PROYECCIONDETALLEFITOSANIDAD
    SELECT 
        LOTID,
        DIAS,
        CAMPAIGNID,
        estadoFenologicoID,
        FECHAPROGRAMACION,
        ROW_NUMBER() OVER (PARTITION BY LOTID ORDER BY FECHAPROGRAMACION DESC) AS rn
    FROM (
        SELECT 
            A.LOTID,
            D.FECHAPROGRAMACION,
            DATEDIFF(DAY, D.FECHAPROGRAMACION, GETDATE()) AS DIAS,
            A.CAMPAIGNID,
            B.estadoFenologicoID
        FROM PPP.PROYECCION A WITH (NOLOCK)
        INNER JOIN PPP.PROYECCIONDETALLEFITOSANIDAD B WITH (NOLOCK) 
            ON B.PROYECCIONID = A.PROYECCIONID
        INNER JOIN PPP.PROGRAMACIONFITOSANIDADDETALLE C WITH (NOLOCK) 
            ON C.PROYECCIONDETALLEFITOSANIDADID = B.PROYECCIONDETALLEFITOSANIDADID
        INNER JOIN PPP.PROGRAMACION D WITH (NOLOCK) 
            ON D.PROGRAMACIONID = C.PROGRAMACIONID
        INNER JOIN PROPER.PROGRAMACIONFITOSANIDADMOVIMIENTOS E WITH (NOLOCK) 
            ON E.PROGRAMACIONID = D.PROGRAMACIONID
        CROSS APPLY (
            SELECT VALUE AS PRODUCTID 
            FROM STRING_SPLIT((SELECT VALOR FROM PROPER.PARAMETROS WHERE CLAVE = 'IDS_CIANAMIDA'), ',')
        ) AS CIANAMIDA
        WHERE B.PRODUCTID = CIANAMIDA.PRODUCTID 
            AND B.FASECULTIVOID = 1
    ) AS CianamidaRaw
),
CianamidaFinal AS (
    SELECT 
        LOTID, 
        DIAS, 
        CAMPAIGNID,
        estadoFenologicoID,
        FECHAPROGRAMACION
    FROM CianamidaData
    WHERE rn = 1
),
EstadoFenologicoEvaluacion AS (
    -- Estado fenológico más reciente desde evalAgri.evaluacionPlagaEnfermedad (fallback)
    SELECT 
        lotID,
        EstadoFenologicoId,
        Fecha,
        ROW_NUMBER() OVER (PARTITION BY lotID ORDER BY Fecha DESC) AS rn
    FROM evalAgri.evaluacionPlagaEnfermedad WITH (NOLOCK)
    WHERE estadoID = 1
        AND EstadoFenologicoId IS NOT NULL
),
EstadoFenologicoFinal AS (
    SELECT 
        lotID,
        EstadoFenologicoId,
        Fecha AS fechaEvaluacion
    FROM EstadoFenologicoEvaluacion
    WHERE rn = 1
)
SELECT 
    l.lotID,
    l.name AS lote, -- Agregar nombre del lote para referencia
    cd.DIAS AS diasCianamida,
    cd.FECHAPROGRAMACION AS fechaCianamida,
    cd.CAMPAIGNID,
    -- Estado fenológico: prioridad a cianamida, fallback a evaluación
    COALESCE(ef_cianamida.cfdescripcion, ef_eval.EstadoFenologicoNom) AS estadoFenologico,
    cd.estadoFenologicoID AS estadoFenologicoID_Cianamida,
    efe.EstadoFenologicoId AS estadoFenologicoID_Evaluacion,
    efe.fechaEvaluacion
FROM GROWER.LOT l WITH (NOLOCK)
LEFT JOIN CianamidaFinal cd ON l.lotID = cd.LOTID
LEFT JOIN PPP.ESTADOFENOLOGICO ef_cianamida WITH (NOLOCK) 
    ON cd.estadoFenologicoID = ef_cianamida.estadofenologicoID
LEFT JOIN EstadoFenologicoFinal efe ON l.lotID = efe.lotID
LEFT JOIN evalAgri.EstadoFenologico ef_eval WITH (NOLOCK) 
    ON efe.EstadoFenologicoId = ef_eval.EstadoFenologicoId
WHERE l.statusID = 1
ORDER BY l.name
-- Limitar a 50 registros para revisión rápida (quitar TOP 50 antes de crear la vista)
OFFSET 0 ROWS
FETCH NEXT 50 ROWS ONLY;

-- =====================================================
-- Estadísticas de la consulta (para verificar cobertura)
-- =====================================================

PRINT '========================================';
PRINT 'Estadísticas del Query:';
PRINT '========================================';

-- Contar total de lotes activos
SELECT 
    COUNT(*) AS totalLotesActivos
FROM GROWER.LOT l WITH (NOLOCK)
WHERE l.statusID = 1;

-- Contar lotes con datos de cianamida
SELECT 
    COUNT(DISTINCT cd.LOTID) AS lotesConCianamida
FROM (
    SELECT 
        A.LOTID,
        ROW_NUMBER() OVER (PARTITION BY A.LOTID ORDER BY D.FECHAPROGRAMACION DESC) AS rn
    FROM PPP.PROYECCION A WITH (NOLOCK)
    INNER JOIN PPP.PROYECCIONDETALLEFITOSANIDAD B WITH (NOLOCK) 
        ON B.PROYECCIONID = A.PROYECCIONID
    INNER JOIN PPP.PROGRAMACIONFITOSANIDADDETALLE C WITH (NOLOCK) 
        ON C.PROYECCIONDETALLEFITOSANIDADID = B.PROYECCIONDETALLEFITOSANIDADID
    INNER JOIN PPP.PROGRAMACION D WITH (NOLOCK) 
        ON D.PROGRAMACIONID = C.PROGRAMACIONID
    INNER JOIN PROPER.PROGRAMACIONFITOSANIDADMOVIMIENTOS E WITH (NOLOCK) 
        ON E.PROGRAMACIONID = D.PROGRAMACIONID
    CROSS APPLY (
        SELECT VALUE AS PRODUCTID 
        FROM STRING_SPLIT((SELECT VALOR FROM PROPER.PARAMETROS WHERE CLAVE = 'IDS_CIANAMIDA'), ',')
    ) AS CIANAMIDA
    WHERE B.PRODUCTID = CIANAMIDA.PRODUCTID 
        AND B.FASECULTIVOID = 1
) cd
WHERE cd.rn = 1;

-- Contar lotes con estado fenológico desde evaluación
SELECT 
    COUNT(DISTINCT lotID) AS lotesConEstadoFenologicoEval
FROM (
    SELECT 
        lotID,
        ROW_NUMBER() OVER (PARTITION BY lotID ORDER BY Fecha DESC) AS rn
    FROM evalAgri.evaluacionPlagaEnfermedad WITH (NOLOCK)
    WHERE estadoID = 1
        AND EstadoFenologicoId IS NOT NULL
) efe
WHERE efe.rn = 1;

GO

PRINT '✅ Query de prueba ejecutado. Revisa los resultados antes de crear la vista.';
GO
