-- =====================================================
-- SCRIPT: Crear tabla evalImagen.Alerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Registrar alertas generadas cuando un lote cruza un umbral
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.Alerta
--   ✅ Índices:
--      - IDX_Alerta_LotID (NONCLUSTERED, filtered)
--      - IDX_Alerta_Estado (NONCLUSTERED, filtered)
--      - IDX_Alerta_TipoUmbral (NONCLUSTERED, filtered)
--      - IDX_Alerta_FechaCreacion (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_Alerta (PRIMARY KEY)
--      - FK_Alerta_LOT (FOREIGN KEY → GROWER.LOT)
--      - FK_Alerta_LoteEvaluacion (FOREIGN KEY → evalImagen.LoteEvaluacion)
--      - FK_Alerta_Umbral (FOREIGN KEY → evalImagen.UmbralLuz)
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
--   ❌ Ninguno
--
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: evalImagen.LoteEvaluacion (debe ejecutarse después)
--   ⚠️  Requiere: evalImagen.UmbralLuz (debe ejecutarse después)
--   ⚠️  Requiere: GROWER.VARIETY (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
--
-- ORDEN DE EJECUCIÓN:
--   4 de 8 - Después de crear evalImagen.LoteEvaluacion y evalImagen.UmbralLuz
--
-- USADO POR:
--   - evalImagen.MensajeAlerta (relación N:N con Mensaje)
--   - Backend: lógica de generación de alertas
--   - Dashboard de alertas (futuro)
--
-- NOTA: La relación con Mensaje se maneja a través de evalImagen.MensajeAlerta
--       (no hay FK directa para evitar dependencia circular)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla evalImagen.Alerta
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Alerta' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.Alerta (
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
        usuarioResolvioID INT NULL,
        notas NVARCHAR(500) NULL,
        
        -- Auditoría
        statusID INT NOT NULL DEFAULT 1,
        
        CONSTRAINT PK_Alerta PRIMARY KEY CLUSTERED (alertaID),
        CONSTRAINT FK_Alerta_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
        CONSTRAINT FK_Alerta_LoteEvaluacion FOREIGN KEY (loteEvaluacionID) REFERENCES evalImagen.LoteEvaluacion(loteEvaluacionID),
        CONSTRAINT FK_Alerta_Umbral FOREIGN KEY (umbralID) REFERENCES evalImagen.UmbralLuz(umbralID),
        CONSTRAINT FK_Alerta_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
        CONSTRAINT FK_Alerta_UsuarioResolvio FOREIGN KEY (usuarioResolvioID) REFERENCES MAST.USERS(userID),
        CONSTRAINT CK_Alerta_Estado CHECK (estado IN ('Pendiente', 'Enviada', 'Resuelta', 'Ignorada')),
        CONSTRAINT CK_Alerta_TipoUmbral CHECK (tipoUmbral IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
        CONSTRAINT CK_Alerta_Severidad CHECK (severidad IN ('Critica', 'Advertencia', 'Info')),
        CONSTRAINT CK_Alerta_PorcentajeLuz CHECK (porcentajeLuzEvaluado >= 0 AND porcentajeLuzEvaluado <= 100)
    );
    
    PRINT '[OK] Tabla evalImagen.Alerta creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.Alerta ya existe';
END
GO

-- =====================================================
-- Crear índices
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_LotID' AND object_id = OBJECT_ID('evalImagen.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_LotID 
    ON evalImagen.Alerta(lotID, estado, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_LotID creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_Estado' AND object_id = OBJECT_ID('evalImagen.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_Estado 
    ON evalImagen.Alerta(estado, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_Estado creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_TipoUmbral' AND object_id = OBJECT_ID('evalImagen.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_TipoUmbral 
    ON evalImagen.Alerta(tipoUmbral, severidad, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_TipoUmbral creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Alerta_FechaCreacion' AND object_id = OBJECT_ID('evalImagen.Alerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Alerta_FechaCreacion
    ON evalImagen.Alerta(fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Alerta_FechaCreacion creado';
END
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.Alerta') 
    AND minor_id = 0 
    AND name = 'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Registra alertas generadas cuando un lote cruza un umbral de porcentaje de luz. Permite tracking de estado y gestión de notificaciones.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'Alerta';
    PRINT '[OK] Extended property agregado a tabla';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la alerta', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'alertaID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la alerta: Pendiente (creada pero no procesada), Enviada (mensaje enviado), Resuelta (lote volvió a normal), Ignorada (marcada como no relevante)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'estado';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Severidad de la alerta: Critica (CriticoRojo), Advertencia (CriticoAmarillo), Info (Normal)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'severidad';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de luz que activó la alerta (promedio del lote)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Alerta', @level2type = N'COLUMN', @level2name = N'porcentajeLuzEvaluado';
GO

PRINT '';
PRINT '=== Script completado ===';
GO

