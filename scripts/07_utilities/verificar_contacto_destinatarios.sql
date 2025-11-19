-- =====================================================
-- SCRIPT: Verificar Contacto y Destinatarios
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Verificar por qué no se encuentran destinatarios
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Verificar contacto actual
-- =====================================================
PRINT '=== Contacto actual ===';
SELECT 
    contactoID,
    nombre,
    email,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    fundoID,
    sectorID,
    activo,
    statusID
FROM image.Contacto
WHERE email = 'jemner.vera@agricolaandrea.com';
GO

-- =====================================================
-- Simular query que hace el código para fundo 'CAL'
-- =====================================================
PRINT '';
PRINT '=== Query para fundo CAL (CriticoRojo) ===';
SELECT 
    c.nombre,
    c.email,
    c.recibirAlertasCriticas,
    c.fundoID,
    CASE 
        WHEN c.fundoID IS NULL THEN 'NULL (todos los fundos)'
        ELSE 'Específico: ' + RTRIM(c.fundoID)
    END AS fundoID_desc
FROM image.Contacto c
WHERE c.activo = 1
  AND c.statusID = 1
  AND c.recibirAlertasCriticas = 1
  AND (c.fundoID IS NULL OR RTRIM(c.fundoID) = 'CAL');
GO

-- =====================================================
-- Simular query que hace el código para fundo 'VAL'
-- =====================================================
PRINT '';
PRINT '=== Query para fundo VAL (CriticoAmarillo) ===';
SELECT 
    c.nombre,
    c.email,
    c.recibirAlertasAdvertencias,
    c.fundoID,
    CASE 
        WHEN c.fundoID IS NULL THEN 'NULL (todos los fundos)'
        ELSE 'Específico: ' + RTRIM(c.fundoID)
    END AS fundoID_desc
FROM image.Contacto c
WHERE c.activo = 1
  AND c.statusID = 1
  AND c.recibirAlertasAdvertencias = 1
  AND (c.fundoID IS NULL OR RTRIM(c.fundoID) = 'VAL');
GO

-- =====================================================
-- Verificar si el contacto debería recibir alertas de ambos fundos
-- =====================================================
PRINT '';
PRINT '=== ¿El contacto debería recibir alertas? ===';
SELECT 
    'CAL' AS fundo,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM image.Contacto c
            WHERE c.email = 'jemner.vera@agricolaandrea.com'
              AND c.activo = 1
              AND c.statusID = 1
              AND c.recibirAlertasCriticas = 1
              AND (c.fundoID IS NULL OR RTRIM(c.fundoID) = 'CAL')
        ) THEN '✅ SÍ'
        ELSE '❌ NO'
    END AS deberia_recibir
UNION ALL
SELECT 
    'VAL' AS fundo,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM image.Contacto c
            WHERE c.email = 'jemner.vera@agricolaandrea.com'
              AND c.activo = 1
              AND c.statusID = 1
              AND c.recibirAlertasAdvertencias = 1
              AND (c.fundoID IS NULL OR RTRIM(c.fundoID) = 'VAL')
        ) THEN '✅ SÍ'
        ELSE '❌ NO'
    END AS deberia_recibir;
GO

