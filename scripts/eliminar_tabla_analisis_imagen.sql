-- =====================================================
-- SCRIPT: Eliminar Tabla image.Analisis_Imagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- 
-- ⚠️ ADVERTENCIA: Este script ELIMINARÁ la tabla y TODOS sus datos
-- ⚠️ Ejecutar solo si estás seguro de que puedes perder los datos
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '=== Script de eliminación de tabla image.Analisis_Imagen ===';
PRINT '';

-- =====================================================
-- 1. Verificar si la tabla existe y mostrar datos
-- =====================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.Analisis_Imagen') AND type in (N'U'))
BEGIN
    PRINT '[INFO] Tabla image.Analisis_Imagen encontrada';
    
    DECLARE @rowCount INT;
    SELECT @rowCount = COUNT(*) FROM image.Analisis_Imagen;
    PRINT CONCAT('[INFO] Registros en la tabla: ', @rowCount);
    
    IF @rowCount > 0
    BEGIN
        PRINT '⚠️ ADVERTENCIA: La tabla contiene datos que se perderán al eliminar.';
    END
    ELSE
    BEGIN
        PRINT '[INFO] La tabla está vacía.';
    END
END
ELSE
BEGIN
    PRINT '[INFO] La tabla image.Analisis_Imagen NO existe.';
    PRINT '[INFO] No hay nada que eliminar.';
    RETURN;
END
GO

-- =====================================================
-- 2. Mostrar estructura actual de la tabla
-- =====================================================
PRINT '';
PRINT '=== Estructura actual de la tabla ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'image' 
  AND TABLE_NAME = 'Analisis_Imagen'
ORDER BY ORDINAL_POSITION;
GO

-- =====================================================
-- 3. Eliminar Foreign Key Constraints primero
-- =====================================================
PRINT '';
PRINT '=== Eliminando Foreign Keys ===';

-- Eliminar FK_Analisis_Imagen_LOT_01
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Analisis_Imagen_LOT_01')
BEGIN
    ALTER TABLE image.Analisis_Imagen
    DROP CONSTRAINT FK_Analisis_Imagen_LOT_01;
    PRINT '[OK] Foreign Key FK_Analisis_Imagen_LOT_01 eliminada';
END
ELSE
BEGIN
    PRINT '[INFO] Foreign Key FK_Analisis_Imagen_LOT_01 no existe';
END
GO

-- =====================================================
-- 4. Eliminar Unique Constraints
-- =====================================================
PRINT '';
PRINT '=== Eliminando Unique Constraints ===';

-- Eliminar UQ_Analisis_Imagen_FILENAME_LOT_01
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_Analisis_Imagen_FILENAME_LOT_01')
BEGIN
    ALTER TABLE image.Analisis_Imagen
    DROP CONSTRAINT UQ_Analisis_Imagen_FILENAME_LOT_01;
    PRINT '[OK] Unique Constraint UQ_Analisis_Imagen_FILENAME_LOT_01 eliminada';
END
ELSE
BEGIN
    PRINT '[INFO] Unique Constraint UQ_Analisis_Imagen_FILENAME_LOT_01 no existe';
END
GO

-- =====================================================
-- 5. Eliminar Índices (los índices se eliminan automáticamente al eliminar la tabla, pero por si acaso)
-- =====================================================
PRINT '';
PRINT '=== Eliminando Índices ===';

-- Eliminar IDX_Analisis_Imagen_FECHA_01
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Analisis_Imagen_FECHA_01' AND object_id = OBJECT_ID('image.Analisis_Imagen'))
BEGIN
    DROP INDEX IDX_Analisis_Imagen_FECHA_01 ON image.Analisis_Imagen;
    PRINT '[OK] Índice IDX_Analisis_Imagen_FECHA_01 eliminado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_Analisis_Imagen_FECHA_01 no existe';
END
GO

-- Eliminar IDX_Analisis_Imagen_LOT_01
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Analisis_Imagen_LOT_01' AND object_id = OBJECT_ID('image.Analisis_Imagen'))
BEGIN
    DROP INDEX IDX_Analisis_Imagen_LOT_01 ON image.Analisis_Imagen;
    PRINT '[OK] Índice IDX_Analisis_Imagen_LOT_01 eliminado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_Analisis_Imagen_LOT_01 no existe';
END
GO

-- Eliminar IDX_Analisis_Imagen_UBICACION_01
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Analisis_Imagen_UBICACION_01' AND object_id = OBJECT_ID('image.Analisis_Imagen'))
BEGIN
    DROP INDEX IDX_Analisis_Imagen_UBICACION_01 ON image.Analisis_Imagen;
    PRINT '[OK] Índice IDX_Analisis_Imagen_UBICACION_01 eliminado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_Analisis_Imagen_UBICACION_01 no existe';
END
GO

-- =====================================================
-- 6. Eliminar Extended Properties (comentarios)
-- =====================================================
PRINT '';
PRINT '=== Eliminando Extended Properties ===';

-- Eliminar extended properties de la tabla
IF EXISTS (SELECT * FROM sys.extended_properties WHERE major_id = OBJECT_ID('image.Analisis_Imagen') AND minor_id = 0)
BEGIN
    EXEC sp_dropextendedproperty 
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = N'image',
        @level1type = N'TABLE', @level1name = N'Analisis_Imagen';
    PRINT '[OK] Extended property de tabla eliminada';
END
GO

-- =====================================================
-- 7. ELIMINAR LA TABLA
-- =====================================================
PRINT '';
PRINT '=== Eliminando tabla image.Analisis_Imagen ===';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.Analisis_Imagen') AND type in (N'U'))
BEGIN
    DROP TABLE image.Analisis_Imagen;
    PRINT '[OK] Tabla image.Analisis_Imagen eliminada exitosamente';
END
ELSE
BEGIN
    PRINT '[ERROR] La tabla no existe o no se pudo eliminar';
END
GO

-- =====================================================
-- 8. Verificar que la tabla fue eliminada
-- =====================================================
PRINT '';
PRINT '=== Verificación final ===';

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.Analisis_Imagen') AND type in (N'U'))
BEGIN
    PRINT '[✅] CONFIRMADO: La tabla image.Analisis_Imagen ha sido eliminada correctamente';
    PRINT '[✅] Ahora puedes ejecutar el script de creación de la nueva tabla';
END
ELSE
BEGIN
    PRINT '[❌] ERROR: La tabla aún existe. Verifica permisos o dependencias.';
END
GO

PRINT '';
PRINT '[✅] Script de eliminación completado';
GO

