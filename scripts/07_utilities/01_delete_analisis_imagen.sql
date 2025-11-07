-- =====================================================
-- SCRIPT: Eliminar Entradas de image.Analisis_Imagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Utilidad / Administración
-- Propósito: Scripts para eliminar entradas de image.Analisis_Imagen de forma segura
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno
-- 
-- OBJETOS MODIFICADOS:
--   ⚠️  Tablas (al ejecutar):
--      - image.Analisis_Imagen (DELETE - solo si se descomenta)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.Analisis_Imagen (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento (solo si es necesario)
-- 
-- ADVERTENCIA:
--   ⚠️  Este script contiene comandos DELETE que están comentados por seguridad.
--   ⚠️  Siempre ejecutar primero los SELECT COUNT(*) para verificar cuántos registros se eliminarán.
--   ⚠️  Hacer backup antes de ejecutar cualquier DELETE.
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ELIMINACIÓN DE ENTRADAS - image.Analisis_Imagen';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT '⚠️  ADVERTENCIA: Este script contiene comandos DELETE.';
PRINT '   Todos los comandos DELETE están comentados por seguridad.';
PRINT '   Descomentar SOLO después de verificar con SELECT COUNT(*)';
PRINT '';

-- =====================================================
-- OPCIÓN 1: Eliminar TODAS las entradas (CUIDADO!)
-- =====================================================
PRINT '=== OPCIÓN 1: Eliminar TODAS las entradas ===';
PRINT '';

-- Primero verificar cuántos registros se eliminarían
SELECT COUNT(*) AS TotalRegistrosAEliminar
FROM image.Analisis_Imagen;
GO

-- Descomentar para ejecutar (CUIDADO!)
/*
BEGIN TRANSACTION;

DELETE FROM image.Analisis_Imagen;

-- Verificar resultado
DECLARE @RegistrosEliminados INT = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' entradas eliminadas';

-- Recalcular estadísticas para todos los lotes
EXEC image.sp_CalcularLoteEvaluacion;

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 2: Eliminar solo entradas inactivas (statusID != 1)
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 2: Eliminar entradas inactivas ===';
PRINT '';

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS RegistrosInactivos
FROM image.Analisis_Imagen
WHERE statusID != 1;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @RegistrosEliminados INT;
DECLARE @LotID INT;

-- Guardar lotIDs afectados antes de eliminar
SELECT DISTINCT lotID INTO #LotesAfectados
FROM image.Analisis_Imagen
WHERE statusID != 1;

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE statusID != 1;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' entradas inactivas eliminadas';

-- Recalcular estadísticas para lotes afectados
DECLARE lot_cursor CURSOR FOR
SELECT lotID FROM #LotesAfectados;

OPEN lot_cursor;
FETCH NEXT FROM lot_cursor INTO @LotID;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC image.sp_CalcularLoteEvaluacion @LotID = @LotID;
    FETCH NEXT FROM lot_cursor INTO @LotID;
END;

CLOSE lot_cursor;
DEALLOCATE lot_cursor;
DROP TABLE #LotesAfectados;

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 3: Eliminar por fecha (más antiguas que X días)
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 3: Eliminar entradas más antiguas que X días ===';
PRINT '';

DECLARE @DiasAntiguos INT = 90; -- Cambiar según necesidad

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS RegistrosAntiguos
FROM image.Analisis_Imagen
WHERE fechaCreacion < DATEADD(DAY, -@DiasAntiguos, GETDATE());
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @DiasAntiguos INT = 90; -- Cambiar según necesidad
DECLARE @RegistrosEliminados INT;
DECLARE @LotID INT;

-- Guardar lotIDs afectados antes de eliminar
SELECT DISTINCT lotID INTO #LotesAfectados
FROM image.Analisis_Imagen
WHERE fechaCreacion < DATEADD(DAY, -@DiasAntiguos, GETDATE());

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE fechaCreacion < DATEADD(DAY, -@DiasAntiguos, GETDATE());

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' entradas más antiguas que ' + CAST(@DiasAntiguos AS VARCHAR) + ' días eliminadas';

-- Recalcular estadísticas para lotes afectados
DECLARE lot_cursor CURSOR FOR
SELECT lotID FROM #LotesAfectados;

OPEN lot_cursor;
FETCH NEXT FROM lot_cursor INTO @LotID;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC image.sp_CalcularLoteEvaluacion @LotID = @LotID;
    FETCH NEXT FROM lot_cursor INTO @LotID;
END;

CLOSE lot_cursor;
DEALLOCATE lot_cursor;
DROP TABLE #LotesAfectados;

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 4: Eliminar por lotID específico
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 4: Eliminar entradas de un lote específico ===';
PRINT '';

DECLARE @LotID INT = 1003; -- Cambiar según necesidad

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS RegistrosPorLote
FROM image.Analisis_Imagen
WHERE lotID = @LotID;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @LotID INT = 1003; -- Cambiar según necesidad
DECLARE @RegistrosEliminados INT;

DELETE FROM image.Analisis_Imagen
WHERE lotID = @LotID;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' entradas del lote ' + CAST(@LotID AS VARCHAR) + ' eliminadas';

-- Recalcular estadísticas para el lote
EXEC image.sp_CalcularLoteEvaluacion @LotID = @LotID;

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- OPCIÓN 5: Eliminar por rango de fechas
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 5: Eliminar entradas en un rango de fechas ===';
PRINT '';

DECLARE @FechaInicio DATETIME = '2024-01-01'; -- Cambiar según necesidad
DECLARE @FechaFin DATETIME = '2024-12-31';     -- Cambiar según necesidad

-- Verificar cuántos registros se eliminarían
SELECT COUNT(*) AS RegistrosEnRango
FROM image.Analisis_Imagen
WHERE fechaCreacion >= @FechaInicio 
  AND fechaCreacion <= @FechaFin;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @FechaInicio DATETIME = '2024-01-01';
DECLARE @FechaFin DATETIME = '2024-12-31';
DECLARE @RegistrosEliminados INT;
DECLARE @LotID INT;

-- Guardar lotIDs afectados antes de eliminar
SELECT DISTINCT lotID INTO #LotesAfectados
FROM image.Analisis_Imagen
WHERE fechaCreacion >= @FechaInicio 
  AND fechaCreacion <= @FechaFin;

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE fechaCreacion >= @FechaInicio 
  AND fechaCreacion <= @FechaFin;

SET @RegistrosEliminados = @@ROWCOUNT;
PRINT '[OK] ' + CAST(@RegistrosEliminados AS VARCHAR) + ' entradas en rango de fechas eliminadas';

-- Recalcular estadísticas para lotes afectados
DECLARE lot_cursor CURSOR FOR
SELECT lotID FROM #LotesAfectados;

OPEN lot_cursor;
FETCH NEXT FROM lot_cursor INTO @LotID;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC image.sp_CalcularLoteEvaluacion @LotID = @LotID;
    FETCH NEXT FROM lot_cursor INTO @LotID;
END;

CLOSE lot_cursor;
DEALLOCATE lot_cursor;
DROP TABLE #LotesAfectados;

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- =====================================================
-- OPCIÓN 6: Eliminar por analisisID específico
-- =====================================================
PRINT '';
PRINT '=== OPCIÓN 6: Eliminar entrada específica por analisisID ===';
PRINT '';

DECLARE @AnalisisID INT = 1; -- Cambiar según necesidad

-- Verificar que existe
SELECT 
    analisisID,
    lotID,
    filename,
    fechaCreacion,
    porcentajeLuz,
    porcentajeSombra
FROM image.Analisis_Imagen
WHERE analisisID = @AnalisisID;
GO

-- Descomentar para ejecutar
/*
BEGIN TRANSACTION;

DECLARE @AnalisisID INT = 1; -- Cambiar según necesidad
DECLARE @LotID INT;

-- Obtener lotID antes de eliminar
SELECT @LotID = lotID
FROM image.Analisis_Imagen
WHERE analisisID = @AnalisisID;

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE analisisID = @AnalisisID;

IF @@ROWCOUNT > 0
BEGIN
    PRINT '[OK] Entrada ' + CAST(@AnalisisID AS VARCHAR) + ' eliminada';
    
    -- Recalcular estadísticas para el lote
    IF @LotID IS NOT NULL
    BEGIN
        EXEC image.sp_CalcularLoteEvaluacion @LotID = @LotID;
    END
END
ELSE
BEGIN
    PRINT '[INFO] No se encontró entrada con analisisID ' + CAST(@AnalisisID AS VARCHAR);
END

COMMIT TRANSACTION;
GO
*/

-- =====================================================
-- NOTA IMPORTANTE: Actualizar image.LoteEvaluacion después de eliminar
-- =====================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  NOTA IMPORTANTE';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Después de eliminar entradas de image.Analisis_Imagen,';
PRINT 'SIEMPRE ejecutar para recalcular estadísticas:';
PRINT '';
PRINT '  -- Para un lote específico:';
PRINT '  EXEC image.sp_CalcularLoteEvaluacion @LotID = [lotID];';
PRINT '';
PRINT '  -- Para todos los lotes:';
PRINT '  EXEC image.sp_CalcularLoteEvaluacion;';
PRINT '';
PRINT 'NOTA: Los scripts de DELETE arriba ya incluyen la recalculación automática.';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

