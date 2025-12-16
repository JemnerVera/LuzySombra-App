-- =====================================================
-- SCRIPT: Resolver Alertas - Cambiar umbral a Normal
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Resolver alertas cambiando el umbral a Normal
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '========================================';
PRINT 'DEMO: Resolver Alertas';
PRINT '========================================';
PRINT '';

-- =====================================================
-- 1. Ver Alertas Activas
-- =====================================================
PRINT '1. Alertas activas (Pendiente/Enviada):';
PRINT '';

SELECT 
    a.alertaID,
    a.lotID,
    l.name AS lote,
    a.tipoUmbral,
    a.severidad,
    a.estado,
    a.porcentajeLuzEvaluado,
    le.porcentajeLuzPromedio AS porcentajeLuzActual,
    le.tipoUmbralActual AS umbralActual
FROM evalImagen.alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
LEFT JOIN evalImagen.loteEvaluacion le ON a.lotID = le.lotID AND le.statusID = 1
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
-- 2. Resolver Alertas Cambiando Umbral a Normal
-- =====================================================
PRINT '2. Resolviendo alertas cambiando umbral a Normal...';
PRINT '';

-- Obtener lotes con alertas activas
DECLARE @lotesConAlertas TABLE (lotID INT);

INSERT INTO @lotesConAlertas (lotID)
SELECT DISTINCT a.lotID
FROM evalImagen.alerta a
WHERE a.statusID = 1
  AND a.estado IN ('Pendiente', 'Enviada');

DECLARE @lotID INT;
DECLARE @umbralNormalID INT;

-- Obtener umbralID para Normal
SELECT TOP 1 @umbralNormalID = umbralID
FROM evalImagen.umbralLuz
WHERE tipo = 'Normal'
  AND activo = 1
  AND statusID = 1
ORDER BY orden;

IF @umbralNormalID IS NULL
BEGIN
    PRINT '   ⚠️ No se encontró umbral Normal. Usando umbralID = 3 por defecto.';
    SET @umbralNormalID = 3;
END

-- Resolver cada lote
DECLARE lotes_cursor CURSOR FOR
SELECT lotID FROM @lotesConAlertas;

OPEN lotes_cursor;
FETCH NEXT FROM lotes_cursor INTO @lotID;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT('   📍 Resolviendo alertas para lotID ', @lotID, '...');
    
    -- Actualizar evaluación a Normal (esto activará el trigger que resuelve alertas)
    UPDATE evalImagen.loteEvaluacion
    SET 
        porcentajeLuzPromedio = 60.00, -- 60% luz = NORMAL
        porcentajeSombraPromedio = 40.00,
        porcentajeLuzMin = 55.00,
        porcentajeLuzMax = 65.00,
        porcentajeSombraMin = 35.00,
        porcentajeSombraMax = 45.00,
        tipoUmbralActual = 'Normal',
        umbralIDActual = @umbralNormalID,
        fechaUltimaEvaluacion = GETDATE(),
        fechaUltimaActualizacion = GETDATE()
    WHERE lotID = @lotID
      AND statusID = 1;
    
    -- Esperar un momento para que el trigger se ejecute
    WAITFOR DELAY '00:00:01';
    
    -- Verificar que las alertas se resolvieron
    DECLARE @alertasResueltas INT;
    SELECT @alertasResueltas = COUNT(*)
    FROM evalImagen.alerta
    WHERE lotID = @lotID
      AND estado = 'Resuelta'
      AND statusID = 1
      AND fechaResolucion >= DATEADD(MINUTE, -1, GETDATE()); -- Resueltas en el último minuto
    
    IF @alertasResueltas > 0
    BEGIN
        PRINT CONCAT('   ✅ ', @alertasResueltas, ' alerta(s) resuelta(s) automáticamente');
    END
    ELSE
    BEGIN
        PRINT '   ⚠️ No se resolvieron alertas. Verifica que el trigger esté activo.';
    END
    
    FETCH NEXT FROM lotes_cursor INTO @lotID;
END

CLOSE lotes_cursor;
DEALLOCATE lotes_cursor;

PRINT '';

-- =====================================================
-- 3. Verificar Alertas Resueltas
-- =====================================================
PRINT '3. Alertas resueltas:';
PRINT '';

SELECT 
    a.alertaID,
    a.lotID,
    l.name AS lote,
    a.tipoUmbral,
    a.severidad,
    a.estado,
    a.fechaCreacion,
    a.fechaResolucion,
    DATEDIFF(MINUTE, a.fechaCreacion, a.fechaResolucion) AS minutosParaResolver
FROM evalImagen.alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
WHERE a.statusID = 1
  AND a.estado = 'Resuelta'
  AND a.fechaResolucion >= DATEADD(MINUTE, -5, GETDATE()) -- Resueltas en los últimos 5 minutos
ORDER BY a.fechaResolucion DESC;

PRINT '';

-- =====================================================
-- 4. Resumen Final
-- =====================================================
PRINT '4. Resumen de estados de alertas:';
PRINT '';

SELECT 
    estado,
    COUNT(*) AS cantidad
FROM evalImagen.alerta
WHERE statusID = 1
GROUP BY estado
ORDER BY 
    CASE estado
        WHEN 'Pendiente' THEN 1
        WHEN 'Enviada' THEN 2
        WHEN 'Resuelta' THEN 3
        WHEN 'Ignorada' THEN 4
        ELSE 5
    END;

PRINT '';
PRINT '========================================';
PRINT '✅ Resolución de alertas completada';
PRINT '========================================';
GO

