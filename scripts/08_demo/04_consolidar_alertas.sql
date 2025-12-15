-- =====================================================
-- SCRIPT: Consolidar Alertas - Simular consolidación (normalmente vía API)
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Mostrar cómo se consolidan alertas en mensajes
-- NOTA: Normalmente esto se hace vía API POST /api/alertas/consolidar
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '========================================';
PRINT 'DEMO: Consolidar Alertas en Mensajes';
PRINT '========================================';
PRINT '';
PRINT '⚠️ NOTA: Normalmente la consolidación se hace vía API:';
PRINT '   POST http://localhost:3001/api/alertas/consolidar?horasAtras=24';
PRINT '';
PRINT 'Este script muestra el proceso, pero es mejor usar la API.';
PRINT '';

-- =====================================================
-- 1. Ver Alertas Sin Mensaje
-- =====================================================
PRINT '1. Alertas pendientes sin mensaje:';
PRINT '';

SELECT 
    a.alertaID,
    a.lotID,
    le.fundoID,
    le.sectorID,
    a.tipoUmbral,
    a.severidad,
    a.estado,
    a.fechaCreacion
FROM evalImagen.alerta a
LEFT JOIN evalImagen.loteEvaluacion le ON a.lotID = le.lotID AND le.statusID = 1
WHERE a.statusID = 1
  AND a.estado IN ('Pendiente', 'Enviada')
  AND NOT EXISTS (
      SELECT 1 FROM evalImagen.mensaje m 
      WHERE m.alertaID = a.alertaID AND m.statusID = 1
  )
  AND NOT EXISTS (
      SELECT 1 FROM evalImagen.mensajeAlerta ma
      INNER JOIN evalImagen.mensaje m ON ma.mensajeID = m.mensajeID
      WHERE ma.alertaID = a.alertaID AND m.statusID = 1
  )
ORDER BY le.fundoID, a.fechaCreacion;

PRINT '';
PRINT '========================================';
PRINT 'Para consolidar alertas, usa la API:';
PRINT '========================================';
PRINT '';
PRINT 'POST /api/alertas/consolidar?horasAtras=24';
PRINT '';
PRINT 'O desde curl:';
PRINT 'curl -X POST "http://localhost:3001/api/alertas/consolidar?horasAtras=24"';
PRINT '';
PRINT 'La API:';
PRINT '  1. Agrupa alertas por fundo';
PRINT '  2. Crea un mensaje consolidado por fundo';
PRINT '  3. Asocia las alertas al mensaje';
PRINT '  4. Obtiene destinatarios desde evalImagen.contacto';
PRINT '  5. Genera HTML y texto del mensaje';
PRINT '';
PRINT 'Después de ejecutar la API, verifica los mensajes con:';
PRINT '  SELECT * FROM evalImagen.mensaje WHERE statusID = 1 ORDER BY fechaCreacion DESC;';
PRINT '';
GO

