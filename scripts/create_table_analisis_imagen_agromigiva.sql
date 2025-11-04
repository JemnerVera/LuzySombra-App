-- =====================================================
-- SCRIPT: Crear Tabla image.Analisis_Imagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Schema: image
-- Propósito: Almacenar resultados de análisis de imágenes luz/sombra
-- =====================================================
-- IMPORTANTE: Ejecutar con usuario con permisos de CREATE TABLE
-- Usuario recomendado: ucown_powerbi_desa
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- 1. Crear Schema image (si no existe)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'image')
BEGIN
    EXEC('CREATE SCHEMA image');
    PRINT '[OK] Schema image creado';
END
ELSE
BEGIN
    PRINT '[INFO] Schema image ya existe';
END
GO

-- =====================================================
-- 2. Crear Tabla image.Analisis_Imagen
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.Analisis_Imagen') AND type in (N'U'))
BEGIN
    CREATE TABLE image.Analisis_Imagen (
        -- Clave primaria
        analisisID INT IDENTITY(1,1) NOT NULL,
        
        -- Foreign Key a GROWER.LOT (lotID INT)
        lotID INT NOT NULL,
        
        -- Ubicación en campo
        hilera NVARCHAR(50) NULL,
        planta NVARCHAR(50) NULL,
        
        -- Datos de la imagen
        filename NVARCHAR(500) NOT NULL,
        fechaCaptura DATETIME NULL,
        
        -- Resultados del análisis
        porcentajeLuz DECIMAL(5,2) NOT NULL,
        porcentajeSombra DECIMAL(5,2) NOT NULL,
        
        -- Geolocalización
        latitud DECIMAL(10,8) NULL,
        longitud DECIMAL(11,8) NULL,
        
        -- Metadatos
        processedImageUrl NVARCHAR(MAX) NULL,  -- Thumbnail optimizado en Base64 (JPEG, ~100-200KB)
        modeloVersion NVARCHAR(50) NULL DEFAULT 'heuristic_v1',
        
        -- Auditoría (según estándares AgroMigiva - LowerCamelCase)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NOT NULL DEFAULT 1,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Constraints con nomenclatura estándar
        CONSTRAINT PK_Analisis_Imagen PRIMARY KEY (analisisID),
        CONSTRAINT FK_Analisis_Imagen_LOT_01 
            FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT UQ_Analisis_Imagen_FILENAME_LOT_01 
            UNIQUE (filename, lotID)
    );
    
    -- Índices con nomenclatura estándar IDX_
    CREATE NONCLUSTERED INDEX IDX_Analisis_Imagen_FECHA_01 
        ON image.Analisis_Imagen(fechaCreacion DESC);
    
    CREATE NONCLUSTERED INDEX IDX_Analisis_Imagen_LOT_01 
        ON image.Analisis_Imagen(lotID, fechaCreacion DESC);
    
    CREATE NONCLUSTERED INDEX IDX_Analisis_Imagen_UBICACION_01 
        ON image.Analisis_Imagen(lotID, hilera, planta);
    
    PRINT '[OK] Tabla image.Analisis_Imagen creada con índices';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla image.Analisis_Imagen ya existe';
END
GO

-- =====================================================
-- 3. Verificar creación
-- =====================================================
PRINT '=== Verificación de tabla creada ===';
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'image' AND TABLE_NAME = 'Analisis_Imagen') AS COLUMN_COUNT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'image' 
  AND TABLE_NAME = 'Analisis_Imagen';

PRINT '=== Índices creados ===';
SELECT 
    i.name AS INDEX_NAME,
    i.type_desc AS INDEX_TYPE,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS COLUMNS
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('image.Analisis_Imagen')
  AND i.type > 0  -- Excluir índice clustered (PK)
GROUP BY i.name, i.type_desc
ORDER BY i.name;

GO

-- =====================================================
-- 4. Agregar comentarios extendidos (Documentación)
-- =====================================================
-- Tabla
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Almacena resultados de análisis de imágenes para clasificación de luz/sombra en campos agrícolas', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen';

-- Columnas principales
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único del análisis de imagen', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'analisisID';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Foreign Key al lote donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'lotID';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre del archivo de la imagen procesada', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'filename';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora de captura de la imagen (desde EXIF)', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'fechaCaptura';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Porcentaje de área clasificada como luz (0-100)', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'porcentajeLuz';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Porcentaje de área clasificada como sombra (0-100)', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'porcentajeSombra';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Latitud GPS de la ubicación donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'latitud';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Longitud GPS de la ubicación donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'longitud';

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Versión del modelo de Machine Learning usado para el análisis', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'Analisis_Imagen',
    @level2type = N'COLUMN', @level2name = N'modeloVersion';

PRINT '[OK] Comentarios extendidos agregados';

GO

PRINT '[✅] Script completado exitosamente';
GO

