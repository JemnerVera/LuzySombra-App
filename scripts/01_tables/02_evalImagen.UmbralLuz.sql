-- =====================================================
-- SCRIPT: Crear tabla de Umbrales de Luz (%)
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Almacenar umbrales de clasificación de % de luz
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.umbralLuz
--   ✅ Índices:
--      - IDX_umbralLuz_variedadID_001 (NONCLUSTERED, filtered)
--      - IDX_umbralLuz_tipo_activo_statusID_002 (NONCLUSTERED)
--      - IDX_umbralLuz_minPorcentajeLuz_maxPorcentajeLuz_003 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_umbralLuz (PRIMARY KEY)
--      - FK_umbralLuz_variety_01 (FOREIGN KEY → GROWER.VARIETY)
--      - FK_umbralLuz_usuarioCrea_02 (FOREIGN KEY → MAST.USERS)
--      - FK_umbralLuz_usuarioModifica_03 (FOREIGN KEY → MAST.USERS)
--      - CK_umbralLuz_tipoValido_01 (CHECK)
--      - CK_umbralLuz_porcentajeValido_02 (CHECK)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
--   ✅ Datos Iniciales:
--      - 5 umbrales insertados (CriticoRojo, CriticoAmarillo, Normal)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir o se crea)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   2 de 10 - Después de crear evalImagen.analisisImagen
-- 
-- USADO POR:
--   - evalImagen.usp_evalImagen_calcularLoteEvaluacion (para clasificar umbrales)
--   - evalImagen.loteEvaluacion (FK a umbralIDActual)
--   - evalImagen.alerta (FK a umbralID)
--   - Backend: lógica de generación de alertas
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

-- Crear schema si no existe
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
-- Crear tabla evalImagen.umbralLuz
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'umbralLuz' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.umbralLuz (
        umbralID INT IDENTITY(1,1) NOT NULL,
        tipo VARCHAR(20) NOT NULL, -- 'CriticoRojo', 'CriticoAmarillo', 'Normal'
        minPorcentajeLuz DECIMAL(5,2) NOT NULL, -- Porcentaje mínimo (inclusive)
        maxPorcentajeLuz DECIMAL(5,2) NOT NULL, -- Porcentaje máximo (inclusive)
        variedadID INT NULL, -- NULL = aplica a todas las variedades, INT = variedad específica
        descripcion NVARCHAR(200) NULL,
        colorHex VARCHAR(7) NULL, -- Color para UI (ej: #FF0000 para rojo)
        orden INT NOT NULL DEFAULT 0, -- Orden de prioridad para consultas
        activo BIT NOT NULL DEFAULT 1,
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NULL,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        
        CONSTRAINT PK_umbralLuz PRIMARY KEY CLUSTERED (umbralID),
        CONSTRAINT FK_umbralLuz_variety_01 FOREIGN KEY (variedadID) 
            REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_umbralLuz_usuarioCrea_02 FOREIGN KEY (usuarioCreaID) 
            REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_umbralLuz_usuarioModifica_03 FOREIGN KEY (usuarioModificaID) 
            REFERENCES MAST.USERS(userID),
        CONSTRAINT CK_umbralLuz_tipoValido_01 CHECK (tipo IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
        CONSTRAINT CK_umbralLuz_porcentajeValido_02 CHECK (minPorcentajeLuz >= 0 AND maxPorcentajeLuz <= 100 AND minPorcentajeLuz <= maxPorcentajeLuz)
    );
    
    PRINT '[OK] Tabla evalImagen.umbralLuz creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.umbralLuz ya existe';
END
GO

-- =====================================================
-- Crear índices para optimizar consultas (con correlativo)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_umbralLuz_variedadID_001' AND object_id = OBJECT_ID('evalImagen.umbralLuz'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_umbralLuz_variedadID_001 
    ON evalImagen.umbralLuz(variedadID)
    WHERE activo = 1 AND statusID = 1;
    PRINT '[OK] Índice IDX_umbralLuz_variedadID_001 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_umbralLuz_tipo_activo_statusID_002' AND object_id = OBJECT_ID('evalImagen.umbralLuz'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_umbralLuz_tipo_activo_statusID_002 
    ON evalImagen.umbralLuz(tipo, activo, statusID);
    PRINT '[OK] Índice IDX_umbralLuz_tipo_activo_statusID_002 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_umbralLuz_minPorcentajeLuz_maxPorcentajeLuz_003' AND object_id = OBJECT_ID('evalImagen.umbralLuz'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_umbralLuz_minPorcentajeLuz_maxPorcentajeLuz_003 
    ON evalImagen.umbralLuz(minPorcentajeLuz, maxPorcentajeLuz)
    WHERE activo = 1 AND statusID = 1;
    PRINT '[OK] Índice IDX_umbralLuz_minPorcentajeLuz_maxPorcentajeLuz_003 creado';
END
GO

-- =====================================================
-- Agregar Extended Properties para documentación (según estándar)
-- =====================================================

-- Tabla (MS_TablaDescription según estándar)
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.umbralLuz') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Almacena los umbrales de clasificación de porcentaje de luz para evaluaciones. Permite definir múltiples rangos por tipo (Crítico Rojo, Crítico Amarillo, Normal) y opcionalmente por variedad.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'umbralLuz';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

-- Columnas (MS_ColXDesc según estándar)
EXEC sp_addextendedproperty @name = N'MS_Col1Desc', @value = N'Identificador único del umbral', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'umbralID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col2Desc', @value = N'Tipo de umbral: CriticoRojo, CriticoAmarillo, Normal', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'tipo';
GO

EXEC sp_addextendedproperty @name = N'MS_Col3Desc', @value = N'Porcentaje mínimo de luz (inclusive). Valor entre 0 y 100.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'minPorcentajeLuz';
GO

EXEC sp_addextendedproperty @name = N'MS_Col4Desc', @value = N'Porcentaje máximo de luz (inclusive). Valor entre 0 y 100.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'maxPorcentajeLuz';
GO

EXEC sp_addextendedproperty @name = N'MS_Col5Desc', @value = N'ID de variedad específica. NULL = Umbral global aplicable a todas las variedades. Si tiene valor, el umbral es específico solo para esa variedad. Los umbrales específicos tienen prioridad sobre los globales.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'variedadID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col6Desc', @value = N'Descripción del umbral (ej: "Muy bajo - Crítico")', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'descripcion';
GO

EXEC sp_addextendedproperty @name = N'MS_Col7Desc', @value = N'Color hexadecimal para UI (ej: #FF0000 para rojo, #FFA500 para amarillo, #00FF00 para verde)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'umbralLuz', @level2type = N'COLUMN', @level2name = N'colorHex';
GO

-- =====================================================
-- Insertar datos iniciales (umbrales para todas las variedades)
-- =====================================================
PRINT '';
PRINT '=== Insertando umbrales iniciales ===';

-- Verificar si ya existen datos
IF NOT EXISTS (SELECT * FROM evalImagen.umbralLuz)
BEGIN
    -- Crítico Rojo: X < 10%
    INSERT INTO evalImagen.umbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoRojo', 0.00, 9.99, NULL, 'Muy bajo - Crítico', '#FF0000', 1);
    
    -- Crítico Rojo: X > 35%
    INSERT INTO evalImagen.umbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoRojo', 35.01, 100.00, NULL, 'Muy alto - Crítico', '#FF0000', 2);
    
    -- Crítico Amarillo: 10% <= X < 15%
    INSERT INTO evalImagen.umbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoAmarillo', 10.00, 14.99, NULL, 'Bajo - Advertencia', '#FFA500', 3);
    
    -- Crítico Amarillo: 25% < X <= 35%
    INSERT INTO evalImagen.umbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
    VALUES ('CriticoAmarillo', 25.01, 35.00, NULL, 'Alto - Advertencia', '#FFA500', 4);
    
    -- Normal: 15% <= X <= 25%
    INSERT INTO evalImagen.umbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
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
INSERT INTO evalImagen.umbralLuz (tipo, minPorcentajeLuz, maxPorcentajeLuz, variedadID, descripcion, colorHex, orden)
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
    FROM evalImagen.umbralLuz ul 
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
FROM evalImagen.umbralLuz
ORDER BY orden, tipo;
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT 'Tabla evalImagen.umbralLuz creada y poblada con umbrales.';
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
PRINT '';
PRINT '[✅] Script completado según estándares AgroMigiva';
GO
