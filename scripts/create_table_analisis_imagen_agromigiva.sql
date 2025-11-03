-- =====================================================
-- SCRIPT: Crear Tabla IMAGE.ANALISIS_IMAGEN
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Schema: IMAGE
-- Propósito: Almacenar resultados de análisis de imágenes luz/sombra
-- =====================================================
-- IMPORTANTE: Ejecutar con usuario con permisos de CREATE TABLE
-- Usuario recomendado: ucown_powerbi_desa
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- 1. Crear Schema IMAGE (si no existe)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'IMAGE')
BEGIN
    EXEC('CREATE SCHEMA IMAGE');
    PRINT '[OK] Schema IMAGE creado';
END
ELSE
BEGIN
    PRINT '[INFO] Schema IMAGE ya existe';
END
GO

-- =====================================================
-- 2. Crear Tabla IMAGE.ANALISIS_IMAGEN
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'IMAGE.ANALISIS_IMAGEN') AND type in (N'U'))
BEGIN
    CREATE TABLE IMAGE.ANALISIS_IMAGEN (
        -- Clave primaria
        analisisID INT IDENTITY(1,1) PRIMARY KEY,
        
        -- Foreign Key a GROWER.LOT (lotID INT)
        lotID INT NOT NULL,
        
        -- Ubicación en campo
        hilera NVARCHAR(50) NULL,
        planta NVARCHAR(50) NULL,
        
        -- Datos de la imagen
        filename NVARCHAR(500) NOT NULL,
        filepath NVARCHAR(MAX) NULL,  -- Base64 puede ser muy largo
        fecha_captura DATETIME NULL,
        
        -- Resultados del análisis
        porcentaje_luz DECIMAL(5,2) NOT NULL,
        porcentaje_sombra DECIMAL(5,2) NOT NULL,
        
        -- Geolocalización
        latitud DECIMAL(10,8) NULL,
        longitud DECIMAL(11,8) NULL,
        
        -- Metadatos
        processed_image_url NVARCHAR(MAX) NULL,  -- Base64 o URL
        modelo_version NVARCHAR(50) NULL DEFAULT 'heuristic_v1',
        
        -- Auditoría (según estándares AgroMigiva)
        statusID INT NOT NULL DEFAULT 1,
        userCreatedID INT NOT NULL DEFAULT 1,
        dateCreated DATETIME NOT NULL DEFAULT GETDATE(),
        userModifiedID INT NULL,
        dateModified DATETIME NULL,
        
        -- Foreign Key Constraint
        CONSTRAINT FK_ANALISIS_IMAGEN_LOT 
            FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID)
    );
    
    -- Índices para optimizar consultas
    CREATE NONCLUSTERED INDEX IX_ANALISIS_IMAGEN_FECHA 
        ON IMAGE.ANALISIS_IMAGEN(dateCreated DESC);
    
    CREATE NONCLUSTERED INDEX IX_ANALISIS_IMAGEN_LOT 
        ON IMAGE.ANALISIS_IMAGEN(lotID, dateCreated DESC);
    
    CREATE NONCLUSTERED INDEX IX_ANALISIS_IMAGEN_UBICACION 
        ON IMAGE.ANALISIS_IMAGEN(lotID, hilera, planta);
    
    PRINT '[OK] Tabla IMAGE.ANALISIS_IMAGEN creada con índices';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla IMAGE.ANALISIS_IMAGEN ya existe';
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
     WHERE TABLE_SCHEMA = 'IMAGE' AND TABLE_NAME = 'ANALISIS_IMAGEN') AS COLUMN_COUNT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'IMAGE' 
  AND TABLE_NAME = 'ANALISIS_IMAGEN';

PRINT '=== Índices creados ===';
SELECT 
    i.name AS INDEX_NAME,
    i.type_desc AS INDEX_TYPE,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS COLUMNS
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('IMAGE.ANALISIS_IMAGEN')
  AND i.type > 0  -- Excluir índice clustered (PK)
GROUP BY i.name, i.type_desc
ORDER BY i.name;

GO

PRINT '[✅] Script completado exitosamente';
GO

