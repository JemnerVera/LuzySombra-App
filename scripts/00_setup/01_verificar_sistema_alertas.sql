-- =====================================================
-- SCRIPT MAESTRO: Crear Sistema Completo de Alertas
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Setup / Script Maestro
-- Propósito: Verificar que todos los componentes del sistema de alertas existen
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno (solo verifica existencia)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno (solo verificación)
-- 
-- DEPENDENCIAS:
--   ⚠️  Verifica existencia de:
--      - image.UmbralLuz (tabla)
--      - image.LoteEvaluacion (tabla)
--      - image.Alerta (tabla)
--      - image.Mensaje (tabla)
--      - image.sp_CalcularLoteEvaluacion (stored procedure)
-- 
-- ORDEN DE EJECUCIÓN:
--   Ejecutar DESPUÉS de crear todos los componentes individuales
-- 
-- CONTENIDO:
--   - Verificación de existencia de todos los componentes
--   - Resumen de instalación
--   - Instrucciones de próximos pasos
-- 
-- NOTA: Este script SOLO VERIFICA, no crea objetos.
--       Ejecutar los scripts individuales en orden primero.
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  SISTEMA COMPLETO DE ALERTAS - INSTALACIÓN';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Este script ejecutará todos los componentes necesarios:';
PRINT '  1. Tabla de Umbrales (image.UmbralLuz)';
PRINT '  2. Tabla de Agregación de Lotes (image.LoteEvaluacion)';
PRINT '  3. Tabla de Alertas (image.Alerta)';
PRINT '  4. Tabla de Mensajes (image.Mensaje)';
PRINT '  5. Stored Procedure de Cálculo (image.sp_CalcularLoteEvaluacion)';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- PASO 1: Crear tabla image.UmbralLuz
-- =====================================================
PRINT '>>> PASO 1: Creando tabla image.UmbralLuz...';
PRINT '';

-- Ejecutar script de UmbralLuz (incluye datos iniciales)
-- NOTA: Este script debe ejecutarse primero desde el archivo create_table_umbral_luz.sql
-- Se incluye aquí solo la referencia

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UmbralLuz' AND schema_id = SCHEMA_ID('image'))
BEGIN
    PRINT '⚠️  ERROR: Tabla image.UmbralLuz no existe.';
    PRINT '    Por favor ejecute primero: scripts/create_table_umbral_luz.sql';
    PRINT '';
    PRINT '    O ejecute este script maestro que incluye todos los scripts:';
    PRINT '    scripts/00_crear_sistema_alertas_completo.sql';
    RETURN;
END
ELSE
BEGIN
    PRINT '✅ Tabla image.UmbralLuz existe';
END
GO

-- =====================================================
-- PASO 2: Crear tabla image.LoteEvaluacion
-- =====================================================
PRINT '';
PRINT '>>> PASO 2: Creando tabla image.LoteEvaluacion...';
PRINT '';

-- Ejecutar script de LoteEvaluacion
-- NOTA: El contenido del script está en create_table_lote_evaluacion.sql
-- Por simplicidad, se referencia aquí

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LoteEvaluacion' AND schema_id = SCHEMA_ID('image'))
BEGIN
    PRINT '⚠️  ERROR: Tabla image.LoteEvaluacion no existe.';
    PRINT '    Por favor ejecute: scripts/create_table_lote_evaluacion.sql';
    RETURN;
END
ELSE
BEGIN
    PRINT '✅ Tabla image.LoteEvaluacion existe';
END
GO

-- =====================================================
-- PASO 3: Crear tabla image.Alerta
-- =====================================================
PRINT '';
PRINT '>>> PASO 3: Creando tabla image.Alerta...';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Alerta' AND schema_id = SCHEMA_ID('image'))
BEGIN
    PRINT '⚠️  ERROR: Tabla image.Alerta no existe.';
    PRINT '    Por favor ejecute: scripts/create_table_alerta.sql';
    RETURN;
END
ELSE
BEGIN
    PRINT '✅ Tabla image.Alerta existe';
END
GO

-- =====================================================
-- PASO 4: Crear tabla image.Mensaje
-- =====================================================
PRINT '';
PRINT '>>> PASO 4: Creando tabla image.Mensaje...';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Mensaje' AND schema_id = SCHEMA_ID('image'))
BEGIN
    PRINT '⚠️  ERROR: Tabla image.Mensaje no existe.';
    PRINT '    Por favor ejecute: scripts/create_table_mensaje.sql';
    RETURN;
END
ELSE
BEGIN
    PRINT '✅ Tabla image.Mensaje existe';
END
GO

-- =====================================================
-- PASO 5: Crear Stored Procedure
-- =====================================================
PRINT '';
PRINT '>>> PASO 5: Creando Stored Procedure image.sp_CalcularLoteEvaluacion...';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.sp_CalcularLoteEvaluacion') AND type in (N'P', N'PC'))
BEGIN
    PRINT '⚠️  ERROR: Stored Procedure image.sp_CalcularLoteEvaluacion no existe.';
    PRINT '    Por favor ejecute: scripts/create_sp_calcular_lote_evaluacion.sql';
    RETURN;
END
ELSE
BEGIN
    PRINT '✅ Stored Procedure image.sp_CalcularLoteEvaluacion existe';
END
GO

-- =====================================================
-- Verificación final
-- =====================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  VERIFICACIÓN FINAL';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

SELECT 
    'Tablas' AS Tipo,
    t.name AS Nombre,
    CASE WHEN t.name IS NOT NULL THEN '✅ Creada' ELSE '❌ No existe' END AS Estado
FROM (
    SELECT 'UmbralLuz' AS name
    UNION ALL SELECT 'LoteEvaluacion'
    UNION ALL SELECT 'Alerta'
    UNION ALL SELECT 'Mensaje'
) t
LEFT JOIN sys.tables st ON st.name = t.name AND st.schema_id = SCHEMA_ID('image')
UNION ALL
SELECT 
    'Stored Procedure' AS Tipo,
    'sp_CalcularLoteEvaluacion' AS Nombre,
    CASE WHEN EXISTS (
        SELECT * FROM sys.objects 
        WHERE object_id = OBJECT_ID(N'image.sp_CalcularLoteEvaluacion') 
        AND type in (N'P', N'PC')
    ) THEN '✅ Creado' ELSE '❌ No existe' END AS Estado;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  PRÓXIMOS PASOS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT '1. Calcular estadísticas iniciales para todos los lotes:';
PRINT '   EXEC image.sp_CalcularLoteEvaluacion;';
PRINT '';
PRINT '2. Configurar job SQL Server para recalcular periódicamente:';
PRINT '   - Ejecutar diariamente: EXEC image.sp_CalcularLoteEvaluacion;';
PRINT '';
PRINT '3. Implementar lógica de generación de alertas en backend:';
PRINT '   - Verificar cambios en tipoUmbralActual';
PRINT '   - Crear alertas cuando cambia a CriticoRojo/CriticoAmarillo';
PRINT '';
PRINT '4. Configurar Resend API en variables de entorno:';
PRINT '   RESEND_API_KEY=...';
PRINT '   ALERTAS_EMAIL_DESTINATARIOS=["email1@example.com"]';
PRINT '';
PRINT '5. Implementar servicio de envío de emails (Resend)';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  INSTALACIÓN COMPLETA';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

