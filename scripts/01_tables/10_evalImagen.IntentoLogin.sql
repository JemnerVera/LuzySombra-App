-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.intentoLogin
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Servidor: [CONFIGURAR - Reemplazar con IP o hostname de tu servidor SQL]
-- Tipo: Tabla
-- Propósito: Registrar intentos de login (exitosos y fallidos) para rate limiting y auditoría
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.intentoLogin
--   ✅ Índices:
--      - IDX_intentoLogin_deviceId_fechaIntento_001 (NONCLUSTERED, filtered)
--      - IDX_intentoLogin_username_fechaIntento_002 (NONCLUSTERED, filtered)
--      - IDX_intentoLogin_ipAddress_fechaIntento_003 (NONCLUSTERED, filtered)
--   ✅ Constraints:
--      - PK_intentoLogin (PRIMARY KEY)
--      - CK_intentoLogin_deviceOrUser_01 (CHECK)
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
--   10 de 10 - Después de todas las otras tablas del schema evalImagen
-- 
-- USADO POR:
--   - Rate limiting en /api/auth/login (dispositivos)
--   - Rate limiting en /api/auth/web/login (usuarios web)
--   - Auditoría de intentos de acceso
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
-- 2. Crear Tabla evalImagen.intentoLogin
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.intentoLogin') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.intentoLogin (
        -- Clave primaria
        intentoID INT IDENTITY(1,1) NOT NULL,
        
        -- Identificación
        deviceId NVARCHAR(100) NULL,              -- ID del dispositivo (NULL si es usuario web)
        username NVARCHAR(100) NULL,              -- Username (NULL si es dispositivo)
        ipAddress NVARCHAR(45) NOT NULL,          -- IP del cliente (IPv4 o IPv6)
        
        -- Resultado
        exitoso BIT NOT NULL,                     -- 1 = login exitoso, 0 = fallido
        motivoFallo NVARCHAR(200) NULL,          -- Razón del fallo (ej: "Invalid credentials", "Device disabled")
        
        -- Timestamp
        fechaIntento DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Constraints (con correlativo según estándar)
        CONSTRAINT PK_intentoLogin PRIMARY KEY (intentoID),
        CONSTRAINT CK_intentoLogin_deviceOrUser_01 CHECK (
            (deviceId IS NOT NULL AND username IS NULL) OR 
            (deviceId IS NULL AND username IS NOT NULL)
        )
    );
    
    PRINT '[OK] Tabla evalImagen.intentoLogin creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.intentoLogin ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices (con correlativo)
-- =====================================================

-- Índice para rate limiting por deviceId
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IDX_intentoLogin_deviceId_fechaIntento_001' 
    AND object_id = OBJECT_ID('evalImagen.intentoLogin')
)
BEGIN
    CREATE NONCLUSTERED INDEX IDX_intentoLogin_deviceId_fechaIntento_001 
    ON evalImagen.intentoLogin(deviceId, fechaIntento DESC)
    WHERE exitoso = 0;
    
    PRINT '[OK] Índice IDX_intentoLogin_deviceId_fechaIntento_001 creado';
END
GO

-- Índice para rate limiting por username
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IDX_intentoLogin_username_fechaIntento_002' 
    AND object_id = OBJECT_ID('evalImagen.intentoLogin')
)
BEGIN
    CREATE NONCLUSTERED INDEX IDX_intentoLogin_username_fechaIntento_002 
    ON evalImagen.intentoLogin(username, fechaIntento DESC)
    WHERE exitoso = 0;
    
    PRINT '[OK] Índice IDX_intentoLogin_username_fechaIntento_002 creado';
END
GO

-- Índice para rate limiting por IP
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IDX_intentoLogin_ipAddress_fechaIntento_003' 
    AND object_id = OBJECT_ID('evalImagen.intentoLogin')
)
BEGIN
    CREATE NONCLUSTERED INDEX IDX_intentoLogin_ipAddress_fechaIntento_003 
    ON evalImagen.intentoLogin(ipAddress, fechaIntento DESC)
    WHERE exitoso = 0;
    
    PRINT '[OK] Índice IDX_intentoLogin_ipAddress_fechaIntento_003 creado';
END
GO

-- =====================================================
-- 4. Agregar Extended Properties (según estándar)
-- =====================================================

-- Tabla (MS_TablaDescription según estándar)
IF NOT EXISTS (
    SELECT * FROM sys.extended_properties 
    WHERE major_id = OBJECT_ID('evalImagen.intentoLogin') 
    AND minor_id = 0 
    AND name = 'MS_TablaDescription'
)
BEGIN
    EXEC sys.sp_addextendedproperty 
        @name = N'MS_TablaDescription', 
        @value = N'Registra intentos de login (exitosos y fallidos) para rate limiting y auditoría', 
        @level0type = N'SCHEMA', @level0name = 'evalImagen',
        @level1type = N'TABLE', @level1name = 'intentoLogin';
    PRINT '[OK] Extended property MS_TablaDescription agregado';
END
GO

-- Columnas (MS_ColXDesc según estándar)
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col1Desc', 
    @value = N'ID del dispositivo Android (NULL si es usuario web)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'intentoLogin',
    @level2type = N'COLUMN', @level2name = 'deviceId';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col2Desc', 
    @value = N'Username del usuario web (NULL si es dispositivo)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'intentoLogin',
    @level2type = N'COLUMN', @level2name = 'username';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col3Desc', 
    @value = N'IP del cliente (IPv4 o IPv6)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'intentoLogin',
    @level2type = N'COLUMN', @level2name = 'ipAddress';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col4Desc', 
    @value = N'1 = login exitoso, 0 = fallido', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'intentoLogin',
    @level2type = N'COLUMN', @level2name = 'exitoso';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Col5Desc', 
    @value = N'Razón del fallo (ej: "Invalid credentials", "Device disabled")', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'intentoLogin',
    @level2type = N'COLUMN', @level2name = 'motivoFallo';
GO

PRINT '';
PRINT '========================================';
PRINT 'TABLA evalImagen.intentoLogin CREADA EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'Índices creados:';
PRINT '  - IDX_intentoLogin_deviceId_fechaIntento_001 (rate limiting por dispositivo)';
PRINT '  - IDX_intentoLogin_username_fechaIntento_002 (rate limiting por usuario)';
PRINT '  - IDX_intentoLogin_ipAddress_fechaIntento_003 (rate limiting por IP)';
PRINT '';
PRINT '[✅] Script completado según estándares AgroMigiva';
GO
