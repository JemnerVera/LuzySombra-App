-- =====================================================
-- SCRIPT: Eliminar entradas de image.Analisis_Imagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- ADVERTENCIA: Esta operación es IRREVERSIBLE
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- OPCIÓN 1: Ver cuántas entradas hay antes de eliminar
-- =====================================================
PRINT '=== CONSULTA: Total de entradas en image.Analisis_Imagen ===';
SELECT 
    COUNT(*) as TotalEntradas,
    COUNT(CASE WHEN statusID = 1 THEN 1 END) as Activas,
    COUNT(CASE WHEN statusID != 1 OR statusID IS NULL THEN 1 END) as Inactivas,
    MIN(fechaCreacion) as FechaMasAntigua,
    MAX(fechaCreacion) as FechaMasReciente
FROM image.Analisis_Imagen WITH (NOLOCK);
GO

-- =====================================================
-- OPCIÓN 2: Ver detalles de las entradas (TOP 100)
-- =====================================================
PRINT '=== CONSULTA: Detalles de entradas (TOP 100) ===';
SELECT TOP 100
    analisisID,
    lotID,
    hilera,
    planta,
    filename,
    fechaCaptura,
    fechaCreacion,
    porcentajeLuz,
    porcentajeSombra,
    statusID
FROM image.Analisis_Imagen WITH (NOLOCK)
ORDER BY fechaCreacion DESC;
GO

-- =====================================================
-- OPCIÓN 3: Eliminar TODAS las entradas (¡CUIDADO!)
-- Descomenta las siguientes líneas para ejecutar:
-- =====================================================
/*
PRINT '=== ELIMINANDO TODAS LAS ENTRADAS ===';
DELETE FROM image.Analisis_Imagen;
PRINT '✅ Todas las entradas eliminadas';
GO
*/

-- =====================================================
-- OPCIÓN 4: Eliminar solo entradas inactivas (statusID != 1)
-- Más seguro que eliminar todo
-- =====================================================
/*
PRINT '=== ELIMINANDO SOLO ENTRADAS INACTIVAS ===';
DELETE FROM image.Analisis_Imagen
WHERE statusID != 1 OR statusID IS NULL;
PRINT '✅ Entradas inactivas eliminadas';
GO
*/

-- =====================================================
-- OPCIÓN 5: Eliminar entradas por rango de fechas
-- Ajusta las fechas según necesites
-- =====================================================
/*
DECLARE @FechaDesde DATE = '2024-01-01';
DECLARE @FechaHasta DATE = '2024-12-31';

PRINT '=== ELIMINANDO ENTRADAS POR RANGO DE FECHAS ===';
PRINT 'Fecha desde: ' + CAST(@FechaDesde AS VARCHAR);
PRINT 'Fecha hasta: ' + CAST(@FechaHasta AS VARCHAR);

-- Ver cuántas se van a eliminar primero
SELECT COUNT(*) as EntradasAEliminar
FROM image.Analisis_Imagen
WHERE CAST(COALESCE(fechaCaptura, fechaCreacion) AS DATE) BETWEEN @FechaDesde AND @FechaHasta;

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE CAST(COALESCE(fechaCaptura, fechaCreacion) AS DATE) BETWEEN @FechaDesde AND @FechaHasta;

PRINT '✅ Entradas eliminadas por rango de fechas';
GO
*/

-- =====================================================
-- OPCIÓN 6: Eliminar entradas por lotID específico
-- Útil para eliminar datos de un lote específico
-- =====================================================
/*
DECLARE @LotID INT = 123; -- Cambiar por el lotID deseado

PRINT '=== ELIMINANDO ENTRADAS POR LOTID ===';
PRINT 'LotID: ' + CAST(@LotID AS VARCHAR);

-- Ver cuántas se van a eliminar primero
SELECT COUNT(*) as EntradasAEliminar
FROM image.Analisis_Imagen
WHERE lotID = @LotID;

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE lotID = @LotID;

PRINT '✅ Entradas eliminadas para lotID ' + CAST(@LotID AS VARCHAR);
GO
*/

-- =====================================================
-- OPCIÓN 7: Eliminar entradas antiguas (anteriores a X días)
-- Ejemplo: eliminar entradas con más de 30 días
-- =====================================================
/*
DECLARE @DiasAntiguedad INT = 30;
DECLARE @FechaLimite DATE = DATEADD(DAY, -@DiasAntiguedad, GETDATE());

PRINT '=== ELIMINANDO ENTRADAS ANTERIORES A ' + CAST(@FechaLimite AS VARCHAR) + ' ===';

-- Ver cuántas se van a eliminar primero
SELECT COUNT(*) as EntradasAEliminar
FROM image.Analisis_Imagen
WHERE CAST(COALESCE(fechaCaptura, fechaCreacion) AS DATE) < @FechaLimite;

-- Eliminar
DELETE FROM image.Analisis_Imagen
WHERE CAST(COALESCE(fechaCaptura, fechaCreacion) AS DATE) < @FechaLimite;

PRINT '✅ Entradas antiguas eliminadas';
GO
*/

-- =====================================================
-- VERIFICACIÓN FINAL: Ver cuántas entradas quedan
-- =====================================================
PRINT '=== VERIFICACIÓN FINAL ===';
SELECT COUNT(*) as TotalEntradasRestantes
FROM image.Analisis_Imagen WITH (NOLOCK);
GO

PRINT '=== Script completado ===';
PRINT 'NOTA: Para ejecutar alguna de las opciones de eliminación, descomenta el bloque correspondiente (quita /* y */)';
GO
