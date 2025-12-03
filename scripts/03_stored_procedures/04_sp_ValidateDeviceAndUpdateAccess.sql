-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.sp_ValidateDeviceAndUpdateAccess
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Validar credenciales de dispositivo y actualizar último acceso
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Stored Procedures:
--      - evalImagen.sp_ValidateDeviceAndUpdateAccess
--   ✅ Extended Properties:
--      - Documentación de stored procedure y parámetros
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas (al ejecutarse):
--      - evalImagen.dispositivo (UPDATE ultimoAcceso)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.dispositivo (tabla)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear evalImagen.dispositivo
-- 
-- USADO POR:
--   - Backend: src/routes/auth.ts (POST /api/auth/login)
--   - Autenticación de dispositivos AgriQR
-- 
-- PARÁMETROS:
--   @deviceId VARCHAR(100) - ID del dispositivo
--   @apiKey VARCHAR(255) - API Key del dispositivo
-- 
-- RETORNO:
--   @dispositivoID INT OUTPUT - ID del dispositivo si es válido, NULL si no
--   @nombreDispositivo NVARCHAR(100) OUTPUT - Nombre del dispositivo
--   @activo BIT OUTPUT - Si el dispositivo está activo
--   @isValid BIT OUTPUT - Si las credenciales son válidas (1 = válido, 0 = inválido)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear Stored Procedure
-- =====================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.sp_ValidateDeviceAndUpdateAccess') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.sp_ValidateDeviceAndUpdateAccess;
GO

CREATE PROCEDURE evalImagen.sp_ValidateDeviceAndUpdateAccess
    @deviceId VARCHAR(100),
    @apiKey VARCHAR(255),
    @dispositivoID INT OUTPUT,
    @nombreDispositivo NVARCHAR(100) OUTPUT,
    @activo BIT OUTPUT,
    @isValid BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Inicializar outputs
    SET @dispositivoID = NULL;
    SET @nombreDispositivo = NULL;
    SET @activo = 0;
    SET @isValid = 0;
    
    BEGIN TRY
        -- Buscar dispositivo por deviceId y apiKey
        SELECT 
            @dispositivoID = dispositivoID,
            @nombreDispositivo = nombreDispositivo,
            @activo = activo
        FROM evalImagen.dispositivo
        WHERE deviceId = @deviceId
          AND apiKey = @apiKey
          AND statusID = 1;
        
        -- Si se encontró el dispositivo y está activo, es válido
        IF @dispositivoID IS NOT NULL AND @activo = 1
        BEGIN
            SET @isValid = 1;
            
            -- Actualizar último acceso
            UPDATE evalImagen.dispositivo
            SET ultimoAcceso = GETDATE()
            WHERE dispositivoID = @dispositivoID;
        END
        ELSE
        BEGIN
            SET @isValid = 0;
        END;
        
    END TRY
    BEGIN CATCH
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
    @value = N'Valida las credenciales de un dispositivo (deviceId y apiKey) y actualiza su último acceso si es válido y está activo.',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'sp_ValidateDeviceAndUpdateAccess';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'ID único del dispositivo',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'sp_ValidateDeviceAndUpdateAccess',
    @level2type = N'PARAMETER', @level2name = N'@deviceId';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'API Key del dispositivo',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'sp_ValidateDeviceAndUpdateAccess',
    @level2type = N'PARAMETER', @level2name = N'@apiKey';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'1 si las credenciales son válidas y el dispositivo está activo, 0 en caso contrario',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'sp_ValidateDeviceAndUpdateAccess',
    @level2type = N'PARAMETER', @level2name = N'@isValid';
GO

PRINT '[OK] Stored Procedure evalImagen.sp_ValidateDeviceAndUpdateAccess creado exitosamente';
GO

