-- =====================================================
-- SCRIPT: Crear Stored Procedure evalImagen.sp_GetFieldData
-- Base de datos: BD_PACKING_AGROMIGIVA_DESA
-- Schema: evalImagen
-- Propósito: Obtener datos jerárquicos de empresas, fundos, sectores y lotes
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Stored Procedures:
--      - evalImagen.sp_GetFieldData
--   ✅ Extended Properties:
--      - Documentación de stored procedure
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: Schema evalImagen (debe existir)
--   ⚠️  Requiere: GROWER.LOT, GROWER.STAGE, GROWER.FARMS, GROWER.GROWERS (tablas existentes)
-- 
-- ORDEN DE EJECUCIÓN:
--   Puede ejecutarse en cualquier momento
-- 
-- USADO POR:
--   - Backend: src/services/sqlServerService.ts (getFieldData)
--   - Frontend: hooks/useFieldData.ts (carga datos para filtros)
-- 
-- PARÁMETROS:
--   Ninguno
-- 
-- RETORNO:
--   ResultSet con columnas:
--     - empresa VARCHAR(100) - Nombre de la empresa
--     - fundo VARCHAR(100) - Nombre del fundo
--     - sector VARCHAR(100) - Nombre del sector
--     - lote VARCHAR(100) - Nombre del lote
--     - growerID VARCHAR(10) - ID de la empresa
--     - farmID CHAR(4) - ID del fundo
--     - stageID INT - ID del sector
--     - lotID INT - ID del lote
-- 
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- =====================================================
-- Crear Stored Procedure
-- =====================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'evalImagen.sp_GetFieldData') AND type in (N'P', N'PC'))
    DROP PROCEDURE evalImagen.sp_GetFieldData;
GO

CREATE PROCEDURE evalImagen.sp_GetFieldData
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        g.businessName AS [empresa],
        f.Description AS [fundo],
        s.stage AS [sector],
        l.name AS [lote],
        g.growerID,
        f.farmID,
        s.stageID,
        l.lotID
    FROM GROWER.LOT l
    INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
    INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
    INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
    WHERE l.statusID = 1 
      AND s.statusID = 1 
      AND f.statusID = 1 
      AND g.statusID = 1
    ORDER BY g.businessName, f.Description, s.stage, l.name;
END;
GO

-- =====================================================
-- Agregar Extended Properties
-- =====================================================
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Obtiene la jerarquía completa de empresas, fundos, sectores y lotes activos para uso en filtros del frontend.',
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'PROCEDURE', @level1name = N'sp_GetFieldData';
GO

PRINT '[OK] Stored Procedure evalImagen.sp_GetFieldData creado exitosamente';
GO

