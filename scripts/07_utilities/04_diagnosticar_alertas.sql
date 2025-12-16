-- =====================================================
-- SCRIPT: Diagnosticar por qué no se generan alertas
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Verificar estado de umbrales, loteEvaluacion y alertas
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '========================================';
PRINT 'DIAGNÓSTICO DE ALERTAS';
PRINT '========================================';
PRINT '';

-- 1. Verificar umbrales configurados
PRINT '1. UMBRALES CONFIGURADOS:';
PRINT '----------------------------------------';
SELECT 
    umbralID,
    tipo,
    descripcion,
    minPorcentajeLuz,
    maxPorcentajeLuz,
    variedadID,
    activo,
    statusID,
    orden
FROM evalImagen.umbralLuz
WHERE statusID = 1
ORDER BY orden, tipo;
PRINT '';

-- 2. Verificar loteEvaluacion recientes con tipoUmbralActual
PRINT '2. EVALUACIONES DE LOTES (últimas 20):';
PRINT '----------------------------------------';
SELECT TOP 20
    le.loteEvaluacionID,
    le.lotID,
    l.name AS lote,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual,
    le.umbralIDActual,
    le.fechaUltimaEvaluacion,
    le.fechaUltimaActualizacion,
    le.statusID
FROM evalImagen.loteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
WHERE le.statusID = 1
ORDER BY le.fechaUltimaActualizacion DESC;
PRINT '';

-- 3. Verificar alertas existentes
PRINT '3. ALERTAS EXISTENTES:';
PRINT '----------------------------------------';
SELECT 
    a.alertaID,
    a.lotID,
    l.name AS lote,
    a.tipoUmbral,
    a.severidad,
    a.estado,
    a.porcentajeLuzEvaluado,
    a.fechaCreacion,
    a.fechaEnvio,
    a.fechaResolucion,
    a.statusID
FROM evalImagen.alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
WHERE a.statusID = 1
ORDER BY a.fechaCreacion DESC;
PRINT '';

-- 4. Verificar lotes con porcentaje de luz bajo que NO tienen alerta
PRINT '4. LOTES CON LUZ BAJA SIN ALERTA:';
PRINT '----------------------------------------';
SELECT 
    le.loteEvaluacionID,
    le.lotID,
    l.name AS lote,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual,
    CASE 
        WHEN le.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo') THEN 'DEBERÍA TENER ALERTA'
        ELSE 'NO DEBERÍA TENER ALERTA'
    END AS estadoEsperado,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM evalImagen.alerta a 
            WHERE a.lotID = le.lotID 
              AND a.tipoUmbral = le.tipoUmbralActual
              AND a.estado IN ('Pendiente', 'Enviada')
              AND a.statusID = 1
        ) THEN 'TIENE ALERTA ACTIVA'
        ELSE 'NO TIENE ALERTA ACTIVA'
    END AS tieneAlertaActiva
FROM evalImagen.loteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
WHERE le.statusID = 1
  AND le.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo')
  AND le.porcentajeLuzPromedio < 40  -- Porcentaje bajo
ORDER BY le.porcentajeLuzPromedio ASC;
PRINT '';

-- 5. Verificar análisis recientes y su loteEvaluacion asociada
PRINT '5. ANÁLISIS RECIENTES Y SU EVALUACIÓN:';
PRINT '----------------------------------------';
SELECT TOP 20
    ai.analisisID,
    ai.lotID,
    l.name AS lote,
    ai.porcentajeLuz,
    ai.fechaCaptura,
    ai.fechaCreacion,
    le.loteEvaluacionID,
    le.porcentajeLuzPromedio AS luzPromedioLote,
    le.tipoUmbralActual,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM evalImagen.alerta a 
            WHERE a.lotID = ai.lotID 
              AND a.tipoUmbral = le.tipoUmbralActual
              AND a.estado IN ('Pendiente', 'Enviada')
              AND a.statusID = 1
        ) THEN 'SÍ'
        ELSE 'NO'
    END AS tieneAlertaActiva
FROM evalImagen.analisisImagen ai
INNER JOIN GROWER.LOT l ON ai.lotID = l.lotID
LEFT JOIN evalImagen.loteEvaluacion le ON ai.lotID = le.lotID AND le.statusID = 1
WHERE ai.statusID = 1
ORDER BY ai.fechaCreacion DESC;
PRINT '';

-- 6. Verificar si el trigger está activo
PRINT '6. ESTADO DEL TRIGGER:';
PRINT '----------------------------------------';
SELECT 
    t.name AS trigger_name,
    t.is_disabled,
    t.is_instead_of_trigger,
    OBJECT_NAME(t.parent_id) AS parent_table
FROM sys.triggers t
WHERE t.parent_id = OBJECT_ID('evalImagen.loteEvaluacion')
  AND t.name = 'trg_loteEvaluacionAlerta_AF_IU';
PRINT '';

PRINT '========================================';
PRINT 'FIN DEL DIAGNÓSTICO';
PRINT '========================================';
PRINT '';
PRINT 'NOTAS:';
PRINT '- Si "tipoUmbralActual" es NULL, verificar que hay umbrales configurados';
PRINT '- Si "tipoUmbralActual" es crítico pero "tieneAlertaActiva" es SÍ, el trigger está bloqueando nuevas alertas';
PRINT '- Si "tipoUmbralActual" es Normal, no se generarán alertas (comportamiento esperado)';
PRINT '- Si el trigger está deshabilitado (is_disabled = 1), habilitarlo con: ALTER TABLE evalImagen.loteEvaluacion ENABLE TRIGGER trg_loteEvaluacionAlerta_AF_IU';
GO

