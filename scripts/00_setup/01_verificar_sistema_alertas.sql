-- =====================================================
-- SCRIPT: Verificar Sistema Completo de Alertas
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Verificar que todos los componentes del sistema existen
-- =====================================================
-- 
-- OBJETOS VERIFICADOS:
--   ✅ Tablas (9):
--      - evalImagen.AnalisisImagen
--      - evalImagen.UmbralLuz
--      - evalImagen.LoteEvaluacion
--      - evalImagen.Alerta
--      - evalImagen.Mensaje
--      - evalImagen.Contacto
--      - evalImagen.Dispositivo
--      - evalImagen.UsuarioWeb
--      - evalImagen.MensajeAlerta
--   ✅ Stored Procedures (1):
--      - evalImagen.usp_evalImagen_calcularLoteEvaluacion
--   ✅ Triggers (1):
--      - evalImagen.trg_loteEvaluacionAlerta_AF_IU
-- 
-- ORDEN DE EJECUCIÓN:
--   Ejecutar DESPUÉS de crear todos los componentes
-- 
-- NOTA: Este script SOLO VERIFICA, no crea objetos.
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  VERIFICACIÓN: SISTEMA COMPLETO DE ALERTAS evalImagen';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- Verificar Tablas
-- =====================================================
PRINT '>>> VERIFICANDO TABLAS...';
PRINT '';

DECLARE @TablasFaltantes INT = 0;
DECLARE @TablasExistentes INT = 0;

-- AnalisisImagen
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AnalisisImagen' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.AnalisisImagen';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.AnalisisImagen - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- UmbralLuz
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UmbralLuz' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.UmbralLuz';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.UmbralLuz - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- LoteEvaluacion
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LoteEvaluacion' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.LoteEvaluacion';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.LoteEvaluacion - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- Alerta
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Alerta' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.Alerta';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.Alerta - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- Mensaje
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Mensaje' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.Mensaje';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.Mensaje - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- Contacto
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Contacto' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.Contacto';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.Contacto - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- Dispositivo
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Dispositivo' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.Dispositivo';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.Dispositivo - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- UsuarioWeb
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UsuarioWeb' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.UsuarioWeb';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.UsuarioWeb - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

-- MensajeAlerta
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'MensajeAlerta' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    PRINT '✅ evalImagen.MensajeAlerta';
    SET @TablasExistentes = @TablasExistentes + 1;
END
ELSE
BEGIN
    PRINT '❌ evalImagen.MensajeAlerta - FALTA';
    SET @TablasFaltantes = @TablasFaltantes + 1;
END

PRINT '';
PRINT 'RESUMEN TABLAS: ' + CAST(@TablasExistentes AS VARCHAR) + ' existentes, ' + CAST(@TablasFaltantes AS VARCHAR) + ' faltantes';
PRINT '';

-- =====================================================
-- Verificar Stored Procedures
-- =====================================================
PRINT '>>> VERIFICANDO STORED PROCEDURES...';
PRINT '';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usp_evalImagen_calcularLoteEvaluacion') AND type in (N'P', N'PC'))
BEGIN
    PRINT '✅ evalImagen.usp_evalImagen_calcularLoteEvaluacion';
END
ELSE
BEGIN
    PRINT '❌ evalImagen.usp_evalImagen_calcularLoteEvaluacion - FALTA';
END

PRINT '';

-- =====================================================
-- Verificar Triggers
-- =====================================================
PRINT '>>> VERIFICANDO TRIGGERS...';
PRINT '';

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_loteEvaluacionAlerta_AF_IU' AND parent_id = OBJECT_ID('evalImagen.loteEvaluacion'))
BEGIN
    PRINT '✅ evalImagen.trg_loteEvaluacionAlerta_AF_IU';
END
ELSE
BEGIN
    PRINT '❌ evalImagen.trg_loteEvaluacionAlerta_AF_IU - FALTA';
END

PRINT '';

-- =====================================================
-- Resumen Final
-- =====================================================
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  RESUMEN FINAL';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

IF @TablasFaltantes = 0 
   AND EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usp_evalImagen_calcularLoteEvaluacion') AND type in (N'P', N'PC'))
   AND EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_loteEvaluacionAlerta_AF_IU' AND parent_id = OBJECT_ID('evalImagen.loteEvaluacion'))
BEGIN
    PRINT '✅ SISTEMA COMPLETO - Todos los componentes están instalados';
    PRINT '';
    PRINT 'Próximos pasos:';
    PRINT '  1. Insertar umbrales iniciales en evalImagen.UmbralLuz';
    PRINT '  2. Insertar contactos en evalImagen.Contacto';
    PRINT '  3. Insertar usuario admin inicial en evalImagen.UsuarioWeb';
    PRINT '  4. Probar el sistema con una imagen de prueba';
END
ELSE
BEGIN
    PRINT '⚠️  SISTEMA INCOMPLETO - Faltan componentes';
    PRINT '';
    PRINT 'Por favor ejecute los scripts faltantes según el orden en:';
    PRINT '  scripts/00_setup/00_SCRIPT_MAESTRO_RECREAR_TABLAS.sql';
END

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
GO
