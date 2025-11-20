-- =====================================================
-- SCRIPT: Insertar Contacto de Prueba para Alertas
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Crear un contacto de prueba para recibir alertas
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Verificar contactos existentes
-- =====================================================
PRINT '=== Contactos existentes ===';
SELECT 
    contactoID,
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    fundoID,
    sectorID,
    activo
FROM image.Contacto
WHERE statusID = 1
ORDER BY nombre;
GO

-- =====================================================
-- Insertar contacto de prueba (descomentar para ejecutar)
-- =====================================================
PRINT '';
PRINT '=== Insertar contacto de prueba ===';
PRINT '';

/*
-- Contacto que recibe TODAS las alertas (todos los fundos y sectores)
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
    'Contacto Prueba Alertas',
    'jemner.vera@agricolaandrea.com',  -- CAMBIAR POR TU EMAIL
    'Admin',
    1,  -- Recibe críticas
    1,  -- Recibe advertencias
    0,  -- NO recibe normales
    NULL, -- Todos los fundos
    NULL, -- Todos los sectores
    1,  -- Activo
    1   -- StatusID
);

PRINT '[OK] Contacto de prueba insertado';
GO
*/

-- =====================================================
-- Verificar contactos después de insertar
-- =====================================================
PRINT '';
PRINT '=== Contactos activos ===';
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
WHERE statusID = 1
ORDER BY nombre;
GO

