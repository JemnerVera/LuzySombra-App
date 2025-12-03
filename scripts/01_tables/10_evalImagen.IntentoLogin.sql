-- =====================================================
-- SCRIPT: Crear Tabla evalImagen.IntentoLogin
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Servidor: 10.1.10.4
-- Tipo: Tabla
-- Propósito: Registrar intentos de login (exitosos y fallidos) para rate limiting y auditoría
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - evalImagen.IntentoLogin
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
-- 2. Crear Tabla evalImagen.IntentoLogin
-- =====================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.IntentoLogin') AND type in (N'U'))
BEGIN
    CREATE TABLE evalImagen.IntentoLogin (
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
        
        -- Constraints
        CONSTRAINT PK_IntentoLogin PRIMARY KEY (intentoID),
        CONSTRAINT CK_IntentoLogin_DeviceOrUser CHECK (
            (deviceId IS NOT NULL AND username IS NULL) OR 
            (deviceId IS NULL AND username IS NOT NULL)
        )
    );
    
    PRINT '[OK] Tabla evalImagen.IntentoLogin creada';
END
ELSE
BEGIN
    PRINT '[INFO] Tabla evalImagen.IntentoLogin ya existe';
END
GO

-- =====================================================
-- 3. Crear Índices
-- =====================================================

-- Índice para rate limiting por deviceId
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_IntentoLogin_DeviceId_Fecha' 
    AND object_id = OBJECT_ID('evalImagen.IntentoLogin')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_IntentoLogin_DeviceId_Fecha 
    ON evalImagen.IntentoLogin(deviceId, fechaIntento DESC)
    WHERE exitoso = 0;
    
    PRINT '[OK] Índice IX_IntentoLogin_DeviceId_Fecha creado';
END
GO

-- Índice para rate limiting por username
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_IntentoLogin_Username_Fecha' 
    AND object_id = OBJECT_ID('evalImagen.IntentoLogin')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_IntentoLogin_Username_Fecha 
    ON evalImagen.IntentoLogin(username, fechaIntento DESC)
    WHERE exitoso = 0;
    
    PRINT '[OK] Índice IX_IntentoLogin_Username_Fecha creado';
END
GO

-- Índice para rate limiting por IP
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IX_IntentoLogin_IpAddress_Fecha' 
    AND object_id = OBJECT_ID('evalImagen.IntentoLogin')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_IntentoLogin_IpAddress_Fecha 
    ON evalImagen.IntentoLogin(ipAddress, fechaIntento DESC)
    WHERE exitoso = 0;
    
    PRINT '[OK] Índice IX_IntentoLogin_IpAddress_Fecha creado';
END
GO

-- =====================================================
-- 4. Comentarios
-- =====================================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Registra intentos de login (exitosos y fallidos) para rate limiting y auditoría', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'IntentoLogin';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'ID del dispositivo Android (NULL si es usuario web)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'IntentoLogin',
    @level2type = N'COLUMN', @level2name = 'deviceId';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Username del usuario web (NULL si es dispositivo)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'IntentoLogin',
    @level2type = N'COLUMN', @level2name = 'username';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'IP del cliente (IPv4 o IPv6)', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'IntentoLogin',
    @level2type = N'COLUMN', @level2name = 'ipAddress';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'1 = login exitoso, 0 = fallido', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'IntentoLogin',
    @level2type = N'COLUMN', @level2name = 'exitoso';
GO

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Razón del fallo (ej: "Invalid credentials", "Device disabled")', 
    @level0type = N'SCHEMA', @level0name = 'evalImagen',
    @level1type = N'TABLE', @level1name = 'IntentoLogin',
    @level2type = N'COLUMN', @level2name = 'motivoFallo';
GO

PRINT '';
PRINT '========================================';
PRINT 'TABLA evalImagen.IntentoLogin CREADA EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'Índices creados:';
PRINT '  - IX_IntentoLogin_DeviceId_Fecha (rate limiting por dispositivo)';
PRINT '  - IX_IntentoLogin_Username_Fecha (rate limiting por usuario)';
PRINT '  - IX_IntentoLogin_IpAddress_Fecha (rate limiting por IP)';
PRINT '';

