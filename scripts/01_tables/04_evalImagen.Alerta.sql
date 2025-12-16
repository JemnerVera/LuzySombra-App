-- =====================================================
-- SCRIPT: Crear tabla evalImagen.alerta
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Registrar alertas generadas cuando un lote cruza un umbral
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.alerta
--   ✅ Índices:
--      - IDX_alerta_lotID_estado_statusID_001 (NONCLUSTERED, filtered)
--      - IDX_alerta_estado_fechaCreacion_002 (NONCLUSTERED, filtered)
--      - IDX_alerta_tipoUmbral_severidad_fechaCreacion_003 (NONCLUSTERED, filtered)
--      - IDX_alerta_fechaCreacion_004 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_alerta (PRIMARY KEY)
--      - FK_alerta_lot_01 (FOREIGN KEY → GROWER.LOT)
--      - FK_alerta_loteEvaluacion_02 (FOREIGN KEY → evalImagen.loteEvaluacion)
--      - FK_alerta_umbral_03 (FOREIGN KEY → evalImagen.umbralLuz)
--      - FK_alerta_variety_04 (FOREIGN KEY → GROWER.VARIETY)
--      - FK_alerta_usuarioResolvio_05 (FOREIGN KEY → MAST.USERS)
--      - FK_alerta_usuarioCrea_06 (FOREIGN KEY → MAST.USERS)
--      - FK_alerta_usuarioModifica_07 (FOREIGN KEY → MAST.USERS)
--      - CK_alerta_estadoValido_01 (CHECK)
--      - CK_alerta_tipoUmbralValido_02 (CHECK)
--      - CK_alerta_severidadValida_03 (CHECK)
--      - CK_alerta_porcentajeLuzValido_04 (CHECK)
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
--   ⚠️  Requiere: evalImagen.loteEvaluacion (debe ejecutarse después)
--   ⚠️  Requiere: evalImagen.umbralLuz (debe ejecutarse después)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
--
-- ORDEN DE EJECUCIÓN:
--   4 de 10 - Después de crear evalImagen.loteEvaluacion y evalImagen.umbralLuz
--
-- USADO POR:
--   - evalImagen.mensajeAlerta (relación N:N con mensaje)
--   - Backend: lógica de generación de alertas
--   - Dashboard de alertas
--
-- NOTA: La relación con mensaje se maneja a través de evalImagen.mensajeAlerta
--       (no hay FK directa para evitar dependencia circular)
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

-- =====================================================
-- Crear tabla evalImagen.alerta
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'alerta' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.alerta (
        alertaID INT IDENTITY(1,1) NOT NULL,
        lotID INT NOT NULL,
        loteEvaluacionID INT NULL,
        umbralID INT NOT NULL,
        variedadID INT NULL,
        
        -- Valores que activaron la alerta
        porcentajeLuzEvaluado DECIMAL(5,2) NOT NULL,
        tipoUmbral VARCHAR(20) NOT NULL,
        severidad VARCHAR(20) NOT NULL,
        
        -- Estado de la alerta
        estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
        fechaEnvio DATETIME NULL,
        fechaResolucion DATETIME NULL,
        
        -- Contexto adicional
        usuarioResolvioID INT NULL,
        notas NVARCHAR(500) NULL,
        
        -- Auditoría (según estándares AgroMigiva)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NULL,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        
        CONSTRAINT PK_alerta PRIMARY KEY CLUSTERED (alertaID),
        CONSTRAINT FK_alerta_lot_01 FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT FK_alerta_loteEvaluacion_02 FOREIGN KEY (loteEvaluacionID) REFERENCES evalImagen.loteEvaluacion(loteEvaluacionID),
        CONSTRAINT FK_alerta_umbral_03 FOREIGN KEY (umbralID) REFERENCES evalImagen.umbralLuz(umbralID),
        CONSTRAINT FK_alerta_variety_04 FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_alerta_usuarioResolvio_05 FOREIGN KEY (usuarioResolvioID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_alerta_usuarioCrea_06 FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_alerta_usuarioModifica_07 FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT CK_alerta_estadoValido_01 CHECK (estado IN ('Pendiente', 'Enviada', 'Resuelta', 'Ignorada')),
        CONSTRAINT CK_alerta_tipoUmbralValido_02 CHECK (tipoUmbral IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
        CONSTRAINT CK_alerta_severidadValida_03 CHECK (severidad IN ('Critica', 'Advertencia', 'Info')),
        CONSTRAINT CK_alerta_porcentajeLuzValido_04 CHECK (porcentajeLuzEvaluado >= 0 AND porcentajeLuzEvaluado <= 100)
    );
    
    PRINT '[OK] Tabla evalImagen.alerta creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.alerta ya existe';
END
GO

-- =====================================================
-- Crear índices (con correlativo)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_alerta_lotID_estado_statusID_001' AND object_id = OBJECT_ID('evalImagen.alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_alerta_lotID_estado_statusID_001 
    ON evalImagen.alerta(lotID, estado, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_alerta_lotID_estado_statusID_001 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_alerta_estado_fechaCreacion_002' AND object_id = OBJECT_ID('evalImagen.alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_alerta_estado_fechaCreacion_002 
    ON evalImagen.alerta(estado, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_alerta_estado_fechaCreacion_002 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_alerta_tipoUmbral_severidad_fechaCreacion_003' AND object_id = OBJECT_ID('evalImagen.alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_alerta_tipoUmbral_severidad_fechaCreacion_003 
    ON evalImagen.alerta(tipoUmbral, severidad, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_alerta_tipoUmbral_severidad_fechaCreacion_003 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_alerta_fechaCreacion_004' AND object_id = OBJECT_ID('evalImagen.alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_alerta_fechaCreacion_004
    ON evalImagen.alerta(fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_alerta_fechaCreacion_004 creado';
END
GO

-- =====================================================
-- Agregar Extended Properties (según estándar)
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.alerta') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Registra alertas generadas cuando un lote cruza un umbral de porcentaje de luz. Permite tracking de estado y gestión de notificaciones.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'alerta';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Col1Desc', @value = N'Identificador único de la alerta', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'alertaID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col2Desc', @value = N'Foreign Key al lote que generó la alerta', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'lotID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col3Desc', @value = N'Foreign Key a la evaluación del lote que generó la alerta', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'loteEvaluacionID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col4Desc', @value = N'Foreign Key al umbral que activó la alerta', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'umbralID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col5Desc', @value = N'Porcentaje de luz que activó la alerta (promedio del lote)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'porcentajeLuzEvaluado';
GO

EXEC sp_addextendedproperty @name = N'MS_Col6Desc', @value = N'Tipo de umbral que activó la alerta: CriticoRojo, CriticoAmarillo, Normal', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'tipoUmbral';
GO

EXEC sp_addextendedproperty @name = N'MS_Col7Desc', @value = N'Severidad de la alerta: Critica (CriticoRojo), Advertencia (CriticoAmarillo), Info (Normal)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'severidad';
GO

EXEC sp_addextendedproperty @name = N'MS_Col8Desc', @value = N'Estado de la alerta: Pendiente (creada pero no procesada), Enviada (mensaje enviado), Resuelta (lote volvió a normal), Ignorada (marcada como no relevante)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'alerta', @level2type = N'COLUMN', @level2name = N'estado';
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT '[✅] Tabla evalImagen.alerta creada según estándares AgroMigiva';
GO
