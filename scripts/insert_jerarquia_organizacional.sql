-- =====================================================
-- Script de Inserción de Datos - Jerarquía Organizacional
-- Generado: 2025-10-21 21:47:44
-- Fuente: Google Sheets - Data-campo
-- JERARQUÍA EN CASCADA: Empresa -> Fundo -> Sector -> Lote
-- NOTA: Se guardan tanto IDs como Nombres para mantener orden
-- =====================================================

USE BD_PACKING_AGROMIGIVA_PRD;
GO

-- =====================================================
-- 1. INSERTAR PAÍSES
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM sense.pais WHERE paisabrev = 'PE')
BEGIN
    INSERT INTO sense.pais (pais, paisabrev, statusid, usercreatedid, usermodifiedid)
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
IF NOT EXISTS (SELECT 1 FROM sense.empresa WHERE empresabrev = 'AGA' AND paisid = (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO sense.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'),
        'AGRICOLA ANDREA',
        'AGA',
        1, 1, 1
    );
    PRINT 'Empresa [AGA] AGRICOLA ANDREA insertada';
END
GO

-- Empresa: [ARE] ARENUVA S.A.C. (con 2 fundos)
IF NOT EXISTS (SELECT 1 FROM sense.empresa WHERE empresabrev = 'ARE' AND paisid = (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO sense.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'),
        'ARENUVA S.A.C.',
        'ARE',
        1, 1, 1
    );
    PRINT 'Empresa [ARE] ARENUVA S.A.C. insertada';
END
GO

-- Empresa: [BMP] AGRICOLA BMP SAC (con 1 fundos)
IF NOT EXISTS (SELECT 1 FROM sense.empresa WHERE empresabrev = 'BMP' AND paisid = (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO sense.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'),
        'AGRICOLA BMP SAC',
        'BMP',
        1, 1, 1
    );
    PRINT 'Empresa [BMP] AGRICOLA BMP SAC insertada';
END
GO

-- Empresa: [NEW] NEWTERRA S.A.C. (con 2 fundos)
IF NOT EXISTS (SELECT 1 FROM sense.empresa WHERE empresabrev = 'NEW' AND paisid = (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO sense.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'),
        'NEWTERRA S.A.C.',
        'NEW',
        1, 1, 1
    );
    PRINT 'Empresa [NEW] NEWTERRA S.A.C. insertada';
END
GO

-- Empresa: [OZB] LARAMA BERRIES (con 2 fundos)
IF NOT EXISTS (SELECT 1 FROM sense.empresa WHERE empresabrev = 'OZB' AND paisid = (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'))
BEGIN
    INSERT INTO sense.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM sense.pais WHERE paisabrev = 'PE'),
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
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'),
        'FUNDO CALIFORNIA',
        'CAL',
        1, 1, 1
    );
    PRINT 'Fundo [CAL] FUNDO CALIFORNIA insertado en empresa [AGA]';
END
GO

-- Fundo: [CAR] FUNDO CARRIZALES | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'),
        'FUNDO CARRIZALES',
        'CAR',
        1, 1, 1
    );
    PRINT 'Fundo [CAR] FUNDO CARRIZALES insertado en empresa [AGA]';
END
GO

-- Fundo: [ELI] FUNDO ELISE | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'),
        'FUNDO ELISE',
        'ELI',
        1, 1, 1
    );
    PRINT 'Fundo [ELI] FUNDO ELISE insertado en empresa [AGA]';
END
GO

-- Fundo: [VAL] FDO. VALERIE | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'),
        'FDO. VALERIE',
        'VAL',
        1, 1, 1
    );
    PRINT 'Fundo [VAL] FDO. VALERIE insertado en empresa [AGA]';
END
GO

-- Fundo: [ZOE] FUNDO ZOE | Empresa: [AGA] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA'),
        'FUNDO ZOE',
        'ZOE',
        1, 1, 1
    );
    PRINT 'Fundo [ZOE] FUNDO ZOE insertado en empresa [AGA]';
END
GO

-- Fundo: [FS2] FDO. SANTA ZOILA 2,3 | Empresa: [ARE] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE'),
        'FDO. SANTA ZOILA 2,3',
        'FS2',
        1, 1, 1
    );
    PRINT 'Fundo [FS2] FDO. SANTA ZOILA 2,3 insertado en empresa [ARE]';
END
GO

-- Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA | Empresa: [ARE] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE'),
        'FDO. SANTA ZOILA ARENUVA',
        'FSZ',
        1, 1, 1
    );
    PRINT 'Fundo [FSZ] FDO. SANTA ZOILA ARENUVA insertado en empresa [ARE]';
END
GO

-- Fundo: [BMP] FDO. NVA CALIFORNIA | Empresa: [BMP] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP'),
        'FDO. NVA CALIFORNIA',
        'BMP',
        1, 1, 1
    );
    PRINT 'Fundo [BMP] FDO. NVA CALIFORNIA insertado en empresa [BMP]';
END
GO

-- Fundo: [JOA] FUNDO JOAQUIN | Empresa: [NEW] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW'),
        'FUNDO JOAQUIN',
        'JOA',
        1, 1, 1
    );
    PRINT 'Fundo [JOA] FUNDO JOAQUIN insertado en empresa [NEW]';
END
GO

-- Fundo: [NAN] FUNDO ÑAÑA | Empresa: [NEW] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'NAN' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW'),
        'FUNDO ÑAÑA',
        'NAN',
        1, 1, 1
    );
    PRINT 'Fundo [NAN] FUNDO ÑAÑA insertado en empresa [NEW]';
END
GO

-- Fundo: [CAL] FUNDO CALIFORNIA | Empresa: [OZB] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB'),
        'FUNDO CALIFORNIA',
        'CAL',
        1, 1, 1
    );
    PRINT 'Fundo [CAL] FUNDO CALIFORNIA insertado en empresa [OZB]';
END
GO

-- Fundo: [NAT] Fundo Natalia | Empresa: [OZB] | Sectores: 0
IF NOT EXISTS (SELECT 1 FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB'))
BEGIN
    INSERT INTO sense.fundo (empresaid, fundo, fundoabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB'),
        'Fundo Natalia',
        'NAT',
        1, 1, 1
    );
    PRINT 'Fundo [NAT] Fundo Natalia insertado en empresa [OZB]';
END
GO

-- =====================================================
-- 4. INSERTAR SECTORES (ubicacion)
-- Total: 270
-- CASCADA: Cada sector pertenece a un fundo específico
-- Columnas: ubicacionid (auto), ubicacion (nombre del sector)
-- NOTA: El sector_id se guarda en el nombre para mantener orden
-- =====================================================

-- Sector: [2779] CAL DIST2 C011 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2779] CAL DIST2 C011 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2779] CAL DIST2 C011 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2779] CAL DIST2 C011 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2820] CAL DIST2 G003 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2820] CAL DIST2 G003 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2820] CAL DIST2 G003 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2820] CAL DIST2 G003 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2821] CAL DIST2 F008 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2821] CAL DIST2 F008 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2821] CAL DIST2 F008 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2821] CAL DIST2 F008 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2838] CAL DIST2 C012 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2838] CAL DIST2 C012 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2838] CAL DIST2 C012 ACR',
        1, 1, 1
    );
    PRINT 'Sector [2838] CAL DIST2 C012 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [2839] CAL DIST3 E001-01 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2839] CAL DIST3 E001-01 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2839] CAL DIST3 E001-01 JSA',
        1, 1, 1
    );
    PRINT 'Sector [2839] CAL DIST3 E001-01 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [5848] CAL DIST3 F009 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5848] CAL DIST3 F009 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5848] CAL DIST3 F009 JSA',
        1, 1, 1
    );
    PRINT 'Sector [5848] CAL DIST3 F009 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [6659] CAL DIST1 A003 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6659] CAL DIST1 A003 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6659] CAL DIST1 A003 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6659] CAL DIST1 A003 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6682] CAL DIST1 B008 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6682] CAL DIST1 B008 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6682] CAL DIST1 B008 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6682] CAL DIST1 B008 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6683] CAL DIST1 B009 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6683] CAL DIST1 B009 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6683] CAL DIST1 B009 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6683] CAL DIST1 B009 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6729] CAL DIST2 D007 FCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6729] CAL DIST2 D007 FCA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6729] CAL DIST2 D007 FCA',
        1, 1, 1
    );
    PRINT 'Sector [6729] CAL DIST2 D007 FCA insertado en fundo [CAL]';
END
GO

-- Sector: [6730] CAL DIST2 D009 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6730] CAL DIST2 D009 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6730] CAL DIST2 D009 JSA',
        1, 1, 1
    );
    PRINT 'Sector [6730] CAL DIST2 D009 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [6731] CAL DIST2 C014 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6731] CAL DIST2 C014 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6731] CAL DIST2 C014 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6731] CAL DIST2 C014 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [6778] CAL DIST2 D008 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6778] CAL DIST2 D008 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6778] CAL DIST2 D008 JSA',
        1, 1, 1
    );
    PRINT 'Sector [6778] CAL DIST2 D008 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [6780] CAL DIST3 C013 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6780] CAL DIST3 C013 CCA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6780] CAL DIST3 C013 CCA',
        1, 1, 1
    );
    PRINT 'Sector [6780] CAL DIST3 C013 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [6782] CAL DIST2 C015 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6782] CAL DIST2 C015 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[6782] CAL DIST2 C015 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6782] CAL DIST2 C015 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [781] CAL DIST1 A002 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[781] CAL DIST1 A002 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[781] CAL DIST1 A002 SGL',
        1, 1, 1
    );
    PRINT 'Sector [781] CAL DIST1 A002 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [789] CAL DIST1 A011 SGL. | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[789] CAL DIST1 A011 SGL.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[789] CAL DIST1 A011 SGL.',
        1, 1, 1
    );
    PRINT 'Sector [789] CAL DIST1 A011 SGL. insertado en fundo [CAL]';
END
GO

-- Sector: [910] CAL DIST1 A004 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[910] CAL DIST1 A004 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[910] CAL DIST1 A004 JSA',
        1, 1, 1
    );
    PRINT 'Sector [910] CAL DIST1 A004 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [911] CAL DIST1 A005 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[911] CAL DIST1 A005 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[911] CAL DIST1 A005 SGL',
        1, 1, 1
    );
    PRINT 'Sector [911] CAL DIST1 A005 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [912] CAL DIST1 A006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[912] CAL DIST1 A006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[912] CAL DIST1 A006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [912] CAL DIST1 A006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [913] CAL DIST1 A007 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[913] CAL DIST1 A007 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[913] CAL DIST1 A007 SGL',
        1, 1, 1
    );
    PRINT 'Sector [913] CAL DIST1 A007 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [914] CAL DIST1 A008 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[914] CAL DIST1 A008 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[914] CAL DIST1 A008 SGL',
        1, 1, 1
    );
    PRINT 'Sector [914] CAL DIST1 A008 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [915] CAL DIST1 A009 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[915] CAL DIST1 A009 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[915] CAL DIST1 A009 SGL',
        1, 1, 1
    );
    PRINT 'Sector [915] CAL DIST1 A009 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [916] CAL DIST1 A010 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[916] CAL DIST1 A010 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[916] CAL DIST1 A010 SGL',
        1, 1, 1
    );
    PRINT 'Sector [916] CAL DIST1 A010 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [923] CAL DIST1 B006A SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[923] CAL DIST1 B006A SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[923] CAL DIST1 B006A SGL',
        1, 1, 1
    );
    PRINT 'Sector [923] CAL DIST1 B006A SGL insertado en fundo [CAL]';
END
GO

-- Sector: [924] CAL DIST1 B006B SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[924] CAL DIST1 B006B SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[924] CAL DIST1 B006B SGL',
        1, 1, 1
    );
    PRINT 'Sector [924] CAL DIST1 B006B SGL insertado en fundo [CAL]';
END
GO

-- Sector: [926] CAL DIST1 B005 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[926] CAL DIST1 B005 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[926] CAL DIST1 B005 SGL',
        1, 1, 1
    );
    PRINT 'Sector [926] CAL DIST1 B005 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [931] CAL DIST2 C004 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[931] CAL DIST2 C004 CCA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[931] CAL DIST2 C004 CCA',
        1, 1, 1
    );
    PRINT 'Sector [931] CAL DIST2 C004 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [932] CAL DIST2 C005 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[932] CAL DIST2 C005 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[932] CAL DIST2 C005 ACR',
        1, 1, 1
    );
    PRINT 'Sector [932] CAL DIST2 C005 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [933] CAL DIST2 C006 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[933] CAL DIST2 C006 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[933] CAL DIST2 C006 ACR',
        1, 1, 1
    );
    PRINT 'Sector [933] CAL DIST2 C006 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [934] CAL DIST2 C007 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[934] CAL DIST2 C007 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[934] CAL DIST2 C007 ACR',
        1, 1, 1
    );
    PRINT 'Sector [934] CAL DIST2 C007 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [935] CAL DIST2 C008 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[935] CAL DIST2 C008 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[935] CAL DIST2 C008 ACR',
        1, 1, 1
    );
    PRINT 'Sector [935] CAL DIST2 C008 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [936] CAL DIST2 C009 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[936] CAL DIST2 C009 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[936] CAL DIST2 C009 JSA',
        1, 1, 1
    );
    PRINT 'Sector [936] CAL DIST2 C009 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [937] CAL DIST2 C010 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[937] CAL DIST2 C010 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[937] CAL DIST2 C010 JSA',
        1, 1, 1
    );
    PRINT 'Sector [937] CAL DIST2 C010 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [938] CAL DIST2 D001A JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[938] CAL DIST2 D001A JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[938] CAL DIST2 D001A JSA',
        1, 1, 1
    );
    PRINT 'Sector [938] CAL DIST2 D001A JSA insertado en fundo [CAL]';
END
GO

-- Sector: [939] CAL DIST2 D002 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[939] CAL DIST2 D002 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[939] CAL DIST2 D002 JSA',
        1, 1, 1
    );
    PRINT 'Sector [939] CAL DIST2 D002 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [940] CAL DIST2 D003 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[940] CAL DIST2 D003 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[940] CAL DIST2 D003 JSA',
        1, 1, 1
    );
    PRINT 'Sector [940] CAL DIST2 D003 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [941] CAL DIST2 D004 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[941] CAL DIST2 D004 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[941] CAL DIST2 D004 SGL',
        1, 1, 1
    );
    PRINT 'Sector [941] CAL DIST2 D004 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [942] CAL DIST2 D005 ACR | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[942] CAL DIST2 D005 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[942] CAL DIST2 D005 ACR',
        1, 1, 1
    );
    PRINT 'Sector [942] CAL DIST2 D005 ACR insertado en fundo [CAL]';
END
GO

-- Sector: [943] CAL DIST2 D006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[943] CAL DIST2 D006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[943] CAL DIST2 D006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [943] CAL DIST2 D006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [944] CAL DIST2 G002 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[944] CAL DIST2 G002 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[944] CAL DIST2 G002 SGL',
        1, 1, 1
    );
    PRINT 'Sector [944] CAL DIST2 G002 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [945] CAL DIST2 G001 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[945] CAL DIST2 G001 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[945] CAL DIST2 G001 SGL',
        1, 1, 1
    );
    PRINT 'Sector [945] CAL DIST2 G001 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [946] CAL DIST3 E001 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[946] CAL DIST3 E001 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[946] CAL DIST3 E001 JSA',
        1, 1, 1
    );
    PRINT 'Sector [946] CAL DIST3 E001 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [947] CAL DIST3 E002 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[947] CAL DIST3 E002 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[947] CAL DIST3 E002 JSA',
        1, 1, 1
    );
    PRINT 'Sector [947] CAL DIST3 E002 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [948] CAL DIST3 E003 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[948] CAL DIST3 E003 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[948] CAL DIST3 E003 JSA',
        1, 1, 1
    );
    PRINT 'Sector [948] CAL DIST3 E003 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [949] CAL DIST3 E004 JSA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[949] CAL DIST3 E004 JSA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[949] CAL DIST3 E004 JSA',
        1, 1, 1
    );
    PRINT 'Sector [949] CAL DIST3 E004 JSA insertado en fundo [CAL]';
END
GO

-- Sector: [950] CAL DIST3 E005 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[950] CAL DIST3 E005 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[950] CAL DIST3 E005 SGL',
        1, 1, 1
    );
    PRINT 'Sector [950] CAL DIST3 E005 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [951] CAL DIST3 E006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[951] CAL DIST3 E006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[951] CAL DIST3 E006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [951] CAL DIST3 E006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [952] CAL DIST3 E007 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[952] CAL DIST3 E007 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[952] CAL DIST3 E007 SGL',
        1, 1, 1
    );
    PRINT 'Sector [952] CAL DIST3 E007 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [953] CAL DIST3 E008 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[953] CAL DIST3 E008 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[953] CAL DIST3 E008 SGL',
        1, 1, 1
    );
    PRINT 'Sector [953] CAL DIST3 E008 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [954] CAL DIST3 E009 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[954] CAL DIST3 E009 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[954] CAL DIST3 E009 SGL',
        1, 1, 1
    );
    PRINT 'Sector [954] CAL DIST3 E009 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [955] CAL DIST3 F006 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[955] CAL DIST3 F006 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[955] CAL DIST3 F006 SGL',
        1, 1, 1
    );
    PRINT 'Sector [955] CAL DIST3 F006 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [956] CAL DIST3 F007 SGL | Fundo: [CAL] | Empresa: [AGA] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[956] CAL DIST3 F007 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[956] CAL DIST3 F007 SGL',
        1, 1, 1
    );
    PRINT 'Sector [956] CAL DIST3 F007 SGL insertado en fundo [CAL]';
END
GO

-- Sector: [957] CAL DIST3 F001 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[957] CAL DIST3 F001 CCA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[957] CAL DIST3 F001 CCA',
        1, 1, 1
    );
    PRINT 'Sector [957] CAL DIST3 F001 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [958] CAL DIST3 F002 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[958] CAL DIST3 F002 CCA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[958] CAL DIST3 F002 CCA',
        1, 1, 1
    );
    PRINT 'Sector [958] CAL DIST3 F002 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [961] CAL DIST3 F003 CCA | Fundo: [CAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[961] CAL DIST3 F003 CCA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[961] CAL DIST3 F003 CCA',
        1, 1, 1
    );
    PRINT 'Sector [961] CAL DIST3 F003 CCA insertado en fundo [CAL]';
END
GO

-- Sector: [1033] CAR DIST1 CARRIZALES-LOTE | Fundo: [CAR] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1033] CAR DIST1 CARRIZALES-LOTE' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1033] CAR DIST1 CARRIZALES-LOTE',
        1, 1, 1
    );
    PRINT 'Sector [1033] CAR DIST1 CARRIZALES-LOTE insertado en fundo [CAR]';
END
GO

-- Sector: [761] CAR DIST1 SAN PABLO A | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[761] CAR DIST1 SAN PABLO A' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[761] CAR DIST1 SAN PABLO A',
        1, 1, 1
    );
    PRINT 'Sector [761] CAR DIST1 SAN PABLO A insertado en fundo [CAR]';
END
GO

-- Sector: [762] CAR DIST1 SAN PABLO B | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[762] CAR DIST1 SAN PABLO B' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[762] CAR DIST1 SAN PABLO B',
        1, 1, 1
    );
    PRINT 'Sector [762] CAR DIST1 SAN PABLO B insertado en fundo [CAR]';
END
GO

-- Sector: [763] CAR DIST1 ZAPATA 1 | Fundo: [CAR] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[763] CAR DIST1 ZAPATA 1' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[763] CAR DIST1 ZAPATA 1',
        1, 1, 1
    );
    PRINT 'Sector [763] CAR DIST1 ZAPATA 1 insertado en fundo [CAR]';
END
GO

-- Sector: [764] CAR DIST1 ZAPATA 2 | Fundo: [CAR] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[764] CAR DIST1 ZAPATA 2' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[764] CAR DIST1 ZAPATA 2',
        1, 1, 1
    );
    PRINT 'Sector [764] CAR DIST1 ZAPATA 2 insertado en fundo [CAR]';
END
GO

-- Sector: [767] CAR DIST1 SAN FRANCISCO A | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[767] CAR DIST1 SAN FRANCISCO A' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[767] CAR DIST1 SAN FRANCISCO A',
        1, 1, 1
    );
    PRINT 'Sector [767] CAR DIST1 SAN FRANCISCO A insertado en fundo [CAR]';
END
GO

-- Sector: [769] CAR DIST2 SANTA RITA A | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[769] CAR DIST2 SANTA RITA A' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[769] CAR DIST2 SANTA RITA A',
        1, 1, 1
    );
    PRINT 'Sector [769] CAR DIST2 SANTA RITA A insertado en fundo [CAR]';
END
GO

-- Sector: [770] CAR DIST2 SANTA RITA B | Fundo: [CAR] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[770] CAR DIST2 SANTA RITA B' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAR' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAR' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[770] CAR DIST2 SANTA RITA B',
        1, 1, 1
    );
    PRINT 'Sector [770] CAR DIST2 SANTA RITA B insertado en fundo [CAR]';
END
GO

-- Sector: [5380] M01 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5380] M01 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5380] M01 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5380] M01 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5381] M01 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5381] M01 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5381] M01 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5381] M01 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5382] M01 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5382] M01 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5382] M01 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5382] M01 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5383] M02 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5383] M02 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5383] M02 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5383] M02 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5384] M02 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5384] M02 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5384] M02 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5384] M02 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5385] M02 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5385] M02 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5385] M02 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5385] M02 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5386] M03 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5386] M03 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5386] M03 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5386] M03 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5387] M03 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5387] M03 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5387] M03 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5387] M03 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5388] M03 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5388] M03 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5388] M03 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5388] M03 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5389] M03 LOTE 4 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5389] M03 LOTE 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5389] M03 LOTE 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5389] M03 LOTE 4 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5390] M03 LOTE 5 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5390] M03 LOTE 5 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5390] M03 LOTE 5 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5390] M03 LOTE 5 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5391] M04 LOTE 1 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5391] M04 LOTE 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5391] M04 LOTE 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5391] M04 LOTE 1 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5392] M04 LOTE 2 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5392] M04 LOTE 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5392] M04 LOTE 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5392] M04 LOTE 2 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5393] M04 LOTE 3 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5393] M04 LOTE 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5393] M04 LOTE 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5393] M04 LOTE 3 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [5394] M04 LOTE 4 RAYMI | Fundo: [ELI] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5394] M04 LOTE 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ELI' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ELI' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[5394] M04 LOTE 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [5394] M04 LOTE 4 RAYMI insertado en fundo [ELI]';
END
GO

-- Sector: [1052] VAL DIST1 LOTE 01 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1052] VAL DIST1 LOTE 01 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1052] VAL DIST1 LOTE 01 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1052] VAL DIST1 LOTE 01 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1053] VAL DIST1 LOTE 02 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1053] VAL DIST1 LOTE 02 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1053] VAL DIST1 LOTE 02 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1053] VAL DIST1 LOTE 02 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1054] VAL DIST1 LOTE 03 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1054] VAL DIST1 LOTE 03 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1054] VAL DIST1 LOTE 03 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1054] VAL DIST1 LOTE 03 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1055] VAL DIST1 LOTE 04 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1055] VAL DIST1 LOTE 04 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1055] VAL DIST1 LOTE 04 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1055] VAL DIST1 LOTE 04 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1056] VAL DIST1 LOTE 05 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1056] VAL DIST1 LOTE 05 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1056] VAL DIST1 LOTE 05 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1056] VAL DIST1 LOTE 05 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1057] VAL DIST1 LOTE 06 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1057] VAL DIST1 LOTE 06 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1057] VAL DIST1 LOTE 06 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1057] VAL DIST1 LOTE 06 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1058] VAL DIST1 LOTE 07 SGL | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1058] VAL DIST1 LOTE 07 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1058] VAL DIST1 LOTE 07 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1058] VAL DIST1 LOTE 07 SGL insertado en fundo [VAL]';
END
GO

-- Sector: [1059] VAL DIST1 LOTE 08 ACR | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1059] VAL DIST1 LOTE 08 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1059] VAL DIST1 LOTE 08 ACR',
        1, 1, 1
    );
    PRINT 'Sector [1059] VAL DIST1 LOTE 08 ACR insertado en fundo [VAL]';
END
GO

-- Sector: [1060] VAL DIST1 LOTE 09 ACR | Fundo: [VAL] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1060] VAL DIST1 LOTE 09 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[1060] VAL DIST1 LOTE 09 ACR',
        1, 1, 1
    );
    PRINT 'Sector [1060] VAL DIST1 LOTE 09 ACR insertado en fundo [VAL]';
END
GO

-- Sector: [2260] M01 SECTOR 1 [1A] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2260] M01 SECTOR 1 [1A] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2260] M01 SECTOR 1 [1A] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2260] M01 SECTOR 1 [1A] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2261] M01 SECTOR 1 [1B] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2261] M01 SECTOR 1 [1B] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2261] M01 SECTOR 1 [1B] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2261] M01 SECTOR 1 [1B] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2262] M01 SECTOR 2 [2A] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2262] M01 SECTOR 2 [2A] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2262] M01 SECTOR 2 [2A] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2262] M01 SECTOR 2 [2A] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2263] M01 SECTOR 2 [2B] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2263] M01 SECTOR 2 [2B] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2263] M01 SECTOR 2 [2B] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2263] M01 SECTOR 2 [2B] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2411] M01 SECTOR 3 [3] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2411] M01 SECTOR 3 [3] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2411] M01 SECTOR 3 [3] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2411] M01 SECTOR 3 [3] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2412] M01 SECTOR 4 [4] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2412] M01 SECTOR 4 [4] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2412] M01 SECTOR 4 [4] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2412] M01 SECTOR 4 [4] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2413] M01 SECTOR 5 [5] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2413] M01 SECTOR 5 [5] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2413] M01 SECTOR 5 [5] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2413] M01 SECTOR 5 [5] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2414] M01 SECTOR 6 [6] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2414] M01 SECTOR 6 [6] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2414] M01 SECTOR 6 [6] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2414] M01 SECTOR 6 [6] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2415] M02 SECTOR 1 [1] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2415] M02 SECTOR 1 [1] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2415] M02 SECTOR 1 [1] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2415] M02 SECTOR 1 [1] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2568] M02 SECTOR 2 [2A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2568] M02 SECTOR 2 [2A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2568] M02 SECTOR 2 [2A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2568] M02 SECTOR 2 [2A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2569] M02 SECTOR 2 [2B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2569] M02 SECTOR 2 [2B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2569] M02 SECTOR 2 [2B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2569] M02 SECTOR 2 [2B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2570] M02 SECTOR 3 [3A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2570] M02 SECTOR 3 [3A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2570] M02 SECTOR 3 [3A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2570] M02 SECTOR 3 [3A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2571] M02 SECTOR 3 [3B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2571] M02 SECTOR 3 [3B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2571] M02 SECTOR 3 [3B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2571] M02 SECTOR 3 [3B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2572] M02 SECTOR 4 [4A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2572] M02 SECTOR 4 [4A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2572] M02 SECTOR 4 [4A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2572] M02 SECTOR 4 [4A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2573] M02 SECTOR 4 [4B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2573] M02 SECTOR 4 [4B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2573] M02 SECTOR 4 [4B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2573] M02 SECTOR 4 [4B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2574] M02 SECTOR 4 [4C] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2574] M02 SECTOR 4 [4C] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2574] M02 SECTOR 4 [4C] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2574] M02 SECTOR 4 [4C] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2575] M02 SECTOR 5 [5A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2575] M02 SECTOR 5 [5A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2575] M02 SECTOR 5 [5A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2575] M02 SECTOR 5 [5A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2736] M02 SECTOR 5 [5B] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2736] M02 SECTOR 5 [5B] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2736] M02 SECTOR 5 [5B] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2736] M02 SECTOR 5 [5B] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2737] M02 SECTOR 6 [6] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2737] M02 SECTOR 6 [6] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2737] M02 SECTOR 6 [6] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2737] M02 SECTOR 6 [6] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2738] M02 SECTOR 7 [7A] RAYMI | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2738] M02 SECTOR 7 [7A] RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2738] M02 SECTOR 7 [7A] RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2738] M02 SECTOR 7 [7A] RAYMI insertado en fundo [VAL]';
END
GO

-- Sector: [2739] M02 SECTOR 7 [7B] ROSITA | Fundo: [VAL] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2739] M02 SECTOR 7 [7B] ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'VAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'VAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2739] M02 SECTOR 7 [7B] ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [2739] M02 SECTOR 7 [7B] ROSITA insertado en fundo [VAL]';
END
GO

-- Sector: [2113] M01 TURNO 1 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2113] M01 TURNO 1 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2113] M01 TURNO 1 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2113] M01 TURNO 1 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2114] M01 TURNO 2 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2114] M01 TURNO 2 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2114] M01 TURNO 2 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2114] M01 TURNO 2 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2115] M01 TURNO 3 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2115] M01 TURNO 3 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2115] M01 TURNO 3 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2115] M01 TURNO 3 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2116] M01 TURNO 4 ROSITA. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2116] M01 TURNO 4 ROSITA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2116] M01 TURNO 4 ROSITA.',
        1, 1, 1
    );
    PRINT 'Sector [2116] M01 TURNO 4 ROSITA. insertado en fundo [ZOE]';
END
GO

-- Sector: [2865] FDO ZOE AUTUMN CRISP M01 LOTE 02 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2865] FDO ZOE AUTUMN CRISP M01 LOTE 02' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2865] FDO ZOE AUTUMN CRISP M01 LOTE 02',
        1, 1, 1
    );
    PRINT 'Sector [2865] FDO ZOE AUTUMN CRISP M01 LOTE 02 insertado en fundo [ZOE]';
END
GO

-- Sector: [2867] FDO ZOE AUTUMN CRISP M01 LOTE 04 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2867] FDO ZOE AUTUMN CRISP M01 LOTE 04' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2867] FDO ZOE AUTUMN CRISP M01 LOTE 04',
        1, 1, 1
    );
    PRINT 'Sector [2867] FDO ZOE AUTUMN CRISP M01 LOTE 04 insertado en fundo [ZOE]';
END
GO

-- Sector: [2869] FDO ZOE AUTUMN CRISP M01 LOTE 06 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2869] FDO ZOE AUTUMN CRISP M01 LOTE 06' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2869] FDO ZOE AUTUMN CRISP M01 LOTE 06',
        1, 1, 1
    );
    PRINT 'Sector [2869] FDO ZOE AUTUMN CRISP M01 LOTE 06 insertado en fundo [ZOE]';
END
GO

-- Sector: [2874] FDO ZOE AUTUMN CRISP M02 LOTE 11 | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2874] FDO ZOE AUTUMN CRISP M02 LOTE 11' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2874] FDO ZOE AUTUMN CRISP M02 LOTE 11',
        1, 1, 1
    );
    PRINT 'Sector [2874] FDO ZOE AUTUMN CRISP M02 LOTE 11 insertado en fundo [ZOE]';
END
GO

-- Sector: [2882] M04 TURNO 4 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[2882] M04 TURNO 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[2882] M04 TURNO 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [2882] M04 TURNO 4 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4538] FDO ZOE ACR ET I SEC 01. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4538] FDO ZOE ACR ET I SEC 01.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4538] FDO ZOE ACR ET I SEC 01.',
        1, 1, 1
    );
    PRINT 'Sector [4538] FDO ZOE ACR ET I SEC 01. insertado en fundo [ZOE]';
END
GO

-- Sector: [4926] FDO ZOE ACR ET I SEC 02. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4926] FDO ZOE ACR ET I SEC 02.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4926] FDO ZOE ACR ET I SEC 02.',
        1, 1, 1
    );
    PRINT 'Sector [4926] FDO ZOE ACR ET I SEC 02. insertado en fundo [ZOE]';
END
GO

-- Sector: [4927] FDO ZOE ACR ET I SEC 03. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4927] FDO ZOE ACR ET I SEC 03.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4927] FDO ZOE ACR ET I SEC 03.',
        1, 1, 1
    );
    PRINT 'Sector [4927] FDO ZOE ACR ET I SEC 03. insertado en fundo [ZOE]';
END
GO

-- Sector: [4928] FDO ZOE ACR ET II SEC 04. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4928] FDO ZOE ACR ET II SEC 04.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4928] FDO ZOE ACR ET II SEC 04.',
        1, 1, 1
    );
    PRINT 'Sector [4928] FDO ZOE ACR ET II SEC 04. insertado en fundo [ZOE]';
END
GO

-- Sector: [4929] FDO ZOE ACR ET II SEC 05. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4929] FDO ZOE ACR ET II SEC 05.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4929] FDO ZOE ACR ET II SEC 05.',
        1, 1, 1
    );
    PRINT 'Sector [4929] FDO ZOE ACR ET II SEC 05. insertado en fundo [ZOE]';
END
GO

-- Sector: [4930] FDO ZOE ACR ET II SEC 06. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4930] FDO ZOE ACR ET II SEC 06.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4930] FDO ZOE ACR ET II SEC 06.',
        1, 1, 1
    );
    PRINT 'Sector [4930] FDO ZOE ACR ET II SEC 06. insertado en fundo [ZOE]';
END
GO

-- Sector: [4931] FDO ZOE ACR ET II SEC 07. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4931] FDO ZOE ACR ET II SEC 07.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4931] FDO ZOE ACR ET II SEC 07.',
        1, 1, 1
    );
    PRINT 'Sector [4931] FDO ZOE ACR ET II SEC 07. insertado en fundo [ZOE]';
END
GO

-- Sector: [4932] FDO ZOE ACR ET III SEC 08. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4932] FDO ZOE ACR ET III SEC 08.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4932] FDO ZOE ACR ET III SEC 08.',
        1, 1, 1
    );
    PRINT 'Sector [4932] FDO ZOE ACR ET III SEC 08. insertado en fundo [ZOE]';
END
GO

-- Sector: [4933] FDO ZOE ACR ET III SEC 09. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4933] FDO ZOE ACR ET III SEC 09.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4933] FDO ZOE ACR ET III SEC 09.',
        1, 1, 1
    );
    PRINT 'Sector [4933] FDO ZOE ACR ET III SEC 09. insertado en fundo [ZOE]';
END
GO

-- Sector: [4934] FDO ZOE ACR ET III SEC 10. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4934] FDO ZOE ACR ET III SEC 10.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4934] FDO ZOE ACR ET III SEC 10.',
        1, 1, 1
    );
    PRINT 'Sector [4934] FDO ZOE ACR ET III SEC 10. insertado en fundo [ZOE]';
END
GO

-- Sector: [4935] FDO ZOE ACR ET IV SEC 11. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4935] FDO ZOE ACR ET IV SEC 11.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4935] FDO ZOE ACR ET IV SEC 11.',
        1, 1, 1
    );
    PRINT 'Sector [4935] FDO ZOE ACR ET IV SEC 11. insertado en fundo [ZOE]';
END
GO

-- Sector: [4936] FDO ZOE ACR ET IV SEC 12. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4936] FDO ZOE ACR ET IV SEC 12.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4936] FDO ZOE ACR ET IV SEC 12.',
        1, 1, 1
    );
    PRINT 'Sector [4936] FDO ZOE ACR ET IV SEC 12. insertado en fundo [ZOE]';
END
GO

-- Sector: [4937] FDO ZOE ACR ET IV SEC 13. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4937] FDO ZOE ACR ET IV SEC 13.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4937] FDO ZOE ACR ET IV SEC 13.',
        1, 1, 1
    );
    PRINT 'Sector [4937] FDO ZOE ACR ET IV SEC 13. insertado en fundo [ZOE]';
END
GO

-- Sector: [4938] FDO ZOE ACR ET IV SEC 14. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4938] FDO ZOE ACR ET IV SEC 14.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4938] FDO ZOE ACR ET IV SEC 14.',
        1, 1, 1
    );
    PRINT 'Sector [4938] FDO ZOE ACR ET IV SEC 14. insertado en fundo [ZOE]';
END
GO

-- Sector: [4939] FDO ZOE FCR ET IV SEC 15. | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4939] FDO ZOE FCR ET IV SEC 15.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4939] FDO ZOE FCR ET IV SEC 15.',
        1, 1, 1
    );
    PRINT 'Sector [4939] FDO ZOE FCR ET IV SEC 15. insertado en fundo [ZOE]';
END
GO

-- Sector: [4942] M02 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4942] M02 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4942] M02 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4942] M02 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4943] M02 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4943] M02 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4943] M02 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4943] M02 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4944] M02 TURNO 3 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4944] M02 TURNO 3 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4944] M02 TURNO 3 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4944] M02 TURNO 3 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4945] M02 TURNO 4 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4945] M02 TURNO 4 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4945] M02 TURNO 4 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4945] M02 TURNO 4 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4946] M03 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4946] M03 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4946] M03 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4946] M03 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4947] M03 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4947] M03 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4947] M03 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4947] M03 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4948] M03 TURNO 3 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4948] M03 TURNO 3 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4948] M03 TURNO 3 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4948] M03 TURNO 3 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4949] M04 TURNO 1 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4949] M04 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4949] M04 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4949] M04 TURNO 1 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4950] M04 TURNO 2 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4950] M04 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4950] M04 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4950] M04 TURNO 2 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4951] M04 TURNO 3 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4951] M04 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4951] M04 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4951] M04 TURNO 3 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4953] M05 TURNO 1 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4953] M05 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4953] M05 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4953] M05 TURNO 1 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4954] M05 TURNO 2 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4954] M05 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4954] M05 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4954] M05 TURNO 2 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4955] M05 TURNO 3 RAYMI | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4955] M05 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4955] M05 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [4955] M05 TURNO 3 RAYMI insertado en fundo [ZOE]';
END
GO

-- Sector: [4956] M06 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4956] M06 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4956] M06 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4956] M06 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4957] M06 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4957] M06 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4957] M06 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4957] M06 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4958] M07 TURNO 1 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4958] M07 TURNO 1 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4958] M07 TURNO 1 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4958] M07 TURNO 1 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [4959] M07 TURNO 2 ROSITA | Fundo: [ZOE] | Empresa: [AGA] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4959] M07 TURNO 2 ROSITA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'ZOE' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'ZOE' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'AGA')),
        '[4959] M07 TURNO 2 ROSITA',
        1, 1, 1
    );
    PRINT 'Sector [4959] M07 TURNO 2 ROSITA insertado en fundo [ZOE]';
END
GO

-- Sector: [200] M01 TURNO 1 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[200] M01 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[200] M01 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [200] M01 TURNO 1 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [201] M01 TURNO 2 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[201] M01 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[201] M01 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [201] M01 TURNO 2 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [202] M02 TURNO 1 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[202] M02 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[202] M02 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [202] M02 TURNO 1 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [203] M02 TURNO 2 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[203] M02 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[203] M02 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [203] M02 TURNO 2 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [204] M03 TURNO 1 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[204] M03 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[204] M03 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [204] M03 TURNO 1 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [205] M03 TURNO 2 RAYMI | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[205] M03 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[205] M03 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [205] M03 TURNO 2 RAYMI insertado en fundo [FS2]';
END
GO

-- Sector: [3733] SZ2 SEC 1 ACR. | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3733] SZ2 SEC 1 ACR.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[3733] SZ2 SEC 1 ACR.',
        1, 1, 1
    );
    PRINT 'Sector [3733] SZ2 SEC 1 ACR. insertado en fundo [FS2]';
END
GO

-- Sector: [3734] SZ2 SEC 2 ACR. | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3734] SZ2 SEC 2 ACR.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[3734] SZ2 SEC 2 ACR.',
        1, 1, 1
    );
    PRINT 'Sector [3734] SZ2 SEC 2 ACR. insertado en fundo [FS2]';
END
GO

-- Sector: [3735] SZ3 SEC 1 ACR. | Fundo: [FS2] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3735] SZ3 SEC 1 ACR.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FS2' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FS2' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[3735] SZ3 SEC 1 ACR.',
        1, 1, 1
    );
    PRINT 'Sector [3735] SZ3 SEC 1 ACR. insertado en fundo [FS2]';
END
GO

-- Sector: [206] M04 TURNO 1 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[206] M04 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[206] M04 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [206] M04 TURNO 1 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [207] M04 TURNO 2 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[207] M04 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[207] M04 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [207] M04 TURNO 2 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [208] M04 TURNO 3 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[208] M04 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[208] M04 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [208] M04 TURNO 3 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [209] M04 TURNO 4 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[209] M04 TURNO 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[209] M04 TURNO 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [209] M04 TURNO 4 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [210] M05 TURNO 1 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[210] M05 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[210] M05 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [210] M05 TURNO 1 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [211] M05 TURNO 2 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[211] M05 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[211] M05 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [211] M05 TURNO 2 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [212] M05 TURNO 3 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[212] M05 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[212] M05 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [212] M05 TURNO 3 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [213] M05 TURNO 4 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[213] M05 TURNO 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[213] M05 TURNO 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [213] M05 TURNO 4 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [214] M05 TURNO 5 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[214] M05 TURNO 5 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[214] M05 TURNO 5 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [214] M05 TURNO 5 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [215] M05 TURNO 6 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[215] M05 TURNO 6 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[215] M05 TURNO 6 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [215] M05 TURNO 6 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [216] M05 TURNO 7 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[216] M05 TURNO 7 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[216] M05 TURNO 7 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [216] M05 TURNO 7 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [217] M06 TURNO 1 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[217] M06 TURNO 1 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[217] M06 TURNO 1 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [217] M06 TURNO 1 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [218] M06 TURNO 2 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[218] M06 TURNO 2 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[218] M06 TURNO 2 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [218] M06 TURNO 2 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [219] M06 TURNO 3 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[219] M06 TURNO 3 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[219] M06 TURNO 3 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [219] M06 TURNO 3 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [220] M06 TURNO 4 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[220] M06 TURNO 4 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[220] M06 TURNO 4 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [220] M06 TURNO 4 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [221] M06 TURNO 5 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[221] M06 TURNO 5 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[221] M06 TURNO 5 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [221] M06 TURNO 5 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [222] M06 TURNO 6 RAYMI | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[222] M06 TURNO 6 RAYMI' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[222] M06 TURNO 6 RAYMI',
        1, 1, 1
    );
    PRINT 'Sector [222] M06 TURNO 6 RAYMI insertado en fundo [FSZ]';
END
GO

-- Sector: [3731] SZ1 SEC 2 ACR. | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3731] SZ1 SEC 2 ACR.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[3731] SZ1 SEC 2 ACR.',
        1, 1, 1
    );
    PRINT 'Sector [3731] SZ1 SEC 2 ACR. insertado en fundo [FSZ]';
END
GO

-- Sector: [3732] SZ1 SEC 3 ACR. | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3732] SZ1 SEC 3 ACR.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[3732] SZ1 SEC 3 ACR.',
        1, 1, 1
    );
    PRINT 'Sector [3732] SZ1 SEC 3 ACR. insertado en fundo [FSZ]';
END
GO

-- Sector: [828] SZ1 SEC 1 ACR. | Fundo: [FSZ] | Empresa: [ARE] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[828] SZ1 SEC 1 ACR.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'FSZ' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'FSZ' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'ARE')),
        '[828] SZ1 SEC 1 ACR.',
        1, 1, 1
    );
    PRINT 'Sector [828] SZ1 SEC 1 ACR. insertado en fundo [FSZ]';
END
GO

-- Sector: [1197] NVA CAL DIST1 A001A JS | Fundo: [BMP] | Empresa: [BMP] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1197] NVA CAL DIST1 A001A JS' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1197] NVA CAL DIST1 A001A JS',
        1, 1, 1
    );
    PRINT 'Sector [1197] NVA CAL DIST1 A001A JS insertado en fundo [BMP]';
END
GO

-- Sector: [1198] NVA CAL DIST1 A001B JS | Fundo: [BMP] | Empresa: [BMP] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1198] NVA CAL DIST1 A001B JS' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1198] NVA CAL DIST1 A001B JS',
        1, 1, 1
    );
    PRINT 'Sector [1198] NVA CAL DIST1 A001B JS insertado en fundo [BMP]';
END
GO

-- Sector: [1199] NVA CAL DIST1 A002 SG | Fundo: [BMP] | Empresa: [BMP] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1199] NVA CAL DIST1 A002 SG' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1199] NVA CAL DIST1 A002 SG',
        1, 1, 1
    );
    PRINT 'Sector [1199] NVA CAL DIST1 A002 SG insertado en fundo [BMP]';
END
GO

-- Sector: [1200] NVA CAL DIST1 A003 SG | Fundo: [BMP] | Empresa: [BMP] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1200] NVA CAL DIST1 A003 SG' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1200] NVA CAL DIST1 A003 SG',
        1, 1, 1
    );
    PRINT 'Sector [1200] NVA CAL DIST1 A003 SG insertado en fundo [BMP]';
END
GO

-- Sector: [1201] NVA CAL DIST2 B001 SGL | Fundo: [BMP] | Empresa: [BMP] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1201] NVA CAL DIST2 B001 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1201] NVA CAL DIST2 B001 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1201] NVA CAL DIST2 B001 SGL insertado en fundo [BMP]';
END
GO

-- Sector: [1202] NVA CAL DIST2 B002 SGL | Fundo: [BMP] | Empresa: [BMP] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1202] NVA CAL DIST2 B002 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1202] NVA CAL DIST2 B002 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1202] NVA CAL DIST2 B002 SGL insertado en fundo [BMP]';
END
GO

-- Sector: [1203] NVA CAL DIST2 B003 SGL | Fundo: [BMP] | Empresa: [BMP] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1203] NVA CAL DIST2 B003 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1203] NVA CAL DIST2 B003 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1203] NVA CAL DIST2 B003 SGL insertado en fundo [BMP]';
END
GO

-- Sector: [1204] NVA CAL DIST3 C001 SGL | Fundo: [BMP] | Empresa: [BMP] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1204] NVA CAL DIST3 C001 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1204] NVA CAL DIST3 C001 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1204] NVA CAL DIST3 C001 SGL insertado en fundo [BMP]';
END
GO

-- Sector: [1205] NVA CAL DIST3 C002 SGL | Fundo: [BMP] | Empresa: [BMP] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1205] NVA CAL DIST3 C002 SGL' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[1205] NVA CAL DIST3 C002 SGL',
        1, 1, 1
    );
    PRINT 'Sector [1205] NVA CAL DIST3 C002 SGL insertado en fundo [BMP]';
END
GO

-- Sector: [6633] NVA CAL DIST3 C003 ACR | Fundo: [BMP] | Empresa: [BMP] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6633] NVA CAL DIST3 C003 ACR' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'BMP' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'BMP' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'BMP')),
        '[6633] NVA CAL DIST3 C003 ACR',
        1, 1, 1
    );
    PRINT 'Sector [6633] NVA CAL DIST3 C003 ACR insertado en fundo [BMP]';
END
GO

-- Sector: [4104] AC1 SECTOR E3A | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4104] AC1 SECTOR E3A' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4104] AC1 SECTOR E3A',
        1, 1, 1
    );
    PRINT 'Sector [4104] AC1 SECTOR E3A insertado en fundo [JOA]';
END
GO

-- Sector: [4105] AC1 SECTOR E4 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4105] AC1 SECTOR E4' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4105] AC1 SECTOR E4',
        1, 1, 1
    );
    PRINT 'Sector [4105] AC1 SECTOR E4 insertado en fundo [JOA]';
END
GO

-- Sector: [4106] AC1 SECTOR E5 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4106] AC1 SECTOR E5' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4106] AC1 SECTOR E5',
        1, 1, 1
    );
    PRINT 'Sector [4106] AC1 SECTOR E5 insertado en fundo [JOA]';
END
GO

-- Sector: [4107] AC1 SECTOR E6 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4107] AC1 SECTOR E6' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4107] AC1 SECTOR E6',
        1, 1, 1
    );
    PRINT 'Sector [4107] AC1 SECTOR E6 insertado en fundo [JOA]';
END
GO

-- Sector: [4108] AC1 SECTOR E7 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4108] AC1 SECTOR E7' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4108] AC1 SECTOR E7',
        1, 1, 1
    );
    PRINT 'Sector [4108] AC1 SECTOR E7 insertado en fundo [JOA]';
END
GO

-- Sector: [4109] AC1 SECTOR E8 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4109] AC1 SECTOR E8' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4109] AC1 SECTOR E8',
        1, 1, 1
    );
    PRINT 'Sector [4109] AC1 SECTOR E8 insertado en fundo [JOA]';
END
GO

-- Sector: [4110] AC1 SECTOR E9 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4110] AC1 SECTOR E9' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4110] AC1 SECTOR E9',
        1, 1, 1
    );
    PRINT 'Sector [4110] AC1 SECTOR E9 insertado en fundo [JOA]';
END
GO

-- Sector: [4111] AC1 SECTOR E10 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4111] AC1 SECTOR E10' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4111] AC1 SECTOR E10',
        1, 1, 1
    );
    PRINT 'Sector [4111] AC1 SECTOR E10 insertado en fundo [JOA]';
END
GO

-- Sector: [4112] JS1 SECTOR F3B | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4112] JS1 SECTOR F3B' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4112] JS1 SECTOR F3B',
        1, 1, 1
    );
    PRINT 'Sector [4112] JS1 SECTOR F3B insertado en fundo [JOA]';
END
GO

-- Sector: [4113] AC1 SECTOR F6 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4113] AC1 SECTOR F6' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4113] AC1 SECTOR F6',
        1, 1, 1
    );
    PRINT 'Sector [4113] AC1 SECTOR F6 insertado en fundo [JOA]';
END
GO

-- Sector: [4114] AC1 SECTOR F7 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4114] AC1 SECTOR F7' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4114] AC1 SECTOR F7',
        1, 1, 1
    );
    PRINT 'Sector [4114] AC1 SECTOR F7 insertado en fundo [JOA]';
END
GO

-- Sector: [4115] AC1 SECTOR F8 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4115] AC1 SECTOR F8' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4115] AC1 SECTOR F8',
        1, 1, 1
    );
    PRINT 'Sector [4115] AC1 SECTOR F8 insertado en fundo [JOA]';
END
GO

-- Sector: [4116] AC1 SECTOR F9 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4116] AC1 SECTOR F9' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4116] AC1 SECTOR F9',
        1, 1, 1
    );
    PRINT 'Sector [4116] AC1 SECTOR F9 insertado en fundo [JOA]';
END
GO

-- Sector: [4117] AC1 SECTOR F10 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[4117] AC1 SECTOR F10' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[4117] AC1 SECTOR F10',
        1, 1, 1
    );
    PRINT 'Sector [4117] AC1 SECTOR F10 insertado en fundo [JOA]';
END
GO

-- Sector: [5773] ACR SECTOR F4 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5773] ACR SECTOR F4' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5773] ACR SECTOR F4',
        1, 1, 1
    );
    PRINT 'Sector [5773] ACR SECTOR F4 insertado en fundo [JOA]';
END
GO

-- Sector: [5774] ACR SECTOR F5 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5774] ACR SECTOR F5' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5774] ACR SECTOR F5',
        1, 1, 1
    );
    PRINT 'Sector [5774] ACR SECTOR F5 insertado en fundo [JOA]';
END
GO

-- Sector: [5780] ACR SECTOR E1 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5780] ACR SECTOR E1' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5780] ACR SECTOR E1',
        1, 1, 1
    );
    PRINT 'Sector [5780] ACR SECTOR E1 insertado en fundo [JOA]';
END
GO

-- Sector: [5781] ACR SECTOR E2 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5781] ACR SECTOR E2' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5781] ACR SECTOR E2',
        1, 1, 1
    );
    PRINT 'Sector [5781] ACR SECTOR E2 insertado en fundo [JOA]';
END
GO

-- Sector: [5782] ACR SECTOR E11 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5782] ACR SECTOR E11' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5782] ACR SECTOR E11',
        1, 1, 1
    );
    PRINT 'Sector [5782] ACR SECTOR E11 insertado en fundo [JOA]';
END
GO

-- Sector: [5783] ACR SECTOR E12 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5783] ACR SECTOR E12' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5783] ACR SECTOR E12',
        1, 1, 1
    );
    PRINT 'Sector [5783] ACR SECTOR E12 insertado en fundo [JOA]';
END
GO

-- Sector: [5784] ACR SECTOR F1 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5784] ACR SECTOR F1' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5784] ACR SECTOR F1',
        1, 1, 1
    );
    PRINT 'Sector [5784] ACR SECTOR F1 insertado en fundo [JOA]';
END
GO

-- Sector: [5785] TMP SECTOR F1 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5785] TMP SECTOR F1' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5785] TMP SECTOR F1',
        1, 1, 1
    );
    PRINT 'Sector [5785] TMP SECTOR F1 insertado en fundo [JOA]';
END
GO

-- Sector: [5786] ACR SECTOR F2 | Fundo: [JOA] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[5786] ACR SECTOR F2' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'JOA' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'JOA' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[5786] ACR SECTOR F2',
        1, 1, 1
    );
    PRINT 'Sector [5786] ACR SECTOR F2 insertado en fundo [JOA]';
END
GO

-- Sector: [6295] ACR SECTOR C8 | Fundo: [NAN] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6295] ACR SECTOR C8' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAN' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAN' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[6295] ACR SECTOR C8',
        1, 1, 1
    );
    PRINT 'Sector [6295] ACR SECTOR C8 insertado en fundo [NAN]';
END
GO

-- Sector: [6296] ACR SECTOR D8 | Fundo: [NAN] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6296] ACR SECTOR D8' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAN' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAN' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[6296] ACR SECTOR D8',
        1, 1, 1
    );
    PRINT 'Sector [6296] ACR SECTOR D8 insertado en fundo [NAN]';
END
GO

-- Sector: [6297] FCR SECTOR C9 | Fundo: [NAN] | Empresa: [NEW] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[6297] FCR SECTOR C9' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAN' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAN' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'NEW')),
        '[6297] FCR SECTOR C9',
        1, 1, 1
    );
    PRINT 'Sector [6297] FCR SECTOR C9 insertado en fundo [NAN]';
END
GO

-- Sector: [3104] CAL M01 SECTOR 09 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3104] CAL M01 SECTOR 09 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3104] CAL M01 SECTOR 09 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3104] CAL M01 SECTOR 09 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3126] CAL M09 SECTOR 13 OZ OLIVIA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3126] CAL M09 SECTOR 13 OZ OLIVIA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3126] CAL M09 SECTOR 13 OZ OLIVIA',
        1, 1, 1
    );
    PRINT 'Sector [3126] CAL M09 SECTOR 13 OZ OLIVIA insertado en fundo [CAL]';
END
GO

-- Sector: [3127] CAL M10 SECTOR 01 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3127] CAL M10 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3127] CAL M10 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3127] CAL M10 SECTOR 01 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3128] CAL M10 SECTOR 02 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3128] CAL M10 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3128] CAL M10 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3128] CAL M10 SECTOR 02 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3129] CAL M10 SECTOR 03 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3129] CAL M10 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3129] CAL M10 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3129] CAL M10 SECTOR 03 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3130] CAL M11 SECTOR 01 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3130] CAL M11 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3130] CAL M11 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3130] CAL M11 SECTOR 01 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3373] CAL M11 SECTOR 02 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3373] CAL M11 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3373] CAL M11 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3373] CAL M11 SECTOR 02 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3374] CAL M11 SECTOR 03 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3374] CAL M11 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3374] CAL M11 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3374] CAL M11 SECTOR 03 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [3375] CAL M12 SECTOR 01 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[3375] CAL M12 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[3375] CAL M12 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [3375] CAL M12 SECTOR 01 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [508] CAL M13 SECTOR 09 OZ DINA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[508] CAL M13 SECTOR 09 OZ DINA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[508] CAL M13 SECTOR 09 OZ DINA',
        1, 1, 1
    );
    PRINT 'Sector [508] CAL M13 SECTOR 09 OZ DINA insertado en fundo [CAL]';
END
GO

-- Sector: [669] CAL M13 SECTOR 07 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[669] CAL M13 SECTOR 07 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[669] CAL M13 SECTOR 07 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [669] CAL M13 SECTOR 07 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [670] CAL M13 SECTOR 08 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[670] CAL M13 SECTOR 08 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[670] CAL M13 SECTOR 08 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [670] CAL M13 SECTOR 08 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [671] CAL M13 SECTOR 04 OZ DINA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[671] CAL M13 SECTOR 04 OZ DINA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[671] CAL M13 SECTOR 04 OZ DINA',
        1, 1, 1
    );
    PRINT 'Sector [671] CAL M13 SECTOR 04 OZ DINA insertado en fundo [CAL]';
END
GO

-- Sector: [673] CAL M13 SECTOR 06 OZ CAROLINA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[673] CAL M13 SECTOR 06 OZ CAROLINA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[673] CAL M13 SECTOR 06 OZ CAROLINA',
        1, 1, 1
    );
    PRINT 'Sector [673] CAL M13 SECTOR 06 OZ CAROLINA insertado en fundo [CAL]';
END
GO

-- Sector: [674] CAL M13 SECTOR 02 OZ ANDREA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[674] CAL M13 SECTOR 02 OZ ANDREA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[674] CAL M13 SECTOR 02 OZ ANDREA',
        1, 1, 1
    );
    PRINT 'Sector [674] CAL M13 SECTOR 02 OZ ANDREA insertado en fundo [CAL]';
END
GO

-- Sector: [687] CAL M01 SECTOR 01 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[687] CAL M01 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[687] CAL M01 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [687] CAL M01 SECTOR 01 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [689] CAL M01 SECTOR 08 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[689] CAL M01 SECTOR 08 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[689] CAL M01 SECTOR 08 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [689] CAL M01 SECTOR 08 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [691] CAL M01 SECTOR 09 OZ CAROLINA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[691] CAL M01 SECTOR 09 OZ CAROLINA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[691] CAL M01 SECTOR 09 OZ CAROLINA',
        1, 1, 1
    );
    PRINT 'Sector [691] CAL M01 SECTOR 09 OZ CAROLINA insertado en fundo [CAL]';
END
GO

-- Sector: [692] CAL M02 SECTOR 01 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 8
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[692] CAL M02 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[692] CAL M02 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [692] CAL M02 SECTOR 01 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [694] CAL M03 SECTOR 03 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 8
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[694] CAL M03 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[694] CAL M03 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [694] CAL M03 SECTOR 03 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [696] CAL M04 SECTOR 01 OZ JULIETA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[696] CAL M04 SECTOR 01 OZ JULIETA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[696] CAL M04 SECTOR 01 OZ JULIETA',
        1, 1, 1
    );
    PRINT 'Sector [696] CAL M04 SECTOR 01 OZ JULIETA insertado en fundo [CAL]';
END
GO

-- Sector: [699] CAL M05 SECTOR 03 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[699] CAL M05 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[699] CAL M05 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [699] CAL M05 SECTOR 03 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [700] CAL M05 SECTOR 04 OZ CAROLINA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[700] CAL M05 SECTOR 04 OZ CAROLINA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[700] CAL M05 SECTOR 04 OZ CAROLINA',
        1, 1, 1
    );
    PRINT 'Sector [700] CAL M05 SECTOR 04 OZ CAROLINA insertado en fundo [CAL]';
END
GO

-- Sector: [702] CAL M06 SECTOR 02 OZ OLIVIA. | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[702] CAL M06 SECTOR 02 OZ OLIVIA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[702] CAL M06 SECTOR 02 OZ OLIVIA.',
        1, 1, 1
    );
    PRINT 'Sector [702] CAL M06 SECTOR 02 OZ OLIVIA. insertado en fundo [CAL]';
END
GO

-- Sector: [705] CAL M06 SECTOR 06 OZ CAROLINA. | Fundo: [CAL] | Empresa: [OZB] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[705] CAL M06 SECTOR 06 OZ CAROLINA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[705] CAL M06 SECTOR 06 OZ CAROLINA.',
        1, 1, 1
    );
    PRINT 'Sector [705] CAL M06 SECTOR 06 OZ CAROLINA. insertado en fundo [CAL]';
END
GO

-- Sector: [706] CAL M08 SECTOR 01 OZ MAGICA. | Fundo: [CAL] | Empresa: [OZB] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[706] CAL M08 SECTOR 01 OZ MAGICA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[706] CAL M08 SECTOR 01 OZ MAGICA.',
        1, 1, 1
    );
    PRINT 'Sector [706] CAL M08 SECTOR 01 OZ MAGICA. insertado en fundo [CAL]';
END
GO

-- Sector: [710] CAL M09 SECTOR 08 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[710] CAL M09 SECTOR 08 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[710] CAL M09 SECTOR 08 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [710] CAL M09 SECTOR 08 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [711] CAL M09 SECTOR 10 OZ ANDREA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 10
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[711] CAL M09 SECTOR 10 OZ ANDREA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[711] CAL M09 SECTOR 10 OZ ANDREA',
        1, 1, 1
    );
    PRINT 'Sector [711] CAL M09 SECTOR 10 OZ ANDREA insertado en fundo [CAL]';
END
GO

-- Sector: [712] CAL M14 SECTOR 01 OZ ANDREA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[712] CAL M14 SECTOR 01 OZ ANDREA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[712] CAL M14 SECTOR 01 OZ ANDREA',
        1, 1, 1
    );
    PRINT 'Sector [712] CAL M14 SECTOR 01 OZ ANDREA insertado en fundo [CAL]';
END
GO

-- Sector: [714] CAL M15 SECTOR 02 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[714] CAL M15 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[714] CAL M15 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [714] CAL M15 SECTOR 02 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [723] CAL M01 SECTOR 03 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[723] CAL M01 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[723] CAL M01 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [723] CAL M01 SECTOR 03 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [725] CAL M01 SECTOR 06 OZ JULIETA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[725] CAL M01 SECTOR 06 OZ JULIETA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[725] CAL M01 SECTOR 06 OZ JULIETA',
        1, 1, 1
    );
    PRINT 'Sector [725] CAL M01 SECTOR 06 OZ JULIETA insertado en fundo [CAL]';
END
GO

-- Sector: [728] CAL M03 SECTOR 02 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[728] CAL M03 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[728] CAL M03 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [728] CAL M03 SECTOR 02 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [730] CAL M03 SECTOR 06 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[730] CAL M03 SECTOR 06 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[730] CAL M03 SECTOR 06 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [730] CAL M03 SECTOR 06 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [732] CAL M04 SECTOR 02 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[732] CAL M04 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[732] CAL M04 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [732] CAL M04 SECTOR 02 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [733] CAL M05 SECTOR 02 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[733] CAL M05 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[733] CAL M05 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [733] CAL M05 SECTOR 02 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [736] CAL M06 SECTOR 01 OZ MAGICA. | Fundo: [CAL] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[736] CAL M06 SECTOR 01 OZ MAGICA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[736] CAL M06 SECTOR 01 OZ MAGICA.',
        1, 1, 1
    );
    PRINT 'Sector [736] CAL M06 SECTOR 01 OZ MAGICA. insertado en fundo [CAL]';
END
GO

-- Sector: [738] CAL M06 SECTOR 03 OZ ANDREA. | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[738] CAL M06 SECTOR 03 OZ ANDREA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[738] CAL M06 SECTOR 03 OZ ANDREA.',
        1, 1, 1
    );
    PRINT 'Sector [738] CAL M06 SECTOR 03 OZ ANDREA. insertado en fundo [CAL]';
END
GO

-- Sector: [742] CAL M08 SECTOR 02 OZ MAGICA. | Fundo: [CAL] | Empresa: [OZB] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[742] CAL M08 SECTOR 02 OZ MAGICA.' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[742] CAL M08 SECTOR 02 OZ MAGICA.',
        1, 1, 1
    );
    PRINT 'Sector [742] CAL M08 SECTOR 02 OZ MAGICA. insertado en fundo [CAL]';
END
GO

-- Sector: [743] CAL M09 SECTOR 06 OZ OLIVIA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 3
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[743] CAL M09 SECTOR 06 OZ OLIVIA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[743] CAL M09 SECTOR 06 OZ OLIVIA',
        1, 1, 1
    );
    PRINT 'Sector [743] CAL M09 SECTOR 06 OZ OLIVIA insertado en fundo [CAL]';
END
GO

-- Sector: [744] CAL M09 SECTOR 09 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[744] CAL M09 SECTOR 09 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[744] CAL M09 SECTOR 09 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [744] CAL M09 SECTOR 09 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [748] CAL M15 SECTOR 01 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[748] CAL M15 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[748] CAL M15 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [748] CAL M15 SECTOR 01 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [757] CAL M05 SECTOR 05 OZ MAGICA | Fundo: [CAL] | Empresa: [OZB] | Lotes: 4
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[757] CAL M05 SECTOR 05 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'CAL' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'CAL' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[757] CAL M05 SECTOR 05 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [757] CAL M05 SECTOR 05 OZ MAGICA insertado en fundo [CAL]';
END
GO

-- Sector: [1185] NAT M02 SECTOR 01 OZ MAGICA.. | Fundo: [NAT] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1185] NAT M02 SECTOR 01 OZ MAGICA..' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[1185] NAT M02 SECTOR 01 OZ MAGICA..',
        1, 1, 1
    );
    PRINT 'Sector [1185] NAT M02 SECTOR 01 OZ MAGICA.. insertado en fundo [NAT]';
END
GO

-- Sector: [1188] NAT M03 SECTOR 01 OZ MAGICA.. | Fundo: [NAT] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1188] NAT M03 SECTOR 01 OZ MAGICA..' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[1188] NAT M03 SECTOR 01 OZ MAGICA..',
        1, 1, 1
    );
    PRINT 'Sector [1188] NAT M03 SECTOR 01 OZ MAGICA.. insertado en fundo [NAT]';
END
GO

-- Sector: [1190] NAT M04 SECTOR 01 OZ MAGICA.. | Fundo: [NAT] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[1190] NAT M04 SECTOR 01 OZ MAGICA..' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[1190] NAT M04 SECTOR 01 OZ MAGICA..',
        1, 1, 1
    );
    PRINT 'Sector [1190] NAT M04 SECTOR 01 OZ MAGICA.. insertado en fundo [NAT]';
END
GO

-- Sector: [675] NAT M05 SECTOR 02 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[675] NAT M05 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[675] NAT M05 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [675] NAT M05 SECTOR 02 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [680] NAT M01 SECTOR 01 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 12
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[680] NAT M01 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[680] NAT M01 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [680] NAT M01 SECTOR 01 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [682] NAT M02 SECTOR 02 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[682] NAT M02 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[682] NAT M02 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [682] NAT M02 SECTOR 02 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [684] NAT M03 SECTOR 01 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 6
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[684] NAT M03 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[684] NAT M03 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [684] NAT M03 SECTOR 01 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [686] NAT M04 SECTOR 01 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 5
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[686] NAT M04 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[686] NAT M04 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [686] NAT M04 SECTOR 01 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [716] NAT M02 SECTOR 01 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[716] NAT M02 SECTOR 01 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[716] NAT M02 SECTOR 01 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [716] NAT M02 SECTOR 01 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [718] NAT M02 SECTOR 03 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 2
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[718] NAT M02 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[718] NAT M02 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [718] NAT M02 SECTOR 03 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [720] NAT M03 SECTOR 02 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[720] NAT M03 SECTOR 02 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[720] NAT M03 SECTOR 02 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [720] NAT M03 SECTOR 02 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- Sector: [756] NAT M05 SECTOR 03 OZ MAGICA | Fundo: [NAT] | Empresa: [OZB] | Lotes: 1
IF NOT EXISTS (
    SELECT 1 FROM sense.ubicacion 
    WHERE ubicacion = '[756] NAT M05 SECTOR 03 OZ MAGICA' 
    AND fundoid = (
        SELECT fundoid FROM sense.fundo 
        WHERE fundoabrev = 'NAT' 
        AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')
    )
)
BEGIN
    INSERT INTO sense.ubicacion (fundoid, ubicacion, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM sense.fundo WHERE fundoabrev = 'NAT' AND empresaid = (SELECT empresaid FROM sense.empresa WHERE empresabrev = 'OZB')),
        '[756] NAT M05 SECTOR 03 OZ MAGICA',
        1, 1, 1
    );
    PRINT 'Sector [756] NAT M05 SECTOR 03 OZ MAGICA insertado en fundo [NAT]';
END
GO

-- =====================================================
-- 5. LOTES
-- Total: 509
-- CASCADA: Cada lote pertenece a un sector específico
-- NOTA: Los lotes están en grower.lot que es parte del sistema existente
--       No se insertan aquí para no duplicar datos
--       Este listado es solo informativo con IDs y Nombres
-- =====================================================

-- Sector: [2779] CAL DIST2 C011 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1509] LOTE 140, [1510] LOTE 139, [1511] LOTE 138

-- Sector: [2820] CAL DIST2 G003 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1601] LOTE 144, [1602] LOTE 145, [1603] LOTE 146, [1604] LOTE 147

-- Sector: [2821] CAL DIST2 F008 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1490] LOTE 148, [1491] LOTE 149

-- Sector: [2838] CAL DIST2 C012 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1506] LOTE 143, [1507] LOTE 142, [1508] LOTE 141

-- Sector: [2839] CAL DIST3 E001-01 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1483] LOTE 74B

-- Sector: [5848] CAL DIST3 F009 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1737] LOTE 176, [1738] LOTE 177, [1739] LOTE 178

-- Sector: [6659] CAL DIST1 A003 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1799] LOTE 155, [1800] LOTE 156

-- Sector: [6682] CAL DIST1 B008 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1815] LOTE 152, [1813] LOTE 150, [1814] LOTE 151

-- Sector: [6683] CAL DIST1 B009 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1816] LOTE 153, [1817] LOTE 154

-- Sector: [6729] CAL DIST2 D007 FCA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1826] LOTE 164, [1827] LOTE 165, [1828] LOTE 166, [1829] LOTE 167

-- Sector: [6730] CAL DIST2 D009 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1823] LOTE 173, [1824] LOTE 174, [1825] LOTE 175

-- Sector: [6731] CAL DIST2 C014 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1832] LOTE 157, [1833] LOTE 158, [1834] LOTE 159

-- Sector: [6778] CAL DIST2 D008 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (5): [1818] LOTE 169, [1819] LOTE 170, [1820] LOTE 171, [1821] LOTE 172, [1822] LOTE 168

-- Sector: [6780] CAL DIST3 C013 CCA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1830] LOTE 180, [1831] LOTE 181

-- Sector: [6782] CAL DIST2 C015 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1835] LOTE 160, [1836] LOTE 161, [1837] LOTE 162, [1838] LOTE 163

-- Sector: [781] CAL DIST1 A002 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [98] LOTE 19, [99] LOTE 20, [100] LOTE 21

-- Sector: [789] CAL DIST1 A011 SGL.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [119] LOTE 122, [122] LOTE 125

-- Sector: [910] CAL DIST1 A004 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1480] LOTE 23, [1481] LOTE 25, [1482] LOTE 27

-- Sector: [911] CAL DIST1 A005 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1298] LOTE 26, [1299] LOTE 28

-- Sector: [912] CAL DIST1 A006 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1236] LOTE 29, [1237] LOTE 30, [1238] LOTE 31

-- Sector: [913] CAL DIST1 A007 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1300] LOTE 114, [1301] LOTE 115, [1302] LOTE 118

-- Sector: [914] CAL DIST1 A008 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1303] LOTE 121, [1304] LOTE 124

-- Sector: [915] CAL DIST1 A009 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1242] LOTE 117, [1243] LOTE 116, [1244] LOTE 119

-- Sector: [916] CAL DIST1 A010 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1305] LOTE 120, [1306] LOTE 123

-- Sector: [923] CAL DIST1 B006A SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1568] LOTE 09, [1569] LOTE 12, [1570] LOTE 13A

-- Sector: [924] CAL DIST1 B006B SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1492] LOTE 11

-- Sector: [926] CAL DIST1 B005 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1553] LOTE 10

-- Sector: [931] CAL DIST2 C004 CCA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1252] LOTE 40, [1253] LOTE 38, [1254] LOTE 35, [1255] LOTE 32

-- Sector: [932] CAL DIST2 C005 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1571] LOTE 42, [1572] LOTE 44

-- Sector: [933] CAL DIST2 C006 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1573] LOTE 47, [1574] LOTE 48

-- Sector: [934] CAL DIST2 C007 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1576] LOTE 51, [1577] LOTE 52

-- Sector: [935] CAL DIST2 C008 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1575] LOTE 50, [1578] LOTE 53, [1579] LOTE 54

-- Sector: [936] CAL DIST2 C009 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1580] LOTE 55, [1581] LOTE 56, [1582] LOTE 57

-- Sector: [937] CAL DIST2 C010 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1599] LOTE 46, [1600] LOTE 49

-- Sector: [938] CAL DIST2 D001A JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1583] LOTE 58, [1584] LOTE 59, [1585] LOTE 61, [1597] LOTE 60B

-- Sector: [939] CAL DIST2 D002 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (6): [1291] LOTE 62, [1586] LOTE 63, [1587] LOTE 64, [1588] LOTE 65, [1589] LOTE 66... (+1 más)

-- Sector: [940] CAL DIST2 D003 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1590] LOTE 67, [1591] LOTE 68, [1592] LOTE 69, [1593] LOTE 70

-- Sector: [941] CAL DIST2 D004 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1256] LOTE 71, [1257] LOTE 73, [1308] LOTE 72

-- Sector: [942] CAL DIST2 D005 ACR
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1594] LOTE 128, [1595] LOTE 130

-- Sector: [943] CAL DIST2 D006 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1230] LOTE 129, [1231] LOTE 131

-- Sector: [944] CAL DIST2 G002 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (4): [1282] LOTE 133, [1283] LOTE 135, [1284] LOTE 137, [1287] LOTE 136B

-- Sector: [945] CAL DIST2 G001 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1285] LOTE 132, [1286] LOTE 134, [1598] LOTE 136A

-- Sector: [946] CAL DIST3 E001 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1265] LOTE 75, [1266] LOTE 74A

-- Sector: [947] CAL DIST3 E002 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1267] LOTE 78, [1268] LOTE 77, [1269] LOTE 76

-- Sector: [948] CAL DIST3 E003 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1484] LOTE 81, [1485] LOTE 80, [1486] LOTE 79

-- Sector: [949] CAL DIST3 E004 JSA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1487] LOTE 84, [1488] LOTE 83, [1489] LOTE 82

-- Sector: [950] CAL DIST3 E005 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1262] LOTE 87, [1263] LOTE 86, [1264] LOTE 85

-- Sector: [951] CAL DIST3 E006 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1260] LOTE 90, [1261] LOTE 89

-- Sector: [952] CAL DIST3 E007 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1258] LOTE 93, [1259] LOTE 92

-- Sector: [953] CAL DIST3 E008 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1280] LOTE 96, [1281] LOTE 95

-- Sector: [954] CAL DIST3 E009 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1249] LOTE 88, [1250] LOTE 91, [1251] LOTE 94

-- Sector: [955] CAL DIST3 F006 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1239] LOTE 102, [1240] LOTE 100, [1241] LOTE 97

-- Sector: [956] CAL DIST3 F007 SGL
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (5): [1232] LOTE 112, [1233] LOTE 110, [1234] LOTE 108, [1235] LOTE 106, [1307] LOTE 104

-- Sector: [957] CAL DIST3 F001 CCA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1270] LOTE 99, [1272] LOTE 98, [1274] LOTE 101

-- Sector: [958] CAL DIST3 F002 CCA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1276] LOTE 103

-- Sector: [961] CAL DIST3 F003 CCA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1278] LOTE 105

-- Sector: [1033] CAR DIST1 CARRIZALES-LOTE
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1003] CARRIZALES A, [1021] CARRIZALES B

-- Sector: [761] CAR DIST1 SAN PABLO A
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1010] SAN PABLO A

-- Sector: [762] CAR DIST1 SAN PABLO B
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1020] SAN PABLO B

-- Sector: [763] CAR DIST1 ZAPATA 1
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1011] ZAPATA 1A, [1012] ZAPATA 1B

-- Sector: [764] CAR DIST1 ZAPATA 2
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1013] ZAPATA 2A, [1014] ZAPATA 2B, [1015] ZAPATA 2C

-- Sector: [767] CAR DIST1 SAN FRANCISCO A
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1006] SAN FRANCISCO A

-- Sector: [769] CAR DIST2 SANTA RITA A
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1004] SANTA RITA A

-- Sector: [770] CAR DIST2 SANTA RITA B
--   Fundo: [CAR] FUNDO CARRIZALES
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1005] SANTA RITA B

-- Sector: [5380] M01 LOTE 1 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1754] T1

-- Sector: [5381] M01 LOTE 2 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1755] T2

-- Sector: [5382] M01 LOTE 3 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1756] T3

-- Sector: [5383] M02 LOTE 1 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1757] T1

-- Sector: [5384] M02 LOTE 2 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1758] T2

-- Sector: [5385] M02 LOTE 3 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1759] T3

-- Sector: [5386] M03 LOTE 1 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1760] T1

-- Sector: [5387] M03 LOTE 2 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1761] T2

-- Sector: [5388] M03 LOTE 3 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1762] T3

-- Sector: [5389] M03 LOTE 4 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1763] T4

-- Sector: [5390] M03 LOTE 5 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1764] T5

-- Sector: [5391] M04 LOTE 1 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1765] T1

-- Sector: [5392] M04 LOTE 2 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1766] T2

-- Sector: [5393] M04 LOTE 3 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1767] T3

-- Sector: [5394] M04 LOTE 4 RAYMI
--   Fundo: [ELI] FUNDO ELISE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1768] T4

-- Sector: [1052] VAL DIST1 LOTE 01 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1094] LOTE 1A, [1095] LOTE 1B, [1096] LOTE 1C

-- Sector: [1053] VAL DIST1 LOTE 02 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1097] LOTE 2A, [1098] LOTE 2B

-- Sector: [1054] VAL DIST1 LOTE 03 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1099] LOTE 3A, [1100] LOTE 3B

-- Sector: [1055] VAL DIST1 LOTE 04 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1101] LOTE 4A, [1102] LOTE 4B

-- Sector: [1056] VAL DIST1 LOTE 05 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1103] LOTE 5A

-- Sector: [1057] VAL DIST1 LOTE 06 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1104] LOTE 6A, [1105] LOTE 6B

-- Sector: [1058] VAL DIST1 LOTE 07 SGL
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1106] LOTE 7A, [1107] LOTE 7B

-- Sector: [1059] VAL DIST1 LOTE 08 ACR
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1108] LOTE 8A, [1109] LOTE 8B

-- Sector: [1060] VAL DIST1 LOTE 09 ACR
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1110] LOTE 9A, [1111] LOTE 9B

-- Sector: [2260] M01 SECTOR 1 [1A] ROSITA
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1022] T1A

-- Sector: [2261] M01 SECTOR 1 [1B] ROSITA
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1023] T1B

-- Sector: [2262] M01 SECTOR 2 [2A] ROSITA
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1024] T2A

-- Sector: [2263] M01 SECTOR 2 [2B] ROSITA
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1025] T2B

-- Sector: [2411] M01 SECTOR 3 [3] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1026] T3

-- Sector: [2412] M01 SECTOR 4 [4] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1027] T4

-- Sector: [2413] M01 SECTOR 5 [5] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1028] T5

-- Sector: [2414] M01 SECTOR 6 [6] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1029] T6

-- Sector: [2415] M02 SECTOR 1 [1] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1030] T1

-- Sector: [2568] M02 SECTOR 2 [2A] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1031] T2A

-- Sector: [2569] M02 SECTOR 2 [2B] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1032] T2B

-- Sector: [2570] M02 SECTOR 3 [3A] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1033] T3A

-- Sector: [2571] M02 SECTOR 3 [3B] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1034] T3B

-- Sector: [2572] M02 SECTOR 4 [4A] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1035] T4A

-- Sector: [2573] M02 SECTOR 4 [4B] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1036] T4B

-- Sector: [2574] M02 SECTOR 4 [4C] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1037] T4C

-- Sector: [2575] M02 SECTOR 5 [5A] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1038] T5A

-- Sector: [2736] M02 SECTOR 5 [5B] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1039] T5B

-- Sector: [2737] M02 SECTOR 6 [6] ROSITA
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1040] T6

-- Sector: [2738] M02 SECTOR 7 [7A] RAYMI
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1041] 7A

-- Sector: [2739] M02 SECTOR 7 [7B] ROSITA
--   Fundo: [VAL] FDO. VALERIE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1042] 7B

-- Sector: [2113] M01 TURNO 1 ROSITA.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1700] T1

-- Sector: [2114] M01 TURNO 2 ROSITA.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1701] T2

-- Sector: [2115] M01 TURNO 3 ROSITA.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1702] T3

-- Sector: [2116] M01 TURNO 4 ROSITA.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1703] T4

-- Sector: [2865] FDO ZOE AUTUMN CRISP M01 LOTE 02
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1053] LOTE 02

-- Sector: [2867] FDO ZOE AUTUMN CRISP M01 LOTE 04
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1055] LOTE 04

-- Sector: [2869] FDO ZOE AUTUMN CRISP M01 LOTE 06
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1057] LOTE 06

-- Sector: [2874] FDO ZOE AUTUMN CRISP M02 LOTE 11
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1062] LOTE 11

-- Sector: [2882] M04 TURNO 4 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1089] T4

-- Sector: [4538] FDO ZOE ACR ET I SEC 01.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1636] LOTE 01, [1637] LOTE 02

-- Sector: [4926] FDO ZOE ACR ET I SEC 02.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1638] LOTE 03, [1639] LOTE 04

-- Sector: [4927] FDO ZOE ACR ET I SEC 03.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1640] LOTE 05, [1641] LOTE 06

-- Sector: [4928] FDO ZOE ACR ET II SEC 04.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1642] LOTE 07

-- Sector: [4929] FDO ZOE ACR ET II SEC 05.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1643] LOTE 08

-- Sector: [4930] FDO ZOE ACR ET II SEC 06.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1644] LOTE 09

-- Sector: [4931] FDO ZOE ACR ET II SEC 07.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1645] LOTE 10, [1646] LOTE 11

-- Sector: [4932] FDO ZOE ACR ET III SEC 08.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1647] LOTE 01, [1648] LOTE 02

-- Sector: [4933] FDO ZOE ACR ET III SEC 09.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1649] LOTE 03, [1650] LOTE 04

-- Sector: [4934] FDO ZOE ACR ET III SEC 10.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (3): [1651] LOTE 05, [1652] LOTE 06, [1653] LOTE 07

-- Sector: [4935] FDO ZOE ACR ET IV SEC 11.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1654] LOTE 01, [1655] LOTE 02

-- Sector: [4936] FDO ZOE ACR ET IV SEC 12.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1656] LOTE 03, [1657] LOTE 04

-- Sector: [4937] FDO ZOE ACR ET IV SEC 13.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1658] LOTE 05, [1659] LOTE 06

-- Sector: [4938] FDO ZOE ACR ET IV SEC 14.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1660] LOTE 07, [1661] LOTE 08

-- Sector: [4939] FDO ZOE FCR ET IV SEC 15.
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (2): [1662] LOTE 09, [1663] LOTE 10

-- Sector: [4942] M02 TURNO 1 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1704] T1

-- Sector: [4943] M02 TURNO 2 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1705] T2

-- Sector: [4944] M02 TURNO 3 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1706] T3

-- Sector: [4945] M02 TURNO 4 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1707] T4

-- Sector: [4946] M03 TURNO 1 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1708] T1

-- Sector: [4947] M03 TURNO 2 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1709] T2

-- Sector: [4948] M03 TURNO 3 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1710] T3

-- Sector: [4949] M04 TURNO 1 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1713] T1

-- Sector: [4950] M04 TURNO 2 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1714] T2

-- Sector: [4951] M04 TURNO 3 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1715] T3

-- Sector: [4953] M05 TURNO 1 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1711] T1

-- Sector: [4954] M05 TURNO 2 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1712] T2

-- Sector: [4955] M05 TURNO 3 RAYMI
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1801] T3

-- Sector: [4956] M06 TURNO 1 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1740] T1

-- Sector: [4957] M06 TURNO 2 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1741] T2

-- Sector: [4958] M07 TURNO 1 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1742] T1

-- Sector: [4959] M07 TURNO 2 ROSITA
--   Fundo: [ZOE] FUNDO ZOE
--   Empresa: [AGA] AGRICOLA ANDREA
--   Lotes (1): [1743] T2

-- Sector: [200] M01 TURNO 1 RAYMI
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1669] T1

-- Sector: [201] M01 TURNO 2 RAYMI
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1670] T2

-- Sector: [202] M02 TURNO 1 RAYMI
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1671] T1

-- Sector: [203] M02 TURNO 2 RAYMI
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1672] T2

-- Sector: [204] M03 TURNO 1 RAYMI
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1673] T1

-- Sector: [205] M03 TURNO 2 RAYMI
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1674] T2

-- Sector: [3733] SZ2 SEC 1 ACR.
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1446] LOTE 07

-- Sector: [3734] SZ2 SEC 2 ACR.
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1447] LOTE 08

-- Sector: [3735] SZ3 SEC 1 ACR.
--   Fundo: [FS2] FDO. SANTA ZOILA 2,3
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1448] LOTE 09

-- Sector: [206] M04 TURNO 1 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1675] T1

-- Sector: [207] M04 TURNO 2 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1676] T2

-- Sector: [208] M04 TURNO 3 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1677] T3

-- Sector: [209] M04 TURNO 4 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1678] T4

-- Sector: [210] M05 TURNO 1 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1679] T1

-- Sector: [211] M05 TURNO 2 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1680] T2

-- Sector: [212] M05 TURNO 3 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1681] T3

-- Sector: [213] M05 TURNO 4 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1682] T4

-- Sector: [214] M05 TURNO 5 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1683] T5

-- Sector: [215] M05 TURNO 6 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1684] T6

-- Sector: [216] M05 TURNO 7 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1685] T7

-- Sector: [217] M06 TURNO 1 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1686] T1

-- Sector: [218] M06 TURNO 2 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1687] T2

-- Sector: [219] M06 TURNO 3 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1688] T3

-- Sector: [220] M06 TURNO 4 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1689] T4

-- Sector: [221] M06 TURNO 5 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1690] T5

-- Sector: [222] M06 TURNO 6 RAYMI
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (1): [1691] T6

-- Sector: [3731] SZ1 SEC 2 ACR.
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (2): [1422] LOTE 03, [1423] LOTE 04

-- Sector: [3732] SZ1 SEC 3 ACR.
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (2): [1424] LOTE 05, [1425] LOTE 06

-- Sector: [828] SZ1 SEC 1 ACR.
--   Fundo: [FSZ] FDO. SANTA ZOILA ARENUVA
--   Empresa: [ARE] ARENUVA S.A.C.
--   Lotes (2): [1330] LOTE 01, [1331] LOTE 02

-- Sector: [1197] NVA CAL DIST1 A001A JS
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (4): [1605] LOTE 1, [1606] LOTE 2, [1607] LOTE 4, [1608] LOTE 5

-- Sector: [1198] NVA CAL DIST1 A001B JS
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (1): [1609] LOTE 3

-- Sector: [1199] NVA CAL DIST1 A002 SG
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (6): [1610] LOTE 6, [1611] LOTE 7, [1612] LOTE 8, [1613] LOTE 9, [1614] LOTE 13... (+1 más)

-- Sector: [1200] NVA CAL DIST1 A003 SG
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (5): [1616] LOTE 10, [1617] LOTE 11, [1618] LOTE 12, [1619] LOTE 15, [1620] LOTE 16

-- Sector: [1201] NVA CAL DIST2 B001 SGL
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (5): [1472] LOTE 21, [1473] LOTE 20, [1474] LOTE 19, [1475] LOTE 18, [1476] LOTE 17

-- Sector: [1202] NVA CAL DIST2 B002 SGL
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (6): [1360] LOTE 27, [1433] LOTE 26, [1445] LOTE 25, [1463] LOTE 24, [1464] LOTE 23... (+1 más)

-- Sector: [1203] NVA CAL DIST2 B003 SGL
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (4): [1412] LOTE 31, [1413] LOTE 30, [1414] LOTE 29, [1415] LOTE 28

-- Sector: [1204] NVA CAL DIST3 C001 SGL
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (4): [1408] LOTE 39, [1409] LOTE 38, [1410] LOTE 37, [1411] LOTE 36

-- Sector: [1205] NVA CAL DIST3 C002 SGL
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (2): [1406] LOTE 34, [1407] LOTE 35

-- Sector: [6633] NVA CAL DIST3 C003 ACR
--   Fundo: [BMP] FDO. NVA CALIFORNIA
--   Empresa: [BMP] AGRICOLA BMP SAC
--   Lotes (2): [1750] LOTE 32, [1751] LOTE 33

-- Sector: [4104] AC1 SECTOR E3A
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [998] LOTE E3

-- Sector: [4105] AC1 SECTOR E4
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1725] LOTE E4

-- Sector: [4106] AC1 SECTOR E5
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1731] LOTE E5

-- Sector: [4107] AC1 SECTOR E6
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1733] LOTE E6

-- Sector: [4108] AC1 SECTOR E7
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1727] LOTE E7

-- Sector: [4109] AC1 SECTOR E8
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1729] LOTE E8

-- Sector: [4110] AC1 SECTOR E9
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1735] LOTE E9

-- Sector: [4111] AC1 SECTOR E10
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1726] LOTE E10

-- Sector: [4112] JS1 SECTOR F3B
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [992] LOTE F3

-- Sector: [4113] AC1 SECTOR F6
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1734] LOTE F6

-- Sector: [4114] AC1 SECTOR F7
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1728] LOTE F7

-- Sector: [4115] AC1 SECTOR F8
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1732] LOTE F8

-- Sector: [4116] AC1 SECTOR F9
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1736] LOTE F9

-- Sector: [4117] AC1 SECTOR F10
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1730] LOTE F10

-- Sector: [5773] ACR SECTOR F4
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1723] LOTE F4

-- Sector: [5774] ACR SECTOR F5
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1724] LOTE F5

-- Sector: [5780] ACR SECTOR E1
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1716] LOTE E1

-- Sector: [5781] ACR SECTOR E2
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1717] LOTE E2

-- Sector: [5782] ACR SECTOR E11
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1718] LOTE E11

-- Sector: [5783] ACR SECTOR E12
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1719] LOTE E12

-- Sector: [5784] ACR SECTOR F1
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1720] LOTE F1 AC

-- Sector: [5785] TMP SECTOR F1
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1721] LOTE F1 TH

-- Sector: [5786] ACR SECTOR F2
--   Fundo: [JOA] FUNDO JOAQUIN
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1722] LOTE F2

-- Sector: [6295] ACR SECTOR C8
--   Fundo: [NAN] FUNDO ÑAÑA
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1748] LOTE C8

-- Sector: [6296] ACR SECTOR D8
--   Fundo: [NAN] FUNDO ÑAÑA
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1747] LOTE D8

-- Sector: [6297] FCR SECTOR C9
--   Fundo: [NAN] FUNDO ÑAÑA
--   Empresa: [NEW] NEWTERRA S.A.C.
--   Lotes (1): [1749] LOTE C9

-- Sector: [3104] CAL M01 SECTOR 09 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (3): [1164] T1, [1358] T1A, [1359] T2

-- Sector: [3126] CAL M09 SECTOR 13 OZ OLIVIA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1317] T13

-- Sector: [3127] CAL M10 SECTOR 01 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1325] T1

-- Sector: [3128] CAL M10 SECTOR 02 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1316] T2

-- Sector: [3129] CAL M10 SECTOR 03 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [1296] T03, [1297] T04

-- Sector: [3130] CAL M11 SECTOR 01 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1354] T1

-- Sector: [3373] CAL M11 SECTOR 02 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1405] T2

-- Sector: [3374] CAL M11 SECTOR 03 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1421] T3

-- Sector: [3375] CAL M12 SECTOR 01 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1355] T1

-- Sector: [508] CAL M13 SECTOR 09 OZ DINA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (4): [1050] T1C, [1051] T2, [1113] T3B, [1116] T4B

-- Sector: [669] CAL M13 SECTOR 07 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1131] T5

-- Sector: [670] CAL M13 SECTOR 08 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [1046] T3A, [1115] T4A

-- Sector: [671] CAL M13 SECTOR 04 OZ DINA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1044] T1D

-- Sector: [673] CAL M13 SECTOR 06 OZ CAROLINA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1045] T1E

-- Sector: [674] CAL M13 SECTOR 02 OZ ANDREA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1043] T1B

-- Sector: [687] CAL M01 SECTOR 01 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [1426] T1, [1450] T5

-- Sector: [689] CAL M01 SECTOR 08 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [1419] T8, [1420] T9

-- Sector: [691] CAL M01 SECTOR 09 OZ CAROLINA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [725] T10

-- Sector: [692] CAL M02 SECTOR 01 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (8): [1047] T4, [1048] T5, [1049] T6, [1112] T7, [1114] T8... (+3 más)

-- Sector: [694] CAL M03 SECTOR 03 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (8): [1157] T6, [1158] T7, [1159] T8, [1160] T9A, [1161] T9B... (+3 más)

-- Sector: [696] CAL M04 SECTOR 01 OZ JULIETA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1467] T3A

-- Sector: [699] CAL M05 SECTOR 03 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1295] T03

-- Sector: [700] CAL M05 SECTOR 04 OZ CAROLINA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [744] T7B

-- Sector: [702] CAL M06 SECTOR 02 OZ OLIVIA.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1324] T6

-- Sector: [705] CAL M06 SECTOR 06 OZ CAROLINA.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (3): [1328] T3, [1332] T4, [1339] T5A

-- Sector: [706] CAL M08 SECTOR 01 OZ MAGICA.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (4): [749] T1, [1117] T4A, [1118] T5, [1128] T2A

-- Sector: [710] CAL M09 SECTOR 08 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1130] T14

-- Sector: [711] CAL M09 SECTOR 10 OZ ANDREA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (10): [1333] T5, [1334] T6, [1335] T7A, [1336] T10, [1337] T12... (+5 más)

-- Sector: [712] CAL M14 SECTOR 01 OZ ANDREA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1451] T1

-- Sector: [714] CAL M15 SECTOR 02 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1436] T2

-- Sector: [723] CAL M01 SECTOR 03 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (5): [1418] T7, [1427] T6, [1434] T2B, [1437] T3, [1449] T4

-- Sector: [725] CAL M01 SECTOR 06 OZ JULIETA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1417] T2A

-- Sector: [728] CAL M03 SECTOR 02 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1156] T4

-- Sector: [730] CAL M03 SECTOR 06 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1165] T2

-- Sector: [732] CAL M04 SECTOR 02 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (6): [1452] T1, [1466] T2, [1468] T3B, [1469] T4, [1470] T5... (+1 más)

-- Sector: [733] CAL M05 SECTOR 02 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (3): [1309] T1, [1310] T2, [1311] T4A

-- Sector: [736] CAL M06 SECTOR 01 OZ MAGICA.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [771] T5B, [1326] T1A

-- Sector: [738] CAL M06 SECTOR 03 OZ ANDREA.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1327] T2B

-- Sector: [742] CAL M08 SECTOR 02 OZ MAGICA.
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (3): [773] T4B, [774] T2B, [1129] T3

-- Sector: [743] CAL M09 SECTOR 06 OZ OLIVIA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (3): [1402] T7B, [1403] T8, [1404] T9

-- Sector: [744] CAL M09 SECTOR 09 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1344] T4

-- Sector: [748] CAL M15 SECTOR 01 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1435] T1

-- Sector: [757] CAL M05 SECTOR 05 OZ MAGICA
--   Fundo: [CAL] FUNDO CALIFORNIA
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (4): [1312] T4B, [1313] T5, [1314] T6, [1315] T7A

-- Sector: [1185] NAT M02 SECTOR 01 OZ MAGICA..
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [597] T01

-- Sector: [1188] NAT M03 SECTOR 01 OZ MAGICA..
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [606] T03

-- Sector: [1190] NAT M04 SECTOR 01 OZ MAGICA..
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [610] T03

-- Sector: [675] NAT M05 SECTOR 02 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1353] T02

-- Sector: [680] NAT M01 SECTOR 01 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (12): [1428] T01, [1429] T02, [1430] T03, [1431] T04, [1432] T05... (+7 más)

-- Sector: [682] NAT M02 SECTOR 02 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (6): [1457] T3B, [1458] T04, [1459] T05, [1460] T06, [1455] T02... (+1 más)

-- Sector: [684] NAT M03 SECTOR 01 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (6): [1318] T2A, [1319] T2B, [1320] T3A, [1321] T3B, [1322] T1A... (+1 más)

-- Sector: [686] NAT M04 SECTOR 01 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (5): [1163] T01, [1294] T04, [1356] T3A, [1357] T3B, [1416] T02

-- Sector: [716] NAT M02 SECTOR 01 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [1453] T1A, [1454] T1B

-- Sector: [718] NAT M02 SECTOR 03 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (2): [1461] T7, [1462] T7A

-- Sector: [720] NAT M03 SECTOR 02 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1351] T04

-- Sector: [756] NAT M05 SECTOR 03 OZ MAGICA
--   Fundo: [NAT] Fundo Natalia
--   Empresa: [OZB] LARAMA BERRIES
--   Lotes (1): [1352] T1A

-- =====================================================
-- Script completado
-- RESUMEN:
--   Empresas: 5
--   Fundos: 12
--   Sectores: 270
--   Lotes: 509 (solo informativos)
-- =====================================================