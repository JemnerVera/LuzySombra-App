-- =====================================================
-- SCRIPT: Actualizar Stored Procedure evalImagen.usp_evalImagen_insertAnalisisImagen (V2)
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Actualizar SP para usar tabla metadataImagen separada
-- =====================================================
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Stored Procedures:
--      - evalImagen.usp_evalImagen_insertAnalisisImagen (UPDATE)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: evalImagen.metadataImagen (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   1. Crear tabla metadataImagen
--   2. Migrar datos existentes
--   3. Ejecutar este script para actualizar el SP
--   4. Actualizar código backend
--   5. (Opcional) Eliminar columnas antiguas
-- 
-- CAMBIOS RESPECTO A V1:
--   - Elimina processedImageUrl y originalImageUrl del INSERT en analisisImagen
--   - Inserta imágenes en metadataImagen después de insertar en analisisImagen
-- 
-- =====================================================

-- ⚠️ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

-- =====================================================
-- Actualizar Stored Procedure
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
    @modeloDispositivo NVARCHAR(100) = NULL,
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
        
        -- 1. Obtener growerID desde empresa (SIN filtrar por statusID - puede estar inactivo)
        SELECT TOP 1 @growerID = growerID
        FROM GROWER.GROWERS
        WHERE businessName = @empresa;
        
        IF @growerID IS NULL
        BEGIN
            RAISERROR('Empresa no encontrada: %s', 16, 1, @empresa);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 2. Obtener farmID desde fundo (SIN filtrar por statusID)
        SELECT TOP 1 @farmID = f.farmID
        FROM GROWER.FARMS f
        INNER JOIN GROWER.STAGE s ON f.farmID = s.farmID
        WHERE f.Description = @fundo
          AND s.growerID = @growerID;
        
        IF @farmID IS NULL
        BEGIN
            RAISERROR('Fundo no encontrado: %s en empresa %s', 16, 1, @fundo, @empresa);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 3. Obtener stageID desde sector (SIN filtrar por statusID)
        SELECT TOP 1 @stageID = stageID
        FROM GROWER.STAGE
        WHERE stage = @sector
          AND farmID = @farmID;
        
        IF @stageID IS NULL
        BEGIN
            RAISERROR('Sector no encontrado: %s en fundo %s', 16, 1, @sector, @fundo);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- 4. Obtener lotID desde lote (SIN filtrar por statusID)
        SELECT TOP 1 @lotID = lotID
        FROM GROWER.LOT
        WHERE name = @lote
          AND stageID = @stageID;
        
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
        ORDER BY analisisID DESC;
        
        -- Si ya existe, retornar el ID existente y salir (sin error)
        IF @existingAnalisisID IS NOT NULL
        BEGIN
            SET @analisisID = @existingAnalisisID;
            PRINT '⚠️ Registro ya existe para filename=' + @filename + ', lotID=' + CAST(@lotID AS VARCHAR(10)) + '. Retornando analisisID existente: ' + CAST(@analisisID AS VARCHAR(10));
            
            -- Actualizar modeloDispositivo si se proporciona y está vacío
            IF @modeloDispositivo IS NOT NULL
            BEGIN
                UPDATE evalImagen.analisisImagen
                SET modeloDispositivo = @modeloDispositivo
                WHERE analisisID = @existingAnalisisID AND (modeloDispositivo IS NULL OR modeloDispositivo = '');
            END

            -- Actualizar imágenes si se proporcionan y no existen
            IF (@processedImageUrl IS NOT NULL OR @originalImageUrl IS NOT NULL)
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM evalImagen.metadataImagen WHERE analisisID = @existingAnalisisID)
                BEGIN
                    INSERT INTO evalImagen.metadataImagen (
                        analisisID,
                        processedImageUrl,
                        originalImageUrl,
                        statusID,
                        usuarioCreaID,
                        fechaCreacion
                    )
                    VALUES (
                        @existingAnalisisID,
                        @processedImageUrl,
                        @originalImageUrl,
                        1,
                        @usuarioCreaID,
                        GETDATE()
                    );
                END
                ELSE
                BEGIN
                    -- Actualizar imágenes existentes
                    UPDATE evalImagen.metadataImagen
                    SET processedImageUrl = @processedImageUrl,
                        originalImageUrl = @originalImageUrl,
                        usuarioModificaID = @usuarioCreaID,
                        fechaModificacion = GETDATE()
                    WHERE analisisID = @existingAnalisisID;
                END
            END
            
            COMMIT TRANSACTION;
            RETURN;
        END;
        
        -- 6. Insertar en evalImagen.analisisImagen (SIN las columnas de imágenes)
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
            modeloDispositivo,
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
            @modeloDispositivo,
            @usuarioCreaID,
            GETDATE(),
            1
        );
        
        -- 7. Obtener el ID insertado
        SET @analisisID = SCOPE_IDENTITY();
        
        -- 8. Insertar imágenes en metadataImagen (solo si se proporcionan)
        IF (@processedImageUrl IS NOT NULL OR @originalImageUrl IS NOT NULL)
        BEGIN
            INSERT INTO evalImagen.metadataImagen (
                analisisID,
                processedImageUrl,
                originalImageUrl,
                statusID,
                usuarioCreaID,
                fechaCreacion
            )
            VALUES (
                @analisisID,
                @processedImageUrl,
                @originalImageUrl,
                1,
                @usuarioCreaID,
                GETDATE()
            );
        END
        
        -- 9. Ejecutar usp_evalImagen_calcularLoteEvaluacion para actualizar estadísticas
        BEGIN TRY
            EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion 
                @LotID = @lotID,
                @PeriodoDias = 30,
                @ForzarRecalculo = 1;
            PRINT '✅ Evaluación de lote calculada exitosamente para lotID=' + CAST(@lotID AS VARCHAR(10));
        END TRY
        BEGIN CATCH
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

PRINT '[OK] Stored Procedure evalImagen.usp_evalImagen_insertAnalisisImagen actualizado (V2)';
GO

