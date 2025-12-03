-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.analisisImagen
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Schema: evalImagen
-- Propósito: Almacenar resultados de análisis de imágenes luz/sombra
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Schema:
--      - evalImagen (si no existe)
--   ✅ Tablas:
--      - evalImagen.analisisImagen
--   ✅ Índices:
--      - IDX_analisisImagen_fechaCreacion_001 (NONCLUSTERED)
--      - IDX_analisisImagen_lotID_fechaCreacion_002 (NONCLUSTERED)
--      - IDX_analisisImagen_lotID_hilera_planta_003 (NONCLUSTERED)
--   ✅ Constraints:
--      - PK_analisisImagen (PRIMARY KEY)
--      - FK_analisisImagen_lot_01 (FOREIGN KEY → GROWER.LOT)
--      - FK_analisisImagen_usuarioCrea_02 (FOREIGN KEY → MAST.USERS)
--      - FK_analisisImagen_usuarioModifica_03 (FOREIGN KEY → MAST.USERS)
--      - UQ_analisisImagen_filename_lotID_01 (UNIQUE)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente) - para usuarioCreaID
-- 
-- ORDEN DE EJECUCIÓN:
--   1. Este script debe ejecutarse PRIMERO (crea schema evalImagen)
--   2. Luego pueden ejecutarse otros scripts del schema evalImagen
-- 
-- USADO POR:
--   - Backend: src/services/sqlServerService.ts (saveProcessingResult)
--   - API: src/app/api/procesar-imagen/route.ts
--   - Query consolidada: getConsolidatedTable (indirectamente vía evalImagen.loteEvaluacion)
-- 
-- IMPORTANTE: Ejecutar con usuario con permisos de CREATE TABLE
-- Usuario: ucser_luzsombra_desa (DESA) / ucser_luzSombra (PROD)
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- 1. Crear Schema evalImagen (si no existe)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'evalImagen')
BEGIN
    EXEC('CREATE SCHEMA evalImagen');
    PRINT '[OK] Schema evalImagen creado';
END
ELSE
BEGIN
    PRINT '[INFO] Schema evalImagen ya existe';
END
GO

-- =====================================================
-- 2. Crear Tabla evalImagen.analisisImagen
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.analisisImagen') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.analisisImagen (
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
        processedImageUrl NVARCHAR(MAX) NULL,  -- Thumbnail optimizado en Base64 (JPEG, ~100-200KB) - Imagen procesada con ML
        originalImageUrl NVARCHAR(MAX) NULL,   -- Imagen original en Base64 (antes del procesamiento ML). Thumbnail comprimido (400x300, calidad 0.5, ~50-100KB)
        modeloVersion NVARCHAR(50) NULL DEFAULT 'heuristic_v1',
        
        -- Auditoría (según estándares AgroMigiva - LowerCamelCase)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NOT NULL DEFAULT 1,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        
        -- Constraints con nomenclatura estándar Migiva (con correlativos)
        CONSTRAINT PK_analisisImagen PRIMARY KEY (analisisID),
        CONSTRAINT FK_analisisImagen_lot_01 
            FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT FK_analisisImagen_usuarioCrea_02 
            FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_analisisImagen_usuarioModifica_03 
            FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT UQ_analisisImagen_filename_lotID_01 
            UNIQUE (filename, lotID)
    );
    
    -- Índices con nomenclatura estándar IDX_ + correlativo
    CREATE NONCLUSTERED INDEX IDX_analisisImagen_fechaCreacion_001 
        ON evalImagen.analisisImagen(fechaCreacion DESC);
    
    CREATE NONCLUSTERED INDEX IDX_analisisImagen_lotID_fechaCreacion_002 
        ON evalImagen.analisisImagen(lotID, fechaCreacion DESC);
    
    CREATE NONCLUSTERED INDEX IDX_analisisImagen_lotID_hilera_planta_003 
        ON evalImagen.analisisImagen(lotID, hilera, planta);
    
    PRINT '[OK] Tabla evalImagen.analisisImagen creada con índices';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.analisisImagen ya existe';
END
GO

-- =====================================================
-- 3. Agregar comentarios extendidos (Documentación según estándar)
-- =====================================================
-- Tabla (MS_TablaDescription según estándar)
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.analisisImagen') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Almacena resultados de análisis de imágenes para clasificación de luz/sombra en campos agrícolas', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'analisisImagen';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

-- Columnas (MS_ColXDesc según estándar)
EXEC sp_addextendedproperty 
    @name = N'MS_Col1Desc', 
    @value = N'Identificador único del análisis de imagen', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'analisisID';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col2Desc', 
    @value = N'Foreign Key al lote donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'lotID';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col3Desc', 
    @value = N'Hilera donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'hilera';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col4Desc', 
    @value = N'Planta donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'planta';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col5Desc', 
    @value = N'Nombre del archivo de la imagen procesada', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'filename';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col6Desc', 
    @value = N'Fecha y hora de captura de la imagen (desde EXIF)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'fechaCaptura';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col7Desc', 
    @value = N'Porcentaje de área clasificada como luz (0-100)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'porcentajeLuz';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col8Desc', 
    @value = N'Porcentaje de área clasificada como sombra (0-100)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'porcentajeSombra';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col9Desc', 
    @value = N'Latitud GPS de la ubicación donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'latitud';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col10Desc', 
    @value = N'Longitud GPS de la ubicación donde se tomó la imagen', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'longitud';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col11Desc', 
    @value = N'Thumbnail optimizado en Base64 (JPEG, ~100-200KB) para minimizar impacto en BD. Imagen procesada con Machine Learning (colores ML aplicados).', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'processedImageUrl';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col12Desc', 
    @value = N'Imagen original en Base64 (antes del procesamiento con Machine Learning). Thumbnail altamente comprimido (400x300, calidad 0.5, ~50-100KB) para minimizar impacto en BD.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'originalImageUrl';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col13Desc', 
    @value = N'Versión del modelo de Machine Learning usado para el análisis', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'analisisImagen',
    @level2type = N'COLUMN', @level2name = N'modeloVersion';
GO

PRINT '[OK] Comentarios extendidos agregados';
GO

PRINT '[✅] Script completado exitosamente';
PRINT 'Tabla evalImagen.analisisImagen creada según estándares AgroMigiva';
GO
