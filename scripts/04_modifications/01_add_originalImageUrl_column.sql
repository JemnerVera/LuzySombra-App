-- =====================================================
-- SCRIPT: Agregar columna originalImageUrl a image.Analisis_Imagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: image
-- Propósito: Guardar la imagen original antes del procesamiento ML
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas:
--      - image.Analisis_Imagen (agrega columna originalImageUrl)
--   ✅ Extended Properties:
--      - Documentación de columna originalImageUrl
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.Analisis_Imagen (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de ejecutar create_table_analisis_imagen.sql
-- 
-- USADO POR:
--   - Backend: src/app/api/procesar-imagen/route.ts (guarda imagen original comprimida)
--   - Frontend: src/components/EvaluacionDetallePlanta.tsx (muestra imagen original)
-- 
-- NOTA: Esta columna almacena thumbnail comprimido (400x300, calidad 0.5, ~50-100KB)
-- para minimizar impacto en BD mientras permite visualizar imagen original.
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Agregar columna originalImageUrl si no existe
IF NOT EXISTS (
    SELECT * 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'image.Analisis_Imagen') 
    AND name = 'originalImageUrl'
)
BEGIN
    ALTER TABLE image.Analisis_Imagen
    ADD originalImageUrl NVARCHAR(MAX) NULL;
    
    -- Agregar extended property para documentación
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Imagen original en Base64 (antes del procesamiento con Machine Learning). Thumbnail altamente comprimido (400x300, calidad 0.5, ~50-100KB) para minimizar impacto en BD. La imagen procesada (con colores ML) se guarda en processedImageUrl.', 
        @level0type = N'SCHEMA', @level0name = N'image',
        @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
        @level2type = N'COLUMN', @level2name = N'originalImageUrl';
    
    PRINT '[OK] Columna originalImageUrl agregada a image.Analisis_Imagen';
END
ELSE
BEGIN
    PRINT '[INFO] Columna originalImageUrl ya existe en image.Analisis_Imagen';
END
GO

-- Verificar que la columna fue agregada
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'image' 
  AND TABLE_NAME = 'Analisis_Imagen'
  AND COLUMN_NAME = 'originalImageUrl';
GO

PRINT '=== Script completado ===';
GO
