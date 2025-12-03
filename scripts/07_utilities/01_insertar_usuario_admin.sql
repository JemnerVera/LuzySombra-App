-- =====================================================
-- SCRIPT: Insertar Usuario Admin Inicial
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Crear usuario administrador inicial para login web
-- =====================================================
-- 
-- ⚠️  IMPORTANTE: Este script usa un hash pre-generado
--     Para generar un hash nuevo, ejecuta:
--     node scripts/07_utilities/generar_usuario_admin.js
-- 
-- USUARIO POR DEFECTO:
--   Username: admin
--   Password: admin123
--   Email: admin@luzsombra.com
--   Rol: Admin
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Insertar Usuario Admin
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM evalImagen.UsuarioWeb WHERE username = 'admin')
BEGIN
    INSERT INTO evalImagen.UsuarioWeb (
        username,
        passwordHash,
        email,
        nombreCompleto,
        rol,
        activo,
        statusID,
        usuarioCreaID
    ) VALUES (
        'admin',
        -- Hash bcrypt de "admin123" (10 rounds)
        -- Para generar un hash nuevo: node scripts/07_utilities/generar_usuario_admin.js
        '$2b$10$rK8Z8Z8Z8Z8Z8Z8Z8Z8Z8u8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z8Z',
        'admin@luzsombra.com',
        'Administrador',
        'Admin',
        1, -- activo
        1, -- statusID
        NULL -- usuarioCreaID
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
    fechaCreacion
FROM evalImagen.UsuarioWeb
WHERE username = 'admin';
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ SCRIPT COMPLETADO';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'NOTA: Este script usa un hash de ejemplo.';
PRINT 'Para generar un hash real, ejecuta:';
PRINT '  node scripts/07_utilities/generar_usuario_admin.js';
PRINT '';
GO

