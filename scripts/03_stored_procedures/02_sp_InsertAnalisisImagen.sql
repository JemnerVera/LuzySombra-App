-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.usp_evalImagen_insertAnalisisImagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Insertar análisis de imagen y obtener IDs necesarios desde nombres
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Stored Procedures:
--      - evalImagen.usp_evalImagen_insertAnalisisImagen
--   ✅ Extended Properties:
--      - Documentación de stored procedure y parámetros
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas (al ejecutarse):
--      - evalImagen.analisisImagen (INSERT)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.analisisImagen (tabla)
--   ⚠️  Requiere: GROWER.GROWERS, GROWER.FARMS, GROWER.STAGE, GROWER.LOT (tablas existentes)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear evalImagen.analisisImagen
-- 
-- USADO POR:
--   - Backend: src/services/sqlServerService.ts (saveProcessingResult)
--   - Backend: src/routes/photo-upload.ts (procesamiento de imágenes)
-- 
-- PARÁMETROS:
--   @empresa VARCHAR(100) - Nombre de la empresa
--   @fundo VARCHAR(100) - Nombre del fundo
--   @sector VARCHAR(100) - Nombre del sector
--   @lote VARCHAR(100) - Nombre del lote
--   @hilera NVARCHAR(50) - Número de hilera
--   @planta NVARCHAR(50) - Número de planta
--   @filename NVARCHAR(500) - Nombre del archivo
--   @processedImageUrl NVARCHAR(MAX) - URL de la imagen procesada
--   @originalImageUrl NVARCHAR(MAX) - URL de la imagen original
--   @fechaCaptura DATETIME NULL - Fecha de captura (EXIF)
--   @porcentajeLuz DECIMAL(5,2) - Porcentaje de luz detectado
--   @porcentajeSombra DECIMAL(5,2) - Porcentaje de sombra detectado
--   @latitud DECIMAL(10,8) NULL - Latitud GPS
--   @longitud DECIMAL(11,8) NULL - Longitud GPS
--   @usuarioCreaID INT NULL - ID del usuario que crea (si NULL, usa el primer usuario activo de MAST.USERS)
-- 
-- RETORNO:
--   @analisisID INT OUTPUT - ID del análisis insertado
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear Stored Procedure
-- =====================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usp_evalImagen_insertAnalisisImagen') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.usp_evalImagen_insertAnalisisImagen;
GO

CREATE PROCEDURE evalImagen.usp_evalImagen_insertAnalisisImagen
    @empresa VARCHAR(100),
    @fundo VARCHAR(100),
    @sector VARCHAR(100),
    @lote VARCHAR(100),
    @hilera NVARCHAR(50),
    @planta NVARCHAR(50),
    @filename NVARCHAR(500),
    @processedImageUrl NVARCHAR(MAX),
    @originalImageUrl NVARCHAR(MAX) = NULL,
    @fechaCaptura DATETIME = NULL,
    @porcentajeLuz DECIMAL(5,2),
    @porcentajeSombra DECIMAL(5,2),
    @latitud DECIMAL(10,8) = NULL,
    @longitud DECIMAL(11,8) = NULL,
    @usuarioCreaID INT = NULL,
    @analisisID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Variables para almacenar IDs
        DECLARE @growerID VARCHAR(10);
        DECLARE @farmID CHAR(4);
        DECLARE @stageID INT;
        DECLARE @lotID INT;
        DECLARE @userID INT;
        
        -- 1. Obtener growerID desde empresa
        SELECT TOP 1 @growerID = growerID
        FROM GROWER.GROWERS
        WHERE businessName = @empresa
          AND statusID = 1;
        
        IF @growerID IS NULL
        BEGIN
            RAISERROR('Empresa no encontrada: %s', 16, 1, @empresa);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 2. Obtener farmID desde fundo
        SELECT TOP 1 @farmID = f.farmID
        FROM GROWER.FARMS f
        INNER JOIN GROWER.STAGE s ON f.farmID = s.farmID
        WHERE f.Description = @fundo
          AND s.growerID = @growerID
          AND f.statusID = 1
          AND s.statusID = 1;
        
        IF @farmID IS NULL
        BEGIN
            RAISERROR('Fundo no encontrado: %s en empresa %s', 16, 1, @fundo, @empresa);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 3. Obtener stageID desde sector
        SELECT TOP 1 @stageID = stageID
        FROM GROWER.STAGE
        WHERE stage = @sector
          AND farmID = @farmID
          AND statusID = 1;
        
        IF @stageID IS NULL
        BEGIN
            RAISERROR('Sector no encontrado: %s en fundo %s', 16, 1, @sector, @fundo);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 4. Obtener lotID desde lote
        SELECT TOP 1 @lotID = lotID
        FROM GROWER.LOT
        WHERE name = @lote
          AND stageID = @stageID
          AND statusID = 1;
        
        IF @lotID IS NULL
        BEGIN
            RAISERROR('Lote no encontrado: %s en sector %s', 16, 1, @lote, @sector);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 5. Obtener usuarioCreaID (si no se proporciona, usar el primero activo)
        IF @usuarioCreaID IS NULL
        BEGIN
            SELECT TOP 1 @userID = userID
            FROM MAST.USERS
            WHERE statusID = 1
            ORDER BY userID;
            
            IF @userID IS NOT NULL
                SET @usuarioCreaID = @userID;
            ELSE
                SET @usuarioCreaID = 1; -- Valor por defecto
        END;
        
        -- 5.5. Verificar si el registro ya existe (para evitar error de duplicado)
        DECLARE @existingAnalisisID INT = NULL;
        SELECT TOP 1 @existingAnalisisID = analisisID
        FROM evalImagen.analisisImagen
        WHERE filename = @filename
          AND lotID = @lotID
          AND statusID = 1
        ORDER BY analisisID DESC; -- Obtener el más reciente
        
        -- Si ya existe, retornar el ID existente y salir (sin error)
        IF @existingAnalisisID IS NOT NULL
        BEGIN
            SET @analisisID = @existingAnalisisID; -- Establecer OUTPUT explícitamente
            PRINT '⚠️ Registro ya existe para filename=' + @filename + ', lotID=' + CAST(@lotID AS VARCHAR(10)) + '. Retornando analisisID existente: ' + CAST(@analisisID AS VARCHAR(10));
            COMMIT TRANSACTION;
            -- El OUTPUT @analisisID está establecido explícitamente
            RETURN;
        END;
        
        -- 6. Insertar en evalImagen.AnalisisImagen
        INSERT INTO evalImagen.analisisImagen (
            lotID,
            hilera,
            planta,
            filename,
            fechaCaptura,
            porcentajeLuz,
            porcentajeSombra,
            latitud,
            longitud,
            processedImageUrl,
            originalImageUrl,
            usuarioCreaID,
            fechaCreacion,
            statusID
        )
        VALUES (
            @lotID,
            @hilera,
            @planta,
            @filename,
            @fechaCaptura,
            @porcentajeLuz,
            @porcentajeSombra,
            @latitud,
            @longitud,
            @processedImageUrl,
            @originalImageUrl,
            @usuarioCreaID,
            GETDATE(),
            1
        );
        
        -- 7. Obtener el ID insertado
        SET @analisisID = SCOPE_IDENTITY();
        
        -- 8. Ejecutar usp_evalImagen_calcularLoteEvaluacion para actualizar estadísticas
        -- IMPORTANTE: Siempre recalcular para asegurar que se actualice con los nuevos datos
        BEGIN TRY
            EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion 
                @LotID = @lotID,
                @PeriodoDias = 30,
                @ForzarRecalculo = 1;  -- Forzar recálculo para asegurar actualización
            PRINT '✅ Evaluación de lote calculada exitosamente para lotID=' + CAST(@lotID AS VARCHAR(10));
        END TRY
        BEGIN CATCH
            -- Si falla el cálculo, solo loguear pero no fallar la inserción
            PRINT '⚠️ Advertencia: Error al calcular evaluación de lote: ' + ERROR_MESSAGE();
            PRINT '   lotID=' + CAST(@lotID AS VARCHAR(10));
        END CATCH;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Inserta un análisis de imagen en evalImagen.analisisImagen, obteniendo automáticamente los IDs necesarios desde los nombres de empresa, fundo, sector y lote. También ejecuta usp_evalImagen_calcularLoteEvaluacion para actualizar estadísticas.',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_insertAnalisisImagen';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Nombre de la empresa (businessName)',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_insertAnalisisImagen',
    @level2type = N'PARAMETER', @level2name = N'@empresa';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Nombre del fundo (Description)',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_insertAnalisisImagen',
    @level2type = N'PARAMETER', @level2name = N'@fundo';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Nombre del sector (stage)',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_insertAnalisisImagen',
    @level2type = N'PARAMETER', @level2name = N'@sector';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Nombre del lote (name)',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_insertAnalisisImagen',
    @level2type = N'PARAMETER', @level2name = N'@lote';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'ID del análisis insertado (OUTPUT)',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_insertAnalisisImagen',
    @level2type = N'PARAMETER', @level2name = N'@analisisID';
GO

PRINT '[OK] Stored Procedure evalImagen.usp_evalImagen_insertAnalisisImagen creado exitosamente';
GO

