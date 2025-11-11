-- =====================================================
-- SCRIPT: Crear Tabla image.Dispositivo
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Tipo: Tabla
-- Propósito: Almacenar información de dispositivos Android (AgriQR) para autenticación
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - image.Dispositivo
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere:
--      - Schema image (ya existe)
-- 
-- ORDEN DE EJECUCIÓN:
--   7 de 7 - Después de todas las otras tablas del schema image
-- 
-- USADO POR:
--   - Endpoint /api/auth/login (validación de apiKey)
--   - Gestión de dispositivos autorizados
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- 1. Verificar/Crear Schema image
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'image')
BEGIN
    EXEC('CREATE SCHEMA image');
    PRINT '[OK] Schema image creado';
END
ELSE
BEGIN
    PRINT '[INFO] Schema image ya existe';
END
GO

-- =====================================================
-- 2. Crear Tabla image.Dispositivo
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.Dispositivo') AND type in (N'U'))
BEGIN
    CREATE TABLE image.Dispositivo (
        -- Clave primaria
        dispositivoID INT IDENTITY(1,1) NOT NULL,
        
        -- Identificación del dispositivo
        deviceId NVARCHAR(100) NOT NULL,           -- ID único del dispositivo Android
        apiKey NVARCHAR(255) NOT NULL,             -- API Key para autenticación (única)
        nombreDispositivo NVARCHAR(200) NULL,      -- Nombre descriptivo (ej: "Tablet Campo 1")
        
        -- Información del dispositivo
        modeloDispositivo NVARCHAR(100) NULL,      -- Modelo del dispositivo (ej: "Samsung Galaxy Tab")
        versionApp NVARCHAR(50) NULL,              -- Versión de la app instalada
        
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
        CONSTRAINT UQ_Dispositivo_ApiKey UNIQUE (apiKey),
        CONSTRAINT CK_Dispositivo_DeviceId CHECK (LEN(deviceId) >= 3),
        CONSTRAINT CK_Dispositivo_ApiKey CHECK (LEN(apiKey) >= 10)
    );
    
    PRINT '[OK] Tabla image.Dispositivo creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla image.Dispositivo ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices
-- =====================================================

-- Índice para búsqueda rápida por apiKey (usado en login)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Dispositivo_ApiKey' AND object_id = OBJECT_ID('image.Dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Dispositivo_ApiKey 
    ON image.Dispositivo(apiKey) 
    WHERE statusID = 1 AND activo = 1;
    PRINT '[OK] Índice IX_Dispositivo_ApiKey creado';
END
GO

-- Índice para búsqueda por deviceId
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Dispositivo_DeviceId' AND object_id = OBJECT_ID('image.Dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Dispositivo_DeviceId 
    ON image.Dispositivo(deviceId) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IX_Dispositivo_DeviceId creado';
END
GO

-- =====================================================
-- 4. Comentarios en Columnas
-- =====================================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'ID único del dispositivo Android (generado por la app)', 
    @level0type = N'SCHEMA', @level0name = 'image',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'deviceId';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'API Key única para autenticación del dispositivo. Se usa junto con deviceId para login.', 
    @level0type = N'SCHEMA', @level0name = 'image',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'apiKey';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Si el dispositivo está activo y puede hacer login. Si es 0, el dispositivo está deshabilitado.', 
    @level0type = N'SCHEMA', @level0name = 'image',
    @level1type = N'TABLE', @level1name = 'Dispositivo',
    @level2type = N'COLUMN', @level2name = 'activo';
GO

PRINT '';
PRINT '========================================';
PRINT 'TABLA image.Dispositivo CREADA EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'Próximos pasos:';
PRINT '1. Insertar dispositivos con: INSERT INTO image.Dispositivo (deviceId, apiKey, nombreDispositivo) VALUES (...)';
PRINT '2. Actualizar el código del backend para consultar esta tabla en lugar de VALID_API_KEYS';
PRINT '';

