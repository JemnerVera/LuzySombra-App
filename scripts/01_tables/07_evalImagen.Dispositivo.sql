-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.Dispositivo
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Tipo: Tabla
-- Propósito: Almacenar información de dispositivos Android (AgriQR) para autenticación
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.Dispositivo
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere:
--      - Schema evalImagen (ya existe)
-- 
-- ORDEN DE EJECUCIÓN:
--   7 de 10 - Después de todas las otras tablas del schema evalImagen
-- 
-- USADO POR:
--   - Endpoint /api/auth/login (validación de apiKeyHash)
--   - Gestión de dispositivos autorizados
--   - Sistema de activación por QR Code
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
-- 2. Crear Tabla evalImagen.Dispositivo
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.Dispositivo') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.Dispositivo (
        -- Clave primaria
        dispositivoID INT IDENTITY(1,1) NOT NULL,
        
        -- Identificación del dispositivo
        deviceId NVARCHAR(100) NOT NULL,           -- ID único del dispositivo Android
        apiKey NVARCHAR(255) NULL,                 -- API Key en texto plano (DEPRECATED - usar apiKeyHash)
        apiKeyHash NVARCHAR(255) NULL,             -- Hash bcrypt de la API Key para autenticación
        apiKeyPlain NVARCHAR(255) NULL,            -- API Key en texto plano (temporal, para migración)
        nombreDispositivo NVARCHAR(200) NULL,      -- Nombre descriptivo (ej: "Tablet Campo 1")
        
        -- Información del dispositivo
        modeloDispositivo NVARCHAR(100) NULL,      -- Modelo del dispositivo (ej: "Samsung Galaxy Tab")
        versionApp NVARCHAR(50) NULL,              -- Versión de la app instalada
        
        -- Sistema de activación por QR Code
        activationCode NVARCHAR(255) NULL,         -- Código temporal para activación del dispositivo mediante QR Code
        activationCodeExpires DATETIME NULL,      -- Fecha y hora de expiración del código de activación
        operarioNombre NVARCHAR(255) NULL,        -- Nombre del operario asignado al dispositivo
        fechaAsignacion DATETIME NULL,            -- Fecha y hora en que se asignó el dispositivo al operario actual
        fechaRevocacion DATETIME NULL,            -- Fecha y hora en que se revocó el acceso del dispositivo
        
        -- Estado y control
        activo BIT NOT NULL DEFAULT 1,              -- Si el dispositivo está activo (puede hacer login)
        fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
        ultimoAcceso DATETIME NULL,                 -- Última vez que hizo login exitoso
        
        -- Auditoría (según estándares AgroMigiva - LowerCamelCase)
        statusID INT NOT NULL DEFAULT 1,
        usuarioCreaID INT NOT NULL DEFAULT 1,
        fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
        usuarioModificaID INT NULL,
        fechaModificacion DATETIME NULL,
        
        -- Constraints
        CONSTRAINT PK_Dispositivo PRIMARY KEY (dispositivoID),
        CONSTRAINT UQ_Dispositivo_DeviceId UNIQUE (deviceId),
        CONSTRAINT CK_Dispositivo_DeviceId CHECK (LEN(deviceId) >= 3)
    );
    
    PRINT '[OK] Tabla evalImagen.Dispositivo creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.Dispositivo ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices
-- =====================================================

-- Índice para búsqueda rápida por apiKeyHash (usado en login)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Dispositivo_ApiKeyHash' AND object_id = OBJECT_ID('evalImagen.Dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Dispositivo_ApiKeyHash 
    ON evalImagen.Dispositivo(apiKeyHash) 
    WHERE statusID = 1 AND activo = 1 AND apiKeyHash IS NOT NULL;
    PRINT '[OK] Índice IX_Dispositivo_ApiKeyHash creado';
END
GO

-- Índice para búsqueda por deviceId
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Dispositivo_DeviceId' AND object_id = OBJECT_ID('evalImagen.Dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Dispositivo_DeviceId 
    ON evalImagen.Dispositivo(deviceId) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IX_Dispositivo_DeviceId creado';
END
GO

-- Índice para búsqueda rápida por código de activación
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Dispositivo_ActivationCode' AND object_id = OBJECT_ID('evalImagen.Dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Dispositivo_ActivationCode 
    ON evalImagen.Dispositivo(activationCode) 
    WHERE activationCode IS NOT NULL;
    PRINT '[OK] Índice IX_Dispositivo_ActivationCode creado';
END
GO

-- =====================================================
-- 4. Comentarios en Columnas
-- =====================================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'ID único del dispositivo Android (generado por la app)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'deviceId';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'API Key en texto plano (DEPRECATED - usar apiKeyHash). Se eliminará después de la migración completa.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'apiKey';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Hash bcrypt de la API Key para autenticación. Se genera automáticamente al crear/regenerar la API key.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'apiKeyHash';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'API Key en texto plano (temporal, para migración). Se eliminará después de que todos los dispositivos tengan hash.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'apiKeyPlain';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Si el dispositivo está activo y puede hacer login. Si es 0, el dispositivo está deshabilitado.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'activo';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Código temporal para activación del dispositivo mediante QR Code. Se genera al crear el QR y se invalida después de usarse. NULL cuando no hay código activo.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'activationCode';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora de expiración del código de activación. Por defecto, 24 horas después de generarse.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'activationCodeExpires';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre del operario asignado al dispositivo. Permite rastrear quién tiene qué dispositivo para revocación rápida.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'operarioNombre';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora en que se asignó el dispositivo al operario actual.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'fechaAsignacion';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora en que se revocó el acceso del dispositivo. NULL si el acceso no ha sido revocado.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'fechaRevocacion';
GO

PRINT '';
PRINT '========================================';
PRINT 'TABLA evalImagen.Dispositivo CREADA EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'Campos incluidos:';
PRINT '  - Identificación: deviceId, apiKeyHash, apiKey (deprecated), apiKeyPlain (temporal)';
PRINT '  - Activación: activationCode, activationCodeExpires, operarioNombre, fechaAsignacion, fechaRevocacion';
PRINT '  - Estado: activo, fechaRegistro, ultimoAcceso';
PRINT '';
PRINT 'Índices creados:';
PRINT '  - IX_Dispositivo_ApiKeyHash (para login)';
PRINT '  - IX_Dispositivo_DeviceId';
PRINT '  - IX_Dispositivo_ActivationCode (para activación por QR)';
PRINT '';
