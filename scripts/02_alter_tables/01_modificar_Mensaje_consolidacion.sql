-- =====================================================
-- SCRIPT: Modificar image.Mensaje para Consolidación
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Propósito: Permitir mensajes consolidados (sin alertaID único)
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  MODIFICANDO image.Mensaje PARA CONSOLIDACIÓN';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '';

-- =====================================================
-- Paso 1: Verificar estructura actual
-- =====================================================
PRINT '=== Paso 1: Estructura actual de image.Mensaje ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'image'
  AND TABLE_NAME = 'Mensaje'
ORDER BY ORDINAL_POSITION;
GO

-- =====================================================
-- Paso 2: Eliminar FK si existe (porque alertaID será NULL)
-- =====================================================
PRINT '';
PRINT '=== Paso 2: Eliminando FK_Mensaje_Alerta ===';
IF EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE name = 'FK_Mensaje_Alerta' 
    AND parent_object_id = OBJECT_ID('image.Mensaje')
)
BEGIN
    ALTER TABLE image.Mensaje
    DROP CONSTRAINT FK_Mensaje_Alerta;
    PRINT '✅ FK_Mensaje_Alerta eliminada';
END
ELSE
BEGIN
    PRINT 'ℹ️ FK_Mensaje_Alerta no existe';
END
GO

-- =====================================================
-- Paso 3: Hacer alertaID NULL (para mensajes consolidados)
-- =====================================================
PRINT '';
PRINT '=== Paso 3: Haciendo alertaID NULL ===';
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'image'
      AND TABLE_NAME = 'Mensaje'
      AND COLUMN_NAME = 'alertaID'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    ALTER TABLE image.Mensaje
    ALTER COLUMN alertaID INT NULL;
    PRINT '✅ alertaID ahora permite NULL';
END
ELSE
BEGIN
    PRINT 'ℹ️ alertaID ya permite NULL o no existe';
END
GO

-- =====================================================
-- Paso 4: Agregar fundoID si no existe
-- =====================================================
PRINT '';
PRINT '=== Paso 4: Agregando fundoID ===';
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'image'
      AND TABLE_NAME = 'Mensaje'
      AND COLUMN_NAME = 'fundoID'
)
BEGIN
    ALTER TABLE image.Mensaje
    ADD fundoID CHAR(4) NULL;
    PRINT '✅ fundoID agregado';
END
ELSE
BEGIN
    PRINT 'ℹ️ fundoID ya existe';
END
GO

-- =====================================================
-- Paso 5: Agregar índice para fundoID (optimización)
-- =====================================================
PRINT '';
PRINT '=== Paso 5: Agregando índice para fundoID ===';
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'IDX_Mensaje_FundoID' 
    AND object_id = OBJECT_ID('image.Mensaje')
)
BEGIN
    CREATE NONCLUSTERED INDEX IDX_Mensaje_FundoID
    ON image.Mensaje(fundoID, estado, statusID)
    WHERE statusID = 1;
    PRINT '✅ Índice IDX_Mensaje_FundoID creado';
END
ELSE
BEGIN
    PRINT 'ℹ️ Índice IDX_Mensaje_FundoID ya existe';
END
GO

-- =====================================================
-- Paso 6: Verificar estructura final
-- =====================================================
PRINT '';
PRINT '=== Paso 6: Estructura final de image.Mensaje ===';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'image'
  AND TABLE_NAME = 'Mensaje'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════';
PRINT '  ✅ MODIFICACIÓN COMPLETADA';
PRINT '  Ahora image.Mensaje soporta:';
PRINT '  - alertaID NULL (mensajes consolidados)';
PRINT '  - fundoID (identificación del fundo)';
PRINT '═══════════════════════════════════════════════════════════════════';
GO

