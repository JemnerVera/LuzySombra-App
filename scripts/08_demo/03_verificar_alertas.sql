-- =====================================================
-- SCRIPT: Verificar Alertas - Ver estado de alertas generadas
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Verificar que las alertas se hayan creado correctamente
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '========================================';
PRINT 'DEMO: Verificar Alertas Generadas';
PRINT '========================================';
PRINT '';

-- =====================================================
-- 1. Resumen General
-- =====================================================
PRINT '1. Resumen General de Alertas:';
PRINT '';

SELECT 
    tipoUmbral,
    severidad,
    estado,
    COUNT(*) AS cantidad
FROM evalImagen.alerta
WHERE statusID = 1
GROUP BY tipoUmbral, severidad, estado
ORDER BY 
    CASE tipoUmbral 
        WHEN 'CriticoRojo' THEN 1 
        WHEN 'CriticoAmarillo' THEN 2 
        ELSE 3 
    END,
    estado;

PRINT '';

-- =====================================================
-- 2. Detalle de Alertas Pendientes
-- =====================================================
PRINT '2. Detalle de Alertas Pendientes (sin mensaje):';
PRINT '';

SELECT 
    a.alertaID,
    a.lotID,
    l.name AS lote,
    f.Description AS fundo,
    s.stage AS sector,
    a.tipoUmbral,
    a.severidad,
    a.porcentajeLuzEvaluado,
    a.estado,
    a.fechaCreacion,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM evalImagen.mensaje m 
            WHERE m.alertaID = a.alertaID AND m.statusID = 1
        ) THEN 'Sí'
        WHEN EXISTS (
            SELECT 1 FROM evalImagen.mensajeAlerta ma
            INNER JOIN evalImagen.mensaje m ON ma.mensajeID = m.mensajeID
            WHERE ma.alertaID = a.alertaID AND m.statusID = 1
        ) THEN 'Sí (consolidado)'
        ELSE 'No'
    END AS tieneMensaje
FROM evalImagen.alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE a.statusID = 1
  AND a.estado IN ('Pendiente', 'Enviada')
ORDER BY 
    CASE a.tipoUmbral 
        WHEN 'CriticoRojo' THEN 1 
        WHEN 'CriticoAmarillo' THEN 2 
        ELSE 3 
    END,
    a.fechaCreacion DESC;

PRINT '';

-- =====================================================
-- 3. Información de Lotes con Alertas
-- =====================================================
PRINT '3. Información de Lotes con Alertas:';
PRINT '';

SELECT 
    a.lotID,
    l.name AS lote,
    f.Description AS fundo,
    s.stage AS sector,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual,
    COUNT(DISTINCT a.alertaID) AS totalAlertas,
    SUM(CASE WHEN a.estado = 'Pendiente' THEN 1 ELSE 0 END) AS alertasPendientes,
    SUM(CASE WHEN a.estado = 'Enviada' THEN 1 ELSE 0 END) AS alertasEnviadas,
    SUM(CASE WHEN a.estado = 'Resuelta' THEN 1 ELSE 0 END) AS alertasResueltas
FROM evalImagen.alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
LEFT JOIN evalImagen.loteEvaluacion le ON a.lotID = le.lotID AND le.statusID = 1
WHERE a.statusID = 1
GROUP BY 
    a.lotID,
    l.name,
    f.Description,
    s.stage,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual
ORDER BY 
    CASE le.tipoUmbralActual 
        WHEN 'CriticoRojo' THEN 1 
        WHEN 'CriticoAmarillo' THEN 2 
        ELSE 3 
    END,
    a.lotID;

PRINT '';

-- =====================================================
-- 4. Contactos Disponibles para Alertas
-- =====================================================
PRINT '4. Contactos Disponibles para Recibir Alertas:';
PRINT '';

SELECT 
    c.contactoID,
    c.nombre,
    c.email,
    c.tipo,
    c.recibirAlertasCriticas,
    c.recibirAlertasAdvertencias,
    c.fundoID,
    c.activo
FROM evalImagen.contacto c
WHERE c.statusID = 1
  AND c.activo = 1
ORDER BY c.prioridad DESC, c.nombre;

PRINT '';
PRINT '========================================';
PRINT '✅ Verificación completada';
PRINT '========================================';
GO

