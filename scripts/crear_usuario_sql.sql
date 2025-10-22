-- Script para crear usuario SQL Server para la aplicación Next.js
USE AgricolaDB;
GO

-- 1. Habilitar autenticación SQL Server (si no está habilitado)
-- Esto debe hacerse desde SSMS: Server Properties > Security > SQL Server and Windows Authentication mode

-- 2. Crear login SQL Server
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'agricola_app')
BEGIN
    CREATE LOGIN agricola_app WITH PASSWORD = 'Agricola2024!', CHECK_POLICY = OFF;
    PRINT '✅ Login agricola_app creado';
END
ELSE
BEGIN
    PRINT '⚠️  Login agricola_app ya existe';
END
GO

-- 3. Crear usuario en la base de datos
USE AgricolaDB;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'agricola_app')
BEGIN
    CREATE USER agricola_app FOR LOGIN agricola_app;
    PRINT '✅ Usuario agricola_app creado en AgricolaDB';
END
ELSE
BEGIN
    PRINT '⚠️  Usuario agricola_app ya existe en AgricolaDB';
END
GO

-- 4. Otorgar permisos (db_datareader = leer, db_datawriter = escribir)
ALTER ROLE db_datareader ADD MEMBER agricola_app;
ALTER ROLE db_datawriter ADD MEMBER agricola_app;
PRINT '✅ Permisos otorgados a agricola_app';
GO

-- 5. Verificar
SELECT 
    name as Usuario,
    type_desc as Tipo,
    authentication_type_desc as Autenticacion
FROM sys.database_principals 
WHERE name = 'agricola_app';
GO

PRINT '✅ Setup completado!';
PRINT 'Usuario: agricola_app';
PRINT 'Password: Agricola2024!';
GO

