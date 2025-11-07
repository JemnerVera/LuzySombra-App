-- =====================================================
-- SCRIPT: Crear tabla image.Alerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: image
-- Propósito: Registrar alertas generadas cuando un lote cruza un umbral
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - image.Alerta
--   ✅ Índices:
--      - IDX_Alerta_LotID (NONCLUSTERED, filtered)
--      - IDX_Alerta_Estado (NONCLUSTERED, filtered)
--      - IDX_Alerta_TipoUmbral (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_Alerta (PRIMARY KEY)
--      - FK_Alerta_LOT (FOREIGN KEY → GROWER.LOT)
--      - FK_Alerta_LoteEvaluacion (FOREIGN KEY → image.LoteEvaluacion)
--      - FK_Alerta_Umbral (FOREIGN KEY → image.UmbralLuz)
--      - FK_Alerta_Variety (FOREIGN KEY → GROWER.VARIETY)
--      - FK_Alerta_UsuarioResolvio (FOREIGN KEY → MAST.USERS)
--      - CK_Alerta_Estado (CHECK)
--      - CK_Alerta_TipoUmbral (CHECK)
--      - CK_Alerta_Severidad (CHECK)
--      - CK_Alerta_PorcentajeLuz (CHECK)
--   ✅ Extended Properties:
--      - Documentación de tabla y columnas principales
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno (FK a image.Mensaje se crea después en create_table_mensaje.sql)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema image (debe existir)
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: image.LoteEvaluacion (debe ejecutarse después)
--   ⚠️  Requiere: image.UmbralLuz (debe ejecutarse después)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
--   ⚠️  Requiere: image.Mensaje (FK circular - se agrega después)
-- 
-- ORDEN DE EJECUCIÓN:
--   4 de 5 - Después de crear image.LoteEvaluacion y image.UmbralLuz
-- 
-- USADO POR:
--   - image.Mensaje (FK desde mensajeID)
--   - Backend: lógica de generación de alertas
--   - Dashboard de alertas (futuro)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla image.Alerta
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Alerta' AND schema_id = SCHEMA_ID('image'))
BEGIN
    CREATE TABLE image.Alerta (
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
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        fechaEnvio DATETIME NULL,
        fechaResolucion DATETIME NULL,
        
        -- Contexto adicional
        mensajeID INT NULL,
        usuarioResolvioID INT NULL,
        notas NVARCHAR(500) NULL,
        
        -- Auditoría
        statusID INT NOT NULL DEFAULT 1,
        
        CONSTRAINT PK_Alerta PRIMARY KEY CLUSTERED (alertaID),
        CONSTRAINT FK_Alerta_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT FK_Alerta_LoteEvaluacion FOREIGN KEY (loteEvaluacionID) REFERENCES image.LoteEvaluacion(loteEvaluacionID),
        CONSTRAINT FK_Alerta_Umbral FOREIGN KEY (umbralID) REFERENCES image.UmbralLuz(umbralID),
        CONSTRAINT FK_Alerta_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_Alerta_UsuarioResolvio FOREIGN KEY (usuarioResolvioID) REFERENCES MAST.USERS(userID),
        CONSTRAINT CK_Alerta_Estado CHECK (estado IN ('Pendiente', 'Enviada', 'Resuelta', 'Ignorada')),
        CONSTRAINT CK_Alerta_TipoUmbral CHECK (tipoUmbral IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
        CONSTRAINT CK_Alerta_Severidad CHECK (severidad IN ('Critica', 'Advertencia', 'Info')),
        CONSTRAINT CK_Alerta_PorcentajeLuz CHECK (porcentajeLuzEvaluado >= 0 AND porcentajeLuzEvaluado <= 100)
    );
    
    PRINT '[OK] Tabla image.Alerta creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla image.Alerta ya existe';
END
GO

-- =====================================================
-- Crear índices
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_LotID' AND object_id = OBJECT_ID('image.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_LotID 
    ON image.Alerta(lotID, estado, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_LotID creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_Estado' AND object_id = OBJECT_ID('image.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_Estado 
    ON image.Alerta(estado, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_Estado creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_TipoUmbral' AND object_id = OBJECT_ID('image.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_TipoUmbral 
    ON image.Alerta(tipoUmbral, severidad, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_TipoUmbral creado';
END
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('image.Alerta') 
    AND minor_id = 0 
    AND name = 'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Registra alertas generadas cuando un lote cruza un umbral de porcentaje de luz. Permite tracking de estado y gestión de notificaciones.', 
        @level0type = N'SCHEMA', @level0name = N'image',
        @level1type = N'TABLE', @level1name = N'Alerta';
    PRINT '[OK] Extended property agregado a tabla';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la alerta', 
    @level0type = N'SCHEMA', @level0name = N'image', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'alertaID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la alerta: Pendiente (creada pero no procesada), Enviada (mensaje enviado), Resuelta (lote volvió a normal), Ignorada (marcada como no relevante)', 
    @level0type = N'SCHEMA', @level0name = N'image', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'estado';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Severidad de la alerta: Critica (CriticoRojo), Advertencia (CriticoAmarillo), Info (Normal)', 
    @level0type = N'SCHEMA', @level0name = N'image', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'severidad';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de luz que activó la alerta (promedio del lote)', 
    @level0type = N'SCHEMA', @level0name = N'image', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'porcentajeLuzEvaluado';
GO

PRINT '';
PRINT '=== Script completado ===';
GO

