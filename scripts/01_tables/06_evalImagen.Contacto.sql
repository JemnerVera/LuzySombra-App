-- =====================================================
-- SCRIPT: Crear tabla evalImagen.contacto
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Almacenar contactos/destinatarios para alertas por email
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.contacto
--   ✅ Índices:
--      - IDX_contacto_email_001 (UNIQUE)
--      - IDX_contacto_activo_statusID_tipo_002 (NONCLUSTERED, filtered)
--      - IDX_contacto_tipo_recibirAlertasCriticas_recibirAlertasAdvertencias_003 (NONCLUSTERED, filtered)
--      - IDX_contacto_fundoID_sectorID_activo_004 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_contacto (PRIMARY KEY)
--      - FK_contacto_farm_01 (FOREIGN KEY → GROWER.FARMS)
--      - FK_contacto_stage_02 (FOREIGN KEY → GROWER.STAGE)
--      - FK_contacto_usuarioCrea_03 (FOREIGN KEY → MAST.USERS)
--      - FK_contacto_usuarioModifica_04 (FOREIGN KEY → MAST.USERS)
--      - CK_contacto_tipoValido_01 (CHECK)
--      - CK_contacto_emailValido_02 (CHECK)
--      - UQ_contacto_email_01 (UNIQUE)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento (no tiene dependencias)
-- 
-- USADO POR:
--   - Backend: alertService.ts (obtener destinatarios para alertas)
--   - Sistema de alertas: envío de emails a múltiples contactos
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

-- =====================================================
-- Crear tabla evalImagen.contacto
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'contacto' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.contacto (
        contactoID INT IDENTITY(1,1) NOT NULL,
        
        -- Información del contacto
        nombre NVARCHAR(100) NOT NULL,
        email NVARCHAR(255) NOT NULL,
        telefono NVARCHAR(20) NULL,
        
        -- Tipo de contacto y roles
        tipo VARCHAR(50) NOT NULL DEFAULT 'General', -- 'General', 'Admin', 'Agronomo', 'Manager', 'Supervisor'
        rol NVARCHAR(100) NULL, -- Rol adicional o descripción
        
        -- Configuración de alertas
        recibirAlertasCriticas BIT NOT NULL DEFAULT 1, -- Recibir alertas críticas (CriticoRojo)
        recibirAlertasAdvertencias BIT NOT NULL DEFAULT 1, -- Recibir alertas de advertencia (CriticoAmarillo)
        recibirAlertasNormales BIT NOT NULL DEFAULT 0, -- Recibir notificaciones cuando vuelve a Normal (opcional)
        
        -- Filtros opcionales (NULL = todos)
        fundoID CHAR(4) NULL, -- NULL = todos los fundos, específico = solo ese fundo (relación: GROWER.FARMS.farmID)
        sectorID INT NULL, -- NULL = todos los sectores, específico = solo ese sector (relación: GROWER.STAGE.stageID)
        
        -- Prioridad de envío
        prioridad INT NOT NULL DEFAULT 0, -- Para ordenar destinatarios (0 = normal, positivo = alta prioridad)
        
        -- Estado
        activo BIT NOT NULL DEFAULT 1,
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NULL,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        
        CONSTRAINT PK_contacto PRIMARY KEY CLUSTERED (contactoID),
        CONSTRAINT UQ_contacto_email_01 UNIQUE (email),
        CONSTRAINT CK_contacto_tipoValido_01 CHECK (tipo IN ('General', 'Admin', 'Agronomo', 'Manager', 'Supervisor', 'Tecnico', 'Otro')),
        CONSTRAINT CK_contacto_emailValido_02 CHECK (
            email LIKE '%_@_%._%' 
            AND email NOT LIKE '%..%' 
            AND email NOT LIKE '%@%@%'
            AND LEN(email) >= 5
            AND LEFT(email, 1) != '@'
            AND RIGHT(email, 1) != '@'
        ), -- Validación mejorada de email
        CONSTRAINT FK_contacto_farm_01 FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
        CONSTRAINT FK_contacto_stage_02 FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID),
        CONSTRAINT FK_contacto_usuarioCrea_03 FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_contacto_usuarioModifica_04 FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID)
    );
    
    PRINT '[OK] Tabla evalImagen.contacto creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.contacto ya existe';
END
GO

-- =====================================================
-- Crear índices (con correlativo)
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_contacto_email_001' AND object_id = OBJECT_ID('evalImagen.contacto'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IDX_contacto_email_001 
    ON evalImagen.contacto(email)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_contacto_email_001 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_contacto_activo_statusID_tipo_002' AND object_id = OBJECT_ID('evalImagen.contacto'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_contacto_activo_statusID_tipo_002 
    ON evalImagen.contacto(activo, statusID, tipo)
    WHERE statusID = 1 AND activo = 1;
    PRINT '[OK] Índice IDX_contacto_activo_statusID_tipo_002 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_contacto_tipo_recibirAlertasCriticas_recibirAlertasAdvertencias_003' AND object_id = OBJECT_ID('evalImagen.contacto'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_contacto_tipo_recibirAlertasCriticas_recibirAlertasAdvertencias_003 
    ON evalImagen.contacto(tipo, recibirAlertasCriticas, recibirAlertasAdvertencias)
    WHERE statusID = 1 AND activo = 1;
    PRINT '[OK] Índice IDX_contacto_tipo_recibirAlertasCriticas_recibirAlertasAdvertencias_003 creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_contacto_fundoID_sectorID_activo_004' AND object_id = OBJECT_ID('evalImagen.contacto'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_contacto_fundoID_sectorID_activo_004
    ON evalImagen.contacto(fundoID, sectorID, activo)
    WHERE statusID = 1 AND activo = 1;
    PRINT '[OK] Índice IDX_contacto_fundoID_sectorID_activo_004 creado';
END
GO

-- =====================================================
-- Agregar Extended Properties (según estándar)
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.contacto') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Almacena contactos/destinatarios para alertas por email. Permite configurar filtros por tipo de alerta, variedad, fundo o sector.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'contacto';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Col1Desc', @value = N'Identificador único del contacto', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'contactoID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col2Desc', @value = N'Nombre completo del contacto', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'nombre';
GO

EXEC sp_addextendedproperty @name = N'MS_Col3Desc', @value = N'Email del contacto (único, validado)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'email';
GO

EXEC sp_addextendedproperty @name = N'MS_Col4Desc', @value = N'Tipo de contacto: General, Admin, Agronomo, Manager, Supervisor, Tecnico, Otro', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'tipo';
GO

EXEC sp_addextendedproperty @name = N'MS_Col5Desc', @value = N'Si 1, recibe alertas críticas (CriticoRojo)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'recibirAlertasCriticas';
GO

EXEC sp_addextendedproperty @name = N'MS_Col6Desc', @value = N'Si 1, recibe alertas de advertencia (CriticoAmarillo)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'recibirAlertasAdvertencias';
GO

EXEC sp_addextendedproperty @name = N'MS_Col7Desc', @value = N'Si NULL, recibe alertas de todos los fundos. Si tiene valor, solo de ese fundo específico. Se hace match con el fundo del lote que tiene la alerta.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'fundoID';
GO

EXEC sp_addextendedproperty @name = N'MS_Col8Desc', @value = N'Si NULL, recibe alertas de todos los sectores. Si tiene valor, solo de ese sector específico. Se hace match con el sector del lote que tiene la alerta.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'contacto', @level2type = N'COLUMN', @level2name = N'sectorID';
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT '[✅] Tabla evalImagen.contacto creada según estándares AgroMigiva';
GO
