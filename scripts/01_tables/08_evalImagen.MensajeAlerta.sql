-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.MensajeAlerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Schema: evalImagen
-- Propósito: Tabla de relación para mensajes consolidados (muchos a muchos)
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.MensajeAlerta
--   ✅ Constraints:
--      - PK_MensajeAlerta (PRIMARY KEY)
--      - FK_MensajeAlerta_Mensaje (FOREIGN KEY → evalImagen.Mensaje)
--      - FK_MensajeAlerta_Alerta (FOREIGN KEY → evalImagen.Alerta)
--      - UQ_MensajeAlerta_MensajeAlerta (UNIQUE - evita duplicados)
--   ✅ Índices:
--      - IDX_MensajeAlerta_MensajeID (NONCLUSTERED)
--      - IDX_MensajeAlerta_AlertaID (NONCLUSTERED)
--   ✅ Extended Properties:
--      - Documentación de tabla y columnas principales
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: evalImagen.Mensaje (tabla debe existir)
--   ⚠️  Requiere: evalImagen.Alerta (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   8 de 8 - Después de crear evalImagen.Mensaje y evalImagen.Alerta
-- 
-- USADO POR:
--   - Backend: src/services/alertService.ts (mensajes consolidados)
--   - Backend: src/services/resendService.ts (actualizar alertas relacionadas)
-- 
-- NOTA: Esta tabla permite que un mensaje consolidado agrupe múltiples alertas
--       y que una alerta pueda estar en múltiples mensajes (aunque no es común)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear Tabla evalImagen.MensajeAlerta
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.MensajeAlerta') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.MensajeAlerta (
        -- Clave primaria compuesta
        mensajeID INT NOT NULL,
        alertaID INT NOT NULL,
        
        -- Auditoría
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        statusID INT NOT NULL DEFAULT 1,
        
        -- Constraints con nomenclatura estándar Migiva
        CONSTRAINT PK_MensajeAlerta PRIMARY KEY (mensajeID, alertaID),
        CONSTRAINT FK_MensajeAlerta_Mensaje 
            FOREIGN KEY (mensajeID) REFERENCES evalImagen.Mensaje(mensajeID),
        CONSTRAINT FK_MensajeAlerta_Alerta 
            FOREIGN KEY (alertaID) REFERENCES evalImagen.Alerta(alertaID),
        CONSTRAINT UQ_MensajeAlerta_MensajeAlerta 
            UNIQUE (mensajeID, alertaID)
    );
    
    PRINT '[OK] Tabla evalImagen.MensajeAlerta creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.MensajeAlerta ya existe';
END
GO

-- =====================================================
-- Crear Índices
-- =====================================================

-- Índice para búsqueda por mensajeID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_MensajeAlerta_MensajeID' AND object_id = OBJECT_ID('evalImagen.MensajeAlerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_MensajeAlerta_MensajeID 
    ON evalImagen.MensajeAlerta(mensajeID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_MensajeAlerta_MensajeID creado';
END
GO

-- Índice para búsqueda por alertaID
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_MensajeAlerta_AlertaID' AND object_id = OBJECT_ID('evalImagen.MensajeAlerta'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_MensajeAlerta_AlertaID 
    ON evalImagen.MensajeAlerta(alertaID, statusID)
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_MensajeAlerta_AlertaID creado';
END
GO

-- =====================================================
-- Agregar Extended Properties (Documentación)
-- =====================================================

-- Tabla
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Tabla de relación entre Mensaje y Alerta. Permite que un mensaje consolidado agrupe múltiples alertas.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'MensajeAlerta';
GO

-- Columnas
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Foreign Key al mensaje consolidado', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'MensajeAlerta',
    @level2type = N'COLUMN', @level2name = N'mensajeID';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Foreign Key a la alerta incluida en el mensaje', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'MensajeAlerta',
    @level2type = N'COLUMN', @level2name = N'alertaID';
GO

PRINT '[OK] Comentarios extendidos agregados';
GO

PRINT '[✅] Script completado exitosamente';
PRINT '';
PRINT 'Tabla evalImagen.MensajeAlerta creada para mensajes consolidados.';
GO

