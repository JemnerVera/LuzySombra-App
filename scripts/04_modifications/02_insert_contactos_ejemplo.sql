-- =====================================================
-- SCRIPT: Ejemplos de inserción de contactos
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Ejemplos de cómo insertar contactos en image.Contacto
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ❌ Ninguno
-- 
-- OBJETOS MODIFICADOS:
--   ⚠️  Tablas (al ejecutar):
--      - image.Contacto (INSERT)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.Contacto (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear image.Contacto
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  EJEMPLOS DE INSERCIÓN DE CONTACTOS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- Ejemplo 1: Contacto que recibe TODAS las alertas
-- =====================================================
PRINT '=== Ejemplo 1: Contacto que recibe todas las alertas ===';
PRINT '';

-- Descomentar para ejecutar
/*
INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    recibirAlertasNormales,
    activo,
    statusID
)
VALUES (
    'Administrador General',
    'admin@example.com',
    'Admin',
    1,  -- Recibe críticas
    1,  -- Recibe advertencias
    0,  -- No recibe normales
    1,  -- Activo
    1   -- StatusID
);
PRINT '[OK] Contacto administrador insertado';
GO
*/

-- =====================================================
-- Ejemplo 2: Contacto que solo recibe alertas CRÍTICAS
-- =====================================================
PRINT '';
PRINT '=== Ejemplo 2: Contacto que solo recibe alertas críticas ===';
PRINT '';

-- Descomentar para ejecutar
/*
INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    recibirAlertasNormales,
    activo,
    statusID
)
VALUES (
    'Gerente General',
    'gerente@example.com',
    'Manager',
    1,  -- Recibe críticas
    0,  -- NO recibe advertencias
    0,  -- No recibe normales
    1,  -- Activo
    1   -- StatusID
);
PRINT '[OK] Contacto gerente insertado';
GO
*/

-- =====================================================
-- Ejemplo 3: Contacto para un FUNDO específico
-- =====================================================
PRINT '';
PRINT '=== Ejemplo 3: Contacto para un fundo específico ===';
PRINT '';

-- Descomentar para ejecutar (cambiar fundoID por el ID real)
/*
-- Primero verificar los fundos disponibles:
SELECT farmID, Description FROM GROWER.FARMS WHERE statusID = 1 ORDER BY Description;
GO

INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    fundoID,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    recibirAlertasNormales,
    activo,
    statusID
)
VALUES (
    'Agrónomo del Fundo X',
    'agronomo.fundo@example.com',
    'Agronomo',
    'F001',  -- ID del fundo (CHAR(4), cambiar por el ID real)
    1,       -- Recibe críticas
    1,       -- Recibe advertencias
    0,       -- No recibe normales
    1,       -- Activo
    1        -- StatusID
);
PRINT '[OK] Contacto del fundo insertado';
GO
*/

-- =====================================================
-- Ejemplo 4: Múltiples contactos
-- =====================================================
PRINT '';
PRINT '=== Ejemplo 4: Insertar múltiples contactos ===';
PRINT '';

-- Descomentar para ejecutar
/*
INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    recibirAlertasNormales,
    activo,
    statusID
)
VALUES 
    ('Juan Pérez', 'juan.perez@example.com', 'Agronomo', 1, 1, 0, 1, 1),
    ('María García', 'maria.garcia@example.com', 'Supervisor', 1, 0, 0, 1, 1),
    ('Carlos López', 'carlos.lopez@example.com', 'Tecnico', 1, 1, 1, 1, 1),
    ('Ana Martínez', 'ana.martinez@example.com', 'Manager', 1, 1, 0, 1, 1);

PRINT '[OK] 4 contactos insertados';
GO
*/

-- =====================================================
-- Ejemplo 5: Contacto con prioridad alta
-- =====================================================
PRINT '';
PRINT '=== Ejemplo 5: Contacto con prioridad alta ===';
PRINT '';

-- Descomentar para ejecutar
/*
INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    prioridad,
    activo,
    statusID
)
VALUES (
    'Director de Operaciones',
    'director@example.com',
    'Admin',
    1,  -- Recibe críticas
    1,  -- Recibe advertencias
    10, -- Prioridad alta (aparecerá primero en la lista)
    1,  -- Activo
    1   -- StatusID
);
PRINT '[OK] Contacto con prioridad alta insertado';
GO
*/

-- =====================================================
-- Verificar contactos insertados
-- =====================================================
PRINT '';
PRINT '=== Verificar contactos activos ===';
PRINT '';

SELECT 
    contactoID,
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    recibirAlertasNormales,
    CASE 
        WHEN variedadID IS NULL THEN 'Todas'
        ELSE CAST(variedadID AS VARCHAR)
    END AS variedadID,
    prioridad,
    activo
FROM image.Contacto
WHERE statusID = 1
ORDER BY prioridad DESC, nombre ASC;
GO

-- =====================================================
-- Consultar contactos que recibirían una alerta específica
-- =====================================================
PRINT '';
PRINT '=== Ejemplo: Contactos que recibirían una alerta CriticoAmarillo de un lote específico ===';
PRINT '';

DECLARE @TipoUmbral VARCHAR(20) = 'CriticoAmarillo';
DECLARE @LotID INT = 1022;  -- Cambiar por el lotID real

-- Obtener fundoID y sectorID del lote
DECLARE @FundoID CHAR(4);
DECLARE @SectorID INT;

SELECT 
    @FundoID = f.farmID,
    @SectorID = s.stageID
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE l.lotID = @LotID;

IF @FundoID IS NULL
BEGIN
    PRINT '⚠️ No se encontró el lote ' + CAST(@LotID AS VARCHAR);
END
ELSE
BEGIN
    PRINT 'Lote: ' + CAST(@LotID AS VARCHAR);
    PRINT 'FundoID: ' + CAST(@FundoID AS VARCHAR);
    PRINT 'SectorID: ' + CAST(@SectorID AS VARCHAR);
    PRINT '';
    
    SELECT 
        c.contactoID,
        c.nombre,
        c.email,
        c.tipo,
        CASE 
            WHEN c.fundoID IS NULL THEN 'Todos los fundos'
            ELSE 'Fundo específico: ' + CAST(c.fundoID AS VARCHAR)
        END AS filtroFundo,
        CASE 
            WHEN c.sectorID IS NULL THEN 'Todos los sectores'
            ELSE 'Sector específico: ' + CAST(c.sectorID AS VARCHAR)
        END AS filtroSector
    FROM image.Contacto c
    WHERE c.activo = 1
      AND c.statusID = 1
      AND c.recibirAlertasAdvertencias = 1
      AND (c.fundoID IS NULL OR c.fundoID = @FundoID)
      AND (c.sectorID IS NULL OR c.sectorID = @SectorID)
    ORDER BY c.prioridad DESC, c.nombre ASC;
END
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  FIN DE EJEMPLOS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'NOTAS:';
PRINT '  - Los contactos con fundoID = NULL reciben alertas de TODOS los fundos';
PRINT '  - Los contactos con fundoID específico solo reciben alertas de lotes de ese fundo';
PRINT '  - Los contactos con sectorID específico solo reciben alertas de lotes de ese sector';
PRINT '  - Si un contacto tiene sectorID NULL pero fundoID específico, recibe de todos los sectores de ese fundo';
PRINT '  - El match se hace automáticamente: alerta (lotID) → fundo → contactos con ese fundoID (o NULL)';
PRINT '  - Puedes desactivar un contacto cambiando activo = 0 (no se elimina)';
PRINT '  - La prioridad determina el orden de los destinatarios (mayor = primero)';
PRINT '';
GO

