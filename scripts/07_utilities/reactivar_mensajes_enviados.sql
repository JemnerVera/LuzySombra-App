-- =====================================================
-- Script: Reactivar Mensajes Enviados
-- Descripción: Reactiva los primeros 2 mensajes enviados
--              para que vuelvan a estado "Pendiente" y se puedan reenviar
-- Fecha: 2025-11-19
-- Autor: Sistema LuzSombra
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  REACTIVANDO PRIMEROS 2 MENSAJES ENVIADOS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- Verificar mensajes enviados
DECLARE @mensajesEnviados INT;
SELECT @mensajesEnviados = COUNT(*)
FROM image.Mensaje
WHERE estado = 'Enviado'
    AND statusID = 1;

PRINT '📊 Mensajes enviados encontrados: ' + CAST(@mensajesEnviados AS VARCHAR);
PRINT '';

IF @mensajesEnviados = 0
BEGIN
    PRINT '⚠️ No se encontraron mensajes con estado "Enviado"';
    PRINT '   Verificando mensajes con otros estados...';
    
    SELECT 
        mensajeID,
        estado,
        asunto,
        fechaEnvio,
        intentosEnvio
    FROM image.Mensaje
    WHERE statusID = 1
    ORDER BY mensajeID ASC;
    
    RETURN;
END
GO

-- Mostrar los primeros 2 mensajes que se van a reactivar
PRINT '=== Mensajes que se reactivarán ===';
SELECT TOP 2
    mensajeID,
    estado,
    asunto,
    fechaEnvio,
    intentosEnvio,
    resendMessageID
FROM image.Mensaje
WHERE estado = 'Enviado'
    AND statusID = 1
ORDER BY mensajeID ASC;
GO

-- Reactivar los primeros 2 mensajes enviados
DECLARE @mensajesActualizados INT;

UPDATE TOP (2) m
SET 
    estado = 'Pendiente',
    fechaEnvio = NULL,
    intentosEnvio = 0,
    ultimoIntentoEnvio = NULL,
    resendMessageID = NULL,
    resendResponse = NULL,
    errorMessage = NULL
FROM image.Mensaje m
WHERE m.estado = 'Enviado'
    AND m.statusID = 1
    AND m.mensajeID IN (
        SELECT TOP 2 mensajeID
        FROM image.Mensaje
        WHERE estado = 'Enviado'
            AND statusID = 1
        ORDER BY mensajeID ASC
    );

SET @mensajesActualizados = @@ROWCOUNT;

PRINT '';
PRINT '✅ Mensajes reactivados: ' + CAST(@mensajesActualizados AS VARCHAR);
PRINT '';

-- Mostrar los mensajes reactivados
PRINT '=== Mensajes reactivados ===';
SELECT 
    mensajeID,
    estado,
    asunto,
    fechaEnvio,
    intentosEnvio
FROM image.Mensaje
WHERE mensajeID IN (
    SELECT TOP 2 mensajeID
    FROM image.Mensaje
    WHERE estado = 'Pendiente'
        AND statusID = 1
        AND fechaEnvio IS NULL
        AND intentosEnvio = 0
    ORDER BY mensajeID ASC
)
ORDER BY mensajeID ASC;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ REACTIVACIÓN COMPLETADA';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📧 Para enviar los mensajes reactivados, ejecuta:';
PRINT '   POST http://localhost:3001/api/alertas/enviar';
PRINT '   (Esto enviará todos los mensajes con estado "Pendiente")';
GO

