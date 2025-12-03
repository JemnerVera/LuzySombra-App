-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.sp_RegistrarIntentoLogin
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Registrar intentos de login (exitosos y fallidos)
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.sp_RegistrarIntentoLogin') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.sp_RegistrarIntentoLogin;
GO

CREATE PROCEDURE evalImagen.sp_RegistrarIntentoLogin
    @deviceId VARCHAR(100) = NULL,
    @username VARCHAR(100) = NULL,
    @ipAddress VARCHAR(45),
    @exitoso BIT,
    @motivoFallo VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO evalImagen.intentoLogin (
            deviceId,
            username,
            ipAddress,
            exitoso,
            motivoFallo,
            fechaIntento
        )
        VALUES (
            @deviceId,
            @username,
            @ipAddress,
            @exitoso,
            @motivoFallo,
            GETDATE()
        );
        
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
    @value = N'Registra un intento de login (exitoso o fallido) para rate limiting y auditoría.',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'sp_RegistrarIntentoLogin';
GO

PRINT '[OK] Stored Procedure evalImagen.sp_RegistrarIntentoLogin creado exitosamente';
GO

