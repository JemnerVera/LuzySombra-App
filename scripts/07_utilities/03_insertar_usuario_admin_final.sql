-- =====================================================
-- SCRIPT: Insertar Usuario Admin Inicial
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Crear usuario administrador inicial para login web
-- =====================================================
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: evalImagen.usuarioWeb (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear evalImagen.usuarioWeb
--
-- 
-- USUARIO POR DEFECTO:
--   Username: admin
--   Password: admin123
--   Email: admin@luzsombra.com
--   Rol: Admin
-- 
-- ⚠️  IMPORTANTE: Cambia la contraseña después del primer login
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Insertar Usuario Admin
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM evalImagen.usuarioWeb WHERE username = 'admin')
BEGIN
    INSERT INTO evalImagen.usuarioWeb (
        username,
        passwordHash,
        email,
        nombreCompleto,
        rol,
        activo,
        intentosLogin,
        bloqueadoHasta,
        ultimoAcceso,
        statusID,
        usuarioCreaID,
        fechaCreacion,
        usuarioModificaID,
        fechaModificacion
    ) VALUES (
        'admin',
        -- Hash bcrypt de "admin123" (10 rounds)
        '$2b$10$hgH.sCRoazQ4/yuyBDQzDuh2d/MGXClg91u.vJ1AiBMtIPKmC6a.W',
        'admin@luzsombra.com',
        'Administrador',
        'Admin',
        1, -- activo
        0, -- intentosLogin (inicial)
        NULL, -- bloqueadoHasta (no bloqueado)
        NULL, -- ultimoAcceso (primer login)
        1, -- statusID
        NULL, -- usuarioCreaID (usuario inicial)
        GETDATE(), -- fechaCreacion
        NULL, -- usuarioModificaID
        NULL -- fechaModificacion
    );
    
    PRINT '✅ Usuario admin creado exitosamente';
    PRINT '';
    PRINT 'Credenciales:';
    PRINT '  Username: admin';
    PRINT '  Password: admin123';
    PRINT '';
    PRINT '⚠️  IMPORTANTE: Cambia la contraseña después del primer login';
END
ELSE
BEGIN
    PRINT '⚠️  Usuario admin ya existe';
    PRINT '';
    PRINT 'Para actualizar la contraseña, ejecuta:';
    PRINT '  UPDATE evalImagen.usuarioWeb';
    PRINT '  SET passwordHash = ''[NUEVO_HASH_AQUI]'',';
    PRINT '      fechaModificacion = GETDATE()';
    PRINT '  WHERE username = ''admin'';';
    PRINT '';
    PRINT 'Para generar un nuevo hash, ejecuta:';
    PRINT '  cd backend';
    PRINT '  node scripts/generar_hash_password.js [nueva_password]';
END
GO

-- =====================================================
-- Verificar Usuario Creado
-- =====================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  USUARIO CREADO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

SELECT 
    usuarioID,
    username,
    email,
    nombreCompleto,
    rol,
    activo,
    intentosLogin,
    bloqueadoHasta,
    ultimoAcceso,
    statusID,
    fechaCreacion,
    fechaModificacion
FROM evalImagen.usuarioWeb
WHERE username = 'admin';
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ SCRIPT COMPLETADO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
GO

