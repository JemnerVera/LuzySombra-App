-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.UsuarioWeb
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Tipo: Tabla
-- Propósito: Almacenar usuarios web para autenticación en la aplicación LuzSombra
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.UsuarioWeb
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere:
--      - Schema evalImagen (ya existe)
-- 
-- ORDEN DE EJECUCIÓN:
--   8 de 8 - Después de todas las otras tablas del schema evalImagen
-- 
-- USADO POR:
--   - Endpoint /api/auth/web/login (autenticación de usuarios web)
--   - Sistema de roles y permisos
--   - Protección de rutas en frontend y backend
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- 1. Verificar/Crear Schema evalImagen
-- =====================================================
-- NOTA: El schema evalImagen se crea en 01_evalImagen.AnalisisImagen.sql
-- Este script asume que el schema ya existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'evalImagen')
BEGIN
    EXEC('CREATE SCHEMA evalImagen');
    PRINT '[OK] Schema evalImagen creado';
END
ELSE
BEGIN
    PRINT '[INFO] Schema evalImagen ya existe';
END
GO

-- =====================================================
-- 2. Crear Tabla evalImagen.UsuarioWeb
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.UsuarioWeb') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.UsuarioWeb (
        -- Clave primaria
        usuarioID INT IDENTITY(1,1) NOT NULL,
        
        -- Credenciales de autenticación
        username NVARCHAR(50) NOT NULL,              -- Nombre de usuario (único)
        passwordHash NVARCHAR(255) NOT NULL,        -- Hash bcrypt de la contraseña
        email NVARCHAR(255) NOT NULL,               -- Email del usuario (único)
        
        -- Información personal
        nombreCompleto NVARCHAR(200) NULL,          -- Nombre completo del usuario
        
        -- Rol y permisos
        rol VARCHAR(50) NOT NULL DEFAULT 'Lector',  -- Rol: Admin, Agronomo, Supervisor, Lector
        
        -- Estado y control de acceso
        activo BIT NOT NULL DEFAULT 1,               -- Si el usuario está activo (puede hacer login)
        intentosLogin INT NOT NULL DEFAULT 0,       -- Contador de intentos de login fallidos
        bloqueadoHasta DATETIME NULL,               -- Fecha/hora hasta la cual está bloqueado (por intentos fallidos)
        ultimoAcceso DATETIME NULL,                 -- Última vez que hizo login exitoso
        
        -- Auditoría (según estándares AgroMigiva - LowerCamelCase)
        statusID INT NOT NULL DEFAULT 1,            -- 1 = Activo, 0 = Eliminado (soft delete)
        usuarioCreaID INT NULL,                     -- ID del usuario que creó este registro
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,                 -- ID del usuario que modificó este registro
        fechaModificacion DATETIME NULL,
        
        -- Constraints
        CONSTRAINT PK_UsuarioWeb PRIMARY KEY (usuarioID),
        CONSTRAINT UQ_UsuarioWeb_Username UNIQUE (username),
        CONSTRAINT UQ_UsuarioWeb_Email UNIQUE (email),
        CONSTRAINT CK_UsuarioWeb_Rol CHECK (rol IN ('Admin', 'Agronomo', 'Supervisor', 'Lector')),
        CONSTRAINT CK_UsuarioWeb_Username CHECK (LEN(username) >= 3 AND LEN(username) <= 50),
        CONSTRAINT CK_UsuarioWeb_Email CHECK (
            email LIKE '%_@__%.__%' 
            AND email NOT LIKE '%..%' 
            AND email NOT LIKE '%@%@%' 
            AND LEN(email) > 5
        ),
        CONSTRAINT CK_UsuarioWeb_IntentosLogin CHECK (intentosLogin >= 0 AND intentosLogin <= 10)
    );
    
    PRINT '[OK] Tabla evalImagen.UsuarioWeb creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.UsuarioWeb ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices
-- =====================================================

-- Índice para búsqueda rápida por username (usado en login)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_UsuarioWeb_Username' AND object_id = OBJECT_ID('evalImagen.UsuarioWeb'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_UsuarioWeb_Username 
    ON evalImagen.UsuarioWeb (username) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_UsuarioWeb_Username creado';
END
GO

-- Índice para búsqueda rápida por email
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_UsuarioWeb_Email' AND object_id = OBJECT_ID('evalImagen.UsuarioWeb'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_UsuarioWeb_Email 
    ON evalImagen.UsuarioWeb (email) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_UsuarioWeb_Email creado';
END
GO

-- Índice para búsqueda por rol y estado
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_UsuarioWeb_RolActivo' AND object_id = OBJECT_ID('evalImagen.UsuarioWeb'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_UsuarioWeb_RolActivo 
    ON evalImagen.UsuarioWeb (rol, activo, statusID) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_UsuarioWeb_RolActivo creado';
END
GO

-- =====================================================
-- 4. Agregar Comentarios (Extended Properties)
-- =====================================================

-- Comentario de la tabla
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Tabla para almacenar usuarios web de la aplicación LuzSombra. Gestiona autenticación, roles y permisos.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'UsuarioWeb';
GO

-- Comentarios de columnas importantes
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Nombre de usuario único para login. Mínimo 3 caracteres, máximo 50.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'UsuarioWeb',
    @level2type = N'COLUMN', @level2name = 'username';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Hash bcrypt de la contraseña. Nunca almacenar contraseñas en texto plano.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'UsuarioWeb',
    @level2type = N'COLUMN', @level2name = 'passwordHash';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Rol del usuario: Admin (acceso completo), Agronomo (gestión de umbrales y alertas), Supervisor (ver y resolver alertas), Lector (solo lectura).',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'UsuarioWeb',
    @level2type = N'COLUMN', @level2name = 'rol';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Contador de intentos de login fallidos. Se bloquea automáticamente después de 5 intentos por 15 minutos.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'UsuarioWeb',
    @level2type = N'COLUMN', @level2name = 'intentosLogin';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Fecha/hora hasta la cual el usuario está bloqueado por múltiples intentos fallidos. NULL si no está bloqueado.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'UsuarioWeb',
    @level2type = N'COLUMN', @level2name = 'bloqueadoHasta';
GO

-- =====================================================
-- 5. Verificación
-- =====================================================
PRINT '';
PRINT '=====================================================';
PRINT 'VERIFICACIÓN DE CREACIÓN';
PRINT '=====================================================';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.UsuarioWeb') AND type in (N'U'))
BEGIN
    PRINT '[OK] Tabla evalImagen.UsuarioWeb existe';
    
    -- Contar columnas
    DECLARE @columnCount INT;
    SELECT @columnCount = COUNT(*)
    FROM sys.columns
    WHERE object_id = OBJECT_ID('evalImagen.UsuarioWeb');
    PRINT '[INFO] Columnas creadas: ' + CAST(@columnCount AS VARCHAR(10));
    
    -- Verificar índices
    DECLARE @indexCount INT;
    SELECT @indexCount = COUNT(*)
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('evalImagen.UsuarioWeb')
      AND name LIKE 'IDX_%';
    PRINT '[INFO] Índices creados: ' + CAST(@indexCount AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT '[ERROR] Tabla evalImagen.UsuarioWeb NO existe';
END

PRINT '=====================================================';
PRINT 'SCRIPT COMPLETADO';
PRINT '=====================================================';
GO

