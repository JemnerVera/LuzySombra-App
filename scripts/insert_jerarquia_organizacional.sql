-- =====================================================
-- Script de Inserción de Datos - Jerarquía Organizacional
-- Generado: 2025-10-22
-- Fuente: Google Sheets - Data-campo
-- Base de datos: AgricolaDB
-- Schema: image
-- JERARQUÍA EN CASCADA: Empresa -> Fundo -> Sector -> Lote
-- NOTA: Se guardan tanto IDs como Nombres para mantener orden
-- =====================================================

USE AgricolaDB;
GO

-- =====================================================
-- 1. INSERTAR PAÍSES
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM image.pais WHERE paisabrev = 'PE')
BEGIN
    INSERT INTO image.pais (pais, paisabrev, statusid, usercreatedid, usermodifiedid)
    VALUES ('Perú', 'PE', 1, 1, 1);
    PRINT 'País Perú insertado';
END
ELSE
BEGIN
    PRINT 'País Perú ya existe';
END
GO

-- =====================================================
-- 2. INSERTAR EMPRESAS
-- Total: 5
-- Columnas: empresaid (ID original), empresa (nombre), empresabrev
-- =====================================================

-- Empresa: [AGA] AGRICOLA ANDREA (con 5 fundos)
IF NOT EXISTS (SELECT 1 FROM image.empresa WHERE empresabrev = 'AGA' AND paisid = (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO image.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'),
        'AGRICOLA ANDREA',
        'AGA',
        1, 1, 1
    );
    PRINT 'Empresa [AGA] AGRICOLA ANDREA insertada';
END
GO

-- Empresa: [ARE] ARENUVA S.A.C. (con 2 fundos)
IF NOT EXISTS (SELECT 1 FROM image.empresa WHERE empresabrev = 'ARE' AND paisid = (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO image.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'),
        'ARENUVA S.A.C.',
        'ARE',
        1, 1, 1
    );
    PRINT 'Empresa [ARE] ARENUVA S.A.C. insertada';
END
GO

-- Empresa: [BMP] AGRICOLA BMP SAC (con 1 fundos)
IF NOT EXISTS (SELECT 1 FROM image.empresa WHERE empresabrev = 'BMP' AND paisid = (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO image.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'),
        'AGRICOLA BMP SAC',
        'BMP',
        1, 1, 1
    );
    PRINT 'Empresa [BMP] AGRICOLA BMP SAC insertada';
END
GO

-- Empresa: [NEW] NEWTERRA S.A.C. (con 2 fundos)
IF NOT EXISTS (SELECT 1 FROM image.empresa WHERE empresabrev = 'NEW' AND paisid = (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO image.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'),
        'NEWTERRA S.A.C.',
        'NEW',
        1, 1, 1
    );
    PRINT 'Empresa [NEW] NEWTERRA S.A.C. insertada';
END
GO

-- Empresa: [OZB] LARAMA BERRIES (con 2 fundos)
IF NOT EXISTS (SELECT 1 FROM image.empresa WHERE empresabrev = 'OZB' AND paisid = (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO image.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM image.pais WHERE paisabrev = 'PE'),
        'LARAMA BERRIES',
        'OZB',
        1, 1, 1
    );
    PRINT 'Empresa [OZB] LARAMA BERRIES insertada';
END
GO

-- =====================================================
-- 3. INSERTAR FUNDOS
-- Total: 12
-- CASCADA: Cada fundo pertenece a una empresa específica
-- Columnas: fundoid (ID original), fundo (nombre), fundoabrev
-- =====================================================

-- Fundo: [CAL] FUNDO CALIFORNIA | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'),
        'FUNDO CALIFORNIA',
        'CAL',
        1, 1, 1
    );
    PRINT 'Fundo [CAL] FUNDO CALIFORNIA insertado en empresa [AGA]';
END
GO

-- Fundo: [CAR] FUNDO CARRIZALES | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'),
        'FUNDO CARRIZALES',
        'CAR',
        1, 1, 1
    );
    PRINT 'Fundo [CAR] FUNDO CARRIZALES insertado en empresa [AGA]';
END
GO

-- Fundo: [ELI] FUNDO ELISE | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'),
        'FUNDO ELISE',
        'ELI',
        1, 1, 1
    );
    PRINT 'Fundo [ELI] FUNDO ELISE insertado en empresa [AGA]';
END
GO

-- Fundo: [VAL] FDO. VALERIE | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'),
        'FDO. VALERIE',
        'VAL',
        1, 1, 1
    );
    PRINT 'Fundo [VAL] FDO. VALERIE insertado en empresa [AGA]';
END
GO

-- Fundo: [ZOE] FUNDO ZOE | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA'),
        'FUNDO ZOE',
        'ZOE',
        1, 1, 1
    );
    PRINT 'Fundo [ZOE] FUNDO ZOE insertado en empresa [AGA]';
END
GO

-- Fundo: [FS2] FDO. SANTA ZOILA 2,3 | Empresa: [ARE] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE'),
        'FDO. SANTA ZOILA 2,3',
        'FS2',
        1, 1, 1
    );
    PRINT 'Fundo [FS2] FDO. SANTA ZOILA 2,3 insertado en empresa [ARE]';
END
GO

-- Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA | Empresa: [ARE] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE'),
        'FDO. SANTA ZOILA ARENUVA',
        'FSZ',
        1, 1, 1
    );
    PRINT 'Fundo [FSZ] FDO. SANTA ZOILA ARENUVA insertado en empresa [ARE]';
END
GO

-- Fundo: [BMP] FDO. NVA CALIFORNIA | Empresa: [BMP] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'BMP'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'BMP'),
        'FDO. NVA CALIFORNIA',
        'BMP',
        1, 1, 1
    );
    PRINT 'Fundo [BMP] FDO. NVA CALIFORNIA insertado en empresa [BMP]';
END
GO

-- Fundo: [JOA] FUNDO JOAQUIN | Empresa: [NEW] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'NEW'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'NEW'),
        'FUNDO JOAQUIN',
        'JOA',
        1, 1, 1
    );
    PRINT 'Fundo [JOA] FUNDO JOAQUIN insertado en empresa [NEW]';
END
GO

-- Fundo: [NAN] FUNDO ÑAÑA | Empresa: [NEW] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'NAN' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'NEW'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'NEW'),
        'FUNDO ÑAÑA',
        'NAN',
        1, 1, 1
    );
    PRINT 'Fundo [NAN] FUNDO ÑAÑA insertado en empresa [NEW]';
END
GO

-- Fundo: [CAL] FUNDO CALIFORNIA | Empresa: [OZB] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'OZB'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'OZB'),
        'FUNDO CALIFORNIA',
        'CAL',
        1, 1, 1
    );
    PRINT 'Fundo [CAL] FUNDO CALIFORNIA insertado en empresa [OZB]';
END
GO

-- Fundo: [NAT] Fundo Natalia | Empresa: [OZB] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'OZB'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = 'OZB'),
        'Fundo Natalia',
        'NAT',
        1, 1, 1
    );
    PRINT 'Fundo [NAT] Fundo Natalia insertado en empresa [OZB]';
END
GO

-- =====================================================
-- 4. INSERTAR SECTORES
-- Total: 270
-- CASCADA: Cada sector pertenece a un fundo específico
-- Columnas: sectorid (auto), sector (nombre del sector), sectorbrev
-- NOTA: El sector_id se guarda en el nombre para mantener orden
-- =====================================================

-- Sector: [2779] CAL DIST2 C011 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2779] CAL DIST2 C011 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2779] CAL DIST2 C011 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2779] CAL DIST2 C011 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2820] CAL DIST2 G003 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2820] CAL DIST2 G003 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2820] CAL DIST2 G003 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2820] CAL DIST2 G003 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2821] CAL DIST2 F008 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2821] CAL DIST2 F008 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2821] CAL DIST2 F008 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2821] CAL DIST2 F008 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2838] CAL DIST2 C012 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2838] CAL DIST2 C012 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2838] CAL DIST2 C012 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2838] CAL DIST2 C012 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2839] CAL DIST3 E001-01 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2839] CAL DIST3 E001-01 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2839] CAL DIST3 E001-01 JSA',
        1, 1, 1
    );
    PRINT 'Sector [2839] CAL DIST3 E001-01 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [5848] CAL DIST3 F009 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5848] CAL DIST3 F009 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5848] CAL DIST3 F009 JSA',
        1, 1, 1
    );
    PRINT 'Sector [5848] CAL DIST3 F009 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [6659] CAL DIST1 A003 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6659] CAL DIST1 A003 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6659] CAL DIST1 A003 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6659] CAL DIST1 A003 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6682] CAL DIST1 B008 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6682] CAL DIST1 B008 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6682] CAL DIST1 B008 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6682] CAL DIST1 B008 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6683] CAL DIST1 B009 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6683] CAL DIST1 B009 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6683] CAL DIST1 B009 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6683] CAL DIST1 B009 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6729] CAL DIST2 D007 FCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6729] CAL DIST2 D007 FCA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6729] CAL DIST2 D007 FCA',
        1, 1, 1
    );
    PRINT 'Sector [6729] CAL DIST2 D007 FCA insertado en fundo [CAL]';
END
GO

-- Sector: [6730] CAL DIST2 D009 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6730] CAL DIST2 D009 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6730] CAL DIST2 D009 JSA',
        1, 1, 1
    );
    PRINT 'Sector [6730] CAL DIST2 D009 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [6731] CAL DIST2 C014 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6731] CAL DIST2 C014 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6731] CAL DIST2 C014 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6731] CAL DIST2 C014 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6778] CAL DIST2 D008 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6778] CAL DIST2 D008 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6778] CAL DIST2 D008 JSA',
        1, 1, 1
    );
    PRINT 'Sector [6778] CAL DIST2 D008 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [6780] CAL DIST3 C013 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6780] CAL DIST3 C013 CCA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6780] CAL DIST3 C013 CCA',
        1, 1, 1
    );
    PRINT 'Sector [6780] CAL DIST3 C013 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [6782] CAL DIST2 C015 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[6782] CAL DIST2 C015 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[6782] CAL DIST2 C015 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6782] CAL DIST2 C015 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [781] CAL DIST1 A002 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[781] CAL DIST1 A002 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[781] CAL DIST1 A002 SGL',
        1, 1, 1
    );
    PRINT 'Sector [781] CAL DIST1 A002 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [789] CAL DIST1 A011 SGL. | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[789] CAL DIST1 A011 SGL.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[789] CAL DIST1 A011 SGL.',
        1, 1, 1
    );
    PRINT 'Sector [789] CAL DIST1 A011 SGL. insertado en fundo [CAL]';
END
GO

-- Sector: [910] CAL DIST1 A004 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[910] CAL DIST1 A004 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[910] CAL DIST1 A004 JSA',
        1, 1, 1
    );
    PRINT 'Sector [910] CAL DIST1 A004 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [911] CAL DIST1 A005 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[911] CAL DIST1 A005 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[911] CAL DIST1 A005 SGL',
        1, 1, 1
    );
    PRINT 'Sector [911] CAL DIST1 A005 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [912] CAL DIST1 A006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[912] CAL DIST1 A006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[912] CAL DIST1 A006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [912] CAL DIST1 A006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [913] CAL DIST1 A007 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[913] CAL DIST1 A007 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[913] CAL DIST1 A007 SGL',
        1, 1, 1
    );
    PRINT 'Sector [913] CAL DIST1 A007 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [914] CAL DIST1 A008 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[914] CAL DIST1 A008 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[914] CAL DIST1 A008 SGL',
        1, 1, 1
    );
    PRINT 'Sector [914] CAL DIST1 A008 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [915] CAL DIST1 A009 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[915] CAL DIST1 A009 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[915] CAL DIST1 A009 SGL',
        1, 1, 1
    );
    PRINT 'Sector [915] CAL DIST1 A009 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [916] CAL DIST1 A010 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[916] CAL DIST1 A010 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[916] CAL DIST1 A010 SGL',
        1, 1, 1
    );
    PRINT 'Sector [916] CAL DIST1 A010 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [923] CAL DIST1 B006A SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[923] CAL DIST1 B006A SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[923] CAL DIST1 B006A SGL',
        1, 1, 1
    );
    PRINT 'Sector [923] CAL DIST1 B006A SGL insertado en fundo [CAL]';
END
GO

-- Sector: [924] CAL DIST1 B006B SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[924] CAL DIST1 B006B SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[924] CAL DIST1 B006B SGL',
        1, 1, 1
    );
    PRINT 'Sector [924] CAL DIST1 B006B SGL insertado en fundo [CAL]';
END
GO

-- Sector: [926] CAL DIST1 B005 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[926] CAL DIST1 B005 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[926] CAL DIST1 B005 SGL',
        1, 1, 1
    );
    PRINT 'Sector [926] CAL DIST1 B005 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [931] CAL DIST2 C004 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[931] CAL DIST2 C004 CCA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[931] CAL DIST2 C004 CCA',
        1, 1, 1
    );
    PRINT 'Sector [931] CAL DIST2 C004 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [932] CAL DIST2 C005 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[932] CAL DIST2 C005 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[932] CAL DIST2 C005 ACR',
        1, 1, 1
    );
    PRINT 'Sector [932] CAL DIST2 C005 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [933] CAL DIST2 C006 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[933] CAL DIST2 C006 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[933] CAL DIST2 C006 ACR',
        1, 1, 1
    );
    PRINT 'Sector [933] CAL DIST2 C006 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [934] CAL DIST2 C007 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[934] CAL DIST2 C007 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[934] CAL DIST2 C007 ACR',
        1, 1, 1
    );
    PRINT 'Sector [934] CAL DIST2 C007 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [935] CAL DIST2 C008 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[935] CAL DIST2 C008 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[935] CAL DIST2 C008 ACR',
        1, 1, 1
    );
    PRINT 'Sector [935] CAL DIST2 C008 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [936] CAL DIST2 C009 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[936] CAL DIST2 C009 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[936] CAL DIST2 C009 JSA',
        1, 1, 1
    );
    PRINT 'Sector [936] CAL DIST2 C009 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [937] CAL DIST2 C010 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[937] CAL DIST2 C010 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[937] CAL DIST2 C010 JSA',
        1, 1, 1
    );
    PRINT 'Sector [937] CAL DIST2 C010 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [938] CAL DIST2 D001A JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[938] CAL DIST2 D001A JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[938] CAL DIST2 D001A JSA',
        1, 1, 1
    );
    PRINT 'Sector [938] CAL DIST2 D001A JSA insertado en fundo [CAL]';
END
GO

-- Sector: [939] CAL DIST2 D002 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[939] CAL DIST2 D002 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[939] CAL DIST2 D002 JSA',
        1, 1, 1
    );
    PRINT 'Sector [939] CAL DIST2 D002 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [940] CAL DIST2 D003 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[940] CAL DIST2 D003 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[940] CAL DIST2 D003 JSA',
        1, 1, 1
    );
    PRINT 'Sector [940] CAL DIST2 D003 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [941] CAL DIST2 D004 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[941] CAL DIST2 D004 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[941] CAL DIST2 D004 SGL',
        1, 1, 1
    );
    PRINT 'Sector [941] CAL DIST2 D004 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [942] CAL DIST2 D005 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[942] CAL DIST2 D005 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[942] CAL DIST2 D005 ACR',
        1, 1, 1
    );
    PRINT 'Sector [942] CAL DIST2 D005 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [943] CAL DIST2 D006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[943] CAL DIST2 D006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[943] CAL DIST2 D006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [943] CAL DIST2 D006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [944] CAL DIST2 G002 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[944] CAL DIST2 G002 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[944] CAL DIST2 G002 SGL',
        1, 1, 1
    );
    PRINT 'Sector [944] CAL DIST2 G002 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [945] CAL DIST2 G001 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[945] CAL DIST2 G001 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[945] CAL DIST2 G001 SGL',
        1, 1, 1
    );
    PRINT 'Sector [945] CAL DIST2 G001 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [946] CAL DIST3 E001 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[946] CAL DIST3 E001 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[946] CAL DIST3 E001 JSA',
        1, 1, 1
    );
    PRINT 'Sector [946] CAL DIST3 E001 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [947] CAL DIST3 E002 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[947] CAL DIST3 E002 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[947] CAL DIST3 E002 JSA',
        1, 1, 1
    );
    PRINT 'Sector [947] CAL DIST3 E002 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [948] CAL DIST3 E003 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[948] CAL DIST3 E003 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[948] CAL DIST3 E003 JSA',
        1, 1, 1
    );
    PRINT 'Sector [948] CAL DIST3 E003 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [949] CAL DIST3 E004 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[949] CAL DIST3 E004 JSA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[949] CAL DIST3 E004 JSA',
        1, 1, 1
    );
    PRINT 'Sector [949] CAL DIST3 E004 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [950] CAL DIST3 E005 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[950] CAL DIST3 E005 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[950] CAL DIST3 E005 SGL',
        1, 1, 1
    );
    PRINT 'Sector [950] CAL DIST3 E005 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [951] CAL DIST3 E006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[951] CAL DIST3 E006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[951] CAL DIST3 E006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [951] CAL DIST3 E006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [952] CAL DIST3 E007 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[952] CAL DIST3 E007 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[952] CAL DIST3 E007 SGL',
        1, 1, 1
    );
    PRINT 'Sector [952] CAL DIST3 E007 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [953] CAL DIST3 E008 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[953] CAL DIST3 E008 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[953] CAL DIST3 E008 SGL',
        1, 1, 1
    );
    PRINT 'Sector [953] CAL DIST3 E008 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [954] CAL DIST3 E009 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[954] CAL DIST3 E009 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[954] CAL DIST3 E009 SGL',
        1, 1, 1
    );
    PRINT 'Sector [954] CAL DIST3 E009 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [955] CAL DIST3 F006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[955] CAL DIST3 F006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[955] CAL DIST3 F006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [955] CAL DIST3 F006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [956] CAL DIST3 F007 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[956] CAL DIST3 F007 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[956] CAL DIST3 F007 SGL',
        1, 1, 1
    );
    PRINT 'Sector [956] CAL DIST3 F007 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [957] CAL DIST3 F001 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[957] CAL DIST3 F001 CCA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[957] CAL DIST3 F001 CCA',
        1, 1, 1
    );
    PRINT 'Sector [957] CAL DIST3 F001 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [958] CAL DIST3 F002 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[958] CAL DIST3 F002 CCA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[958] CAL DIST3 F002 CCA',
        1, 1, 1
    );
    PRINT 'Sector [958] CAL DIST3 F002 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [961] CAL DIST3 F003 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[961] CAL DIST3 F003 CCA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[961] CAL DIST3 F003 CCA',
        1, 1, 1
    );
    PRINT 'Sector [961] CAL DIST3 F003 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [1033] CAR DIST1 CARRIZALES-LOTE | Fundo: [CAR] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1033] CAR DIST1 CARRIZALES-LOTE' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1033] CAR DIST1 CARRIZALES-LOTE',
        1, 1, 1
    );
    PRINT 'Sector [1033] CAR DIST1 CARRIZALES-LOTE insertado en fundo [CAR]';
END
GO

-- Sector: [761] CAR DIST1 SAN PABLO A | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[761] CAR DIST1 SAN PABLO A' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[761] CAR DIST1 SAN PABLO A',
        1, 1, 1
    );
    PRINT 'Sector [761] CAR DIST1 SAN PABLO A insertado en fundo [CAR]';
END
GO

-- Sector: [762] CAR DIST1 SAN PABLO B | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[762] CAR DIST1 SAN PABLO B' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[762] CAR DIST1 SAN PABLO B',
        1, 1, 1
    );
    PRINT 'Sector [762] CAR DIST1 SAN PABLO B insertado en fundo [CAR]';
END
GO

-- Sector: [763] CAR DIST1 ZAPATA 1 | Fundo: [CAR] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[763] CAR DIST1 ZAPATA 1' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[763] CAR DIST1 ZAPATA 1',
        1, 1, 1
    );
    PRINT 'Sector [763] CAR DIST1 ZAPATA 1 insertado en fundo [CAR]';
END
GO

-- Sector: [764] CAR DIST1 ZAPATA 2 | Fundo: [CAR] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[764] CAR DIST1 ZAPATA 2' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[764] CAR DIST1 ZAPATA 2',
        1, 1, 1
    );
    PRINT 'Sector [764] CAR DIST1 ZAPATA 2 insertado en fundo [CAR]';
END
GO

-- Sector: [767] CAR DIST1 SAN FRANCISCO A | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[767] CAR DIST1 SAN FRANCISCO A' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[767] CAR DIST1 SAN FRANCISCO A',
        1, 1, 1
    );
    PRINT 'Sector [767] CAR DIST1 SAN FRANCISCO A insertado en fundo [CAR]';
END
GO

-- Sector: [769] CAR DIST2 SANTA RITA A | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[769] CAR DIST2 SANTA RITA A' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[769] CAR DIST2 SANTA RITA A',
        1, 1, 1
    );
    PRINT 'Sector [769] CAR DIST2 SANTA RITA A insertado en fundo [CAR]';
END
GO

-- Sector: [770] CAR DIST2 SANTA RITA B | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[770] CAR DIST2 SANTA RITA B' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[770] CAR DIST2 SANTA RITA B',
        1, 1, 1
    );
    PRINT 'Sector [770] CAR DIST2 SANTA RITA B insertado en fundo [CAR]';
END
GO

-- Sector: [5380] M01 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5380] M01 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5380] M01 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5380] M01 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5381] M01 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5381] M01 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5381] M01 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5381] M01 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5382] M01 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5382] M01 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5382] M01 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5382] M01 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5383] M02 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5383] M02 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5383] M02 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5383] M02 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5384] M02 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5384] M02 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5384] M02 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5384] M02 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5385] M02 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5385] M02 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5385] M02 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5385] M02 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5386] M03 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5386] M03 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5386] M03 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5386] M03 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5387] M03 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5387] M03 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5387] M03 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5387] M03 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5388] M03 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5388] M03 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5388] M03 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5388] M03 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5389] M03 LOTE 4 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5389] M03 LOTE 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5389] M03 LOTE 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5389] M03 LOTE 4 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5390] M03 LOTE 5 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5390] M03 LOTE 5 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5390] M03 LOTE 5 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5390] M03 LOTE 5 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5391] M04 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5391] M04 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5391] M04 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5391] M04 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5392] M04 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5392] M04 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5392] M04 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5392] M04 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5393] M04 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5393] M04 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5393] M04 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5393] M04 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5394] M04 LOTE 4 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[5394] M04 LOTE 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[5394] M04 LOTE 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5394] M04 LOTE 4 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [1052] VAL DIST1 LOTE 01 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1052] VAL DIST1 LOTE 01 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1052] VAL DIST1 LOTE 01 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1052] VAL DIST1 LOTE 01 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1053] VAL DIST1 LOTE 02 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1053] VAL DIST1 LOTE 02 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1053] VAL DIST1 LOTE 02 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1053] VAL DIST1 LOTE 02 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1054] VAL DIST1 LOTE 03 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1054] VAL DIST1 LOTE 03 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1054] VAL DIST1 LOTE 03 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1054] VAL DIST1 LOTE 03 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1055] VAL DIST1 LOTE 04 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1055] VAL DIST1 LOTE 04 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1055] VAL DIST1 LOTE 04 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1055] VAL DIST1 LOTE 04 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1056] VAL DIST1 LOTE 05 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1056] VAL DIST1 LOTE 05 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1056] VAL DIST1 LOTE 05 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1056] VAL DIST1 LOTE 05 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1057] VAL DIST1 LOTE 06 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1057] VAL DIST1 LOTE 06 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1057] VAL DIST1 LOTE 06 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1057] VAL DIST1 LOTE 06 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1058] VAL DIST1 LOTE 07 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1058] VAL DIST1 LOTE 07 SGL' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1058] VAL DIST1 LOTE 07 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1058] VAL DIST1 LOTE 07 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1059] VAL DIST1 LOTE 08 ACR | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1059] VAL DIST1 LOTE 08 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1059] VAL DIST1 LOTE 08 ACR',
        1, 1, 1
    );
    PRINT 'Sector [1059] VAL DIST1 LOTE 08 ACR insertado en fundo [VAL]';
END
GO

-- Sector: [1060] VAL DIST1 LOTE 09 ACR | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[1060] VAL DIST1 LOTE 09 ACR' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[1060] VAL DIST1 LOTE 09 ACR',
        1, 1, 1
    );
    PRINT 'Sector [1060] VAL DIST1 LOTE 09 ACR insertado en fundo [VAL]';
END
GO

-- Sector: [2260] M01 SECTOR 1 [1A] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2260] M01 SECTOR 1 [1A] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2260] M01 SECTOR 1 [1A] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2260] M01 SECTOR 1 [1A] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2261] M01 SECTOR 1 [1B] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2261] M01 SECTOR 1 [1B] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2261] M01 SECTOR 1 [1B] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2261] M01 SECTOR 1 [1B] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2262] M01 SECTOR 2 [2A] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2262] M01 SECTOR 2 [2A] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2262] M01 SECTOR 2 [2A] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2262] M01 SECTOR 2 [2A] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2263] M01 SECTOR 2 [2B] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2263] M01 SECTOR 2 [2B] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2263] M01 SECTOR 2 [2B] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2263] M01 SECTOR 2 [2B] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2411] M01 SECTOR 3 [3] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2411] M01 SECTOR 3 [3] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2411] M01 SECTOR 3 [3] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2411] M01 SECTOR 3 [3] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2412] M01 SECTOR 4 [4] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2412] M01 SECTOR 4 [4] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2412] M01 SECTOR 4 [4] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2412] M01 SECTOR 4 [4] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2413] M01 SECTOR 5 [5] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2413] M01 SECTOR 5 [5] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2413] M01 SECTOR 5 [5] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2413] M01 SECTOR 5 [5] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2414] M01 SECTOR 6 [6] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2414] M01 SECTOR 6 [6] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2414] M01 SECTOR 6 [6] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2414] M01 SECTOR 6 [6] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2415] M02 SECTOR 1 [1] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2415] M02 SECTOR 1 [1] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2415] M02 SECTOR 1 [1] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2415] M02 SECTOR 1 [1] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2568] M02 SECTOR 2 [2A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2568] M02 SECTOR 2 [2A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2568] M02 SECTOR 2 [2A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2568] M02 SECTOR 2 [2A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2569] M02 SECTOR 2 [2B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2569] M02 SECTOR 2 [2B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2569] M02 SECTOR 2 [2B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2569] M02 SECTOR 2 [2B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2570] M02 SECTOR 3 [3A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2570] M02 SECTOR 3 [3A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2570] M02 SECTOR 3 [3A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2570] M02 SECTOR 3 [3A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2571] M02 SECTOR 3 [3B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2571] M02 SECTOR 3 [3B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2571] M02 SECTOR 3 [3B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2571] M02 SECTOR 3 [3B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2572] M02 SECTOR 4 [4A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2572] M02 SECTOR 4 [4A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2572] M02 SECTOR 4 [4A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2572] M02 SECTOR 4 [4A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2573] M02 SECTOR 4 [4B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2573] M02 SECTOR 4 [4B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2573] M02 SECTOR 4 [4B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2573] M02 SECTOR 4 [4B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2574] M02 SECTOR 4 [4C] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2574] M02 SECTOR 4 [4C] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2574] M02 SECTOR 4 [4C] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2574] M02 SECTOR 4 [4C] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2575] M02 SECTOR 5 [5A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2575] M02 SECTOR 5 [5A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2575] M02 SECTOR 5 [5A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2575] M02 SECTOR 5 [5A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2736] M02 SECTOR 5 [5B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2736] M02 SECTOR 5 [5B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2736] M02 SECTOR 5 [5B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2736] M02 SECTOR 5 [5B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2737] M02 SECTOR 6 [6] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2737] M02 SECTOR 6 [6] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2737] M02 SECTOR 6 [6] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2737] M02 SECTOR 6 [6] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2738] M02 SECTOR 7 [7A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2738] M02 SECTOR 7 [7A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2738] M02 SECTOR 7 [7A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2738] M02 SECTOR 7 [7A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2739] M02 SECTOR 7 [7B] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2739] M02 SECTOR 7 [7B] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2739] M02 SECTOR 7 [7B] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2739] M02 SECTOR 7 [7B] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2113] M01 TURNO 1 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2113] M01 TURNO 1 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2113] M01 TURNO 1 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2113] M01 TURNO 1 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2114] M01 TURNO 2 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2114] M01 TURNO 2 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2114] M01 TURNO 2 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2114] M01 TURNO 2 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2115] M01 TURNO 3 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2115] M01 TURNO 3 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2115] M01 TURNO 3 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2115] M01 TURNO 3 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2116] M01 TURNO 4 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2116] M01 TURNO 4 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2116] M01 TURNO 4 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2116] M01 TURNO 4 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2865] FDO ZOE AUTUMN CRISP M01 LOTE 02 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2865] FDO ZOE AUTUMN CRISP M01 LOTE 02' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2865] FDO ZOE AUTUMN CRISP M01 LOTE 02',
        1, 1, 1
    );
    PRINT 'Sector [2865] FDO ZOE AUTUMN CRISP M01 LOTE 02 insertado en fundo [ZOE]';
END
GO

-- Sector: [2867] FDO ZOE AUTUMN CRISP M01 LOTE 04 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2867] FDO ZOE AUTUMN CRISP M01 LOTE 04' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2867] FDO ZOE AUTUMN CRISP M01 LOTE 04',
        1, 1, 1
    );
    PRINT 'Sector [2867] FDO ZOE AUTUMN CRISP M01 LOTE 04 insertado en fundo [ZOE]';
END
GO

-- Sector: [2869] FDO ZOE AUTUMN CRISP M01 LOTE 06 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2869] FDO ZOE AUTUMN CRISP M01 LOTE 06' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2869] FDO ZOE AUTUMN CRISP M01 LOTE 06',
        1, 1, 1
    );
    PRINT 'Sector [2869] FDO ZOE AUTUMN CRISP M01 LOTE 06 insertado en fundo [ZOE]';
END
GO

-- Sector: [2874] FDO ZOE AUTUMN CRISP M02 LOTE 11 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2874] FDO ZOE AUTUMN CRISP M02 LOTE 11' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2874] FDO ZOE AUTUMN CRISP M02 LOTE 11',
        1, 1, 1
    );
    PRINT 'Sector [2874] FDO ZOE AUTUMN CRISP M02 LOTE 11 insertado en fundo [ZOE]';
END
GO

-- Sector: [2882] M04 TURNO 4 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[2882] M04 TURNO 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[2882] M04 TURNO 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2882] M04 TURNO 4 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4538] FDO ZOE ACR ET I SEC 01. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4538] FDO ZOE ACR ET I SEC 01.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4538] FDO ZOE ACR ET I SEC 01.',
        1, 1, 1
    );
    PRINT 'Sector [4538] FDO ZOE ACR ET I SEC 01. insertado en fundo [ZOE]';
END
GO

-- Sector: [4926] FDO ZOE ACR ET I SEC 02. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4926] FDO ZOE ACR ET I SEC 02.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4926] FDO ZOE ACR ET I SEC 02.',
        1, 1, 1
    );
    PRINT 'Sector [4926] FDO ZOE ACR ET I SEC 02. insertado en fundo [ZOE]';
END
GO

-- Sector: [4927] FDO ZOE ACR ET I SEC 03. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4927] FDO ZOE ACR ET I SEC 03.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4927] FDO ZOE ACR ET I SEC 03.',
        1, 1, 1
    );
    PRINT 'Sector [4927] FDO ZOE ACR ET I SEC 03. insertado en fundo [ZOE]';
END
GO

-- Sector: [4928] FDO ZOE ACR ET II SEC 04. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4928] FDO ZOE ACR ET II SEC 04.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4928] FDO ZOE ACR ET II SEC 04.',
        1, 1, 1
    );
    PRINT 'Sector [4928] FDO ZOE ACR ET II SEC 04. insertado en fundo [ZOE]';
END
GO

-- Sector: [4929] FDO ZOE ACR ET II SEC 05. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4929] FDO ZOE ACR ET II SEC 05.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4929] FDO ZOE ACR ET II SEC 05.',
        1, 1, 1
    );
    PRINT 'Sector [4929] FDO ZOE ACR ET II SEC 05. insertado en fundo [ZOE]';
END
GO

-- Sector: [4930] FDO ZOE ACR ET II SEC 06. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4930] FDO ZOE ACR ET II SEC 06.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4930] FDO ZOE ACR ET II SEC 06.',
        1, 1, 1
    );
    PRINT 'Sector [4930] FDO ZOE ACR ET II SEC 06. insertado en fundo [ZOE]';
END
GO

-- Sector: [4931] FDO ZOE ACR ET II SEC 07. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4931] FDO ZOE ACR ET II SEC 07.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4931] FDO ZOE ACR ET II SEC 07.',
        1, 1, 1
    );
    PRINT 'Sector [4931] FDO ZOE ACR ET II SEC 07. insertado en fundo [ZOE]';
END
GO

-- Sector: [4932] FDO ZOE ACR ET III SEC 08. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4932] FDO ZOE ACR ET III SEC 08.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4932] FDO ZOE ACR ET III SEC 08.',
        1, 1, 1
    );
    PRINT 'Sector [4932] FDO ZOE ACR ET III SEC 08. insertado en fundo [ZOE]';
END
GO

-- Sector: [4933] FDO ZOE ACR ET III SEC 09. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4933] FDO ZOE ACR ET III SEC 09.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4933] FDO ZOE ACR ET III SEC 09.',
        1, 1, 1
    );
    PRINT 'Sector [4933] FDO ZOE ACR ET III SEC 09. insertado en fundo [ZOE]';
END
GO

-- Sector: [4934] FDO ZOE ACR ET III SEC 10. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4934] FDO ZOE ACR ET III SEC 10.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4934] FDO ZOE ACR ET III SEC 10.',
        1, 1, 1
    );
    PRINT 'Sector [4934] FDO ZOE ACR ET III SEC 10. insertado en fundo [ZOE]';
END
GO

-- Sector: [4935] FDO ZOE ACR ET IV SEC 11. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4935] FDO ZOE ACR ET IV SEC 11.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4935] FDO ZOE ACR ET IV SEC 11.',
        1, 1, 1
    );
    PRINT 'Sector [4935] FDO ZOE ACR ET IV SEC 11. insertado en fundo [ZOE]';
END
GO

-- Sector: [4936] FDO ZOE ACR ET IV SEC 12. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4936] FDO ZOE ACR ET IV SEC 12.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4936] FDO ZOE ACR ET IV SEC 12.',
        1, 1, 1
    );
    PRINT 'Sector [4936] FDO ZOE ACR ET IV SEC 12. insertado en fundo [ZOE]';
END
GO

-- Sector: [4937] FDO ZOE ACR ET IV SEC 13. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4937] FDO ZOE ACR ET IV SEC 13.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4937] FDO ZOE ACR ET IV SEC 13.',
        1, 1, 1
    );
    PRINT 'Sector [4937] FDO ZOE ACR ET IV SEC 13. insertado en fundo [ZOE]';
END
GO

-- Sector: [4938] FDO ZOE ACR ET IV SEC 14. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4938] FDO ZOE ACR ET IV SEC 14.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4938] FDO ZOE ACR ET IV SEC 14.',
        1, 1, 1
    );
    PRINT 'Sector [4938] FDO ZOE ACR ET IV SEC 14. insertado en fundo [ZOE]';
END
GO

-- Sector: [4939] FDO ZOE FCR ET IV SEC 15. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4939] FDO ZOE FCR ET IV SEC 15.' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4939] FDO ZOE FCR ET IV SEC 15.',
        1, 1, 1
    );
    PRINT 'Sector [4939] FDO ZOE FCR ET IV SEC 15. insertado en fundo [ZOE]';
END
GO

-- Sector: [4942] M02 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4942] M02 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4942] M02 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4942] M02 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4943] M02 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4943] M02 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4943] M02 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4943] M02 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4944] M02 TURNO 3 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4944] M02 TURNO 3 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4944] M02 TURNO 3 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4944] M02 TURNO 3 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4945] M02 TURNO 4 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4945] M02 TURNO 4 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4945] M02 TURNO 4 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4945] M02 TURNO 4 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4946] M03 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4946] M03 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4946] M03 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4946] M03 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4947] M03 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4947] M03 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4947] M03 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4947] M03 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4948] M03 TURNO 3 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4948] M03 TURNO 3 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4948] M03 TURNO 3 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4948] M03 TURNO 3 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4949] M04 TURNO 1 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4949] M04 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4949] M04 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4949] M04 TURNO 1 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4950] M04 TURNO 2 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4950] M04 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4950] M04 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4950] M04 TURNO 2 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4951] M04 TURNO 3 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4951] M04 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4951] M04 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4951] M04 TURNO 3 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4953] M05 TURNO 1 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4953] M05 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4953] M05 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4953] M05 TURNO 1 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4954] M05 TURNO 2 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4954] M05 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4954] M05 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4954] M05 TURNO 2 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4955] M05 TURNO 3 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4955] M05 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4955] M05 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4955] M05 TURNO 3 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4956] M06 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4956] M06 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4956] M06 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4956] M06 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4957] M06 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4957] M06 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4957] M06 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4957] M06 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4958] M07 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4958] M07 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4958] M07 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4958] M07 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4959] M07 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[4959] M07 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'AGA')),
        '[4959] M07 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4959] M07 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [200] M01 TURNO 1 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[200] M01 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE')),
        '[200] M01 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [200] M01 TURNO 1 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [201] M01 TURNO 2 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '[201] M01 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
