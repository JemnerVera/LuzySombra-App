-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.usp_evalImagen_calcularLoteEvaluacion
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Calcular estadísticas agregadas por lote y actualizar/insertar en LoteEvaluacion
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Stored Procedures:
--      - evalImagen.usp_evalImagen_calcularLoteEvaluacion
--   ✅ Extended Properties:
--      - Documentación de stored procedure y parámetros
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas (al ejecutarse):
--      - evalImagen.LoteEvaluacion (INSERT/UPDATE mediante MERGE)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.AnalisisImagen (tabla - lee datos)
--   ⚠️  Requiere: evalImagen.LoteEvaluacion (tabla - actualiza/inserta)
--   ⚠️  Requiere: evalImagen.UmbralLuz (tabla - compara umbrales)
--   ⚠️  Requiere: GROWER.PLANTATION (tabla existente)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear todas las tablas (evalImagen.AnalisisImagen, evalImagen.LoteEvaluacion, evalImagen.UmbralLuz)
-- 
-- USADO POR:
--   - Backend: src/services/sqlServerService.ts (saveProcessingResult)
--   - Backend: src/app/api/procesar-imagen/route.ts (después de guardar análisis)
--   - Job SQL diario (reconciliación de datos)
--   - Ejecución manual para recalcular estadísticas
-- 
-- PARÁMETROS:
--   @LotID INT = NULL - ID del lote a calcular (NULL = todos los lotes)
--   @PeriodoDias INT = 30 - Período de evaluación en días (por defecto último mes)
--   @ForzarRecalculo BIT = 0 - Si 1, recalcula incluso si ya existe
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear Stored Procedure
-- =====================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usp_evalImagen_calcularLoteEvaluacion') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.usp_evalImagen_calcularLoteEvaluacion;
GO

CREATE PROCEDURE evalImagen.usp_evalImagen_calcularLoteEvaluacion
    @LotID INT = NULL, -- NULL = calcular todos los lotes con evaluaciones
    @PeriodoDias INT = 30, -- Período de evaluación en días (por defecto último mes)
    @ForzarRecalculo BIT = 0 -- Si 1, recalcula incluso si ya existe
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FechaInicio DATETIME;
    SET @FechaInicio = DATEADD(DAY, -@PeriodoDias, GETDATE());
    
    -- CTE con estadísticas calculadas (incluye fundoID y sectorID para optimizar match con Contacto)
    -- IMPORTANTE: Agrupar solo por lotID, sectorID y fundoID (un lote = una entrada)
    -- Para varietyID, tomar la más común o la primera encontrada
    WITH EstadisticasLote AS (
        SELECT 
            ai.lotID,
            s.stageID AS sectorID,
            RTRIM(f.farmID) AS fundoID,  -- RTRIM para quitar espacios en CHAR(4)
            -- Obtener varietyID más común para el lote (si hay múltiples, tomar la primera)
            (SELECT TOP 1 p2.varietyID 
             FROM GROWER.PLANTATION p2 WITH (NOLOCK)
             WHERE p2.lotID = ai.lotID 
               AND p2.statusID = 1
             ORDER BY p2.plantationID) AS varietyID,
            COUNT(*) AS totalEvaluaciones,
            AVG(CAST(ai.porcentajeLuz AS FLOAT)) AS porcentajeLuzPromedio,
            MIN(ai.porcentajeLuz) AS porcentajeLuzMin,
            MAX(ai.porcentajeLuz) AS porcentajeLuzMax,
            AVG(CAST(ai.porcentajeSombra AS FLOAT)) AS porcentajeSombraPromedio,
            MIN(ai.porcentajeSombra) AS porcentajeSombraMin,
            MAX(ai.porcentajeSombra) AS porcentajeSombraMax,
            MAX(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS fechaUltimaEvaluacion,
            MIN(COALESCE(ai.fechaCaptura, ai.fechaCreacion)) AS fechaPrimeraEvaluacion
        FROM evalImagen.analisisImagen ai WITH (NOLOCK)
        INNER JOIN GROWER.LOT l WITH (NOLOCK) ON ai.lotID = l.lotID
        INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
        WHERE ai.statusID = 1
            AND (@LotID IS NULL OR ai.lotID = @LotID)
            -- Aplicar filtro de fecha solo si NO se fuerza recálculo
            -- Si @ForzarRecalculo = 1, incluir TODOS los análisis (sin filtro de fecha)
            AND (
                @ForzarRecalculo = 1 
                OR COALESCE(ai.fechaCaptura, ai.fechaCreacion) >= @FechaInicio
            )
        GROUP BY ai.lotID, s.stageID, f.farmID
    ),
    UmbralesLote AS (
        SELECT 
            el.lotID,
            el.varietyID,
            el.fundoID,
            el.sectorID,
            el.porcentajeLuzPromedio,
            el.porcentajeSombraPromedio,
            el.porcentajeLuzMin,
            el.porcentajeLuzMax,
            el.porcentajeSombraMin,
            el.porcentajeSombraMax,
            el.totalEvaluaciones,
            el.fechaUltimaEvaluacion,
            el.fechaPrimeraEvaluacion,
            -- Obtener umbral correspondiente (prioridad: variedad específica > todas las variedades)
            (
                SELECT TOP 1 u.umbralID
                FROM evalImagen.umbralLuz u
                WHERE u.activo = 1 
                    AND u.statusID = 1
                    AND (u.variedadID = el.varietyID OR u.variedadID IS NULL)
                    AND el.porcentajeLuzPromedio >= u.minPorcentajeLuz 
                    AND el.porcentajeLuzPromedio <= u.maxPorcentajeLuz
                ORDER BY 
                    CASE WHEN u.variedadID IS NOT NULL THEN 0 ELSE 1 END, -- Priorizar variedad específica
                    CASE u.tipo
                        WHEN 'CriticoRojo' THEN 1
                        WHEN 'CriticoAmarillo' THEN 2
                        WHEN 'Normal' THEN 3
                    END,
                    u.orden
            ) AS umbralIDActual,
            (
                SELECT TOP 1 u.tipo
                FROM evalImagen.umbralLuz u
                WHERE u.activo = 1 
                    AND u.statusID = 1
                    AND (u.variedadID = el.varietyID OR u.variedadID IS NULL)
                    AND el.porcentajeLuzPromedio >= u.minPorcentajeLuz 
                    AND el.porcentajeLuzPromedio <= u.maxPorcentajeLuz
                ORDER BY 
                    CASE WHEN u.variedadID IS NOT NULL THEN 0 ELSE 1 END,
                    CASE u.tipo
                        WHEN 'CriticoRojo' THEN 1
                        WHEN 'CriticoAmarillo' THEN 2
                        WHEN 'Normal' THEN 3
                    END,
                    u.orden
            ) AS tipoUmbralActual
        FROM EstadisticasLote el
    )
    -- MERGE para actualizar o insertar
    -- IMPORTANTE: Siempre actualizar si hay nuevos datos o si se fuerza recálculo
    MERGE evalImagen.loteEvaluacion AS target
    USING UmbralesLote AS source
    ON target.lotID = source.lotID
    WHEN MATCHED AND (
        @ForzarRecalculo = 1 
        OR target.fechaUltimaActualizacion < source.fechaUltimaEvaluacion
        OR target.totalEvaluaciones < source.totalEvaluaciones  -- Si hay más evaluaciones, actualizar
        OR target.fechaUltimaEvaluacion < source.fechaUltimaEvaluacion  -- Si hay evaluación más reciente
    )
    THEN
        UPDATE SET
            variedadID = source.varietyID,
            fundoID = source.fundoID,
            sectorID = source.sectorID,
            porcentajeLuzPromedio = source.porcentajeLuzPromedio,
            porcentajeLuzMin = source.porcentajeLuzMin,
            porcentajeLuzMax = source.porcentajeLuzMax,
            porcentajeSombraPromedio = source.porcentajeSombraPromedio,
            porcentajeSombraMin = source.porcentajeSombraMin,
            porcentajeSombraMax = source.porcentajeSombraMax,
            tipoUmbralActual = source.tipoUmbralActual,
            umbralIDActual = source.umbralIDActual,
            fechaUltimaEvaluacion = source.fechaUltimaEvaluacion,
            fechaPrimeraEvaluacion = ISNULL(source.fechaPrimeraEvaluacion, target.fechaPrimeraEvaluacion),
            totalEvaluaciones = source.totalEvaluaciones,
            periodoEvaluacionDias = @PeriodoDias,
            fechaUltimaActualizacion = GETDATE(),
            statusID = 1
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (
            lotID,
            variedadID,
            fundoID,
            sectorID,
            porcentajeLuzPromedio,
            porcentajeLuzMin,
            porcentajeLuzMax,
            porcentajeSombraPromedio,
            porcentajeSombraMin,
            porcentajeSombraMax,
            tipoUmbralActual,
            umbralIDActual,
            fechaUltimaEvaluacion,
            fechaPrimeraEvaluacion,
            totalEvaluaciones,
            periodoEvaluacionDias,
            fechaUltimaActualizacion,
            statusID
        )
        VALUES (
            source.lotID,
            source.varietyID,
            source.fundoID,
            source.sectorID,
            source.porcentajeLuzPromedio,
            source.porcentajeLuzMin,
            source.porcentajeLuzMax,
            source.porcentajeSombraPromedio,
            source.porcentajeSombraMin,
            source.porcentajeSombraMax,
            source.tipoUmbralActual,
            source.umbralIDActual,
            source.fechaUltimaEvaluacion,
            source.fechaPrimeraEvaluacion,
            source.totalEvaluaciones,
            @PeriodoDias,
            GETDATE(),
            1
        );
    
    -- Retornar resumen
    SELECT 
        @@ROWCOUNT AS registrosProcesados,
        (SELECT COUNT(*) FROM evalImagen.loteEvaluacion WHERE statusID = 1) AS totalLotesEvaluados;
END;
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Calcula estadísticas agregadas por lote y actualiza/inserta en evalImagen.loteEvaluacion. Puede calcular para un lote específico o todos los lotes con evaluaciones.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_calcularLoteEvaluacion';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ID del lote a calcular. NULL = calcular todos los lotes con evaluaciones', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_calcularLoteEvaluacion', @level2type = N'PARAMETER', @level2name = N'@LotID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Período de evaluación en días desde la fecha actual (por defecto 30 días = último mes)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_calcularLoteEvaluacion', @level2type = N'PARAMETER', @level2name = N'@PeriodoDias';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Si 1, recalcula incluso si ya existe una evaluación reciente', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_calcularLoteEvaluacion', @level2type = N'PARAMETER', @level2name = N'@ForzarRecalculo';
GO

PRINT '[OK] Stored Procedure evalImagen.usp_evalImagen_calcularLoteEvaluacion creado';
PRINT '';
PRINT '=== Ejemplos de uso ===';
PRINT '-- Calcular para un lote específico:';
PRINT 'EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion @LotID = 1003;';
PRINT '';
PRINT '-- Calcular todos los lotes (último mes):';
PRINT 'EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion;';
PRINT '';
PRINT '-- Calcular todos los lotes (últimos 60 días):';
PRINT 'EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion @PeriodoDias = 60;';
PRINT '';
PRINT '-- Forzar recálculo de todos los lotes:';
PRINT 'EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion @ForzarRecalculo = 1;';
GO

