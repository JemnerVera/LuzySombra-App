-- =====================================================
-- SCRIPT: Migración - Añadir columna modeloDispositivo
-- Schema: evalImagen
-- Tabla: analisisImagen
-- Propósito: Almacenar el origen del procesamiento (Burro, AgriQR, WebApp)
-- =====================================================

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'evalImagen.analisisImagen') 
    AND name = 'modeloDispositivo'
)
BEGIN
    ALTER TABLE evalImagen.analisisImagen 
    ADD modeloDispositivo NVARCHAR(100) NULL;
    
    PRINT '[OK] Columna modeloDispositivo añadida a evalImagen.analisisImagen';
    
    -- Actualizar registros existentes si es necesario
    EXEC('UPDATE evalImagen.analisisImagen SET modeloDispositivo = ''Migración'' WHERE modeloDispositivo IS NULL');
END
ELSE
BEGIN
    PRINT '[INFO] La columna modeloDispositivo ya existe en evalImagen.analisisImagen';
END
GO

-- Documentar la columna
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'evalImagen.analisisImagen') AND name = 'modeloDispositivo')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.extended_properties 
        WHERE major_id = OBJECT_ID('evalImagen.analisisImagen') 
        AND minor_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID('evalImagen.analisisImagen') AND name = 'modeloDispositivo')
        AND name = 'MS_Description'
    )
    BEGIN
        EXEC sp_addextendedproperty 
            @name = N'MS_Description', 
            @value = N'Indica el dispositivo o medio desde el cual se originó el procesamiento (Burro, AgriQR, WebApp)', 
            @level0type = N'SCHEMA', @level0name = N'evalImagen',
            @level1type = N'TABLE', @level1name = N'analisisImagen',
            @level2type = N'COLUMN', @level2name = N'modeloDispositivo';
        PRINT '[OK] Propiedad extendida añadida a modeloDispositivo';
    END
END
GO
