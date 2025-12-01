-- =====================================================
-- SCRIPT: Crear tabla evalImagen.LoteEvaluacion
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Cache de estadísticas agregadas por lote para alertas
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.LoteEvaluacion
--   ✅ Índices:
--      - IDX_LoteEvaluacion_LotID (NONCLUSTERED, filtered)
--      - IDX_LoteEvaluacion_TipoUmbral (NONCLUSTERED, filtered)
--      - IDX_LoteEvaluacion_FechaActualizacion (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_LoteEvaluacion (PRIMARY KEY)
--      - FK_LoteEvaluacion_LOT (FOREIGN KEY → GROWER.LOT)
--      - FK_LoteEvaluacion_Variety (FOREIGN KEY → GROWER.VARIETY)
--      - FK_LoteEvaluacion_Umbral (FOREIGN KEY → evalImagen.UmbralLuz)
--      - FK_LoteEvaluacion_UsuarioCrea (FOREIGN KEY → MAST.USERS)
--      - FK_LoteEvaluacion_UsuarioModifica (FOREIGN KEY → MAST.USERS)
--      - UQ_LoteEvaluacion_LOT (UNIQUE - una fila por lote)
--      - CK_LoteEvaluacion_TipoUmbral (CHECK)
--      - CK_LoteEvaluacion_PorcentajeLuz (CHECK)
--      - CK_LoteEvaluacion_PorcentajeSombra (CHECK)
--   ✅ Extended Properties:
--      - Documentación de tabla y columnas principales
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: evalImagen.UmbralLuz (debe ejecutarse después)
-- 
-- ORDEN DE EJECUCIÓN:
--   3 de 5 - Después de crear evalImagen.UmbralLuz
-- 
-- USADO POR:
--   - getConsolidatedTable (query consolidada - fuente principal de estadísticas)
--   - evalImagen.Alerta (FK a loteEvaluacionID)
--   - evalImagen.sp_CalcularLoteEvaluacion (actualiza esta tabla)
--   - Backend: src/services/sqlServerService.ts (saveProcessingResult actualiza)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla evalImagen.LoteEvaluacion
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LoteEvaluacion' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.LoteEvaluacion (
        loteEvaluacionID INT IDENTITY(1,1) NOT NULL,
        lotID INT NOT NULL,
        variedadID INT NULL,
        
        -- Relaciones con jerarquía (para optimizar match con evalImagen.Contacto)
        fundoID CHAR(4) NULL,  -- Fundo del lote (GROWER.FARMS.farmID)
        sectorID INT NULL,     -- Sector del lote (GROWER.STAGE.stageID)
        
        -- Estadísticas agregadas
        porcentajeLuzPromedio DECIMAL(5,2) NOT NULL,
        porcentajeLuzMin DECIMAL(5,2) NULL,
        porcentajeLuzMax DECIMAL(5,2) NULL,
        porcentajeSombraPromedio DECIMAL(5,2) NOT NULL,
        porcentajeSombraMin DECIMAL(5,2) NULL,
        porcentajeSombraMax DECIMAL(5,2) NULL,
        
        -- Clasificación actual
        tipoUmbralActual VARCHAR(20) NULL, -- CriticoRojo, CriticoAmarillo, Normal
        umbralIDActual INT NULL,
        
        -- Fechas y conteos
        fechaUltimaEvaluacion DATETIME NULL,
        fechaPrimeraEvaluacion DATETIME NULL,
        totalEvaluaciones INT NOT NULL DEFAULT 0,
        periodoEvaluacionDias INT NOT NULL DEFAULT 30,
        
        -- Auditoría (según estándares AgroMigiva)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NULL,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        fechaUltimaActualizacion DATETIME NOT NULL DEFAULT GETDATE(), -- Campo específico para tracking de evaluaciones
        
        CONSTRAINT PK_LoteEvaluacion PRIMARY KEY CLUSTERED (loteEvaluacionID),
        CONSTRAINT FK_LoteEvaluacion_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT FK_LoteEvaluacion_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_LoteEvaluacion_Farm FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
        CONSTRAINT FK_LoteEvaluacion_Stage FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID),
        CONSTRAINT FK_LoteEvaluacion_Umbral FOREIGN KEY (umbralIDActual) REFERENCES evalImagen.UmbralLuz(umbralID),
        CONSTRAINT FK_LoteEvaluacion_UsuarioCrea FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_LoteEvaluacion_UsuarioModifica FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT UQ_LoteEvaluacion_LOT UNIQUE (lotID),
        CONSTRAINT CK_LoteEvaluacion_TipoUmbral CHECK (tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo', 'Normal') OR tipoUmbralActual IS NULL),
        CONSTRAINT CK_LoteEvaluacion_PorcentajeLuz CHECK (porcentajeLuzPromedio >= 0 AND porcentajeLuzPromedio <= 100),
        CONSTRAINT CK_LoteEvaluacion_PorcentajeSombra CHECK (porcentajeSombraPromedio >= 0 AND porcentajeSombraPromedio <= 100)
    );
    
    PRINT '[OK] Tabla evalImagen.LoteEvaluacion creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.LoteEvaluacion ya existe';
END
GO

-- =====================================================
-- Crear índices
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_LoteEvaluacion_LotID' AND object_id = OBJECT_ID('evalImagen.LoteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_LoteEvaluacion_LotID 
    ON evalImagen.LoteEvaluacion(lotID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_LoteEvaluacion_LotID creado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_LoteEvaluacion_LotID ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_LoteEvaluacion_TipoUmbral' AND object_id = OBJECT_ID('evalImagen.LoteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_LoteEvaluacion_TipoUmbral 
    ON evalImagen.LoteEvaluacion(tipoUmbralActual, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_LoteEvaluacion_TipoUmbral creado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_LoteEvaluacion_TipoUmbral ya existe';
END
GO

-- Índice para optimizar match con evalImagen.Contacto por fundoID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_LoteEvaluacion_FundoID' AND object_id = OBJECT_ID('evalImagen.LoteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_LoteEvaluacion_FundoID 
    ON evalImagen.LoteEvaluacion(fundoID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_LoteEvaluacion_FundoID creado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_LoteEvaluacion_FundoID ya existe';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_LoteEvaluacion_FechaActualizacion' AND object_id = OBJECT_ID('evalImagen.LoteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_LoteEvaluacion_FechaActualizacion 
    ON evalImagen.LoteEvaluacion(fechaUltimaActualizacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_LoteEvaluacion_FechaActualizacion creado';
END
ELSE
BEGIN
    PRINT '[INFO] Índice IDX_LoteEvaluacion_FechaActualizacion ya existe';
END
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.LoteEvaluacion') 
    AND minor_id = 0 
    AND name = 'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Cache de estadísticas agregadas por lote para evaluaciones de luz/sombra. Permite tracking de estado actual y generación eficiente de alertas.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'LoteEvaluacion';
    PRINT '[OK] Extended property agregado a tabla';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la evaluación de lote', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'loteEvaluacionID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign Key al lote evaluado', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'lotID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Variedad del cultivo (NULL si el lote tiene múltiples variedades o no está definida)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'variedadID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fundo del lote (GROWER.FARMS.farmID). Se almacena para optimizar el match con evalImagen.Contacto que filtra por fundoID.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'fundoID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sector del lote (GROWER.STAGE.stageID). Se almacena para optimizar el match con evalImagen.Contacto que filtra por sectorID.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'sectorID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje promedio de luz en el período evaluado', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'porcentajeLuzPromedio';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de umbral actual basado en el promedio de luz (CriticoRojo, CriticoAmarillo, Normal)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'tipoUmbralActual';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Período de evaluación en días (por defecto 30 días = último mes)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'LoteEvaluacion', @level2type = N'COLUMN', @level2name = N'periodoEvaluacionDias';
GO

PRINT '';
PRINT '=== Script completado ===';
GO

