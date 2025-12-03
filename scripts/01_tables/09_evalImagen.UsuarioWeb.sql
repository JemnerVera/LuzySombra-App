-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.usuarioWeb
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Tipo: Tabla
-- Propósito: Almacenar usuarios web para autenticación en la aplicación LuzSombra
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.usuarioWeb
--   ✅ Índices:
--      - IDX_usuarioWeb_username_001 (NONCLUSTERED, filtered)
--      - IDX_usuarioWeb_email_002 (NONCLUSTERED, filtered)
--      - IDX_usuarioWeb_rol_activo_statusID_003 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_usuarioWeb (PRIMARY KEY)
--      - UQ_usuarioWeb_username_01 (UNIQUE)
--      - UQ_usuarioWeb_email_02 (UNIQUE)
--      - CK_usuarioWeb_rolValido_01 (CHECK)
--      - CK_usuarioWeb_usernameValido_02 (CHECK)
--      - CK_usuarioWeb_emailValido_03 (CHECK)
--      - CK_usuarioWeb_intentosLoginValido_04 (CHECK)
--   ✅ Extended Properties:
--      - MS_TablaDescription (tabla)
--      - MS_Col1Desc, MS_Col2Desc, etc. (columnas)
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere:
--      - Schema evalImagen (ya existe)
-- 
-- ORDEN DE EJECUCIÓN:
--   9 de 10 - Después de todas las otras tablas del schema evalImagen
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
-- 2. Crear Tabla evalImagen.usuarioWeb
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usuarioWeb') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.usuarioWeb (
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
        
        -- Constraints (con correlativos según estándar)
        CONSTRAINT PK_usuarioWeb PRIMARY KEY (usuarioID),
        CONSTRAINT UQ_usuarioWeb_username_01 UNIQUE (username),
        CONSTRAINT UQ_usuarioWeb_email_02 UNIQUE (email),
        CONSTRAINT CK_usuarioWeb_rolValido_01 CHECK (rol IN ('Admin', 'Agronomo', 'Supervisor', 'Lector')),
        CONSTRAINT CK_usuarioWeb_usernameValido_02 CHECK (LEN(username) >= 3 AND LEN(username) <= 50),
        CONSTRAINT CK_usuarioWeb_emailValido_03 CHECK (
            email LIKE '%_@__%.__%' 
            AND email NOT LIKE '%..%' 
            AND email NOT LIKE '%@%@%' 
            AND LEN(email) > 5
        ),
        CONSTRAINT CK_usuarioWeb_intentosLoginValido_04 CHECK (intentosLogin >= 0 AND intentosLogin <= 10)
    );
    
    PRINT '[OK] Tabla evalImagen.usuarioWeb creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.usuarioWeb ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices (con correlativo)
-- =====================================================

-- Índice para búsqueda rápida por username (usado en login)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_usuarioWeb_username_001' AND object_id = OBJECT_ID('evalImagen.usuarioWeb'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_usuarioWeb_username_001 
    ON evalImagen.usuarioWeb (username) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_usuarioWeb_username_001 creado';
END
GO

-- Índice para búsqueda rápida por email
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_usuarioWeb_email_002' AND object_id = OBJECT_ID('evalImagen.usuarioWeb'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_usuarioWeb_email_002 
    ON evalImagen.usuarioWeb (email) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_usuarioWeb_email_002 creado';
END
GO

-- Índice para búsqueda por rol y estado
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_usuarioWeb_rol_activo_statusID_003' AND object_id = OBJECT_ID('evalImagen.usuarioWeb'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_usuarioWeb_rol_activo_statusID_003 
    ON evalImagen.usuarioWeb (rol, activo, statusID) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_usuarioWeb_rol_activo_statusID_003 creado';
END
GO

-- =====================================================
-- 4. Agregar Extended Properties (según estándar)
-- =====================================================

-- Tabla (MS_TablaDescription según estándar)
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.usuarioWeb') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sys.sp_addextendedproperty 
        @name = N'MS_TablaDescription',
        @value = N'Tabla para almacenar usuarios web de la aplicación LuzSombra. Gestiona autenticación, roles y permisos.',
        @level0type = N'SCHEMA', @level0name = 'evalImagen',
        @level1type = N'TABLE', @level1name = 'usuarioWeb';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

-- Columnas (MS_ColXDesc según estándar)
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col1Desc',
    @value = N'Nombre de usuario único para login. Mínimo 3 caracteres, máximo 50.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'usuarioWeb',
    @level2type = N'COLUMN', @level2name = 'username';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col2Desc',
    @value = N'Hash bcrypt de la contraseña. Nunca almacenar contraseñas en texto plano.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'usuarioWeb',
    @level2type = N'COLUMN', @level2name = 'passwordHash';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col3Desc',
    @value = N'Rol del usuario: Admin (acceso completo), Agronomo (gestión de umbrales y alertas), Supervisor (ver y resolver alertas), Lector (solo lectura).',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'usuarioWeb',
    @level2type = N'COLUMN', @level2name = 'rol';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col4Desc',
    @value = N'Contador de intentos de login fallidos. Se bloquea automáticamente después de 5 intentos por 15 minutos.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'usuarioWeb',
    @level2type = N'COLUMN', @level2name = 'intentosLogin';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col5Desc',
    @value = N'Fecha/hora hasta la cual el usuario está bloqueado por múltiples intentos fallidos. NULL si no está bloqueado.',
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'usuarioWeb',
    @level2type = N'COLUMN', @level2name = 'bloqueadoHasta';
GO

PRINT '';
PRINT '=====================================================';
PRINT 'VERIFICACIÓN DE CREACIÓN';
PRINT '=====================================================';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.usuarioWeb') AND type in (N'U'))
BEGIN
    PRINT '[OK] Tabla evalImagen.usuarioWeb existe';
    
    -- Contar columnas
    DECLARE @columnCount INT;
    SELECT @columnCount = COUNT(*)
    FROM sys.columns
    WHERE object_id = OBJECT_ID('evalImagen.usuarioWeb');
    PRINT '[INFO] Columnas creadas: ' + CAST(@columnCount AS VARCHAR(10));
    
    -- Verificar índices
    DECLARE @indexCount INT;
    SELECT @indexCount = COUNT(*)
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('evalImagen.usuarioWeb')
      AND name LIKE 'IDX_%';
    PRINT '[INFO] Índices creados: ' + CAST(@indexCount AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT '[ERROR] Tabla evalImagen.usuarioWeb NO existe';
END

PRINT '=====================================================';
PRINT 'SCRIPT COMPLETADO';
PRINT '[✅] Tabla evalImagen.usuarioWeb creada según estándares AgroMigiva';
PRINT '=====================================================';
GO
