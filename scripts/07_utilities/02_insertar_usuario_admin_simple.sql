-- =====================================================
-- SCRIPT: Insertar Usuario Admin Inicial
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Crear usuario administrador inicial para login web
-- =====================================================
-- 
-- ⚠️  IMPORTANTE: Este script usa un hash de ejemplo
--     Para generar un hash real de tu contraseña:
--     1. Ejecuta: cd backend
--     2. Ejecuta: npx ts-node ../scripts/07_utilities/generar_usuario_admin.ts [username] [password] [email] [nombre] [rol]
--     3. Copia el hash generado y reemplázalo en este script
-- 
-- USUARIO POR DEFECTO (hash de "admin123"):
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
        -- ⚠️  REEMPLAZA ESTE HASH con uno generado por el script Node.js
        -- Para generar: cd backend && npx ts-node ../scripts/07_utilities/generar_usuario_admin.ts admin admin123
        '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
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
    PRINT '';
    PRINT 'Para actualizar la contraseña, ejecuta:';
    PRINT '  UPDATE evalImagen.UsuarioWeb';
    PRINT '  SET passwordHash = ''[NUEVO_HASH_AQUI]''';
    PRINT '  WHERE username = ''admin'';';
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
PRINT 'NOTA: Este script incluye un hash pre-generado de "admin123".';
PRINT 'Para generar un hash personalizado, ejecuta:';
PRINT '  cd backend';
PRINT '  npx ts-node ../scripts/07_utilities/generar_usuario_admin.ts [username] [password] [email] [nombre] [rol]';
PRINT '';
GO

