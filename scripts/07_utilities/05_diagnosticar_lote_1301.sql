-- =====================================================
-- SCRIPT: Diagnosticar por qué no se genera alerta para lotID 1301
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Diagnosticar por qué no se genera alerta para un lote específico
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

DECLARE @lotID INT = 1301; -- Lote a diagnosticar

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  DIAGNÓSTICO DE ALERTAS PARA LOTID: ' + CAST(@lotID AS VARCHAR(10));
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- 1. Verificar que el lote existe y tiene análisis
PRINT '--- 1. Análisis de Imágenes para el Lote ---';
SELECT 
    analisisID,
    lotID,
    hilera,
    planta,
    filename,
    fechaCaptura,
    porcentajeLuz,
    porcentajeSombra,
    statusID,
    fechaCreacion
FROM evalImagen.analisisImagen
WHERE lotID = @lotID
    AND statusID = 1
ORDER BY fechaCreacion DESC;

PRINT '';

-- 2. Verificar evaluación del lote
PRINT '--- 2. Evaluación del Lote (loteEvaluacion) ---';
SELECT 
    loteEvaluacionID,
    lotID,
    porcentajeLuzPromedio,
    porcentajeLuzMin,
    porcentajeLuzMax,
    tipoUmbralActual,
    umbralIDActual,
    fechaUltimaEvaluacion,
    statusID
FROM evalImagen.loteEvaluacion
WHERE lotID = @lotID
    AND statusID = 1;

PRINT '';

-- 3. Verificar umbrales configurados
PRINT '--- 3. Umbrales de Luz Configurados (activos) ---';
SELECT 
    umbralID,
    descripcion,
    minPorcentajeLuz,
    maxPorcentajeLuz,
    tipo,
    severidad,
    activo,
    statusID
FROM evalImagen.umbralLuz
WHERE activo = 1
    AND statusID = 1
ORDER BY minPorcentajeLuz;

PRINT '';

-- 4. Verificar qué umbral debería aplicarse
PRINT '--- 4. Cálculo de Umbral Esperado ---';
DECLARE @porcentajeLuzPromedio DECIMAL(5,2);
SELECT @porcentajeLuzPromedio = porcentajeLuzPromedio
FROM evalImagen.loteEvaluacion
WHERE lotID = @lotID AND statusID = 1;

IF @porcentajeLuzPromedio IS NOT NULL
BEGIN
    PRINT 'Porcentaje de Luz Promedio: ' + CAST(@porcentajeLuzPromedio AS VARCHAR(10)) + '%';
    PRINT '';
    
    SELECT 
        umbralID,
        descripcion,
        minPorcentajeLuz,
        maxPorcentajeLuz,
        tipo,
        CASE 
            WHEN @porcentajeLuzPromedio >= minPorcentajeLuz AND @porcentajeLuzPromedio <= maxPorcentajeLuz 
            THEN '✅ APLICA'
            ELSE '❌ NO APLICA'
        END AS aplica,
        CASE 
            WHEN @porcentajeLuzPromedio < minPorcentajeLuz THEN 'Por debajo del mínimo'
            WHEN @porcentajeLuzPromedio > maxPorcentajeLuz THEN 'Por encima del máximo'
            ELSE 'Dentro del rango'
        END AS razon
    FROM evalImagen.umbralLuz
    WHERE activo = 1
        AND statusID = 1
    ORDER BY 
        CASE 
            WHEN @porcentajeLuzPromedio >= minPorcentajeLuz AND @porcentajeLuzPromedio <= maxPorcentajeLuz 
            THEN 0
            ELSE 1
        END,
        minPorcentajeLuz DESC;
END
ELSE
BEGIN
    PRINT '⚠️ No se encontró porcentajeLuzPromedio para este lote';
END

PRINT '';

-- 5. Verificar alertas existentes para este lote
PRINT '--- 5. Alertas Existentes para el Lote ---';
SELECT 
    alertaID,
    lotID,
    loteEvaluacionID,
    tipoUmbral,
    severidad,
    estado,
    fechaCreacion,
    fechaEnvio,
    fechaResolucion,
    statusID
FROM evalImagen.alerta
WHERE lotID = @lotID
    AND statusID = 1
ORDER BY fechaCreacion DESC;

PRINT '';

-- 6. Verificar si el trigger está activo
PRINT '--- 6. Estado del Trigger ---';
SELECT 
    name,
    is_disabled,
    is_instead_of_trigger,
    OBJECT_DEFINITION(object_id) AS trigger_definition
FROM sys.triggers
WHERE name = 'trg_loteEvaluacionAlerta_AF_IU' 
    AND parent_id = OBJECT_ID('evalImagen.loteEvaluacion');

PRINT '';

-- 7. Verificar información del lote
PRINT '--- 7. Información del Lote ---';
SELECT 
    l.lotID,
    l.name AS lote,
    s.stage AS sector,
    f.Description AS fundo,
    g.businessName AS empresa,
    l.statusID AS loteStatusID
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
INNER JOIN GROWER.GROWERS g ON f.growerID = g.growerID
WHERE l.lotID = @lotID;

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  FIN DEL DIAGNÓSTICO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'POSIBLES CAUSAS:';
PRINT '  1. El lote no tiene evaluación en loteEvaluacion';
PRINT '  2. El tipoUmbralActual no es CriticoRojo o CriticoAmarillo';
PRINT '  3. Ya existe una alerta Pendiente/Enviada del mismo tipo';
PRINT '  4. El trigger está deshabilitado';
PRINT '  5. No hay umbrales configurados que apliquen al porcentaje de luz';
PRINT '  6. El SP calcularLoteEvaluacion no se ejecutó después del INSERT';
PRINT '';

