-- =====================================================
-- SCRIPT: Verificar Schemas de Tablas Existentes
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Servidor: [CONFIGURAR - Reemplazar con IP o hostname de tu servidor SQL]
-- Tipo: Utilidad / Verificación
-- Propósito: Catalogar estructuras de todas las tablas existentes que usaremos
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno (solo consultas SELECT)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno (solo lectura)
-- 
-- DEPENDENCIAS:
--   ⚠️  Consulta tablas existentes:
--      - MAST.USERS
--      - GROWER.LOT
--      - GROWER.STAGE
--      - GROWER.FARMS
--      - GROWER.GROWERS
--      - GROWER.PLANTATION
--      - GROWER.VARIETY
--      - Y otras tablas relacionadas
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento (solo lectura)
-- 
-- CONTENIDO:
--   - Consultas INFORMATION_SCHEMA para verificar estructura de tablas
--   - Útil para debugging y documentación
-- 
-- NOTA: Este script es SOLO DE LECTURA, no modifica nada
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '========================================';
PRINT 'VERIFICACIÓN DE SCHEMAS - TABLAS EXISTENTES';
PRINT '========================================';
PRINT '';

-- =====================================================
-- 1. MAST.USERS
-- =====================================================
PRINT '=== 1. MAST.USERS (USUARIO) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'MAST' AND TABLE_NAME = 'USERS'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 2. MAST.ORIGIN (PAIS)
-- =====================================================
PRINT '=== 2. MAST.ORIGIN (PAIS) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'MAST' AND TABLE_NAME = 'ORIGIN'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 3. GROWER.GROWERS (EMPRESA)
-- =====================================================
PRINT '=== 3. GROWER.GROWERS (EMPRESA) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'GROWERS'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- Ver Primary Key
SELECT 
    c.COLUMN_NAME,
    c.DATA_TYPE,
    tc.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
    ON tc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
WHERE tc.TABLE_SCHEMA = 'GROWER' 
  AND tc.TABLE_NAME = 'GROWERS'
  AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';
PRINT '';

-- =====================================================
-- 4. GROWER.FARMS (FUNDO)
-- =====================================================
PRINT '=== 4. GROWER.FARMS (FUNDO) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'FARMS'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- Ver Primary Key y Foreign Keys
SELECT 
    c.COLUMN_NAME,
    c.DATA_TYPE,
    tc.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
    ON tc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
WHERE tc.TABLE_SCHEMA = 'GROWER' 
  AND tc.TABLE_NAME = 'FARMS'
  AND tc.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY tc.CONSTRAINT_TYPE, c.ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 5. GROWER.STAGE (SECTOR)
-- =====================================================
PRINT '=== 5. GROWER.STAGE (SECTOR) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'STAGE'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- Ver Primary Key y Foreign Keys
SELECT 
    c.COLUMN_NAME,
    c.DATA_TYPE,
    tc.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
    ON tc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
WHERE tc.TABLE_SCHEMA = 'GROWER' 
  AND tc.TABLE_NAME = 'STAGE'
  AND tc.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY tc.CONSTRAINT_TYPE, c.ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 6. GROWER.LOT (LOTE)
-- =====================================================
PRINT '=== 6. GROWER.LOT (LOTE) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'LOT'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- Ver Primary Key y Foreign Keys
SELECT 
    c.COLUMN_NAME,
    c.DATA_TYPE,
    tc.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
    ON tc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
WHERE tc.TABLE_SCHEMA = 'GROWER' 
  AND tc.TABLE_NAME = 'LOT'
  AND tc.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY tc.CONSTRAINT_TYPE, c.ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 7. GROWER.PLANTATION (UNION PLANTAS)
-- =====================================================
PRINT '=== 7. GROWER.PLANTATION (UNION PLANTAS) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'PLANTATION'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 8. GROWER.PLANT (PLANTAS POR LOTE - PLANTACION)
-- =====================================================
PRINT '=== 8. GROWER.PLANT (PLANTAS POR LOTE) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'PLANT'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 9. GROWER.VARIETY (VARIEDAD - POR PLANTACION)
-- =====================================================
PRINT '=== 9. GROWER.VARIETY (VARIEDAD) ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'VARIETY'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 10. PPP.ESTADOFENOLOGICO (ESTADO_FENOLOGICO)
-- =====================================================
PRINT '=== 10. PPP.ESTADOFENOLOGICO ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'PPP' AND TABLE_NAME = 'ESTADOFENOLOGICO'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 11. PPP.GRUPOFENOLOGICO (GRUPO_FENOLOGICO)
-- =====================================================
PRINT '=== 11. PPP.GRUPOFENOLOGICO ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'PPP' AND TABLE_NAME = 'GRUPOFENOLOGICO'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- 12. GROWER.CAMPAIGN (CAMPAÑA)
-- =====================================================
PRINT '=== 12. GROWER.CAMPAIGN ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'GROWER' AND TABLE_NAME = 'CAMPAIGN'
ORDER BY ORDINAL_POSITION;
PRINT '';

-- =====================================================
-- RESUMEN: Foreign Keys y Relaciones
-- =====================================================
PRINT '========================================';
PRINT 'RESUMEN: FOREIGN KEYS Y RELACIONES';
PRINT '========================================';

-- Foreign Keys de GROWER.FARMS
PRINT '-- Foreign Keys de GROWER.FARMS --';
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ParentTable,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ParentColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc 
    ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'FARMS'
  AND SCHEMA_NAME(fk.schema_id) = 'GROWER';
PRINT '';

-- Foreign Keys de GROWER.STAGE
PRINT '-- Foreign Keys de GROWER.STAGE --';
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ParentTable,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ParentColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc 
    ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'STAGE'
  AND SCHEMA_NAME(fk.schema_id) = 'GROWER';
PRINT '';

-- Foreign Keys de GROWER.LOT
PRINT '-- Foreign Keys de GROWER.LOT --';
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ParentTable,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ParentColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc 
    ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'LOT'
  AND SCHEMA_NAME(fk.schema_id) = 'GROWER';
PRINT '';

PRINT '========================================';
PRINT '[✅] Verificación completada';
PRINT '========================================';
GO

