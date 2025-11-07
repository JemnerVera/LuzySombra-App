-- =====================================================
-- SCRIPT: Insertar contacto de prueba para fundo VAL
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Insertar contacto para probar el sistema de alertas con Resend
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  INSERTAR CONTACTO DE PRUEBA - FUNDO VAL';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- Verificar que el fundo VAL existe
DECLARE @FundoID CHAR(4);
SELECT @FundoID = RTRIM(farmID) 
FROM GROWER.FARMS 
WHERE RTRIM(farmID) = 'VAL';

IF @FundoID IS NULL
BEGIN
    PRINT '⚠️ ERROR: No se encontró el fundo VAL en GROWER.FARMS';
    PRINT 'Fundos disponibles:';
    SELECT RTRIM(farmID) AS farmID, Description FROM GROWER.FARMS WHERE statusID = 1 ORDER BY farmID;
    RETURN;
END
ELSE
BEGIN
    PRINT '[OK] Fundo VAL encontrado: ' + @FundoID;
END
GO

-- Insertar contacto
IF NOT EXISTS (SELECT 1 FROM image.Contacto WHERE email = 'jemner.vera@agricolaandrea.com')
BEGIN
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
        'Jemner Vera',
        'jemner.vera@agricolaandrea.com',
        'Admin',
        'VAL',  -- fundoID (CHAR(4), se rellenará con espacios si es necesario)
        1,      -- Recibe alertas críticas
        1,      -- Recibe alertas de advertencia
        0,      -- No recibe alertas normales
        1,      -- Activo
        1       -- StatusID
    );
    
    PRINT '[OK] Contacto insertado exitosamente';
    PRINT '   Nombre: Jemner Vera';
    PRINT '   Email: jemner.vera@agricolaandrea.com';
    PRINT '   Fundo: VAL';
    PRINT '   Tipo: Admin';
END
ELSE
BEGIN
    -- Actualizar contacto existente
    UPDATE image.Contacto
    SET 
        nombre = 'Jemner Vera',
        tipo = 'Admin',
        fundoID = 'VAL',
        recibirAlertasCriticas = 1,
        recibirAlertasAdvertencias = 1,
        recibirAlertasNormales = 0,
        activo = 1,
        statusID = 1,
        fechaActualizacion = GETDATE()
    WHERE email = 'jemner.vera@agricolaandrea.com';
    
    PRINT '[OK] Contacto actualizado exitosamente';
    PRINT '   Email: jemner.vera@agricolaandrea.com';
    PRINT '   Fundo: VAL';
END
GO

-- Verificar contacto insertado
PRINT '';
PRINT '=== Contacto verificado ===';
SELECT 
    contactoID,
    nombre,
    email,
    tipo,
    fundoID,
    sectorID,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    recibirAlertasNormales,
    activo,
    statusID
FROM image.Contacto
WHERE email = 'jemner.vera@agricolaandrea.com';
GO

-- Verificar que recibiría alertas para un lote del fundo VAL
PRINT '';
PRINT '=== Prueba: Contactos que recibirían alertas para lotes del fundo VAL ===';
DECLARE @FundoIDTest CHAR(4) = 'VAL';

SELECT 
    c.contactoID,
    c.nombre,
    c.email,
    c.tipo,
    c.fundoID,
    CASE 
        WHEN c.fundoID IS NULL THEN 'Todos los fundos'
        ELSE 'Fundo específico: ' + RTRIM(c.fundoID)
    END AS filtroFundo
FROM image.Contacto c
WHERE c.activo = 1
  AND c.statusID = 1
  AND (c.recibirAlertasCriticas = 1 OR c.recibirAlertasAdvertencias = 1)
  AND (c.fundoID IS NULL OR RTRIM(c.fundoID) = @FundoIDTest);
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  CONTACTO LISTO PARA PRUEBAS';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'PRÓXIMOS PASOS:';
PRINT '  1. Procesar una imagen para un lote del fundo VAL';
PRINT '  2. Verificar que se genere una alerta en image.Alerta';
PRINT '  3. Llamar a: POST /api/alertas/procesar-mensajes';
PRINT '  4. Verificar que se cree un mensaje en image.Mensaje';
PRINT '  5. Verificar que se envíe el email a jemner.vera@agricolaandrea.com';
PRINT '';
GO



