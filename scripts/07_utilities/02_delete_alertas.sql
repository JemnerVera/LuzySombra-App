-- =====================================================
-- SCRIPT: Eliminar Entradas de image.Alerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Utilidad / Administración
-- Propósito: Scripts para eliminar entradas de image.Alerta de forma segura
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno
-- 
-- OBJETOS MODIFICADOS:
--   ⚠️  Tablas (al ejecutar):
--      - image.Alerta (DELETE - solo si se descomenta)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.Alerta (tabla debe existir)
--   ⚠️  Requiere: image.Mensaje (si hay FKs relacionadas)
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento (solo si es necesario)
-- 
-- ADVERTENCIA:
--   ⚠️  Este script contiene comandos DELETE que están comentados por seguridad.
--   ⚠️  Siempre ejecutar primero los SELECT COUNT(*) para verificar cuántos registros se eliminarán.
--   ⚠️  Hacer backup antes de ejecutar cualquier DELETE.
--   ⚠️  Las alertas Resueltas o Ignoradas pueden ser importantes para el historial.
--   ⚠️  Considera usar UPDATE para marcar como inactivas (statusID = 0) en lugar de DELETE.
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ELIMINACIÓN DE ENTRADAS - image.Alerta';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT '⚠️  ADVERTENCIA: Este script contiene comandos DELETE.';
PRINT '   Todos los comandos DELETE están comentados por seguridad.';
PRINT '   Descomentar SOLO después de verificar con SELECT COUNT(*)';
PRINT '';
PRINT '💡 RECOMENDACIÓN: Considera usar UPDATE para marcar como inactivas';
PRINT '   (statusID = 0) en lugar de DELETE para mantener historial.';
PRINT '';

-- =====================================================
-- OPCIÓN 1: Eliminar TODAS las entradas (CUIDADO!)
-- =====================================================
PRINT '=== OPCIÓN 1: Eliminar TODAS las entradas ===';
PRINT '';

-- Primero verificar cuántos registros se eliminarían
SELECT COUNT(*) AS TotalRegistrosAEliminar
FROM image.Alerta;
GO

-- Descomentar para ejecutar (CUIDADO!)
/*
BEGIN TRANSACTION;

DELETE FROM image.Alerta;

-- Verificar resultado
DECLARE @RegistrosEliminados INT = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 2: Marcar como inactivas (RECOMENDADO - mantiene historial)
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 2: Marcar alertas como inactivas (RECOMENDADO) ===';
PRINT '';

-- Verificar cuántos registros se marcarían como inactivos
SELECT COUNT(*) AS AlertasActivas
FROM image.Alerta
WHERE statusID = 1;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @RegistrosActualizados INT;

UPDATE image.Alerta
SET statusID = 0
WHERE statusID = 1;

SET @RegistrosActualizados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosActualizados AS VARCHAR) + ' alertas marcadas como inactivas (historial preservado)';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 3: Eliminar solo alertas Resueltas
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 3: Eliminar solo alertas Resueltas ===';
PRINT '';

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasResueltas
FROM image.Alerta
WHERE estado = 'Resuelta';
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE estado = 'Resuelta';

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas resueltas eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 4: Eliminar solo alertas Resueltas o Ignoradas
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 4: Eliminar alertas Resueltas o Ignoradas ===';
PRINT '';

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasResueltasOIgnoradas
FROM image.Alerta
WHERE estado IN ('Resuelta', 'Ignorada');
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE estado IN ('Resuelta', 'Ignorada');

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas resueltas/ignoradas eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 5: Eliminar por fecha (más antiguas que X días)
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 5: Eliminar alertas más antiguas que X días ===';
PRINT '';

DECLARE @DiasAntiguos INT = 90; -- Cambiar según necesidad

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasAntiguas
FROM image.Alerta
WHERE fechaCreacion < DATEADD(DAY, -@DiasAntiguos, GETDATE());
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @DiasAntiguos INT = 90; -- Cambiar según necesidad
DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE fechaCreacion < DATEADD(DAY, -@DiasAntiguos, GETDATE());

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas más antiguas que ' + CAST(@DiasAntiguos AS VARCHAR) + ' días eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 6: Eliminar por lotID específico
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 6: Eliminar alertas de un lote específico ===';
PRINT '';

DECLARE @LotID INT = 1022; -- Cambiar según necesidad

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasPorLote
FROM image.Alerta
WHERE lotID = @LotID;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @LotID INT = 1022; -- Cambiar según necesidad
DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE lotID = @LotID;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas del lote ' + CAST(@LotID AS VARCHAR) + ' eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 7: Eliminar por tipoUmbral específico
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 7: Eliminar alertas por tipo de umbral ===';
PRINT '';

DECLARE @TipoUmbral VARCHAR(20) = 'CriticoAmarillo'; -- 'CriticoRojo', 'CriticoAmarillo', 'Normal'

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasPorTipo
FROM image.Alerta
WHERE tipoUmbral = @TipoUmbral;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @TipoUmbral VARCHAR(20) = 'CriticoAmarillo'; -- Cambiar según necesidad
DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE tipoUmbral = @TipoUmbral;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas del tipo ' + @TipoUmbral + ' eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 8: Eliminar por estado específico
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 8: Eliminar alertas por estado ===';
PRINT '';

DECLARE @Estado VARCHAR(20) = 'Pendiente'; -- 'Pendiente', 'Enviada', 'Resuelta', 'Ignorada'

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasPorEstado
FROM image.Alerta
WHERE estado = @Estado;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @Estado VARCHAR(20) = 'Pendiente'; -- Cambiar según necesidad
DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE estado = @Estado;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas con estado ' + @Estado + ' eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 9: Eliminar por alertaID específico
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 9: Eliminar alerta específica por alertaID ===';
PRINT '';

DECLARE @AlertaID INT = 1; -- Cambiar según necesidad

-- Verificar que existe
SELECT 
    alertaID,
    lotID,
    tipoUmbral,
    severidad,
    estado,
    fechaCreacion
FROM image.Alerta
WHERE alertaID = @AlertaID;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @AlertaID INT = 1; -- Cambiar según necesidad

DELETE FROM image.Alerta
WHERE alertaID = @AlertaID;

IF @@ROWCOUNT > 0
    PRINT '[OK] Alerta ' + CAST(@AlertaID AS VARCHAR) + ' eliminada';
ELSE
    PRINT '[INFO] No se encontró alerta con alertaID ' + CAST(@AlertaID AS VARCHAR);

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 10: Eliminar por rango de fechas
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 10: Eliminar alertas en un rango de fechas ===';
PRINT '';

DECLARE @FechaInicio DATETIME = '2024-01-01'; -- Cambiar según necesidad
DECLARE @FechaFin DATETIME = '2024-12-31';     -- Cambiar según necesidad

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasEnRango
FROM image.Alerta
WHERE fechaCreacion >= @FechaInicio 
  AND fechaCreacion <= @FechaFin;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @FechaInicio DATETIME = '2024-01-01';
DECLARE @FechaFin DATETIME = '2024-12-31';
DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE fechaCreacion >= @FechaInicio 
  AND fechaCreacion <= @FechaFin;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas en rango de fechas eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 11: Eliminar solo alertas inactivas (statusID != 1)
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 11: Eliminar solo alertas inactivas ===';
PRINT '';

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS AlertasInactivas
FROM image.Alerta
WHERE statusID != 1;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @RegistrosEliminados INT;

DELETE FROM image.Alerta
WHERE statusID != 1;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' alertas inactivas eliminadas';

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- NOTA IMPORTANTE: Consideraciones adicionales
-- =====================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  NOTA IMPORTANTE';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'RECOMENDACIONES:';
PRINT '  - Considera usar UPDATE (statusID = 0) en lugar de DELETE para mantener historial';
PRINT '  - Las alertas Resueltas pueden ser importantes para análisis históricos';
PRINT '  - Si hay FKs relacionadas con image.Mensaje, verifica dependencias antes de eliminar';
PRINT '';
PRINT 'VERIFICAR DEPENDENCIAS:';
PRINT '  SELECT * FROM image.Mensaje WHERE alertaID IN (SELECT alertaID FROM image.Alerta WHERE ...);';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

