-- =====================================================
-- Script para optimizar tabla image.Analisis_Imagen
-- Elimina la columna duplicada 'filepath' (solo se usa 'processedImageUrl')
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Verificar estructura actual
PRINT '=== Estructura actual de image.Analisis_Imagen ===';
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

-- Verificar si hay datos en filepath que no estén en processedImageUrl
PRINT '=== Verificando datos en filepath vs processedImageUrl ===';
SELECT 
    COUNT(*) as total_registros,
    SUM(CASE WHEN filepath IS NOT NULL THEN 1 ELSE 0 END) as con_filepath,
    SUM(CASE WHEN processedImageUrl IS NOT NULL THEN 1 ELSE 0 END) as con_processedImageUrl,
    SUM(CASE WHEN filepath IS NOT NULL AND processedImageUrl IS NULL THEN 1 ELSE 0 END) as solo_filepath
FROM image.Analisis_Imagen;
GO

-- IMPORTANTE: Antes de eliminar, copiar datos de filepath a processedImageUrl si es necesario
-- Solo ejecutar si hay datos únicos en filepath que no estén en processedImageUrl
-- UPDATE image.Analisis_Imagen
-- SET processedImageUrl = filepath
-- WHERE processedImageUrl IS NULL AND filepath IS NOT NULL;
-- GO

-- Eliminar columna filepath (COMENTADO POR SEGURIDAD - descomentar cuando esté seguro)
-- ALTER TABLE image.Analisis_Imagen
-- DROP COLUMN filepath;
-- GO

PRINT '=== Script completado ===';
PRINT 'NOTA: La eliminación de la columna filepath está comentada por seguridad.';
PRINT 'Descomentar y ejecutar solo después de verificar que no hay datos únicos en filepath.';
GO

