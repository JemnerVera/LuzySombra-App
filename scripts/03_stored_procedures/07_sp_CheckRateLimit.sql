-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.usp_evalImagen_checkRateLimit
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Verificar si un dispositivo/IP ha excedido el límite de intentos
-- =====================================================
-- 
-- Límites:
-- - Máximo 5 intentos fallidos en 15 minutos por deviceId/IP
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usp_evalImagen_checkRateLimit') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.usp_evalImagen_checkRateLimit;
GO

CREATE PROCEDURE evalImagen.usp_evalImagen_checkRateLimit
    @deviceId VARCHAR(100) = NULL,
    @username VARCHAR(100) = NULL,
    @ipAddress VARCHAR(45),
    @maxIntentos INT = 5,
    @minutosVentana INT = 15,
    @estaBloqueado BIT OUTPUT,
    @intentosRestantes INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @fechaDesde DATETIME = DATEADD(MINUTE, -@minutosVentana, GETDATE());
    DECLARE @intentosFallidos INT = 0;
    
    SET @estaBloqueado = 0;
    SET @intentosRestantes = @maxIntentos;
    
    BEGIN TRY
        -- Contar intentos fallidos en la ventana de tiempo
        IF @deviceId IS NOT NULL
        BEGIN
            SELECT @intentosFallidos = COUNT(*)
            FROM evalImagen.intentoLogin
            WHERE deviceId = @deviceId
              AND exitoso = 0
              AND fechaIntento >= @fechaDesde;
        END
        ELSE IF @username IS NOT NULL
        BEGIN
            SELECT @intentosFallidos = COUNT(*)
            FROM evalImagen.intentoLogin
            WHERE username = @username
              AND exitoso = 0
              AND fechaIntento >= @fechaDesde;
        END
        
        -- También verificar por IP (más restrictivo)
        DECLARE @intentosPorIP INT = 0;
        SELECT @intentosPorIP = COUNT(*)
        FROM evalImagen.IntentoLogin
        WHERE ipAddress = @ipAddress
          AND exitoso = 0
          AND fechaIntento >= @fechaDesde;
        
        -- Usar el mayor de los dos
        IF @intentosPorIP > @intentosFallidos
            SET @intentosFallidos = @intentosPorIP;
        
        -- Verificar si está bloqueado
        IF @intentosFallidos >= @maxIntentos
        BEGIN
            SET @estaBloqueado = 1;
            SET @intentosRestantes = 0;
        END
        ELSE
        BEGIN
            SET @intentosRestantes = @maxIntentos - @intentosFallidos;
        END
        
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
    @value = N'Verifica si un dispositivo/IP ha excedido el límite de intentos fallidos (5 en 15 minutos).',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'usp_evalImagen_checkRateLimit';
GO

PRINT '[OK] Stored Procedure evalImagen.usp_evalImagen_checkRateLimit creado exitosamente';
GO

