-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.mensajeAlerta
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Servidor: [CONFIGURAR - Reemplazar con IP o hostname de tu servidor SQL]
-- Schema: evalImagen
-- Propósito: Tabla de relación para mensajes consolidados (muchos a muchos)
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.mensajeAlerta
--   ✅ Constraints:
--      - PK_mensajeAlerta (PRIMARY KEY)
--      - FK_mensajeAlerta_mensaje_01 (FOREIGN KEY → evalImagen.mensaje)
--      - FK_mensajeAlerta_alerta_02 (FOREIGN KEY → evalImagen.alerta)
--      - FK_mensajeAlerta_usuarioCrea_03 (FOREIGN KEY → MAST.USERS)
--      - FK_mensajeAlerta_usuarioModifica_04 (FOREIGN KEY → MAST.USERS)
--      - UQ_mensajeAlerta_mensajeID_alertaID_01 (UNIQUE - evita duplicados)
--   ✅ Índices:
--      - IDX_mensajeAlerta_mensajeID_statusID_001 (NONCLUSTERED)
--      - IDX_mensajeAlerta_alertaID_statusID_002 (NONCLUSTERED)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.mensaje (tabla debe existir)
--   ⚠️  Requiere: evalImagen.alerta (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   8 de 10 - Después de crear evalImagen.mensaje y evalImagen.alerta
-- 
-- USADO POR:
--   - Backend: src/services/alertService.ts (mensajes consolidados)
--   - Backend: src/services/resendService.ts (actualizar alertas relacionadas)
-- 
-- NOTA: Esta tabla permite que un mensaje consolidado agrupe múltiples alertas
--       y que una alerta pueda estar en múltiples mensajes (aunque no es común)
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

-- =====================================================
-- Crear Tabla evalImagen.mensajeAlerta
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.mensajeAlerta') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.mensajeAlerta (
        -- Clave primaria compuesta
        mensajeID INT NOT NULL,
        alertaID INT NOT NULL,
        
        -- Auditoría (según estándares AgroMigiva)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NULL,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        
        -- Constraints con nomenclatura estándar Migiva (con correlativos)
        CONSTRAINT PK_mensajeAlerta PRIMARY KEY (mensajeID, alertaID),
        CONSTRAINT FK_mensajeAlerta_mensaje_01 
            FOREIGN KEY (mensajeID) REFERENCES evalImagen.mensaje(mensajeID),
        CONSTRAINT FK_mensajeAlerta_alerta_02 
            FOREIGN KEY (alertaID) REFERENCES evalImagen.alerta(alertaID),
        CONSTRAINT FK_mensajeAlerta_usuarioCrea_03 
            FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT FK_mensajeAlerta_usuarioModifica_04 
            FOREIGN KEY (usuarioModificaID) REFERENCES MAST.USERS(userID),
        CONSTRAINT UQ_mensajeAlerta_mensajeID_alertaID_01 
            UNIQUE (mensajeID, alertaID)
    );
    
    PRINT '[OK] Tabla evalImagen.mensajeAlerta creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.mensajeAlerta ya existe';
END
GO

-- =====================================================
-- Crear Índices (con correlativo)
-- =====================================================

-- Índice para búsqueda por mensajeID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensajeAlerta_mensajeID_statusID_001' AND object_id = OBJECT_ID('evalImagen.mensajeAlerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensajeAlerta_mensajeID_statusID_001 
    ON evalImagen.mensajeAlerta(mensajeID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_mensajeAlerta_mensajeID_statusID_001 creado';
END
GO

-- Índice para búsqueda por alertaID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_mensajeAlerta_alertaID_statusID_002' AND object_id = OBJECT_ID('evalImagen.mensajeAlerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_mensajeAlerta_alertaID_statusID_002 
    ON evalImagen.mensajeAlerta(alertaID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_mensajeAlerta_alertaID_statusID_002 creado';
END
GO

-- =====================================================
-- Agregar Extended Properties (según estándar)
-- =====================================================

-- Tabla (MS_TablaDescription según estándar)
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.mensajeAlerta') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Tabla de relación entre mensaje y alerta. Permite que un mensaje consolidado agrupe múltiples alertas.', 
        @level0type = N'SCHEMA', @level0name = N'evalImagen',
        @level1type = N'TABLE', @level1name = N'mensajeAlerta';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

-- Columnas (MS_ColXDesc según estándar)
EXEC sp_addextendedproperty 
    @name = N'MS_Col1Desc', 
    @value = N'Foreign Key al mensaje consolidado', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'mensajeAlerta',
    @level2type = N'COLUMN', @level2name = N'mensajeID';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Col2Desc', 
    @value = N'Foreign Key a la alerta incluida en el mensaje', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'mensajeAlerta',
    @level2type = N'COLUMN', @level2name = N'alertaID';
GO

PRINT '[OK] Comentarios extendidos agregados';
GO

PRINT '[✅] Script completado exitosamente';
PRINT 'Tabla evalImagen.mensajeAlerta creada según estándares AgroMigiva';
GO
