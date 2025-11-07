-- =====================================================
-- SCRIPT: Test del Trigger trg_LoteEvaluacion_Alerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Test / Verificación
-- Propósito: Verificar que el trigger funciona correctamente
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno (solo consultas SELECT)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno (solo lectura y verificación)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.LoteEvaluacion (tabla debe existir)
--   ⚠️  Requiere: image.Alerta (tabla debe existir)
--   ⚠️  Requiere: image.trg_LoteEvaluacion_Alerta (trigger debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Ejecutar DESPUÉS de crear el trigger
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  TEST DEL TRIGGER: trg_LoteEvaluacion_Alerta';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- 1. Verificar que el trigger existe
-- =====================================================
PRINT '=== 1. Verificar existencia del trigger ===';
IF EXISTS (
    SELECT * FROM sys.triggers 
    WHERE name = 'trg_LoteEvaluacion_Alerta' 
    AND parent_id = OBJECT_ID('image.LoteEvaluacion')
)
BEGIN
    PRINT '✅ Trigger trg_LoteEvaluacion_Alerta existe';
END
ELSE
BEGIN
    PRINT '❌ ERROR: Trigger trg_LoteEvaluacion_Alerta NO existe';
    PRINT '   Ejecuta: scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql';
    RETURN;
END
GO

-- =====================================================
-- 2. Verificar estado actual de alertas
-- =====================================================
PRINT '';
PRINT '=== 2. Estado actual de alertas ===';
SELECT 
    COUNT(*) AS TotalAlertas,
    SUM(CASE WHEN estado = 'Pendiente' THEN 1 ELSE 0 END) AS Pendientes,
    SUM(CASE WHEN estado = 'Enviada' THEN 1 ELSE 0 END) AS Enviadas,
    SUM(CASE WHEN estado = 'Resuelta' THEN 1 ELSE 0 END) AS Resueltas,
    SUM(CASE WHEN tipoUmbral = 'CriticoRojo' THEN 1 ELSE 0 END) AS CriticoRojo,
    SUM(CASE WHEN tipoUmbral = 'CriticoAmarillo' THEN 1 ELSE 0 END) AS CriticoAmarillo
FROM image.Alerta
WHERE statusID = 1;
GO

-- =====================================================
-- 3. Verificar lotes con evaluaciones
-- =====================================================
PRINT '';
PRINT '=== 3. Lotes con evaluaciones y su tipoUmbralActual ===';
SELECT TOP 10
    le.lotID,
    l.name AS lote,
    le.tipoUmbralActual,
    le.porcentajeLuzPromedio,
    le.totalEvaluaciones,
    le.fechaUltimaEvaluacion,
    COUNT(a.alertaID) AS AlertasPendientes
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
LEFT JOIN image.Alerta a ON le.lotID = a.lotID 
    AND a.estado IN ('Pendiente', 'Enviada')
    AND a.statusID = 1
WHERE le.statusID = 1
GROUP BY le.lotID, l.name, le.tipoUmbralActual, le.porcentajeLuzPromedio, 
         le.totalEvaluaciones, le.fechaUltimaEvaluacion
ORDER BY le.fechaUltimaEvaluacion DESC;
GO

-- =====================================================
-- 4. Verificar alertas recientes
-- =====================================================
PRINT '';
PRINT '=== 4. Alertas recientes (últimas 10) ===';
SELECT TOP 10
    a.alertaID,
    a.lotID,
    l.name AS lote,
    a.tipoUmbral,
    a.severidad,
    a.porcentajeLuzEvaluado,
    a.estado,
    a.fechaCreacion,
    a.mensajeID
FROM image.Alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
WHERE a.statusID = 1
ORDER BY a.fechaCreacion DESC;
GO

-- =====================================================
-- 5. Verificar lotes que deberían tener alerta pero no la tienen
-- =====================================================
PRINT '';
PRINT '=== 5. Lotes con umbral crítico pero sin alerta pendiente ===';
SELECT 
    le.lotID,
    l.name AS lote,
    le.tipoUmbralActual,
    le.porcentajeLuzPromedio,
    le.fechaUltimaEvaluacion
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
WHERE le.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo')
    AND le.statusID = 1
    AND NOT EXISTS (
        SELECT 1 
        FROM image.Alerta a 
        WHERE a.lotID = le.lotID 
          AND a.tipoUmbral = le.tipoUmbralActual
          AND a.estado IN ('Pendiente', 'Enviada')
          AND a.statusID = 1
    )
ORDER BY le.fechaUltimaEvaluacion DESC;
GO

-- =====================================================
-- 6. Estadísticas de umbrales por lote
-- =====================================================
PRINT '';
PRINT '=== 6. Estadísticas de umbrales por lote ===';
SELECT 
    le.tipoUmbralActual,
    COUNT(*) AS TotalLotes,
    AVG(le.porcentajeLuzPromedio) AS PromedioLuz,
    MIN(le.porcentajeLuzPromedio) AS MinLuz,
    MAX(le.porcentajeLuzPromedio) AS MaxLuz
FROM image.LoteEvaluacion le
WHERE le.statusID = 1
    AND le.tipoUmbralActual IS NOT NULL
GROUP BY le.tipoUmbralActual
ORDER BY 
    CASE le.tipoUmbralActual
        WHEN 'CriticoRojo' THEN 1
        WHEN 'CriticoAmarillo' THEN 2
        WHEN 'Normal' THEN 3
    END;
GO

-- =====================================================
-- 7. Verificar que el trigger está habilitado
-- =====================================================
PRINT '';
PRINT '=== 7. Estado del trigger ===';
SELECT 
    t.name AS TriggerName,
    t.is_disabled AS EstaDeshabilitado,
    t.is_instead_of_trigger AS EsInsteadOf,
    OBJECT_NAME(t.parent_id) AS TablaPadre
FROM sys.triggers t
WHERE t.name = 'trg_LoteEvaluacion_Alerta'
    AND t.parent_id = OBJECT_ID('image.LoteEvaluacion');
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  TEST COMPLETADO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'PRÓXIMOS PASOS PARA PROBAR:';
PRINT '  1. Procesar una imagen desde la app';
PRINT '  2. Verificar que se actualiza image.LoteEvaluacion';
PRINT '  3. Si el umbral cambia a CriticoRojo/CriticoAmarillo,';
PRINT '     verificar que se crea una alerta en image.Alerta';
PRINT '  4. Verificar en la tabla consolidada que muestra los datos correctamente';
GO

