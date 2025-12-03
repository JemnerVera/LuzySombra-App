-- =====================================================
-- SCRIPT: Crear tabla evalImagen.mensaje
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Logs de mensajes enviados vía Resend API
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.mensaje
--   ✅ Índices:
--      - IDX_mensaje_alertaID_statusID_001 (NONCLUSTERED, filtered)
--      - IDX_mensaje_estado_fechaCreacion_002 (NONCLUSTERED, filtered)
--      - IDX_mensaje_resendMessageID_003 (NONCLUSTERED)
--      - IDX_mensaje_fundoID_estado_004 (NONCLUSTERED, filtered)
--      - IDX_mensaje_estado_fechaCreacion_005 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_mensaje (PRIMARY KEY)
--      - FK_mensaje_alerta_01 (FOREIGN KEY → evalImagen.alerta)
--      - FK_mensaje_farm_02 (FOREIGN KEY → GROWER.FARMS)
--      - FK_mensaje_usuarioCrea_03 (FOREIGN KEY → MAST.USERS)
--      - FK_mensaje_usuarioModifica_04 (FOREIGN KEY → MAST.USERS)
--      - CK_mensaje_estadoValido_01 (CHECK)
--      - CK_mensaje_tipoValido_02 (CHECK)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
--
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.alerta (debe ejecutarse después)
--   ⚠️  Requiere: GROWER.FARMS (tabla existente)
--
-- ORDEN DE EJECUCIÓN:
--   5 de 10 - Después de crear evalImagen.alerta
--
-- USADO POR:
--   - evalImagen.mensajeAlerta (relación N:N con alerta)
--   - Backend: servicio de envío de emails vía Resend
--   - Queue jobs: procesamiento de mensajes pendientes
--
-- NOTA: La relación con alerta se maneja a través de evalImagen.mensajeAlerta
--       (no hay FK circular - mensaje.alertaID puede ser NULL para consolidados)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla evalImagen.mensaje
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'mensaje' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.mensaje (
        mensajeID INT IDENTITY(1,1) NOT NULL,
        alertaID INT NULL, -- NULL para mensajes consolidados (usar tabla mensajeAlerta)
        fundoID CHAR(4) NULL, -- Para mensajes consolidados por fundo
        
        -- Contenido del mensaje
        tipoMensaje VARCHAR(50) NOT NULL DEFAULT 'Email',
        asunto NVARCHAR(200) NOT NULL,
        cuerpoHTML NVARCHAR(MAX) NOT NULL,
        cuerpoTexto NVARCHAR(MAX) NULL,
        
        -- Destinatarios (JSON arrays)
        destinatarios NVARCHAR(MAX) NOT NULL, -- JSON: ["email1@example.com", "email2@example.com"]
        destinatariosCC NVARCHAR(MAX) NULL,
        destinatariosBCC NVARCHAR(MAX) NULL,
        
        -- Estado del envío
        estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
        fechaEnvio DATETIME NULL,
        intentosEnvio INT NOT NULL DEFAULT 0,
        ultimoIntentoEnvio DATETIME NULL,
        
        -- Respuesta de Resend API
        resendMessageID NVARCHAR(100) NULL,
        resendResponse NVARCHAR(MAX) NULL, -- JSON response completo
        
        -- Auditoría (según estándares AgroMigiva)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NULL,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        errorMessage NVARCHAR(500) NULL,
        
        CONSTRAINT PK_mensaje PRIMARY KEY CLUSTERED (mensajeID),
        CONSTRAINT FK_mensaje_alerta_01 FOREIGN KEY (alertaID) REFERENCES evalImagen.alerta(alertaID),
        CONSTRAINT FK_mensaje_farm_02 FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
        CONSTRAINT FK_mensaje_usuarioCrea_03 FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_mensaje_usuarioModifica_04 FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT CK_mensaje_estadoValido_01 CHECK (estado IN ('Pendiente', 'Enviando', 'Enviado', 'Error')),
        CONSTRAINT CK_mensaje_tipoValido_02 CHECK (tipoMensaje IN ('Email', 'SMS', 'Push'))
    );
    
    PRINT '[OK] Tabla evalImagen.mensaje creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.mensaje ya existe';
END
GO

-- =====================================================
-- Crear índices (con correlativo)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensaje_alertaID_statusID_001' AND object_id = OBJECT_ID('evalImagen.mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensaje_alertaID_statusID_001 
    ON evalImagen.mensaje(alertaID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_mensaje_alertaID_statusID_001 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensaje_estado_fechaCreacion_002' AND object_id = OBJECT_ID('evalImagen.mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensaje_estado_fechaCreacion_002 
    ON evalImagen.mensaje(estado, fechaCreacion ASC)
    WHERE statusID = 1 AND estado IN ('Pendiente', 'Enviando');
    PRINT '[OK] Índice IDX_mensaje_estado_fechaCreacion_002 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensaje_resendMessageID_003' AND object_id = OBJECT_ID('evalImagen.mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensaje_resendMessageID_003 
    ON evalImagen.mensaje(resendMessageID)
    WHERE resendMessageID IS NOT NULL;
    PRINT '[OK] Índice IDX_mensaje_resendMessageID_003 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensaje_fundoID_estado_004' AND object_id = OBJECT_ID('evalImagen.mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensaje_fundoID_estado_004 
    ON evalImagen.mensaje(fundoID, estado)
    WHERE statusID = 1 AND fundoID IS NOT NULL;
    PRINT '[OK] Índice IDX_mensaje_fundoID_estado_004 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensaje_estado_fechaCreacion_005' AND object_id = OBJECT_ID('evalImagen.mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensaje_estado_fechaCreacion_005
    ON evalImagen.mensaje(estado, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_mensaje_estado_fechaCreacion_005 creado';
END
GO

-- =====================================================
-- Agregar Extended Properties (según estándar)
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.mensaje') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Almacena logs de mensajes enviados vía Resend API. Incluye contenido, destinatarios, estado de envío y respuestas de la API.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'mensaje';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Col1Desc', @value = N'Identificador único del mensaje', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'mensajeID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col2Desc', @value = N'Foreign Key a la alerta (NULL para mensajes consolidados - usar tabla mensajeAlerta)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'alertaID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col3Desc', @value = N'Tipo de mensaje: Email, SMS, Push', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'tipoMensaje';
GO

EXEC sp_addextendedproperty @name = N'MS_Col4Desc', @value = N'Asunto del mensaje', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'asunto';
GO

EXEC sp_addextendedproperty @name = N'MS_Col5Desc', @value = N'Cuerpo del mensaje en formato HTML', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'cuerpoHTML';
GO

EXEC sp_addextendedproperty @name = N'MS_Col6Desc', @value = N'Destinatarios en formato JSON array: ["email1@example.com", "email2@example.com"]', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'destinatarios';
GO

EXEC sp_addextendedproperty @name = N'MS_Col7Desc', @value = N'Estado del envío: Pendiente (en cola), Enviando (en proceso), Enviado (exitoso), Error (falló)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'estado';
GO

EXEC sp_addextendedproperty @name = N'MS_Col8Desc', @value = N'ID del mensaje retornado por Resend API (para tracking y debugging)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'mensaje', @level2type = N'COLUMN', @level2name = N'resendMessageID';
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT '[✅] Tabla evalImagen.mensaje creada según estándares AgroMigiva';
GO
