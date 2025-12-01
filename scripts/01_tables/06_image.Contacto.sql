-- =====================================================
-- SCRIPT: Crear tabla evalImagen.Contacto
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Almacenar contactos/destinatarios para alertas por email
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.Contacto
--   ✅ Índices:
--      - IDX_Contacto_Email (UNIQUE)
--      - IDX_Contacto_Activo (NONCLUSTERED, filtered)
--      - IDX_Contacto_Tipo (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_Contacto (PRIMARY KEY)
--      - CK_Contacto_Estado (CHECK)
--      - CK_Contacto_Tipo (CHECK)
--      - UQ_Contacto_Email (UNIQUE)
--   ✅ Extended Properties:
--      - Documentación de tabla y columnas principales
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema image (debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento (no tiene dependencias)
-- 
-- USADO POR:
--   - Backend: alertService.ts (obtener destinatarios para alertas)
--   - Sistema de alertas: envío de emails a múltiples contactos
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear tabla evalImagen.Contacto
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Contacto' AND schema_id = SCHEMA_ID('evalImagen'))
BEGIN
    CREATE TABLE evalImagen.Contacto (
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
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        fechaActualizacion DATETIME NULL,
        usuarioCreaID INT NULL,
        usuarioActualizaID INT NULL,
        
        -- Auditoría
        statusID INT NOT NULL DEFAULT 1,
        
        CONSTRAINT PK_Contacto PRIMARY KEY CLUSTERED (contactoID),
        CONSTRAINT UQ_Contacto_Email UNIQUE (email),
        CONSTRAINT CK_Contacto_Tipo CHECK (tipo IN ('General', 'Admin', 'Agronomo', 'Manager', 'Supervisor', 'Tecnico', 'Otro')),
        CONSTRAINT CK_Contacto_Email CHECK (email LIKE '%@%.%'), -- Validación básica de email
        CONSTRAINT FK_Contacto_Farm FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
        CONSTRAINT FK_Contacto_Stage FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID),
        CONSTRAINT FK_Contacto_UsuarioCrea FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_Contacto_UsuarioActualiza FOREIGN KEY (usuarioActualizaID) REFERENCES MAST.USERS(userID)
    );
    
    PRINT '[OK] Tabla evalImagen.Contacto creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.Contacto ya existe';
END
GO

-- =====================================================
-- Crear índices
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Contacto_Email' AND object_id = OBJECT_ID('evalImagen.Contacto'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IDX_Contacto_Email 
    ON evalImagen.Contacto(email)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_Contacto_Email creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Contacto_Activo' AND object_id = OBJECT_ID('evalImagen.Contacto'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Contacto_Activo 
    ON evalImagen.Contacto(activo, statusID, tipo)
    WHERE statusID = 1 AND activo = 1;
    PRINT '[OK] Índice IDX_Contacto_Activo creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_Contacto_Tipo' AND object_id = OBJECT_ID('evalImagen.Contacto'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Contacto_Tipo 
    ON evalImagen.Contacto(tipo, recibirAlertasCriticas, recibirAlertasAdvertencias)
    WHERE statusID = 1 AND activo = 1;
    PRINT '[OK] Índice IDX_Contacto_Tipo creado';
END
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.Contacto') 
    AND minor_id = 0 
    AND name = 'MS_Description'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_Description', 
        @value = N'Almacena contactos/destinatarios para alertas por email. Permite configurar filtros por tipo de alerta, variedad, fundo o sector.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'Contacto';
    PRINT '[OK] Extended property agregado a tabla';
END
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del contacto', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'contactoID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre completo del contacto', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'nombre';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Email del contacto (único, validado)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'email';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de contacto: General, Admin, Agronomo, Manager, Supervisor, Tecnico, Otro', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'tipo';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Si 1, recibe alertas críticas (CriticoRojo)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'recirAlertasCriticas';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Si 1, recibe alertas de advertencia (CriticoAmarillo)', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'recirAlertasAdvertencias';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Si NULL, recibe alertas de todos los fundos. Si tiene valor, solo de ese fundo específico. Se hace match con el fundo del lote que tiene la alerta.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'fundoID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Si NULL, recibe alertas de todos los sectores. Si tiene valor, solo de ese sector específico. Se hace match con el sector del lote que tiene la alerta.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen', @level1type = N'TABLE', @level1name = N'Contacto', @level2type = N'COLUMN', @level2name = N'sectorID';
GO

PRINT '';
PRINT '=== Script completado ===';
PRINT '';
PRINT 'Ejemplos de uso:';
PRINT '  -- Insertar contacto que recibe todas las alertas:';
PRINT '  INSERT INTO evalImagen.Contacto (nombre, email, tipo, activo)';
PRINT '  VALUES (''Juan Pérez'', ''juan@example.com'', ''Admin'', 1);';
PRINT '';
PRINT '  -- Insertar contacto que solo recibe alertas críticas:';
PRINT '  INSERT INTO evalImagen.Contacto (nombre, email, tipo, recibirAlertasCriticas, recibirAlertasAdvertencias)';
PRINT '  VALUES (''María García'', ''maria@example.com'', ''Manager'', 1, 0);';
PRINT '';
PRINT '  -- Insertar contacto para un fundo específico:';
PRINT '  INSERT INTO evalImagen.Contacto (nombre, email, tipo, fundoID)';
PRINT '  VALUES (''Carlos López'', ''carlos@example.com'', ''Agronomo'', 1);';
PRINT '';
PRINT '  -- Insertar contacto para un sector específico:';
PRINT '  INSERT INTO evalImagen.Contacto (nombre, email, tipo, sectorID)';
PRINT '  VALUES (''Ana Rodríguez'', ''ana@example.com'', ''Supervisor'', 5);';
GO

