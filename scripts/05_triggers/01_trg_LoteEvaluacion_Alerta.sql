-- =====================================================
-- SCRIPT: Crear Trigger trg_LoteEvaluacion_Alerta
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: image
-- Propósito: Crear alertas automáticamente cuando cambia tipoUmbralActual en LoteEvaluacion
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Triggers:
--      - image.trg_LoteEvaluacion_Alerta
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas (al ejecutarse):
--      - image.Alerta (INSERT cuando cambia umbral)
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: image.LoteEvaluacion (tabla debe existir)
--   ⚠️  Requiere: image.Alerta (tabla debe existir)
--   ⚠️  Requiere: image.UmbralLuz (tabla debe existir)
-- 
-- ORDEN DE EJECUCIÓN:
--   Después de crear image.LoteEvaluacion y image.Alerta
-- 
-- LÓGICA:
--   - Se ejecuta AFTER INSERT, UPDATE en image.LoteEvaluacion
--   - SOLO crea alerta si tipoUmbralActual es CriticoRojo o CriticoAmarillo
--   - NO crea alerta si tipoUmbralActual es 'Normal' o NULL
--   - Crea alerta si NO existe una alerta Pendiente/Enviada del mismo tipo (evita duplicados)
--   - Funciona tanto para INSERT (primera vez) como UPDATE (incluso si el tipo no cambió)
--   - Resuelve alertas cuando vuelve a Normal (solo en UPDATE)
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear Trigger
-- =====================================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_LoteEvaluacion_Alerta' AND parent_id = OBJECT_ID('image.LoteEvaluacion'))
    DROP TRIGGER image.trg_LoteEvaluacion_Alerta;
GO

CREATE TRIGGER image.trg_LoteEvaluacion_Alerta
ON image.LoteEvaluacion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Crear alertas SOLO cuando tipoUmbralActual es CriticoRojo o CriticoAmarillo
    -- IMPORTANTE: NO se crean alertas cuando tipoUmbralActual es 'Normal'
    -- Maneja tanto INSERT (primera vez) como UPDATE (cambio de estado)
    INSERT INTO image.Alerta (
        lotID, 
        loteEvaluacionID, 
        umbralID, 
        variedadID,
        porcentajeLuzEvaluado, 
        tipoUmbral, 
        severidad, 
        estado,
        fechaCreacion,
        statusID
    )
    SELECT 
        i.lotID,
        i.loteEvaluacionID,
        i.umbralIDActual,
        i.variedadID,
        i.porcentajeLuzPromedio,
        i.tipoUmbralActual,
        CASE 
            WHEN i.tipoUmbralActual = 'CriticoRojo' THEN 'Critica'
            WHEN i.tipoUmbralActual = 'CriticoAmarillo' THEN 'Advertencia'
            ELSE 'Info'  -- No debería llegar aquí porque el WHERE filtra, pero por seguridad
        END AS severidad,
        'Pendiente' AS estado,
        GETDATE() AS fechaCreacion,
        1 AS statusID
    FROM inserted i
    LEFT JOIN deleted d ON i.lotID = d.lotID  -- LEFT JOIN para manejar INSERT (d será NULL)
    WHERE 
        -- VALIDACIÓN CRÍTICA: Solo crear alerta si tipoUmbralActual es CriticoRojo o CriticoAmarillo
        -- NO crear alerta si tipoUmbralActual es 'Normal' o NULL
        i.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo')
        AND i.tipoUmbralActual IS NOT NULL  -- Asegurar que no sea NULL
        AND i.tipoUmbralActual != 'Normal'  -- Validación explícita adicional
        AND i.statusID = 1
        -- Crear alerta si NO existe una alerta Pendiente/Enviada del mismo tipo
        -- (Esto cubre tanto INSERT como UPDATE, incluso si el tipo no cambió)
        -- La lógica es: si el tipoUmbralActual es crítico y no hay alerta activa pendiente/enviada, crear alerta
        AND NOT EXISTS (
            SELECT 1 
            FROM image.Alerta a 
            WHERE a.lotID = i.lotID 
              AND a.tipoUmbral = i.tipoUmbralActual
              AND a.estado IN ('Pendiente', 'Enviada')
              AND a.statusID = 1
        );
    
    -- Resolver alertas cuando vuelve a Normal (solo en UPDATE, no en INSERT)
    -- Solo se ejecuta si hay registros en deleted (es decir, es un UPDATE)
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        UPDATE a
        SET 
            estado = 'Resuelta',
            fechaResolucion = GETDATE()
        FROM image.Alerta a
        INNER JOIN inserted i ON a.lotID = i.lotID
        INNER JOIN deleted d ON i.lotID = d.lotID
        WHERE 
            -- Cambió a Normal
            i.tipoUmbralActual = 'Normal'
            AND i.statusID = 1
            -- Y había una alerta Pendiente o Enviada
            AND a.estado IN ('Pendiente', 'Enviada')
            AND a.statusID = 1
            -- Y antes no era Normal (o era NULL)
            AND (d.tipoUmbralActual IS NULL OR d.tipoUmbralActual != 'Normal');
    END;
END;
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Trigger que crea alertas automáticamente cuando tipoUmbralActual cambia a CriticoRojo o CriticoAmarillo en image.LoteEvaluacion. También resuelve alertas cuando vuelve a Normal.', 
    @level0type = N'SCHEMA', @level0name = N'image',
    @level1type = N'TABLE', @level1name = N'LoteEvaluacion',
    @level2type = N'TRIGGER', @level2name = N'trg_LoteEvaluacion_Alerta';
GO

PRINT '';
PRINT '✅ Trigger image.trg_LoteEvaluacion_Alerta creado exitosamente';
PRINT '';
PRINT 'Funcionalidad:';
PRINT '  - Crea alerta SOLO cuando tipoUmbralActual es CriticoRojo/CriticoAmarillo';
PRINT '  - NO crea alerta cuando tipoUmbralActual es Normal (solo se resuelven alertas existentes)';
PRINT '  - Funciona tanto para INSERT (primera vez) como UPDATE (incluso si el tipo no cambió)';
PRINT '  - No crea alertas duplicadas (verifica si ya existe Pendiente/Enviada del mismo tipo)';
PRINT '  - Resuelve alertas cuando tipoUmbralActual vuelve a Normal (solo en UPDATE)';
GO

