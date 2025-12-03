-- =====================================================
-- SCRIPT: Crear tabla evalImagen.loteEvaluacion
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Cache de estadísticas agregadas por lote para alertas
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.loteEvaluacion
--   ✅ Índices:
--      - IDX_loteEvaluacion_lotID_001 (NONCLUSTERED, filtered)
--      - IDX_loteEvaluacion_tipoUmbralActual_statusID_002 (NONCLUSTERED, filtered)
--      - IDX_loteEvaluacion_fundoID_statusID_003 (NONCLUSTERED, filtered)
--      - IDX_loteEvaluacion_fechaUltimaActualizacion_004 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_loteEvaluacion (PRIMARY KEY)
--      - FK_loteEvaluacion_lot_01 (FOREIGN KEY → GROWER.LOT)
--      - FK_loteEvaluacion_variety_02 (FOREIGN KEY → GROWER.VARIETY)
--      - FK_loteEvaluacion_farm_03 (FOREIGN KEY → GROWER.FARMS)
--      - FK_loteEvaluacion_stage_04 (FOREIGN KEY → GROWER.STAGE)
--      - FK_loteEvaluacion_umbral_05 (FOREIGN KEY → evalImagen.umbralLuz)
--      - FK_loteEvaluacion_usuarioCrea_06 (FOREIGN KEY → MAST.USERS)
--      - FK_loteEvaluacion_usuarioModifica_07 (FOREIGN KEY → MAST.USERS)
--      - UQ_loteEvaluacion_lotID_01 (UNIQUE - una fila por lote)
--      - CK_loteEvaluacion_tipoUmbralValido_01 (CHECK)
--      - CK_loteEvaluacion_porcentajeLuzValido_02 (CHECK)
--      - CK_loteEvaluacion_porcentajeSombraValido_03 (CHECK)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: evalImagen.umbralLuz (debe ejecutarse después)
-- 
-- ORDEN DE EJECUCIÓN:
--   3 de 10 - Después de crear evalImagen.umbralLuz
-- 
-- USADO POR:
--   - getConsolidatedTable (query consolidada - fuente principal de estadísticas)
--   - evalImagen.alerta (FK a loteEvaluacionID)
--   - evalImagen.usp_evalImagen_calcularLoteEvaluacion (actualiza esta tabla)
--   - Backend: src/services/sqlServerService.ts (saveProcessingResult actualiza)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla evalImagen.loteEvaluacion
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'loteEvaluacion' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.loteEvaluacion (
        loteEvaluacionID INT IDENTITY(1,1) NOT NULL,
        lotID INT NOT NULL,
        variedadID INT NULL,
        
        -- Relaciones con jerarquía (para optimizar match con evalImagen.contacto)
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
        
        CONSTRAINT PK_loteEvaluacion PRIMARY KEY CLUSTERED (loteEvaluacionID),
        CONSTRAINT FK_loteEvaluacion_lot_01 FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT FK_loteEvaluacion_variety_02 FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_loteEvaluacion_farm_03 FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
        CONSTRAINT FK_loteEvaluacion_stage_04 FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID),
        CONSTRAINT FK_loteEvaluacion_umbral_05 FOREIGN KEY (umbralIDActual) REFERENCES evalImagen.umbralLuz(umbralID),
        CONSTRAINT FK_loteEvaluacion_usuarioCrea_06 FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_loteEvaluacion_usuarioModifica_07 FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT UQ_loteEvaluacion_lotID_01 UNIQUE (lotID),
        CONSTRAINT CK_loteEvaluacion_tipoUmbralValido_01 CHECK (tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo', 'Normal') OR tipoUmbralActual IS NULL),
        CONSTRAINT CK_loteEvaluacion_porcentajeLuzValido_02 CHECK (porcentajeLuzPromedio >= 0 AND porcentajeLuzPromedio <= 100),
        CONSTRAINT CK_loteEvaluacion_porcentajeSombraValido_03 CHECK (porcentajeSombraPromedio >= 0 AND porcentajeSombraPromedio <= 100)
    );
    
    PRINT '[OK] Tabla evalImagen.loteEvaluacion creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.loteEvaluacion ya existe';
END
GO

-- =====================================================
-- Crear índices (con correlativo)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_loteEvaluacion_lotID_001' AND object_id = OBJECT_ID('evalImagen.loteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_loteEvaluacion_lotID_001 
    ON evalImagen.loteEvaluacion(lotID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_loteEvaluacion_lotID_001 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_loteEvaluacion_tipoUmbralActual_statusID_002' AND object_id = OBJECT_ID('evalImagen.loteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_loteEvaluacion_tipoUmbralActual_statusID_002 
    ON evalImagen.loteEvaluacion(tipoUmbralActual, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_loteEvaluacion_tipoUmbralActual_statusID_002 creado';
END
GO

-- Índice para optimizar match con evalImagen.contacto por fundoID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_loteEvaluacion_fundoID_statusID_003' AND object_id = OBJECT_ID('evalImagen.loteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_loteEvaluacion_fundoID_statusID_003 
    ON evalImagen.loteEvaluacion(fundoID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_loteEvaluacion_fundoID_statusID_003 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_loteEvaluacion_fechaUltimaActualizacion_004' AND object_id = OBJECT_ID('evalImagen.loteEvaluacion'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_loteEvaluacion_fechaUltimaActualizacion_004 
    ON evalImagen.loteEvaluacion(fechaUltimaActualizacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_loteEvaluacion_fechaUltimaActualizacion_004 creado';
END
GO

-- =====================================================
-- Agregar Extended Properties (según estándar)
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.loteEvaluacion') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Cache de estadísticas agregadas por lote para evaluaciones de luz/sombra. Permite tracking de estado actual y generación eficiente de alertas.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'loteEvaluacion';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Col1Desc', @value = N'Identificador único de la evaluación de lote', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'loteEvaluacionID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col2Desc', @value = N'Foreign Key al lote evaluado', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'lotID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col3Desc', @value = N'Variedad del cultivo (NULL si el lote tiene múltiples variedades o no está definida)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'variedadID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col4Desc', @value = N'Fundo del lote (GROWER.FARMS.farmID). Se almacena para optimizar el match con evalImagen.contacto que filtra por fundoID.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'fundoID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col5Desc', @value = N'Sector del lote (GROWER.STAGE.stageID). Se almacena para optimizar el match con evalImagen.contacto que filtra por sectorID.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'sectorID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col6Desc', @value = N'Porcentaje promedio de luz en el período evaluado', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'porcentajeLuzPromedio';
GO

EXEC sp_addextendedproperty @name = N'MS_Col7Desc', @value = N'Tipo de umbral actual basado en el promedio de luz (CriticoRojo, CriticoAmarillo, Normal)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'tipoUmbralActual';
GO

EXEC sp_addextendedproperty @name = N'MS_Col8Desc', @value = N'Período de evaluación en días (por defecto 30 días = último mes)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'loteEvaluacion', @level2type = N'COLUMN', @level2name = N'periodoEvaluacionDias';
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT '[✅] Tabla evalImagen.loteEvaluacion creada según estándares AgroMigiva';
GO
