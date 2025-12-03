-- =====================================================
-- SCRIPT: Crear Vista vwc_Cianamida_fenologia
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: dbo
-- Propósito: Vista compuesta que consolida información de días desde cianamida
-- y estado fenológico por lote. Prioriza estado fenológico desde cianamida,
-- fallback a evaluaciones.
-- Estándares: vwc_[Modulo]_[nombreLowerCamelCase] para vistas compuestas
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Vistas:
--      - dbo.vwc_Cianamida_fenologia
--   ✅ Extended Properties:
--      - Documentación de vista y columnas
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: PPP.PROYECCION (tabla existente)
--   ⚠️  Requiere: PPP.PROYECCIONDETALLEFITOSANIDAD (tabla existente)
--   ⚠️  Requiere: PPP.PROGRAMACIONFITOSANIDADDETALLE (tabla existente)
--   ⚠️  Requiere: PPP.PROGRAMACION (tabla existente)
--   ⚠️  Requiere: PROPER.PROGRAMACIONFITOSANIDADMOVIMIENTOS (tabla existente)
--   ⚠️  Requiere: PROPER.PARAMETROS (tabla existente) - para IDs_CIANAMIDA
--   ⚠️  Requiere: PPP.ESTADOFENOLOGICO (tabla existente)
--   ⚠️  Requiere: evalAgri.evaluacionPlagaEnfermedad (tabla existente)
--   ⚠️  Requiere: evalAgri.EstadoFenologico (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento (no depende de schema image)
-- 
-- USADO POR:
--   - getConsolidatedTable (query consolidada - fuente de fenología/cianamida)
--   - src/services/sqlServerService.ts (getConsolidatedTable)
-- 
-- =====================================================

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwc_Cianamida_fenologia]'))
    DROP VIEW [dbo].[vwc_Cianamida_fenologia];
GO

CREATE VIEW [dbo].[vwc_Cianamida_fenologia]
AS
WITH CianamidaData AS (
    -- Query de cianamida proporcionado por PROD - Solo la mas reciente por lote
    -- Incluye estado fenologico desde PROYECCIONDETALLEFITOSANIDAD
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
    -- Estado fenologico mas reciente desde evalAgri.evaluacionPlagaEnfermedad (fallback)
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
    cd.DIAS AS diasCianamida,
    cd.FECHAPROGRAMACION AS fechaCianamida,
    cd.CAMPAIGNID,
    -- Estado fenologico: prioridad a cianamida, fallback a evaluacion
    COALESCE(ef_cianamida.cfdescripcion, ef_eval.EstadoFenologicoNom) AS estadoFenologico
FROM GROWER.LOT l WITH (NOLOCK)
LEFT JOIN CianamidaFinal cd ON l.lotID = cd.LOTID
LEFT JOIN PPP.ESTADOFENOLOGICO ef_cianamida WITH (NOLOCK) 
    ON cd.estadoFenologicoID = ef_cianamida.estadofenologicoID
LEFT JOIN EstadoFenologicoFinal efe ON l.lotID = efe.lotID
LEFT JOIN evalAgri.EstadoFenologico ef_eval WITH (NOLOCK) 
    ON efe.EstadoFenologicoId = ef_eval.EstadoFenologicoId
WHERE l.statusID = 1;
GO

-- =====================================================
-- Documentacion extendida de la vista (estandar AgroMigiva)
-- =====================================================

EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Vista compuesta que consolida informacion de dias desde cianamida y estado fenologico por lote. Prioriza estado fenologico desde datos de cianamida, con fallback a evaluaciones agronomicas.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vwc_Cianamida_fenologia';
GO

-- Documentacion de columnas
EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Identificador unico del lote (FK a GROWER.LOT)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vwc_Cianamida_fenologia',
    @level2type = N'COLUMN', @level2name = N'lotID';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Dias transcurridos desde la fecha de programacion de cianamida hasta la fecha actual',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vwc_Cianamida_fenologia',
    @level2type = N'COLUMN', @level2name = N'diasCianamida';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Fecha de programacion de aplicacion de cianamida',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vwc_Cianamida_fenologia',
    @level2type = N'COLUMN', @level2name = N'fechaCianamida';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Identificador de la campana agricola (FK a GROWER.CAMPAIGN)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vwc_Cianamida_fenologia',
    @level2type = N'COLUMN', @level2name = N'CAMPAIGNID';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Descripcion del estado fenologico. Prioriza estado desde datos de cianamida (PPP.ESTADOFENOLOGICO), con fallback a estado desde evaluaciones (evalAgri.EstadoFenologico)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'vwc_Cianamida_fenologia',
    @level2type = N'COLUMN', @level2name = N'estadoFenologico';
GO

-- Otorgar permisos de lectura (si es necesario)
-- GRANT SELECT ON [dbo].[vwc_Cianamida_fenologia] TO [ucser_powerbi_desa];
GO

PRINT '✅ Vista vwc_Cianamida_fenologia creada exitosamente con documentacion extendida';
GO 