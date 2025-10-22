-- =====================================================
-- ANÁLISIS EXPLORATORIO - Schema EVALAGRI
-- (Fenología y evaluaciones)
-- NO MODIFICA NADA - Solo consulta
-- =====================================================

-- 1. Ver todas las tablas del schema evalAgri
SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'evalAgri'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- 2. Ver estructura de evalAgri.evaluacionPlagaEnfermedad
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'evalAgri' 
  AND TABLE_NAME = 'evaluacionPlagaEnfermedad'
ORDER BY ORDINAL_POSITION;

-- 3. Ver estructura de evalAgri.EstadoFenologico
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'evalAgri' 
  AND TABLE_NAME = 'EstadoFenologico'
ORDER BY ORDINAL_POSITION;

-- 4. Ver todos los estados fenológicos disponibles
SELECT *
FROM evalAgri.EstadoFenologico
ORDER BY EstadoFenologicoId;

-- 5. Contar evaluaciones por estado
SELECT 
    ef.EstadoFenologicoNom,
    COUNT(*) AS TotalEvaluaciones
FROM evalAgri.evaluacionPlagaEnfermedad ep
INNER JOIN evalAgri.EstadoFenologico ef ON ep.EstadoFenologicoId = ef.EstadoFenologicoId
WHERE ep.estadoID = 1
GROUP BY ef.EstadoFenologicoNom
ORDER BY TotalEvaluaciones DESC;

-- 6. Ver muestra de evaluaciones (últimas 10)
SELECT TOP 10
    ep.evaluacionPlagaEnfermedadID,
    ep.Fecha,
    ep.lotID,
    ef.EstadoFenologicoNom,
    ep.Hilera,
    ep.Planta,
    ep.EvaluadorNombre
FROM evalAgri.evaluacionPlagaEnfermedad ep
INNER JOIN evalAgri.EstadoFenologico ef ON ep.EstadoFenologicoId = ef.EstadoFenologicoId
WHERE ep.estadoID = 1
ORDER BY ep.Fecha DESC;

-- 7. Contar registros de tablas principales
SELECT 
    'evaluacionPlagaEnfermedad' AS Tabla,
    COUNT(*) AS TotalRegistros,
    COUNT(CASE WHEN estadoID = 1 THEN 1 END) AS Activos
FROM evalAgri.evaluacionPlagaEnfermedad
UNION ALL
SELECT 
    'EstadoFenologico' AS Tabla,
    COUNT(*) AS TotalRegistros,
    NULL AS Activos
FROM evalAgri.EstadoFenologico;

