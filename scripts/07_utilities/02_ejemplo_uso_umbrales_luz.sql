-- =====================================================
-- SCRIPT: Ejemplos de Uso de Umbrales de Luz
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Tipo: Utilidad / Ejemplos
-- Propósito: Mostrar cómo consultar y usar la tabla image.UmbralLuz
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Funciones:
--      - image.fn_ObtenerUmbralLuz (función escalar para clasificar porcentajes)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.UmbralLuz (tabla debe existir)
--   ⚠️  Requiere: image.Analisis_Imagen (tabla debe existir)
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: GROWER.STAGE (tabla existente)
--   ⚠️  Requiere: GROWER.FARMS (tabla existente)
--   ⚠️  Requiere: GROWER.PLANTATION (tabla existente)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear image.UmbralLuz y image.Analisis_Imagen
-- 
-- CONTENIDO:
--   - Ejemplos de consultas de umbrales
--   - Clasificación de evaluaciones
--   - Estadísticas de clasificación
--   - Función escalar para obtener umbral
--   - Ejemplos integrados con lotes
-- 
-- NOTA: Este es un script de EJEMPLO/UTILIDAD, no crea objetos de producción
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- 1. Consultar todos los umbrales activos
-- =====================================================
PRINT '=== 1. Umbrales activos (todas las variedades) ===';
SELECT 
    umbralID,
    tipo,
    minPorcentajeLuz AS MinLuz,
    maxPorcentajeLuz AS MaxLuz,
    CASE WHEN variedadID IS NULL THEN 'Todas' ELSE CAST(variedadID AS VARCHAR) END AS Variedad,
    descripcion,
    colorHex AS Color,
    orden
FROM image.UmbralLuz
WHERE activo = 1 AND statusID = 1
ORDER BY orden;
GO

-- =====================================================
-- 2. Clasificar una evaluación específica por % de luz
-- Ejemplo: 23.5% de luz
-- =====================================================
PRINT '';
PRINT '=== 2. Clasificar evaluación (ejemplo: 23.5% luz) ===';
DECLARE @PorcentajeLuz DECIMAL(5,2) = 23.5;

SELECT 
    @PorcentajeLuz AS PorcentajeLuz,
    u.tipo,
    u.descripcion,
    u.colorHex AS Color,
    u.minPorcentajeLuz AS MinLuz,
    u.maxPorcentajeLuz AS MaxLuz
FROM image.UmbralLuz u
WHERE u.activo = 1 
    AND u.statusID = 1
    AND (u.variedadID IS NULL) -- Por ahora todas las variedades
    AND @PorcentajeLuz >= u.minPorcentajeLuz 
    AND @PorcentajeLuz <= u.maxPorcentajeLuz;
GO

-- =====================================================
-- 3. Clasificar todas las evaluaciones de image.Analisis_Imagen
-- =====================================================
PRINT '';
PRINT '=== 3. Clasificar todas las evaluaciones ===';
SELECT TOP 20
    ai.analisisID,
    ai.lotID,
    ai.porcentajeLuz,
    ai.porcentajeSombra,
    u.tipo AS TipoUmbral,
    u.descripcion,
    u.colorHex AS Color,
    u.minPorcentajeLuz,
    u.maxPorcentajeLuz
FROM image.Analisis_Imagen ai WITH (NOLOCK)
INNER JOIN image.UmbralLuz u ON (
    ai.porcentajeLuz >= u.minPorcentajeLuz 
    AND ai.porcentajeLuz <= u.maxPorcentajeLuz
    AND (u.variedadID IS NULL) -- Por ahora todas las variedades
    AND u.activo = 1 
    AND u.statusID = 1
)
WHERE ai.statusID = 1
ORDER BY ai.fechaCreacion DESC;
GO

-- =====================================================
-- 4. Estadísticas de clasificación por tipo de umbral
-- =====================================================
PRINT '';
PRINT '=== 4. Estadísticas de clasificación ===';
SELECT 
    u.tipo AS TipoUmbral,
    u.descripcion,
    COUNT(ai.analisisID) AS TotalEvaluaciones,
    AVG(ai.porcentajeLuz) AS PromedioLuz,
    MIN(ai.porcentajeLuz) AS MinLuz,
    MAX(ai.porcentajeLuz) AS MaxLuz,
    u.colorHex AS Color
FROM image.Analisis_Imagen ai WITH (NOLOCK)
INNER JOIN image.UmbralLuz u ON (
    ai.porcentajeLuz >= u.minPorcentajeLuz 
    AND ai.porcentajeLuz <= u.maxPorcentajeLuz
    AND (u.variedadID IS NULL) -- Por ahora todas las variedades
    AND u.activo = 1 
    AND u.statusID = 1
)
WHERE ai.statusID = 1
GROUP BY u.tipo, u.descripcion, u.colorHex
ORDER BY 
    CASE u.tipo
        WHEN 'CriticoRojo' THEN 1
        WHEN 'CriticoAmarillo' THEN 2
        WHEN 'Normal' THEN 3
    END;
GO

-- =====================================================
-- 5. Función para obtener el umbral de un porcentaje
-- (Útil para usar en queries más complejos)
-- =====================================================
PRINT '';
PRINT '=== 5. Función escalar para clasificar ===';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.fn_ObtenerUmbralLuz') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION image.fn_ObtenerUmbralLuz;
GO

CREATE FUNCTION image.fn_ObtenerUmbralLuz(
    @PorcentajeLuz DECIMAL(5,2),
    @VariedadID INT = NULL
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Tipo VARCHAR(20);
    
    SELECT TOP 1 @Tipo = tipo
    FROM image.UmbralLuz
    WHERE activo = 1 
        AND statusID = 1
        AND (variedadID = @VariedadID OR variedadID IS NULL)
        AND @PorcentajeLuz >= minPorcentajeLuz 
        AND @PorcentajeLuz <= maxPorcentajeLuz
    ORDER BY 
        CASE tipo
            WHEN 'CriticoRojo' THEN 1
            WHEN 'CriticoAmarillo' THEN 2
            WHEN 'Normal' THEN 3
        END,
        orden;
    
    RETURN ISNULL(@Tipo, 'Desconocido');
END;
GO

PRINT '[OK] Función image.fn_ObtenerUmbralLuz creada';
GO

-- =====================================================
-- 6. Ejemplo de uso de la función
-- =====================================================
PRINT '';
PRINT '=== 6. Ejemplo de uso de la función ===';
SELECT TOP 10
    analisisID,
    porcentajeLuz,
    porcentajeSombra,
    image.fn_ObtenerUmbralLuz(porcentajeLuz, NULL) AS TipoUmbral
FROM image.Analisis_Imagen WITH (NOLOCK)
WHERE statusID = 1
ORDER BY fechaCreacion DESC;
GO

-- =====================================================
-- 7. Query completo: Lotes con clasificación de umbrales
-- =====================================================
PRINT '';
PRINT '=== 7. Lotes con clasificación de umbrales (ejemplo integrado) ===';
SELECT TOP 10
    l.lotID,
    l.name AS Lote,
    s.stage AS Sector,
    f.Description AS Fundo,
    v.name AS Variedad,
    COUNT(ai.analisisID) AS TotalEvaluaciones,
    AVG(ai.porcentajeLuz) AS PromedioLuz,
    image.fn_ObtenerUmbralLuz(AVG(ai.porcentajeLuz), v.varietyID) AS TipoUmbralPromedio
FROM GROWER.LOT l WITH (NOLOCK)
INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
INNER JOIN GROWER.PLANTATION p WITH (NOLOCK) ON l.lotID = p.lotID
INNER JOIN GROWER.VARIETY v WITH (NOLOCK) ON p.varietyID = v.varietyID
LEFT JOIN image.Analisis_Imagen ai WITH (NOLOCK) ON l.lotID = ai.lotID AND ai.statusID = 1
WHERE l.statusID = 1
    AND s.statusID = 1
    AND f.statusID = 1
    AND ai.analisisID IS NOT NULL
GROUP BY l.lotID, l.name, s.stage, f.Description, v.name, v.varietyID
ORDER BY l.name;
GO

PRINT '';
PRINT '=== Ejemplos completados ===';
GO

