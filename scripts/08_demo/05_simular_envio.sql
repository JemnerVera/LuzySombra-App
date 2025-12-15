-- =====================================================
-- SCRIPT: Simular Envío - Mostrar proceso de envío (normalmente vía API)
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Mostrar cómo se envían mensajes vía Resend API
-- NOTA: Normalmente esto se hace vía API POST /api/alertas/enviar
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '========================================';
PRINT 'DEMO: Simular Envío de Mensajes';
PRINT '========================================';
PRINT '';
PRINT '⚠️ NOTA: Normalmente el envío se hace vía API:';
PRINT '   POST http://localhost:3001/api/alertas/enviar';
PRINT '';
PRINT 'Este script muestra el proceso, pero es mejor usar la API.';
PRINT '';

-- =====================================================
-- 1. Ver Mensajes Pendientes
-- =====================================================
PRINT '1. Mensajes pendientes de envío:';
PRINT '';

SELECT 
    m.mensajeID,
    m.alertaID,
    m.fundoID,
    m.tipoMensaje,
    m.asunto,
    m.estado,
    m.intentosEnvio,
    m.fechaCreacion,
    m.destinatarios,
    CASE 
        WHEN m.alertaID IS NOT NULL THEN 'Individual'
        ELSE 'Consolidado'
    END AS tipoMensajeDetalle
FROM evalImagen.mensaje m
WHERE m.statusID = 1
  AND m.estado = 'Pendiente'
ORDER BY m.fechaCreacion DESC;

PRINT '';

-- =====================================================
-- 2. Simular Envío Exitoso (Solo para Demo - NO envía emails reales)
-- =====================================================
PRINT '2. Para enviar mensajes, usa la API:';
PRINT '';
PRINT 'POST /api/alertas/enviar';
PRINT '';
PRINT 'O desde curl:';
PRINT 'curl -X POST "http://localhost:3001/api/alertas/enviar"';
PRINT '';
PRINT 'La API:';
PRINT '  1. Obtiene mensajes con estado = "Pendiente"';
PRINT '  2. Cambia estado a "Enviando"';
PRINT '  3. Envía email vía Resend API';
PRINT '  4. Si exitoso: estado = "Enviado", fechaEnvio = GETDATE()';
PRINT '  5. Si falla: estado = "Error", incrementa intentosEnvio';
PRINT '  6. Actualiza fechaEnvio en alertas relacionadas';
PRINT '';
PRINT 'Para enviar un mensaje específico:';
PRINT 'POST /api/alertas/enviar/:mensajeID';
PRINT '';
PRINT 'Ejemplo:';
PRINT 'curl -X POST "http://localhost:3001/api/alertas/enviar/1"';
PRINT '';

-- =====================================================
-- 3. Ver Mensajes Enviados (si hay)
-- =====================================================
PRINT '3. Mensajes enviados:';
PRINT '';

SELECT 
    m.mensajeID,
    m.asunto,
    m.estado,
    m.fechaEnvio,
    m.resendMessageID,
    m.intentosEnvio
FROM evalImagen.mensaje m
WHERE m.statusID = 1
  AND m.estado = 'Enviado'
ORDER BY m.fechaEnvio DESC;

PRINT '';
PRINT '========================================';
PRINT '✅ Información de envío mostrada';
PRINT '========================================';
GO

