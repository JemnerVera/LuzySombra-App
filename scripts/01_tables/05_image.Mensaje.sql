-- =====================================================
-- SCRIPT: Crear tabla evalImagen.Mensaje
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Logs de mensajes enviados vía Resend API
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.Mensaje
--   ✅ Índices:
--      - IDX_Mensaje_AlertaID (NONCLUSTERED, filtered)
--      - IDX_Mensaje_Estado (NONCLUSTERED, filtered - para Pendiente/Enviando)
--      - IDX_Mensaje_ResendMessageID (NONCLUSTERED)
--      - IDX_Mensaje_FundoID (NONCLUSTERED, filtered)
--      - IDX_Mensaje_EstadoFecha (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_Mensaje (PRIMARY KEY)
--      - FK_Mensaje_Alerta (FOREIGN KEY → evalImagen.Alerta)
--      - CK_Mensaje_Estado (CHECK)
--      - CK_Mensaje_Tipo (CHECK)
--   ✅ Extended Properties:
--      - Documentación de tabla y columnas principales
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
--
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.Alerta (debe ejecutarse después)
--   ⚠️  Requiere: GROWER.FARMS (tabla existente)
--
-- ORDEN DE EJECUCIÓN:
--   5 de 8 - Después de crear evalImagen.Alerta
--
-- USADO POR:
--   - evalImagen.MensajeAlerta (relación N:N con Alerta)
--   - Backend: servicio de envío de emails vía Resend
--   - Queue jobs: procesamiento de mensajes pendientes
--
-- NOTA: La relación con Alerta se maneja a través de evalImagen.MensajeAlerta
--       (no hay FK circular - Mensaje.alertaID puede ser NULL para consolidados)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla evalImagen.Mensaje
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Mensaje' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.Mensaje (
        mensajeID INT IDENTITY(1,1) NOT NULL,
        alertaID INT NULL, -- NULL para mensajes consolidados (usar tabla MensajeAlerta)
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
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        fechaEnvio DATETIME NULL,
        intentosEnvio INT NOT NULL DEFAULT 0,
        ultimoIntentoEnvio DATETIME NULL,
        
        -- Respuesta de Resend API
        resendMessageID NVARCHAR(100) NULL,
        resendResponse NVARCHAR(MAX) NULL, -- JSON response completo
        errorMessage NVARCHAR(500) NULL,
        
        -- Auditoría
        statusID INT NOT NULL DEFAULT 1,
        
        CONSTRAINT PK_Mensaje PRIMARY KEY CLUSTERED (mensajeID),
        CONSTRAINT FK_Mensaje_Alerta FOREIGN KEY (alertaID) REFERENCES evalImagen.Alerta(alertaID),
        CONSTRAINT FK_Mensaje_Farm FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
        CONSTRAINT CK_Mensaje_Estado CHECK (estado IN ('Pendiente', 'Enviando', 'Enviado', 'Error')),
        CONSTRAINT CK_Mensaje_Tipo CHECK (tipoMensaje IN ('Email', 'SMS', 'Push'))
    );
    
    PRINT '[OK] Tabla evalImagen.Mensaje creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.Mensaje ya existe';
END
GO

-- =====================================================
-- Crear índices
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Mensaje_AlertaID' AND object_id = OBJECT_ID('evalImagen.Mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Mensaje_AlertaID 
    ON evalImagen.Mensaje(alertaID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Mensaje_AlertaID creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Mensaje_Estado' AND object_id = OBJECT_ID('evalImagen.Mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Mensaje_Estado 
    ON evalImagen.Mensaje(estado, fechaCreacion ASC)
    WHERE statusID = 1 AND estado IN ('Pendiente', 'Enviando');
    PRINT '[OK] Índice IDX_Mensaje_Estado creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Mensaje_ResendMessageID' AND object_id = OBJECT_ID('evalImagen.Mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Mensaje_ResendMessageID 
    ON evalImagen.Mensaje(resendMessageID)
    WHERE resendMessageID IS NOT NULL;
    PRINT '[OK] Índice IDX_Mensaje_ResendMessageID creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Mensaje_FundoID' AND object_id = OBJECT_ID('evalImagen.Mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Mensaje_FundoID 
    ON evalImagen.Mensaje(fundoID, estado)
    WHERE statusID = 1 AND fundoID IS NOT NULL;
    PRINT '[OK] Índice IDX_Mensaje_FundoID creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Mensaje_EstadoFecha' AND object_id = OBJECT_ID('evalImagen.Mensaje'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Mensaje_EstadoFecha
    ON evalImagen.Mensaje(estado, fechaCreacion DESC)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Mensaje_EstadoFecha creado';
END
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.Mensaje') 
    AND minor_id = 0 
    AND name = 'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Almacena logs de mensajes enviados vía Resend API. Incluye contenido, destinatarios, estado de envío y respuestas de la API.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'Mensaje';
    PRINT '[OK] Extended property agregado a tabla';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del mensaje', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Mensaje', @level2type = N'COLUMN', @level2name = N'mensajeID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del envío: Pendiente (en cola), Enviando (en proceso), Enviado (exitoso), Error (falló)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Mensaje', @level2type = N'COLUMN', @level2name = N'estado';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Destinatarios en formato JSON array: ["email1@example.com", "email2@example.com"]', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Mensaje', @level2type = N'COLUMN', @level2name = N'destinatarios';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ID del mensaje retornado por Resend API (para tracking y debugging)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Mensaje', @level2type = N'COLUMN', @level2name = N'resendMessageID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Respuesta completa de Resend API en formato JSON (para debugging y auditoría)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Mensaje', @level2type = N'COLUMN', @level2name = N'resendResponse';
GO

PRINT '';
PRINT '=== Script completado ===';
GO

