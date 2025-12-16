-- =====================================================
-- SCRIPT: Setup Demo - Configurar datos iniciales para demo
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Configurar umbrales y contactos de prueba para demo
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '========================================';
PRINT 'DEMO: Setup inicial - Umbrales y Contactos';
PRINT '========================================';
PRINT '';

-- =====================================================
-- 1. Verificar/Crear Umbrales de Luz
-- =====================================================
PRINT '1. Verificando umbrales de luz...';

-- Verificar si ya existen umbrales
IF NOT EXISTS (SELECT 1 FROM evalImagen.umbralLuz WHERE statusID = 1)
BEGIN
    PRINT '   ⚠️ No se encontraron umbrales. Por favor ejecuta scripts/01_tables/02_evalImagen.umbralLuz.sql primero.';
    PRINT '   O inserta umbrales manualmente.';
END
ELSE
BEGIN
    DECLARE @umbralCount INT;
    SELECT @umbralCount = COUNT(*) FROM evalImagen.umbralLuz WHERE statusID = 1;
    PRINT CONCAT('   ✅ Se encontraron ', @umbralCount, ' umbral(es) activo(s)');
    
    -- Mostrar umbrales existentes
    SELECT 
        umbralID,
        tipo,
        minPorcentajeLuz,
        maxPorcentajeLuz,
        descripcion,
        activo
    FROM evalImagen.umbralLuz
    WHERE statusID = 1
    ORDER BY tipo, orden;
END
GO

-- =====================================================
-- 2. Configurar Contacto para Demo ([TU_EMAIL_DEMO])
-- =====================================================
PRINT '';
PRINT '2. Configurando contacto para demo...';

-- Desactivar contactos de ejemplo anteriores
PRINT '   🧹 Desactivando contactos de ejemplo anteriores...';
UPDATE evalImagen.contacto
SET activo = 0, statusID = 0
WHERE email LIKE '%@example.com'
  AND statusID = 1;

DECLARE @contactosDesactivados INT = @@ROWCOUNT;
IF @contactosDesactivados > 0
    PRINT CONCAT('   ✅ ', @contactosDesactivados, ' contacto(s) de ejemplo desactivado(s)');

-- Obtener fundoID específico para demo
-- IMPORTANTE: farmID es CHAR(4), puede tener espacios, usar RTRIM para comparar
DECLARE @fundoDemoID CHAR(4);

-- Obtener el primer fundo activo disponible
SELECT TOP 1 @fundoDemoID = farmID 
FROM GROWER.FARMS 
WHERE statusID = 1 
ORDER BY farmID;

IF @fundoDemoID IS NULL
BEGIN
    PRINT '   ❌ ERROR: No se encontraron fundos activos.';
    PRINT '   Por favor, ejecuta primero: scripts/08_demo/00_verificar_fundos.sql';
    PRINT '   para ver qué fundos están disponibles.';
    RETURN;
END

-- Limpiar espacios (RTRIM) para mostrar, pero mantener el valor original con espacios si los tiene
DECLARE @fundoDemoIDTrimmed VARCHAR(4) = RTRIM(@fundoDemoID);
PRINT CONCAT('   📍 Usando fundoID: ''', @fundoDemoID, ''' (nombre: ', 
    ISNULL((SELECT Description FROM GROWER.FARMS WHERE farmID = @fundoDemoID), 'N/A'), ')');
PRINT CONCAT('   ⚠️ NOTA: Asegúrate de que las evaluaciones usen lotes de este fundo.');

-- Obtener usuarioCreaID (usar el primero disponible)
DECLARE @usuarioCreaID INT;
SELECT TOP 1 @usuarioCreaID = userID 
FROM MAST.USERS 
WHERE statusID = 1 
ORDER BY userID;

IF @usuarioCreaID IS NULL
    SET @usuarioCreaID = 1; -- Valor por defecto

-- Contacto Principal: Agrónomo Real (recibe todas las alertas del fundo)
-- IMPORTANTE: fundoID es CHAR(4), asegurar que tenga el valor correcto
IF NOT EXISTS (SELECT 1 FROM evalImagen.contacto WHERE email = '[TU_EMAIL_DEMO]' AND statusID = 1)
BEGIN
    INSERT INTO evalImagen.contacto (
        nombre,
        email,
        telefono,
        tipo,
        rol,
        recibirAlertasCriticas,
        recibirAlertasAdvertencias,
        recibirAlertasNormales,
        fundoID,
        sectorID,
        prioridad,
        activo,
        statusID,
        usuarioCreaID,
        fechaCreacion
    ) VALUES (
        'Jemner Vera',
        '[TU_EMAIL_DEMO]',
        NULL, -- Telefono opcional
        'Agronomo',
        'Agrónomo',
        1, -- Recibe críticas
        1, -- Recibe advertencias
        0, -- No recibe normales
        @fundoDemoID, -- FundoID específico (CHAR(4))
        NULL, -- Todos los sectores del fundo
        10, -- Alta prioridad
        1,
        1,
        @usuarioCreaID,
        GETDATE()
    );
    PRINT CONCAT('   ✅ Contacto Agrónomo creado: [TU_EMAIL_DEMO] (fundoID: ', @fundoDemoID, ')');
END
ELSE
BEGIN
    -- Si ya existe, actualizar para asegurar que esté activo y configurado correctamente
    UPDATE evalImagen.contacto
    SET 
        nombre = 'Jemner Vera',
        tipo = 'Agronomo',
        recibirAlertasCriticas = 1,
        recibirAlertasAdvertencias = 1,
        recibirAlertasNormales = 0,
        fundoID = @fundoDemoID, -- Actualizar fundoID
        activo = 1,
        statusID = 1,
        prioridad = 10
    WHERE email = '[TU_EMAIL_DEMO]';
    PRINT CONCAT('   ✅ Contacto Agrónomo actualizado: [TU_EMAIL_DEMO] (fundoID: ', @fundoDemoID, ')');
END

PRINT '';
PRINT '   📧 Contacto configurado para recibir alertas vía Resend API';

PRINT '';
PRINT '========================================';
PRINT '✅ Setup completado';
PRINT '========================================';
PRINT '';
PRINT 'Contacto activo para demo:';
SELECT 
    contactoID,
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    fundoID,
    activo,
    prioridad
FROM evalImagen.contacto
WHERE email = '[TU_EMAIL_DEMO]'
  AND statusID = 1;
PRINT '';
PRINT '⚠️ IMPORTANTE: Asegúrate de tener configurado RESEND_API_KEY en .env';
PRINT '   para que los emails se envíen correctamente.';
GO

