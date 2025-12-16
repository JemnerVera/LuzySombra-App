-- =====================================================
-- SCRIPT MAESTRO: Recrear Todas las Tablas del Schema evalImagen
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Servidor: [CONFIGURAR - Reemplazar con IP o hostname de tu servidor SQL]
-- Tipo: Setup / Script Maestro
-- Propósito: Recrear todas las tablas después de borrado
-- =====================================================
-- 
-- ⚠️  IMPORTANTE: Este script NO ejecuta los scripts automáticamente
--     Solo muestra el orden correcto de ejecución
-- 
-- ORDEN DE EJECUCIÓN (ejecutar manualmente en este orden):
-- 
-- 1️⃣ TABLAS (01_tables) - Ejecutar en este orden:
--    ✅ 01_evalImagen.analisisImagen.sql      (crea schema evalImagen)
--    ✅ 02_evalImagen.umbralLuz.sql             (depende de schema evalImagen)
--    ✅ 03_evalImagen.loteEvaluacion.sql       (depende de evalImagen.umbralLuz)
--    ✅ 04_evalImagen.alerta.sql               (depende de evalImagen.loteEvaluacion + evalImagen.umbralLuz)
--    ✅ 05_evalImagen.mensaje.sql              (depende de evalImagen.alerta)
--    ✅ 06_evalImagen.contacto.sql             (independiente)
--    ✅ 07_evalImagen.dispositivo.sql          (independiente)
--    ✅ 08_evalImagen.mensajeAlerta.sql        (depende de evalImagen.mensaje + evalImagen.alerta)
--    ✅ 09_evalImagen.usuarioWeb.sql           (independiente - autenticación usuarios web)
--    ✅ 10_evalImagen.intentoLogin.sql         (independiente - rate limiting y auditoría)
-- 
-- 2️⃣ STORED PROCEDURES (03_stored_procedures):
--    ✅ 01_sp_CalcularLoteEvaluacion.sql   (depende de evalImagen.loteEvaluacion)
-- 
-- 3️⃣ TRIGGERS (05_triggers):
--    ✅ 01_trg_loteEvaluacion_Alerta.sql   (depende de evalImagen.loteEvaluacion + evalImagen.alerta) (ahora: trg_loteEvaluacionAlerta_AF_IU)
-- 
-- 5️⃣ DATOS INICIALES (opcional):
--    ⚠️  Los scripts de datos de ejemplo fueron eliminados
--    ⚠️  Usar scripts/07_utilities/ para insertar datos de prueba si es necesario
-- 
-- VERIFICACIÓN:
--    ✅ 00_setup/01_verificar_sistema_alertas.sql (verificar que todo esté creado)
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  SCRIPT MAESTRO: RECREAR TABLAS DEL SCHEMA evalImagen';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT '⚠️  IMPORTANTE: Este script NO ejecuta automáticamente.';
PRINT '   Debes ejecutar cada script manualmente en el orden indicado.';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  PASO 1: CREAR TABLAS (01_tables)';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Ejecutar en este orden:';
PRINT '  1. scripts/01_tables/01_evalImagen.analisisImagen.sql';
PRINT '  2. scripts/01_tables/02_evalImagen.umbralLuz.sql';
PRINT '  3. scripts/01_tables/03_evalImagen.loteEvaluacion.sql';
PRINT '  4. scripts/01_tables/04_evalImagen.alerta.sql';
PRINT '  5. scripts/01_tables/05_evalImagen.mensaje.sql';
PRINT '  6. scripts/01_tables/06_evalImagen.contacto.sql';
PRINT '  7. scripts/01_tables/07_evalImagen.dispositivo.sql';
PRINT '  8. scripts/01_tables/08_evalImagen.mensajeAlerta.sql';
PRINT '  9. scripts/01_tables/09_evalImagen.usuarioWeb.sql';
PRINT ' 10. scripts/01_tables/10_evalImagen.intentoLogin.sql';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  PASO 2: CREAR STORED PROCEDURES (03_stored_procedures)';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Ejecutar:';
PRINT '  scripts/03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql (ahora: usp_evalImagen_calcularLoteEvaluacion)';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  PASO 3: CREAR TRIGGERS (05_triggers)';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Ejecutar:';
PRINT '  scripts/05_triggers/01_trg_loteEvaluacion_Alerta.sql (ahora: trg_loteEvaluacionAlerta_AF_IU)';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  PASO 4: VERIFICAR INSTALACIÓN';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Ejecutar:';
PRINT '  scripts/00_setup/01_verificar_sistema_alertas.sql';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ INSTRUCCIONES COMPLETAS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Todos los scripts tienen "IF NOT EXISTS", así que son seguros';
PRINT 'de ejecutar múltiples veces.';
PRINT '';
PRINT 'Usuario SQL: [CONFIGURAR - Contactar al administrador]';
PRINT '';

GO

