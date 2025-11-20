-- =====================================================
-- SCRIPT: Diagnosticar por qué no se consolidan alertas
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Verificar qué está impidiendo la consolidación
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  DIAGNÓSTICO: Por qué no se consolidan las alertas';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- Paso 1: Verificar alertas básicas
-- =====================================================
PRINT '=== Paso 1: Alertas pendientes ===';
SELECT 
    a.alertaID,
    a.lotID,
    a.loteEvaluacionID,
    a.estado,
    a.mensajeID,
    a.fechaCreacion,
    DATEDIFF(HOUR, a.fechaCreacion, GETDATE()) AS horas_desde_creacion
FROM image.Alerta a
WHERE a.alertaID IN (3, 4)
  AND a.statusID = 1;
GO

-- =====================================================
-- Paso 2: Verificar si tienen loteEvaluacionID
-- =====================================================
PRINT '';
PRINT '=== Paso 2: ¿Tienen loteEvaluacionID? ===';
SELECT 
    a.alertaID,
    a.loteEvaluacionID,
    CASE 
        WHEN a.loteEvaluacionID IS NULL THEN '❌ NULL - No se puede consolidar'
        ELSE '✅ Tiene loteEvaluacionID'
    END AS estado_loteEvaluacionID
FROM image.Alerta a
WHERE a.alertaID IN (3, 4);
GO

-- =====================================================
-- Paso 3: Verificar si LoteEvaluacion tiene fundoID
-- =====================================================
PRINT '';
PRINT '=== Paso 3: ¿LoteEvaluacion tiene fundoID? ===';
SELECT 
    a.alertaID,
    le.loteEvaluacionID,
    le.fundoID,
    le.sectorID,
    CASE 
        WHEN le.fundoID IS NULL THEN '❌ NULL - No se puede consolidar'
        ELSE '✅ Tiene fundoID: ' + le.fundoID
    END AS estado_fundoID
FROM image.Alerta a
INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
WHERE a.alertaID IN (3, 4);
GO

-- =====================================================
-- Paso 4: Verificar JOIN completo (como en el código)
-- =====================================================
PRINT '';
PRINT '=== Paso 4: Query completa (como en consolidarAlertasPorFundo) ===';
SELECT 
    a.alertaID,
    a.lotID,
    a.porcentajeLuzEvaluado,
    a.tipoUmbral,
    a.estado,
    a.mensajeID,
    a.fechaCreacion,
    CAST(COALESCE(le.fundoID, f.farmID) AS VARCHAR) AS fundoID,
    f.Description AS fundo,
    CASE 
        WHEN le.loteEvaluacionID IS NULL THEN '❌ No tiene loteEvaluacionID'
        WHEN COALESCE(le.fundoID, f.farmID) IS NULL THEN '❌ No se puede obtener fundoID'
        WHEN a.mensajeID IS NOT NULL THEN '❌ Ya tiene mensajeID'
        WHEN a.estado NOT IN ('Pendiente', 'Enviada') THEN '❌ Estado incorrecto: ' + a.estado
        ELSE '✅ Lista para consolidar'
    END AS diagnostico
FROM image.Alerta a
INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
LEFT JOIN GROWER.FARMS f ON COALESCE(le.fundoID, s.farmID) = f.farmID
WHERE a.alertaID IN (3, 4)
  AND a.statusID = 1;
GO

-- =====================================================
-- Paso 5: Verificar con filtro de fecha (últimas 24 horas)
-- =====================================================
PRINT '';
PRINT '=== Paso 5: ¿Están en el rango de 24 horas? ===';
SELECT 
    a.alertaID,
    a.fechaCreacion,
    DATEADD(HOUR, -24, GETDATE()) AS fecha_limite_24h,
    CASE 
        WHEN a.fechaCreacion >= DATEADD(HOUR, -24, GETDATE()) THEN '✅ Dentro de 24 horas'
        ELSE '❌ Fuera de 24 horas (creada hace ' + CAST(DATEDIFF(HOUR, a.fechaCreacion, GETDATE()) AS VARCHAR) + ' horas)'
    END AS estado_fecha
FROM image.Alerta a
WHERE a.alertaID IN (3, 4);
GO

-- =====================================================
-- Paso 6: Query exacta que usa el código (sin filtro de fecha para debug)
-- =====================================================
PRINT '';
PRINT '=== Paso 6: Query sin filtro de fecha (para debug) ===';
SELECT 
    a.alertaID,
    a.lotID,
    CAST(COALESCE(le.fundoID, f.farmID) AS VARCHAR) AS fundoID,
    f.Description AS fundo,
    a.tipoUmbral,
    a.fechaCreacion
FROM image.Alerta a
INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
LEFT JOIN GROWER.FARMS f ON COALESCE(le.fundoID, s.farmID) = f.farmID
WHERE a.estado IN ('Pendiente', 'Enviada')
  AND a.statusID = 1
  AND a.mensajeID IS NULL
  AND a.alertaID IN (3, 4)
  AND COALESCE(le.fundoID, f.farmID) IS NOT NULL
ORDER BY COALESCE(le.fundoID, f.farmID), a.fechaCreacion ASC;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  Si el Paso 6 devuelve 0 filas, revisa los pasos anteriores';
PRINT '  para identificar qué condición está fallando';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

