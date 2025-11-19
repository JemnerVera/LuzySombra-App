-- =====================================================
-- SCRIPT: Insertar Contacto de Prueba - Jemner Vera
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Crear contacto de prueba para recibir alertas
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Verificar si el contacto ya existe
-- =====================================================
IF EXISTS (SELECT 1 FROM image.Contacto WHERE email = 'jemner.vera@agricolaandrea.com' AND statusID = 1)
BEGIN
    PRINT '⚠️ El contacto jemner.vera@agricolaandrea.com ya existe';
    SELECT 
        contactoID,
        nombre,
        email,
        tipo,
        recibirAlertasCriticas,
        recibirAlertasAdvertencias,
        activo
    FROM image.Contacto
    WHERE email = 'jemner.vera@agricolaandrea.com' AND statusID = 1;
END
ELSE
BEGIN
    -- =====================================================
    -- Insertar contacto de prueba
    -- =====================================================
    INSERT INTO image.Contacto (
        nombre,
        email,
        tipo,
        recibirAlertasCriticas,
        recibirAlertasAdvertencias,
        recibirAlertasNormales,
        fundoID,      -- NULL = todos los fundos
        sectorID,     -- NULL = todos los sectores
        activo,
        statusID
    )
    VALUES (
        'Jemner Vera',
        'jemner.vera@agricolaandrea.com',
        'Admin',
        1,  -- Recibe alertas críticas
        1,  -- Recibe alertas de advertencia
        0,  -- NO recibe alertas normales
        NULL, -- Todos los fundos
        NULL, -- Todos los sectores
        1,  -- Activo
        1   -- StatusID
    );

    PRINT '✅ Contacto insertado exitosamente';
    PRINT '';
    PRINT 'Datos del contacto:';
    PRINT '  - Nombre: Jemner Vera';
    PRINT '  - Email: jemner.vera@agricolaandrea.com';
    PRINT '  - Tipo: Admin';
    PRINT '  - Recibe críticas: Sí';
    PRINT '  - Recibe advertencias: Sí';
    PRINT '  - Fundo: Todos';
    PRINT '  - Sector: Todos';
END
GO

-- =====================================================
-- Verificar contacto insertado
-- =====================================================
PRINT '';
PRINT '=== Contacto verificado ===';
SELECT 
    contactoID,
    nombre,
    email,
    tipo,
    CASE WHEN recibirAlertasCriticas = 1 THEN 'Sí' ELSE 'No' END AS Recibe_Criticas,
    CASE WHEN recibirAlertasAdvertencias = 1 THEN 'Sí' ELSE 'No' END AS Recibe_Advertencias,
    CASE WHEN fundoID IS NULL THEN 'Todos' ELSE fundoID END AS Fundo,
    CASE WHEN sectorID IS NULL THEN 'Todos' ELSE CAST(sectorID AS VARCHAR) END AS Sector,
    CASE WHEN activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS Estado
FROM image.Contacto
WHERE email = 'jemner.vera@agricolaandrea.com' AND statusID = 1;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  CONTACTO LISTO PARA RECIBIR ALERTAS';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

