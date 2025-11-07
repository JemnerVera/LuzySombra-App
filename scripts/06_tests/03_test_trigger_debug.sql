-- =====================================================
-- SCRIPT: Test y Debug del Trigger trg_LoteEvaluacion_Alerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Diagnosticar por qué no se están creando alertas
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  DIAGNÓSTICO DEL TRIGGER trg_LoteEvaluacion_Alerta';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- 1. Verificar que el trigger existe
PRINT '=== 1. Verificar existencia del trigger ===';
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_LoteEvaluacion_Alerta' AND parent_id = OBJECT_ID('image.LoteEvaluacion'))
BEGIN
    PRINT '✅ Trigger existe';
    
    SELECT 
        t.name AS trigger_name,
        t.is_disabled,
        t.is_instead_of_trigger,
        t.is_not_for_replication
    FROM sys.triggers t
    WHERE t.name = 'trg_LoteEvaluacion_Alerta' 
      AND t.parent_id = OBJECT_ID('image.LoteEvaluacion');
END
ELSE
BEGIN
    PRINT '❌ Trigger NO existe!';
    PRINT '   Ejecuta: scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql';
END
GO

-- 2. Verificar estado actual de LoteEvaluacion
PRINT '';
PRINT '=== 2. Estado actual de image.LoteEvaluacion ===';
SELECT TOP 5
    loteEvaluacionID,
    lotID,
    variedadID,
    porcentajeLuzPromedio,
    tipoUmbralActual,
    umbralIDActual,
    fechaUltimaActualizacion,
    statusID
FROM image.LoteEvaluacion
WHERE statusID = 1
ORDER BY fechaUltimaActualizacion DESC;
GO

-- 3. Verificar alertas existentes
PRINT '';
PRINT '=== 3. Alertas existentes ===';
SELECT 
    alertaID,
    lotID,
    tipoUmbral,
    severidad,
    estado,
    fechaCreacion
FROM image.Alerta
WHERE statusID = 1
ORDER BY fechaCreacion DESC;
GO

-- 4. Verificar umbrales para el lote 1022
PRINT '';
PRINT '=== 4. Umbrales aplicables para variedad 48 (ROSITA) ===';
SELECT 
    umbralID,
    tipo,
    minPorcentajeLuz,
    maxPorcentajeLuz,
    variedadID,
    activo,
    statusID
FROM image.UmbralLuz
WHERE (variedadID = 48 OR variedadID IS NULL)
  AND activo = 1
  AND statusID = 1
ORDER BY 
    CASE WHEN variedadID IS NOT NULL THEN 0 ELSE 1 END,
    tipo,
    orden;
GO

-- 5. Verificar si el porcentaje de luz (30.55) está en el rango de CriticoAmarillo
PRINT '';
PRINT '=== 5. Verificar clasificación de 30.55% luz ===';
DECLARE @PorcentajeLuz DECIMAL(5,2) = 30.55;
DECLARE @VariedadID INT = 48;

SELECT 
    u.umbralID,
    u.tipo,
    u.minPorcentajeLuz,
    u.maxPorcentajeLuz,
    u.variedadID,
    CASE 
        WHEN @PorcentajeLuz >= u.minPorcentajeLuz AND @PorcentajeLuz <= u.maxPorcentajeLuz 
        THEN '✅ DENTRO DEL RANGO'
        ELSE '❌ FUERA DEL RANGO'
    END AS Estado
FROM image.UmbralLuz u
WHERE u.activo = 1
  AND u.statusID = 1
  AND (u.variedadID = @VariedadID OR u.variedadID IS NULL)
  AND @PorcentajeLuz >= u.minPorcentajeLuz 
  AND @PorcentajeLuz <= u.maxPorcentajeLuz
ORDER BY 
    CASE WHEN u.variedadID IS NOT NULL THEN 0 ELSE 1 END,
    CASE u.tipo
        WHEN 'CriticoRojo' THEN 1
        WHEN 'CriticoAmarillo' THEN 2
        WHEN 'Normal' THEN 3
    END,
    u.orden;
GO

-- 6. Test manual: Simular INSERT directo (para ver si el trigger funciona)
PRINT '';
PRINT '=== 6. Test Manual: Intentar INSERT directo (simular) ===';
PRINT '   (Este test NO ejecutará el INSERT, solo mostrará si pasaría las validaciones)';
GO

DECLARE @TestLotID INT = 1022;
DECLARE @TestVariedadID INT = 48;
DECLARE @TestPorcentajeLuz DECIMAL(5,2) = 30.55;
DECLARE @TestTipoUmbral VARCHAR(20) = 'CriticoAmarillo';
DECLARE @TestUmbralID INT = 207;

-- Verificar condiciones del trigger
PRINT '';
PRINT 'Verificando condiciones del trigger:';
PRINT '  1. tipoUmbralActual IN (''CriticoRojo'', ''CriticoAmarillo''):';
IF @TestTipoUmbral IN ('CriticoRojo', 'CriticoAmarillo')
    PRINT '     ✅ PASÓ';
ELSE
    PRINT '     ❌ FALLÓ';

PRINT '  2. tipoUmbralActual IS NOT NULL:';
IF @TestTipoUmbral IS NOT NULL
    PRINT '     ✅ PASÓ';
ELSE
    PRINT '     ❌ FALLÓ';

PRINT '  3. tipoUmbralActual != ''Normal'':';
IF @TestTipoUmbral != 'Normal'
    PRINT '     ✅ PASÓ';
ELSE
    PRINT '     ❌ FALLÓ';

PRINT '  4. No existe alerta Pendiente/Enviada del mismo tipo:';
IF NOT EXISTS (
    SELECT 1 
    FROM image.Alerta a 
    WHERE a.lotID = @TestLotID 
      AND a.tipoUmbral = @TestTipoUmbral
      AND a.estado IN ('Pendiente', 'Enviada')
      AND a.statusID = 1
)
    PRINT '     ✅ PASÓ (no existe alerta duplicada)';
ELSE
BEGIN
    PRINT '     ❌ FALLÓ (ya existe alerta duplicada)';
    SELECT 
        alertaID,
        estado,
        fechaCreacion
    FROM image.Alerta
    WHERE lotID = @TestLotID 
      AND tipoUmbral = @TestTipoUmbral
      AND estado IN ('Pendiente', 'Enviada')
      AND statusID = 1;
END
GO

-- 7. Test: Forzar recálculo y verificar si se activa el trigger
PRINT '';
PRINT '=== 7. Test: Forzar recálculo del lote 1022 ===';
PRINT '   Ejecutando: EXEC image.sp_CalcularLoteEvaluacion @LotID = 1022, @ForzarRecalculo = 1';
PRINT '   (Observa si se crea una alerta después de esto)';
GO

-- Contar alertas antes
DECLARE @AlertasAntes INT;
SELECT @AlertasAntes = COUNT(*) 
FROM image.Alerta 
WHERE lotID = 1022 
  AND statusID = 1;

PRINT '';
PRINT 'Alertas antes del recálculo: ' + CAST(@AlertasAntes AS VARCHAR);
GO

-- Ejecutar recálculo
EXEC image.sp_CalcularLoteEvaluacion @LotID = 1022, @ForzarRecalculo = 1;
GO

-- Contar alertas después
DECLARE @AlertasDespues INT;
SELECT @AlertasDespues = COUNT(*) 
FROM image.Alerta 
WHERE lotID = 1022 
  AND statusID = 1;

PRINT '';
PRINT 'Alertas después del recálculo: ' + CAST(@AlertasDespues AS VARCHAR);

IF @AlertasDespues > @AlertasAntes
    PRINT '✅ Se creó una nueva alerta!';
ELSE
    PRINT '❌ No se creó ninguna alerta nueva';
GO

-- 8. Verificar alertas creadas recientemente
PRINT '';
PRINT '=== 8. Alertas creadas en los últimos 5 minutos ===';
SELECT 
    alertaID,
    lotID,
    loteEvaluacionID,
    umbralID,
    variedadID,
    porcentajeLuzEvaluado,
    tipoUmbral,
    severidad,
    estado,
    fechaCreacion
FROM image.Alerta
WHERE fechaCreacion >= DATEADD(MINUTE, -5, GETDATE())
  AND statusID = 1
ORDER BY fechaCreacion DESC;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  FIN DEL DIAGNÓSTICO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Si no se creó ninguna alerta, verifica:';
PRINT '  1. Que el trigger esté habilitado (is_disabled = 0)';
PRINT '  2. Que el tipoUmbralActual sea realmente ''CriticoAmarillo'' o ''CriticoRojo''';
PRINT '  3. Que no exista ya una alerta Pendiente/Enviada del mismo tipo';
PRINT '  4. Que el MERGE realmente esté haciendo un INSERT o UPDATE';
PRINT '';
GO

