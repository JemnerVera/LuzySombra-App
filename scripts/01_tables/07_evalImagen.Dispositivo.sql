-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.dispositivo
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Servidor: [CONFIGURAR - Reemplazar con IP o hostname de tu servidor SQL]
-- Tipo: Tabla
-- Propósito: Almacenar información de dispositivos Android (AgriQR) para autenticación
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.dispositivo
--   ✅ Índices:
--      - IDX_dispositivo_apiKeyHash_001 (NONCLUSTERED, filtered)
--      - IDX_dispositivo_deviceId_002 (NONCLUSTERED, filtered)
--      - IDX_dispositivo_activationCode_003 (NONCLUSTERED)
--   ✅ Constraints:
--      - PK_dispositivo (PRIMARY KEY)
--      - UQ_dispositivo_deviceId_01 (UNIQUE)
--      - CK_dispositivo_deviceIdMinLen_01 (CHECK)
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
--   7 de 10 - Después de todas las otras tablas del schema evalImagen
-- 
-- USADO POR:
--   - Endpoint /api/auth/login (validación de apiKeyHash)
--   - Gestión de dispositivos autorizados
--   - Sistema de activación por QR Code
-- 
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
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
-- 2. Crear Tabla evalImagen.dispositivo
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.dispositivo') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.dispositivo (
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
        
        -- Constraints (con correlativos según estándar)
        CONSTRAINT PK_dispositivo PRIMARY KEY (dispositivoID),
        CONSTRAINT UQ_dispositivo_deviceId_01 UNIQUE (deviceId),
        CONSTRAINT CK_dispositivo_deviceIdMinLen_01 CHECK (LEN(deviceId) >= 3)
    );
    
    PRINT '[OK] Tabla evalImagen.dispositivo creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.dispositivo ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices (con correlativo)
-- =====================================================

-- Índice para búsqueda rápida por apiKeyHash (usado en login)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_dispositivo_apiKeyHash_001' AND object_id = OBJECT_ID('evalImagen.dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_dispositivo_apiKeyHash_001 
    ON evalImagen.dispositivo(apiKeyHash) 
    WHERE statusID = 1 AND activo = 1 AND apiKeyHash IS NOT NULL;
    PRINT '[OK] Índice IDX_dispositivo_apiKeyHash_001 creado';
END
GO

-- Índice para búsqueda por deviceId
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_dispositivo_deviceId_002' AND object_id = OBJECT_ID('evalImagen.dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_dispositivo_deviceId_002 
    ON evalImagen.dispositivo(deviceId) 
    WHERE statusID = 1;
    PRINT '[OK] Índice IDX_dispositivo_deviceId_002 creado';
END
GO

-- Índice para búsqueda rápida por código de activación
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_dispositivo_activationCode_003' AND object_id = OBJECT_ID('evalImagen.dispositivo'))
BEGIN
    CREATE NONCLUSTERED INDEX IDX_dispositivo_activationCode_003 
    ON evalImagen.dispositivo(activationCode) 
    WHERE activationCode IS NOT NULL;
    PRINT '[OK] Índice IDX_dispositivo_activationCode_003 creado';
END
GO

-- =====================================================
-- 4. Agregar Extended Properties (según estándar)
-- =====================================================

-- Tabla (MS_TablaDescription según estándar)
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.dispositivo') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sys.sp_addextendedproperty 
        @name = N'MS_TablaDescription',
        @value = N'Almacena información de dispositivos Android (AgriQR) para autenticación. Gestiona API keys hasheadas, activación por QR Code y asignación de operarios.',
        @level0type = N'SCHEMA', @level0name = 'evalImagen',
        @level1type = N'TABLE', @level1name = 'dispositivo';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

-- Columnas (MS_ColXDesc según estándar)
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col1Desc', 
    @value = N'ID único del dispositivo Android (generado por la app)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'dispositivo',
    @level2type = N'COLUMN', @level2name = 'deviceId';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col2Desc', 
    @value = N'API Key en texto plano (DEPRECATED - usar apiKeyHash). Se eliminará después de la migración completa.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'dispositivo',
    @level2type = N'COLUMN', @level2name = 'apiKey';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col3Desc', 
    @value = N'Hash bcrypt de la API Key para autenticación. Se genera automáticamente al crear/regenerar la API key.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'dispositivo',
    @level2type = N'COLUMN', @level2name = 'apiKeyHash';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col4Desc', 
    @value = N'Código temporal para activación del dispositivo mediante QR Code. Se genera al crear el QR y se invalida después de usarse. NULL cuando no hay código activo.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'dispositivo',
    @level2type = N'COLUMN', @level2name = 'activationCode';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col5Desc', 
    @value = N'Nombre del operario asignado al dispositivo. Permite rastrear quién tiene qué dispositivo para revocación rápida.', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'dispositivo',
    @level2type = N'COLUMN', @level2name = 'operarioNombre';
GO

PRINT '';
PRINT '========================================';
PRINT 'TABLA evalImagen.dispositivo CREADA EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'Campos incluidos:';
PRINT '  - Identificación: deviceId, apiKeyHash, apiKey (deprecated), apiKeyPlain (temporal)';
PRINT '  - Activación: activationCode, activationCodeExpires, operarioNombre, fechaAsignacion, fechaRevocacion';
PRINT '  - Estado: activo, fechaRegistro, ultimoAcceso';
PRINT '';
PRINT 'Índices creados:';
PRINT '  - IDX_dispositivo_apiKeyHash_001 (para login)';
PRINT '  - IDX_dispositivo_deviceId_002';
PRINT '  - IDX_dispositivo_activationCode_003 (para activación por QR)';
PRINT '';
PRINT '[✅] Script completado según estándares AgroMigiva';
GO
