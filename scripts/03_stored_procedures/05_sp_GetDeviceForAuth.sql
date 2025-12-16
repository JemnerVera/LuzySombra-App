-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.usp_evalImagen_getDeviceForAuth
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Obtener información del dispositivo para autenticación (incluye hash)
-- =====================================================
-- 
-- NOTA: La comparación de hash bcrypt se hace en el backend (Node.js)
-- SQL Server no tiene soporte nativo para bcrypt
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usp_evalImagen_getDeviceForAuth') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.usp_evalImagen_getDeviceForAuth;
GO

CREATE PROCEDURE evalImagen.usp_evalImagen_getDeviceForAuth
    @deviceId VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        SELECT 
            dispositivoID,
            deviceId,
            apiKeyHash,              -- Hash bcrypt de la API key
            nombreDispositivo,
            activo,
            statusID
        FROM evalImagen.dispositivo
        WHERE deviceId = @deviceId
          AND statusID = 1;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene información del dispositivo (incluyendo apiKeyHash) para autenticación. La comparación de hash se hace en el backend.',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_getDeviceForAuth';
GO

PRINT '[OK] Stored Procedure evalImagen.usp_evalImagen_getDeviceForAuth creado exitosamente';
GO

