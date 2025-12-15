-- =====================================================
-- SCRIPT: Crear Evaluaciones Demo - Generar alertas automáticamente
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Crear evaluaciones que generen alertas vía trigger
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '========================================';
PRINT 'DEMO: Crear Evaluaciones que Generan Alertas';
PRINT '========================================';
PRINT '';

-- =====================================================
-- IMPORTANTE: Usar lotes del mismo fundo que el contacto configurado
-- =====================================================
-- Obtener el fundoID del contacto configurado
DECLARE @fundoFiltro CHAR(4);
SELECT TOP 1 @fundoFiltro = fundoID
FROM evalImagen.contacto
WHERE email = 'jemner.vera@agricolaandrea.com'
  AND statusID = 1;

IF @fundoFiltro IS NULL
BEGIN
    PRINT '❌ ERROR: No se encontró el contacto jemner.vera@agricolaandrea.com con fundoID configurado.';
    PRINT '   Por favor, ejecuta primero: scripts/08_demo/01_setup_demo.sql';
    RETURN;
END

DECLARE @fundoFiltroTrimmed VARCHAR(4) = RTRIM(@fundoFiltro);
PRINT CONCAT('📍 Filtrando por fundoID: ''', @fundoFiltro, ''' (del contacto configurado)');
PRINT '';

-- Obtener un lotID del fundo especificado
DECLARE @lotID INT;
SELECT TOP 1 @lotID = l.lotID 
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE l.statusID = 1 
  AND f.farmID = @fundoFiltro
ORDER BY l.lotID;

IF @lotID IS NULL
BEGIN
    PRINT CONCAT('❌ ERROR: No se encontraron lotes activos para fundoID = ', @fundoFiltro);
    PRINT '   Por favor, ajusta el script con un fundoID válido o crea lotes para ese fundo.';
    RETURN;
END

PRINT CONCAT('📍 Usando lotID de ejemplo: ', @lotID, ' (del fundo ', @fundoFiltro, ')');

-- Obtener información del lote
DECLARE @fundoID CHAR(4);
DECLARE @sectorID INT;
DECLARE @variedadID INT;

SELECT 
    @fundoID = f.farmID,
    @sectorID = s.stageID,
    @variedadID = p.varietyID
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
LEFT JOIN GROWER.PLANTATION p ON l.lotID = p.lotID AND p.statusID = 1
WHERE l.lotID = @lotID
  AND l.statusID = 1;

PRINT CONCAT('   FundoID: ', ISNULL(@fundoID, 'NULL'));
PRINT CONCAT('   SectorID: ', ISNULL(CAST(@sectorID AS VARCHAR), 'NULL'));
PRINT CONCAT('   VariedadID: ', ISNULL(CAST(@variedadID AS VARCHAR), 'NULL'));
PRINT '';

-- =====================================================
-- 1. Crear Evaluación con Umbral CRÍTICO ROJO (< 30% luz)
-- =====================================================
PRINT '1. Creando evaluación con umbral CRÍTICO ROJO (15% luz)...';

-- Primero, verificar si ya existe una evaluación para este lote
DECLARE @loteEvaluacionID INT;
SELECT @loteEvaluacionID = loteEvaluacionID 
FROM evalImagen.loteEvaluacion 
WHERE lotID = @lotID 
  AND statusID = 1;

IF @loteEvaluacionID IS NOT NULL
BEGIN
    PRINT CONCAT('   ℹ️ Ya existe evaluación para lotID ', @lotID, '. Actualizando...');
    
    -- Actualizar la evaluación con umbral crítico
    UPDATE evalImagen.loteEvaluacion
    SET 
        porcentajeLuzPromedio = 15.00, -- 15% luz = CRÍTICO
        porcentajeSombraPromedio = 85.00,
        porcentajeLuzMin = 10.00,
        porcentajeLuzMax = 20.00,
        porcentajeSombraMin = 80.00,
        porcentajeSombraMax = 90.00,
        tipoUmbralActual = 'CriticoRojo', -- Esto activará el trigger
        fechaUltimaEvaluacion = GETDATE(),
        fechaUltimaActualizacion = GETDATE()
    WHERE lotID = @lotID
      AND statusID = 1;
    
    PRINT '   ✅ Evaluación actualizada con umbral CRÍTICO ROJO';
END
ELSE
BEGIN
    -- Obtener umbralID para CriticoRojo
    DECLARE @umbralCriticoRojoID INT;
    SELECT TOP 1 @umbralCriticoRojoID = umbralID
    FROM evalImagen.umbralLuz
    WHERE tipo = 'CriticoRojo'
      AND activo = 1
      AND statusID = 1
      AND (@variedadID IS NULL OR variedadID IS NULL OR variedadID = @variedadID)
    ORDER BY 
        CASE WHEN variedadID IS NULL THEN 1 ELSE 0 END, -- Priorizar umbrales generales
        orden;
    
    IF @umbralCriticoRojoID IS NULL
    BEGIN
        PRINT '   ⚠️ No se encontró umbral CriticoRojo. Usando umbralID = 1 por defecto.';
        SET @umbralCriticoRojoID = 1;
    END
    
    -- Insertar nueva evaluación
    INSERT INTO evalImagen.loteEvaluacion (
        lotID,
        variedadID,
        fundoID,
        sectorID,
        porcentajeLuzPromedio,
        porcentajeLuzMin,
        porcentajeLuzMax,
        porcentajeSombraPromedio,
        porcentajeSombraMin,
        porcentajeSombraMax,
        tipoUmbralActual,
        umbralIDActual,
        fechaUltimaEvaluacion,
        fechaPrimeraEvaluacion,
        totalEvaluaciones,
        periodoEvaluacionDias,
        fechaUltimaActualizacion,
        statusID
    ) VALUES (
        @lotID,
        @variedadID,
        @fundoID,
        @sectorID,
        15.00, -- 15% luz = CRÍTICO
        10.00,
        20.00,
        85.00,
        80.00,
        90.00,
        'CriticoRojo', -- Esto activará el trigger
        @umbralCriticoRojoID,
        GETDATE(),
        GETDATE(),
        1,
        30,
        GETDATE(),
        1
    );
    
    PRINT '   ✅ Evaluación creada con umbral CRÍTICO ROJO';
END

-- Esperar un momento para que el trigger se ejecute
WAITFOR DELAY '00:00:01';

-- Verificar si se creó la alerta
DECLARE @alertaCriticaID INT;
SELECT @alertaCriticaID = alertaID
FROM evalImagen.alerta
WHERE lotID = @lotID
  AND tipoUmbral = 'CriticoRojo'
  AND estado IN ('Pendiente', 'Enviada')
  AND statusID = 1
ORDER BY fechaCreacion DESC;

IF @alertaCriticaID IS NOT NULL
BEGIN
    PRINT CONCAT('   ✅ Alerta CRÍTICA creada automáticamente: alertaID = ', @alertaCriticaID);
END
ELSE
BEGIN
    PRINT '   ⚠️ No se creó alerta. Verifica que el trigger esté activo.';
END

PRINT '';

-- =====================================================
-- 2. Crear Evaluación con Umbral CRÍTICO AMARILLO (30-50% luz)
-- =====================================================
-- Usar un lote diferente del mismo fundo
DECLARE @lotID2 INT;
SELECT TOP 1 @lotID2 = l.lotID 
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE l.statusID = 1 
  AND f.farmID = @fundoFiltro
  AND l.lotID != @lotID
ORDER BY l.lotID;

IF @lotID2 IS NULL
BEGIN
    PRINT '2. ⚠️ No hay otro lote disponible en el mismo fundo. Usando el mismo lote para advertencia.';
    SET @lotID2 = @lotID;
END
ELSE
BEGIN
    PRINT CONCAT('2. Creando evaluación con umbral CRÍTICO AMARILLO (40% luz) para lotID ', @lotID2, '...');
END

-- Obtener información del segundo lote
DECLARE @fundoID2 CHAR(4);
DECLARE @sectorID2 INT;
DECLARE @variedadID2 INT;

SELECT 
    @fundoID2 = f.farmID,
    @sectorID2 = s.stageID,
    @variedadID2 = p.varietyID
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
LEFT JOIN GROWER.PLANTATION p ON l.lotID = p.lotID AND p.statusID = 1
WHERE l.lotID = @lotID2
  AND l.statusID = 1;

-- Verificar si ya existe evaluación
DECLARE @loteEvaluacionID2 INT;
SELECT @loteEvaluacionID2 = loteEvaluacionID 
FROM evalImagen.loteEvaluacion 
WHERE lotID = @lotID2 
  AND statusID = 1;

-- Obtener umbralID para CriticoAmarillo
DECLARE @umbralCriticoAmarilloID INT;
SELECT TOP 1 @umbralCriticoAmarilloID = umbralID
FROM evalImagen.umbralLuz
WHERE tipo = 'CriticoAmarillo'
  AND activo = 1
  AND statusID = 1
  AND (@variedadID2 IS NULL OR variedadID IS NULL OR variedadID = @variedadID2)
ORDER BY 
    CASE WHEN variedadID IS NULL THEN 1 ELSE 0 END,
    orden;

IF @umbralCriticoAmarilloID IS NULL
    SET @umbralCriticoAmarilloID = 2; -- Valor por defecto

IF @loteEvaluacionID2 IS NOT NULL
BEGIN
    UPDATE evalImagen.loteEvaluacion
    SET 
        porcentajeLuzPromedio = 40.00, -- 40% luz = ADVERTENCIA
        porcentajeSombraPromedio = 60.00,
        porcentajeLuzMin = 35.00,
        porcentajeLuzMax = 45.00,
        porcentajeSombraMin = 55.00,
        porcentajeSombraMax = 65.00,
        tipoUmbralActual = 'CriticoAmarillo',
        fechaUltimaEvaluacion = GETDATE(),
        fechaUltimaActualizacion = GETDATE()
    WHERE lotID = @lotID2
      AND statusID = 1;
    
    PRINT '   ✅ Evaluación actualizada con umbral CRÍTICO AMARILLO';
END
ELSE
BEGIN
    INSERT INTO evalImagen.loteEvaluacion (
        lotID,
        variedadID,
        fundoID,
        sectorID,
        porcentajeLuzPromedio,
        porcentajeLuzMin,
        porcentajeLuzMax,
        porcentajeSombraPromedio,
        porcentajeSombraMin,
        porcentajeSombraMax,
        tipoUmbralActual,
        umbralIDActual,
        fechaUltimaEvaluacion,
        fechaPrimeraEvaluacion,
        totalEvaluaciones,
        periodoEvaluacionDias,
        fechaUltimaActualizacion,
        statusID
    ) VALUES (
        @lotID2,
        @variedadID2,
        @fundoID2,
        @sectorID2,
        40.00, -- 40% luz = ADVERTENCIA
        35.00,
        45.00,
        60.00,
        55.00,
        65.00,
        'CriticoAmarillo',
        @umbralCriticoAmarilloID,
        GETDATE(),
        GETDATE(),
        1,
        30,
        GETDATE(),
        1
    );
    
    PRINT '   ✅ Evaluación creada con umbral CRÍTICO AMARILLO';
END

WAITFOR DELAY '00:00:01';

-- Verificar alerta
DECLARE @alertaAdvertenciaID INT;
SELECT @alertaAdvertenciaID = alertaID
FROM evalImagen.alerta
WHERE lotID = @lotID2
  AND tipoUmbral = 'CriticoAmarillo'
  AND estado IN ('Pendiente', 'Enviada')
  AND statusID = 1
ORDER BY fechaCreacion DESC;

IF @alertaAdvertenciaID IS NOT NULL
BEGIN
    PRINT CONCAT('   ✅ Alerta ADVERTENCIA creada automáticamente: alertaID = ', @alertaAdvertenciaID);
END

PRINT '';
PRINT '========================================';
PRINT '✅ Evaluaciones creadas';
PRINT '========================================';
PRINT '';
PRINT 'Resumen de alertas creadas:';
SELECT 
    a.alertaID,
    a.lotID,
    a.tipoUmbral,
    a.severidad,
    a.estado,
    a.porcentajeLuzEvaluado,
    a.fechaCreacion
FROM evalImagen.alerta a
WHERE a.statusID = 1
  AND a.estado IN ('Pendiente', 'Enviada')
ORDER BY a.fechaCreacion DESC;
GO

