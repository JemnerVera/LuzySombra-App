-- =====================================================
-- SCRIPT: Insertar Dispositivos de Ejemplo
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Datos de ejemplo
-- Propósito: Insertar dispositivos de ejemplo para testing
-- =====================================================
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas:
--      - image.Dispositivo (INSERT)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere:
--      - image.Dispositivo (debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear image.Dispositivo
-- 
-- NOTA: 
--   ⚠️  CAMBIAR las apiKeys en producción por valores seguros y únicos
--   ⚠️  Estas son solo para desarrollo/testing
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Verificar que la tabla existe
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.Dispositivo') AND type in (N'U'))
BEGIN
    PRINT '❌ ERROR: La tabla image.Dispositivo no existe. Ejecuta primero el script 07_image.Dispositivo.sql';
    RETURN;
END
GO

-- =====================================================
-- Insertar Dispositivos de Ejemplo
-- =====================================================

-- Dispositivo 1: Tablet Campo 1
IF NOT EXISTS (SELECT * FROM image.Dispositivo WHERE deviceId = 'device-test-001')
BEGIN
    INSERT INTO image.Dispositivo (
        deviceId,
        apiKey,
        nombreDispositivo,
        modeloDispositivo,
        versionApp,
        activo
    ) VALUES (
        'device-test-001',
        'test-api-key-12345',  -- ⚠️ CAMBIAR en producción
        'Dispositivo de Prueba',
        'Samsung Galaxy Tab A8',
        '1.0.0',
        1
    );
    PRINT '[OK] Dispositivo device-test-001 insertado';
END
ELSE
BEGIN
    PRINT '[INFO] Dispositivo device-test-001 ya existe';
END
GO

-- Dispositivo 2: Tablet Campo 2
IF NOT EXISTS (SELECT * FROM image.Dispositivo WHERE deviceId = 'device-002')
BEGIN
    INSERT INTO image.Dispositivo (
        deviceId,
        apiKey,
        nombreDispositivo,
        modeloDispositivo,
        versionApp,
        activo
    ) VALUES (
        'device-002',
        'agriqr-device-002-secret-key-2024',  -- ⚠️ CAMBIAR en producción
        'Tablet Campo 2',
        'Samsung Galaxy Tab A8',
        '1.0.0',
        1
    );
    PRINT '[OK] Dispositivo device-002 insertado';
END
ELSE
BEGIN
    PRINT '[INFO] Dispositivo device-002 ya existe';
END
GO

-- Dispositivo 3: Tablet Campo 3
IF NOT EXISTS (SELECT * FROM image.Dispositivo WHERE deviceId = 'device-003')
BEGIN
    INSERT INTO image.Dispositivo (
        deviceId,
        apiKey,
        nombreDispositivo,
        modeloDispositivo,
        versionApp,
        activo
    ) VALUES (
        'device-003',
        'agriqr-device-003-secret-key-2024',  -- ⚠️ CAMBIAR en producción
        'Tablet Campo 3',
        'Samsung Galaxy Tab A8',
        '1.0.0',
        1
    );
    PRINT '[OK] Dispositivo device-003 insertado';
END
ELSE
BEGIN
    PRINT '[INFO] Dispositivo device-003 ya existe';
END
GO

PRINT '';
PRINT '========================================';
PRINT 'DISPOSITIVOS DE EJEMPLO INSERTADOS';
PRINT '========================================';
PRINT '';
PRINT '⚠️  IMPORTANTE:';
PRINT '   - Cambiar las apiKeys en producción por valores seguros';
PRINT '   - Generar apiKeys únicas y aleatorias para cada dispositivo';
PRINT '   - No usar estas apiKeys en producción';
PRINT '';
PRINT 'Para generar apiKeys seguras, puedes usar:';
PRINT '   - Generador online: https://www.uuidgenerator.net/';
PRINT '   - O comando: openssl rand -hex 32';
PRINT '';

