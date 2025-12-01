-- =====================================================
-- SCRIPT: Crear tabla de Umbrales de Luz (%)
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Almacenar umbrales de clasificación de % de luz
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.UmbralLuz
--   ✅ Índices:
--      - IDX_UmbralLuz_VariedadID (NONCLUSTERED, filtered)
--      - IDX_UmbralLuz_Tipo (NONCLUSTERED)
--      - IDX_UmbralLuz_Rango (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_UmbralLuz (PRIMARY KEY)
--      - FK_UmbralLuz_Variety (FOREIGN KEY → GROWER.VARIETY)
--      - FK_UmbralLuz_UsuarioCrea (FOREIGN KEY → MAST.USERS)
--      - FK_UmbralLuz_UsuarioActualiza (FOREIGN KEY → MAST.USERS)
--      - CK_UmbralLuz_Tipo (CHECK)
--      - CK_UmbralLuz_Porcentaje (CHECK)
--   ✅ Extended Properties:
--      - Documentación de tabla y columnas principales
--   ✅ Datos Iniciales:
--      - 5 umbrales insertados (CriticoRojo, CriticoAmarillo, Normal)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema image (debe existir o se crea)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   2 de 5 - Después de crear evalImagen.Analisis_Imagen
-- 
-- USADO POR:
--   - evalImagen.sp_CalcularLoteEvaluacion (para clasificar umbrales)
--   - evalImagen.LoteEvaluacion (FK a umbralIDActual)
--   - evalImagen.Alerta (FK a umbralID)
--   - Backend: lógica de generación de alertas
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Crear schema si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'evalImagen')
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
-- Crear tabla evalImagen.UmbralLuz
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UmbralLuz' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.UmbralLuz (
        umbralID INT IDENTITY(1,1) NOT NULL,
        tipo VARCHAR(20) NOT NULL, -- 'CriticoRojo', 'CriticoAmarillo', 'Normal'
        minPorcentajeLuz DECIMAL(5,2) NOT NULL, -- Porcentaje mínimo (inclusive)
        maxPorcentajeLuz DECIMAL(5,2) NOT NULL, -- Porcentaje máximo (inclusive)
        variedadID INT NULL, -- NULL = aplica a todas las variedades, INT = variedad específica
        descripcion NVARCHAR(200) NULL,
        colorHex VARCHAR(7) NULL, -- Color para UI (ej: #FF0000 para rojo)
        orden INT NOT NULL DEFAULT 0, -- Orden de prioridad para consultas
        activo BIT NOT NULL DEFAULT 1,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioCreaID INT NULL,
        fechaActualizacion DATETIME NULL,
        usuarioActualizaID INT NULL,
        statusID INT NOT NULL DEFAULT 1,
        
        CONSTRAINT PK_UmbralLuz PRIMARY KEY CLUSTERED (umbralID),
        CONSTRAINT FK_UmbralLuz_Variety FOREIGN KEY (variedadID) 
            REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_UmbralLuz_UsuarioCrea FOREIGN KEY (usuarioCreaID) 
            REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_UmbralLuz_UsuarioActualiza FOREIGN KEY (usuarioActualizaID) 
            REFERENCES MAST.USERS(userID),
        CONSTRAINT CK_UmbralLuz_Tipo CHECK (tipo IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
        CONSTRAINT CK_UmbralLuz_Porcentaje CHECK (minPorcentajeLuz >= 0 AND maxPorcentajeLuz <= 100 AND minPorcentajeLuz <= maxPorcentajeLuz)
    );
    
    PRINT '[OK] Tabla evalImagen.UmbralLuz creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.UmbralLuz ya existe';
END
GO

-- =====================================================
-- Crear índices para optimizar consultas
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_UmbralLuz_VariedadID' AND object_id = OBJECT_ID('evalImagen.UmbralLuz'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_UmbralLuz_VariedadID 
    ON evalImagen.UmbralLuz(variedadID)
    WHERE activo = 1 AND statusID = 1;
    PRINT '[OK] Índice IDX_UmbralLuz_VariedadID creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_UmbralLuz_Tipo' AND object_id = OBJECT_ID('evalImagen.UmbralLuz'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_UmbralLuz_Tipo 
    ON evalImagen.UmbralLuz(tipo, activo, statusID);
    PRINT '[OK] Índice IDX_UmbralLuz_Tipo creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_UmbralLuz_Rango' AND object_id = OBJECT_ID('evalImagen.UmbralLuz'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_UmbralLuz_Rango 
    ON evalImagen.UmbralLuz(minPorcentajeLuz, maxPorcentajeLuz)
    WHERE activo = 1 AND statusID = 1;
    PRINT '[OK] Índice IDX_UmbralLuz_Rango creado';
END
GO

-- =====================================================
-- Agregar Extended Properties para documentación
-- =====================================================

-- Tabla
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.UmbralLuz') 
    AND minor_id = 0 
    AND name = 'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Almacena los umbrales de clasificación de porcentaje de luz para evaluaciones. Permite definir múltiples rangos por tipo (Crítico Rojo, Crítico Amarillo, Normal) y opcionalmente por variedad.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'UmbralLuz';
    PRINT '[OK] Extended property agregado a tabla';
END
GO

-- Columnas principales
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del umbral', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'umbralID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de umbral: CriticoRojo, CriticoAmarillo, Normal', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'tipo';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje mínimo de luz (inclusive). Valor entre 0 y 100.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'minPorcentajeLuz';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje máximo de luz (inclusive). Valor entre 0 y 100.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'maxPorcentajeLuz';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ID de variedad específica. NULL = aplica a todas las variedades.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'variedadID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del umbral (ej: "Muy bajo - Crítico")', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'descripcion';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Color hexadecimal para UI (ej: #FF0000 para rojo, #FFA500 para amarillo, #00FF00 para verde)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'UmbralLuz', @level2type = N'COLUMN', @level2name = N'colorHex';
GO

-- =====================================================
-- Insertar datos iniciales (umbrales para todas las variedades)
-- =====================================================
PRINT '';
PRINT '=== Insertando umbrales iniciales ===';

-- Verificar si ya existen datos
IF NOT EXISTS (SELECT * FROM evalImagen.UmbralLuz)
BEGIN
    -- Crítico Rojo: X < 10%
    INSERT INTO evalImagen.UmbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoRojo', 0.00, 9.99, NULL, 'Muy bajo - Crítico', '#FF0000', 1);
    
    -- Crítico Rojo: X > 35%
    INSERT INTO evalImagen.UmbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoRojo', 35.01, 100.00, NULL, 'Muy alto - Crítico', '#FF0000', 2);
    
    -- Crítico Amarillo: 10% <= X < 15%
    INSERT INTO evalImagen.UmbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoAmarillo', 10.00, 14.99, NULL, 'Bajo - Advertencia', '#FFA500', 3);
    
    -- Crítico Amarillo: 25% < X <= 35%
    INSERT INTO evalImagen.UmbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoAmarillo', 25.01, 35.00, NULL, 'Alto - Advertencia', '#FFA500', 4);
    
    -- Normal: 15% <= X <= 25%
    INSERT INTO evalImagen.UmbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('Normal', 15.00, 25.00, NULL, 'Rango óptimo - Normal', '#00FF00', 5);
    
    PRINT '[OK] Umbrales iniciales insertados (5 registros - para todas las variedades)';
END
ELSE
BEGIN
    PRINT '[INFO] Ya existen umbrales en la tabla. No se insertaron datos iniciales.';
END
GO

-- =====================================================
-- Insertar umbrales para cada variedad específica
-- =====================================================
PRINT '';
PRINT '=== Insertando umbrales por variedad ===';

-- Lista de variedades
DECLARE @Variedades TABLE (variedadID INT);
INSERT INTO @Variedades (variedadID) VALUES
    (1), (2), (3), (4), (5), (6), (7), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20), (21),
    (24), (25), (27), (28), (29), (30), (31), (32), (33), (35), (36), (37), (38), (39), (40), (41), (42), (43), (44),
    (46), (47), (48), (49), (53), (54), (55), (56), (57), (58), (59), (60), (61), (62), (63), (64);

-- Plantilla de umbrales (mismo para todas las variedades)
DECLARE @Umbrales TABLE (
    tipo VARCHAR(20),
    minPorcentajeLuz DECIMAL(5,2),
    maxPorcentajeLuz DECIMAL(5,2),
    descripcion NVARCHAR(200),
    colorHex VARCHAR(7),
    orden INT
);

INSERT INTO @Umbrales (tipo, minPorcentajeLuz, maxPorcentajeLuz, descripcion, colorHex, orden) VALUES
    ('CriticoRojo', 0.00, 9.99, 'Muy bajo - Crítico', '#FF0000', 1),
    ('CriticoRojo', 35.01, 100.00, 'Muy alto - Crítico', '#FF0000', 2),
    ('CriticoAmarillo', 10.00, 14.99, 'Bajo - Advertencia', '#FFA500', 3),
    ('CriticoAmarillo', 25.01, 35.00, 'Alto - Advertencia', '#FFA500', 4),
    ('Normal', 15.00, 25.00, 'Rango óptimo - Normal', '#00FF00', 5);

-- Insertar umbrales para cada variedad (solo si no existen)
INSERT INTO evalImagen.UmbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
SELECT 
    u.tipo,
    u.minPorcentajeLuz,
    u.maxPorcentajeLuz,
    v.variedadID,
    u.descripcion,
    u.colorHex,
    u.orden
FROM @Variedades v
CROSS JOIN @Umbrales u
WHERE NOT EXISTS (
    SELECT 1 
    FROM evalImagen.UmbralLuz ul 
    WHERE ul.variedadID = v.variedadID 
      AND ul.tipo = u.tipo 
      AND ul.minPorcentajeLuz = u.minPorcentajeLuz 
      AND ul.maxPorcentajeLuz = u.maxPorcentajeLuz
);

DECLARE @Contador INT = @@ROWCOUNT;
DECLARE @VariedadesInsertadas INT = @Contador / 5;

IF @Contador > 0
BEGIN
    PRINT '[OK] Umbrales insertados para ' + CAST(@VariedadesInsertadas AS VARCHAR) + ' variedades (' + CAST(@Contador AS VARCHAR) + ' registros)';
END
ELSE
BEGIN
    PRINT '[INFO] Los umbrales para variedades ya existen. No se insertaron datos adicionales.';
END
GO

-- =====================================================
-- Verificar datos insertados
-- =====================================================
PRINT '';
PRINT '=== Verificando datos ===';
SELECT 
    umbralID,
    tipo,
    minPorcentajeLuz AS MinLuz,
    maxPorcentajeLuz AS MaxLuz,
    CASE WHEN variedadID IS NULL THEN 'Todas' ELSE CAST(variedadID AS VARCHAR) END AS Variedad,
    descripcion,
    colorHex AS Color,
    orden,
    activo,
    statusID
FROM evalImagen.UmbralLuz
ORDER BY orden, tipo;
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT 'Tabla evalImagen.UmbralLuz creada y poblada con umbrales.';
PRINT '';
PRINT 'Umbrales definidos:';
PRINT '  - Crítico Rojo: X < 10% y X > 35%';
PRINT '  - Crítico Amarillo: 10% <= X < 15% y 25% < X <= 35%';
PRINT '  - Normal: 15% <= X <= 25%';
PRINT '';
PRINT 'Total de registros:';
PRINT '  - 5 umbrales generales (variedadID = NULL)';
PRINT '  - 5 umbrales por cada variedad específica (56 variedades)';
PRINT '  - Total esperado: 5 + (56 * 5) = 285 registros';
GO

