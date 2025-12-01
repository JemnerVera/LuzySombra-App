-- =====================================================
-- Script: Crear Mensaje de Prueba para Resend
-- Descripción: Crea un mensaje de prueba en image.Mensaje
--              para probar el envío vía Resend API
-- Fecha: 2025-11-19
-- Autor: Sistema LuzSombra
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Verificar que existe el contacto de prueba
IF NOT EXISTS (SELECT 1 FROM image.Contacto WHERE email = 'jemner.vera@agricolaandrea.com' AND activo = 1)
BEGIN
    PRINT '⚠️ No existe contacto jemner.vera@agricolaandrea.com. Ejecuta primero: insertar_contacto_jemner.sql';
    RETURN;
END
GO

-- Crear mensaje de prueba
DECLARE @mensajeID INT;
DECLARE @fundoID VARCHAR(4) = 'VAL'; -- Fundo Valerie
DECLARE @destinatarios NVARCHAR(MAX) = '["jemner.vera@agricolaandrea.com"]';
DECLARE @asunto NVARCHAR(500) = '🧪 Prueba de Resend API - LuzSombra';
DECLARE @cuerpoHTML NVARCHAR(MAX) = '
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { background-color: #f9f9f9; padding: 20px; margin-top: 20px; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
        .alert { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧪 Prueba de Resend API</h1>
        </div>
        <div class="content">
            <h2>Mensaje de Prueba</h2>
            <p>Este es un mensaje de prueba para verificar que la integración con Resend API está funcionando correctamente.</p>
            <div class="alert">
                <strong>✅ Configuración:</strong><br>
                - API Key: Configurada<br>
                - Dominio: updates.agricolaandrea.com<br>
                - Remitente: Sistema de Alertas LuzSombra<br>
            </div>
            <p>Si recibes este email, significa que:</p>
            <ul>
                <li>✅ Resend API está funcionando</li>
                <li>✅ El dominio está verificado</li>
                <li>✅ La configuración es correcta</li>
            </ul>
        </div>
        <div class="footer">
            <p>Sistema de Alertas LuzSombra - Prueba de Integración</p>
            <p>Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120) + '</p>
        </div>
    </div>
</body>
</html>
';

DECLARE @cuerpoTexto NVARCHAR(MAX) = '
PRUEBA DE RESEND API
====================

Este es un mensaje de prueba para verificar que la integración con Resend API está funcionando correctamente.

Configuración:
- API Key: Configurada
- Dominio: updates.agricolaandrea.com
- Remitente: Sistema de Alertas LuzSombra

Si recibes este email, significa que:
- Resend API está funcionando
- El dominio está verificado
- La configuración es correcta

Sistema de Alertas LuzSombra - Prueba de Integración
Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);

-- Insertar mensaje de prueba
INSERT INTO image.Mensaje (
    alertaID,
    fundoID,
    tipoMensaje,
    asunto,
    cuerpoHTML,
    cuerpoTexto,
    destinatarios,
    destinatariosCC,
    destinatariosBCC,
    estado,
    intentosEnvio,
    fechaCreacion,
    statusID
)
VALUES (
    NULL, -- alertaID (NULL porque es mensaje de prueba)
    @fundoID,
    'Email', -- tipoMensaje debe ser: 'Email', 'SMS', o 'Push'
    @asunto,
    @cuerpoHTML,
    @cuerpoTexto,
    @destinatarios,
    NULL, -- destinatariosCC
    NULL, -- destinatariosBCC
    'Pendiente',
    0,
    GETDATE(),
    1
);

SET @mensajeID = SCOPE_IDENTITY();

PRINT '✅ Mensaje de prueba creado exitosamente';
PRINT '   MensajeID: ' + CAST(@mensajeID AS VARCHAR);
PRINT '   Destinatario: jemner.vera@agricolaandrea.com';
PRINT '   Estado: Pendiente';
PRINT '';
PRINT '📧 Para enviar el mensaje, ejecuta:';
PRINT '   POST http://localhost:3001/api/alertas/enviar/' + CAST(@mensajeID AS VARCHAR);
PRINT '   O: POST http://localhost:3001/api/alertas/enviar (envía todos los pendientes)';
GO

