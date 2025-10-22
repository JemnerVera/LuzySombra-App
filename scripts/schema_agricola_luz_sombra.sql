-- =====================================================
-- SCHEMA: IMAGE (Análisis de Imágenes Agrícolas)
-- Descripción: Base de datos para análisis de imágenes,
--              fenología y alertas agrícolas
-- Versión: 1.2
-- Fecha: 2025-10-22
-- =====================================================

USE master;
GO

-- Crear base de datos si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'AgricolaDB')
BEGIN
    CREATE DATABASE AgricolaDB;
    PRINT '✅ Base de datos AgricolaDB creada';
END
ELSE
BEGIN
    PRINT '⚠️ Base de datos AgricolaDB ya existe';
END
GO

USE AgricolaDB;
GO

-- Crear schema 'image' si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'image')
BEGIN
    EXEC('CREATE SCHEMA image');
    PRINT '✅ Schema image creado';
END
ELSE
BEGIN
    PRINT '⚠️ Schema image ya existe';
END
GO

-- =====================================================
-- SECCIÓN 1: JERARQUÍA ORGANIZACIONAL
-- =====================================================

-- Tabla: País
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.pais') AND type in (N'U'))
BEGIN
    CREATE TABLE image.pais (
        paisid INT IDENTITY(1,1) PRIMARY KEY,
        pais NVARCHAR(100) NOT NULL,
        paisabrev NVARCHAR(10) NOT NULL UNIQUE,
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        usermodifiedid INT NOT NULL DEFAULT 1,
        datemodified DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT '✅ Tabla image.pais creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.pais ya existe';
END
GO

-- Tabla: Empresas
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.empresa') AND type in (N'U'))
BEGIN
    CREATE TABLE image.empresa (
        empresaid INT IDENTITY(1,1) PRIMARY KEY,
        paisid INT NOT NULL,
        empresa NVARCHAR(200) NOT NULL,
        empresabrev NVARCHAR(50) NOT NULL,
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        usermodifiedid INT NOT NULL DEFAULT 1,
        datemodified DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_empresas_pais FOREIGN KEY (paisid) REFERENCES image.pais(paisid),
        CONSTRAINT UQ_empresas_pais_abrev UNIQUE (paisid, empresabrev)
    );
    PRINT '✅ Tabla image.empresa creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.empresa ya existe';
END
GO

-- Tabla: Fundos
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.fundo') AND type in (N'U'))
BEGIN
    CREATE TABLE image.fundo (
        fundoid INT IDENTITY(1,1) PRIMARY KEY,
        empresaid INT NOT NULL,
        fundo NVARCHAR(200) NOT NULL,
        fundobrev NVARCHAR(50) NOT NULL,
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        usermodifiedid INT NOT NULL DEFAULT 1,
        datemodified DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_fundos_empresas FOREIGN KEY (empresaid) REFERENCES image.empresa(empresaid),
        CONSTRAINT UQ_fundos_empresa_abrev UNIQUE (empresaid, fundobrev)
    );
    PRINT '✅ Tabla image.fundo creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.fundo ya existe';
END
GO

-- Tabla: Sectores
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.sector') AND type in (N'U'))
BEGIN
    CREATE TABLE image.sector (
        sectorid INT IDENTITY(1,1) PRIMARY KEY,
        fundoid INT NOT NULL,
        sector NVARCHAR(200) NOT NULL,
        sectorbrev NVARCHAR(50) NOT NULL,
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        usermodifiedid INT NOT NULL DEFAULT 1,
        datemodified DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_sectores_fundos FOREIGN KEY (fundoid) REFERENCES image.fundo(fundoid),
        CONSTRAINT UQ_sectores_fundo_abrev UNIQUE (fundoid, sectorbrev)
    );
    PRINT '✅ Tabla image.sector creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.sector ya existe';
END
GO

-- Tabla: Lotes
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.lote') AND type in (N'U'))
BEGIN
    CREATE TABLE image.lote (
        loteid INT IDENTITY(1,1) PRIMARY KEY,
        sectorid INT NOT NULL,
        lote NVARCHAR(200) NOT NULL,
        lotebrev NVARCHAR(50) NOT NULL,
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        usermodifiedid INT NOT NULL DEFAULT 1,
        datemodified DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_lotes_sectores FOREIGN KEY (sectorid) REFERENCES image.sector(sectorid),
        CONSTRAINT UQ_lotes_sector_abrev UNIQUE (sectorid, lotebrev)
    );
    PRINT '✅ Tabla image.lote creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.lote ya existe';
END
GO

-- =====================================================
-- SECCIÓN 2: USUARIOS (Para auditoría)
-- =====================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.usuario') AND type in (N'U'))
BEGIN
    CREATE TABLE image.usuario (
        userid INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE,
        email NVARCHAR(200) NOT NULL UNIQUE,
        nombre_completo NVARCHAR(200),
        rol NVARCHAR(50) NOT NULL DEFAULT 'user', -- 'admin', 'user', 'viewer'
        activo BIT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        datemodified DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT '✅ Tabla image.usuario creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.usuario ya existe';
END
GO

-- =====================================================
-- SECCIÓN 3: ANÁLISIS DE IMÁGENES (Core de la app)
-- =====================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.analisis_imagen') AND type in (N'U'))
BEGIN
    CREATE TABLE image.analisis_imagen (
        analisisid INT IDENTITY(1,1) PRIMARY KEY,
        loteid INT NOT NULL,
        hilera NVARCHAR(50) NOT NULL,
        planta NVARCHAR(50) NOT NULL,
        
        -- Datos de la imagen
        filename NVARCHAR(500) NOT NULL,
        filepath NVARCHAR(1000),
        fecha_captura DATETIME,
        
        -- Resultados del análisis
        porcentaje_luz DECIMAL(5,2) NOT NULL,
        porcentaje_sombra DECIMAL(5,2) NOT NULL,
        
        -- Geolocalización
        latitud DECIMAL(10,8),
        longitud DECIMAL(11,8),
        
        -- Metadatos
        processed_image_url NVARCHAR(MAX), -- Base64 o URL
        modelo_version NVARCHAR(50) DEFAULT 'heuristic_v1',
        
        -- Auditoría
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT FK_analisis_lotes FOREIGN KEY (loteid) REFERENCES image.lote(loteid),
        CONSTRAINT FK_analisis_usuarios FOREIGN KEY (usercreatedid) REFERENCES image.usuario(userid)
    );
    
    -- Índices para optimizar consultas
    CREATE NONCLUSTERED INDEX IX_analisis_fecha 
        ON image.analisis_imagen(fecha_captura DESC);
    
    CREATE NONCLUSTERED INDEX IX_analisis_lote 
        ON image.analisis_imagen(loteid, fecha_captura DESC);
    
    CREATE NONCLUSTERED INDEX IX_analisis_ubicacion 
        ON image.analisis_imagen(loteid, hilera, planta);
    
    PRINT '✅ Tabla image.analisis_imagen creada con índices';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.analisis_imagen ya existe';
END
GO

-- =====================================================
-- SECCIÓN 4: FENOLOGÍA
-- =====================================================

-- Tabla: Estados Fenológicos
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.estado_fenologico') AND type in (N'U'))
BEGIN
    CREATE TABLE image.estado_fenologico (
        estadoid INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL UNIQUE,
        descripcion NVARCHAR(500),
        orden INT NOT NULL, -- Para ordenar los estados secuencialmente
        statusid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT '✅ Tabla image.estado_fenologico creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.estado_fenologico ya existe';
END
GO

-- Tabla: Registro de Fenología
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.registro_fenologia') AND type in (N'U'))
BEGIN
    CREATE TABLE image.registro_fenologia (
        registroid INT IDENTITY(1,1) PRIMARY KEY,
        loteid INT NOT NULL,
        hilera NVARCHAR(50),
        planta NVARCHAR(50),
        
        -- Estado fenológico
        estadoid INT NOT NULL,
        fecha_evaluacion DATE NOT NULL,
        dias_fenologia INT, -- Días desde inicio del estado
        
        -- Evaluador
        evaluador NVARCHAR(200),
        observaciones NVARCHAR(MAX),
        
        -- Auditoría
        statusid INT NOT NULL DEFAULT 1,
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT FK_fenologia_lotes FOREIGN KEY (loteid) REFERENCES image.lote(loteid),
        CONSTRAINT FK_fenologia_estados FOREIGN KEY (estadoid) REFERENCES image.estado_fenologico(estadoid),
        CONSTRAINT FK_fenologia_usuarios FOREIGN KEY (usercreatedid) REFERENCES image.usuario(userid)
    );
    
    -- Índices
    CREATE NONCLUSTERED INDEX IX_fenologia_lote_fecha 
        ON image.registro_fenologia(loteid, fecha_evaluacion DESC);
    
    CREATE NONCLUSTERED INDEX IX_fenologia_estado 
        ON image.registro_fenologia(estadoid, fecha_evaluacion DESC);
    
    PRINT '✅ Tabla image.registro_fenologia creada con índices';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.registro_fenologia ya existe';
END
GO

-- =====================================================
-- SECCIÓN 5: SISTEMA DE ALERTAS
-- =====================================================

-- Tabla: Tipos de Alerta
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.tipo_alerta') AND type in (N'U'))
BEGIN
    CREATE TABLE image.tipo_alerta (
        tipoalertaid INT IDENTITY(1,1) PRIMARY KEY,
        nombre NVARCHAR(100) NOT NULL UNIQUE,
        descripcion NVARCHAR(500),
        categoria NVARCHAR(50), -- 'luz_sombra', 'fenologia', 'sistema'
        statusid INT NOT NULL DEFAULT 1
    );
    PRINT '✅ Tabla image.tipo_alerta creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.tipo_alerta ya existe';
END
GO

-- Tabla: Configuración de Alertas
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.configuracion_alerta') AND type in (N'U'))
BEGIN
    CREATE TABLE image.configuracion_alerta (
        configid INT IDENTITY(1,1) PRIMARY KEY,
        tipoalertaid INT NOT NULL,
        loteid INT, -- NULL = aplica a todos los lotes
        
        -- Umbrales
        umbral_minimo DECIMAL(10,2),
        umbral_maximo DECIMAL(10,2),
        
        -- Configuración
        activo BIT NOT NULL DEFAULT 1,
        enviar_email BIT NOT NULL DEFAULT 0,
        emails_destino NVARCHAR(MAX), -- JSON array: ["email1@domain.com", "email2@domain.com"]
        
        -- Auditoría
        usercreatedid INT NOT NULL DEFAULT 1,
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        usermodifiedid INT NOT NULL DEFAULT 1,
        datemodified DATETIME NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT FK_config_alertas_tipo FOREIGN KEY (tipoalertaid) REFERENCES image.tipo_alerta(tipoalertaid),
        CONSTRAINT FK_config_alertas_lote FOREIGN KEY (loteid) REFERENCES image.lote(loteid),
        CONSTRAINT FK_config_alertas_user_created FOREIGN KEY (usercreatedid) REFERENCES image.usuario(userid),
        CONSTRAINT FK_config_alertas_user_modified FOREIGN KEY (usermodifiedid) REFERENCES image.usuario(userid)
    );
    
    PRINT '✅ Tabla image.configuracion_alerta creada';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.configuracion_alerta ya existe';
END
GO

-- Tabla: Historial de Alertas
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.historial_alerta') AND type in (N'U'))
BEGIN
    CREATE TABLE image.historial_alerta (
        alertaid INT IDENTITY(1,1) PRIMARY KEY,
        tipoalertaid INT NOT NULL,
        loteid INT,
        
        -- Datos de la alerta
        mensaje NVARCHAR(MAX) NOT NULL,
        valor_actual DECIMAL(10,2),
        umbral_configurado DECIMAL(10,2),
        severidad NVARCHAR(20) NOT NULL DEFAULT 'info', -- 'info', 'warning', 'critical'
        
        -- Estado
        leida BIT NOT NULL DEFAULT 0,
        fecha_lectura DATETIME,
        resuelta BIT NOT NULL DEFAULT 0,
        fecha_resolucion DATETIME,
        notas_resolucion NVARCHAR(MAX),
        
        -- Auditoría
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT FK_historial_alertas_tipo FOREIGN KEY (tipoalertaid) REFERENCES image.tipo_alerta(tipoalertaid),
        CONSTRAINT FK_historial_alertas_lote FOREIGN KEY (loteid) REFERENCES image.lote(loteid),
        CONSTRAINT CHK_severidad CHECK (severidad IN ('info', 'warning', 'critical'))
    );
    
    -- Índices para optimizar consultas de alertas
    CREATE NONCLUSTERED INDEX IX_alertas_fecha 
        ON image.historial_alerta(datecreated DESC);
    
    CREATE NONCLUSTERED INDEX IX_alertas_no_leidas 
        ON image.historial_alerta(leida, datecreated DESC) WHERE leida = 0;
    
    CREATE NONCLUSTERED INDEX IX_alertas_no_resueltas 
        ON image.historial_alerta(resuelta, datecreated DESC) WHERE resuelta = 0;
    
    PRINT '✅ Tabla image.historial_alerta creada con índices';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.historial_alerta ya existe';
END
GO

-- =====================================================
-- SECCIÓN 6: MENSAJES Y COMUNICACIÓN
-- =====================================================

-- Tabla: Mensajes (para comunicación relacionada con alertas o análisis)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'image.mensaje') AND type in (N'U'))
BEGIN
    CREATE TABLE image.mensaje (
        mensajeid INT IDENTITY(1,1) PRIMARY KEY,
        
        -- Relación (puede ser mensaje sobre una alerta o un análisis)
        alertaid INT NULL,
        analisisid INT NULL,
        loteid INT NULL,
        
        -- Tipo de mensaje
        tipo NVARCHAR(50) NOT NULL DEFAULT 'general', -- 'alerta_respuesta', 'comentario', 'nota_campo', 'general'
        
        -- Contenido
        asunto NVARCHAR(200),
        mensaje NVARCHAR(MAX) NOT NULL,
        prioridad NVARCHAR(20) DEFAULT 'normal', -- 'baja', 'normal', 'alta', 'urgente'
        
        -- Comunicación (de quién a quién)
        usuario_origen INT NOT NULL, -- Quién envía
        usuario_destino INT NULL, -- Quién recibe (NULL = mensaje general/público)
        
        -- Estado
        leido BIT NOT NULL DEFAULT 0,
        fecha_lectura DATETIME,
        archivado BIT NOT NULL DEFAULT 0,
        
        -- Adjuntos (opcional)
        adjuntos NVARCHAR(MAX), -- JSON array de URLs o paths
        
        -- Auditoría
        datecreated DATETIME NOT NULL DEFAULT GETDATE(),
        
        CONSTRAINT FK_mensaje_alerta FOREIGN KEY (alertaid) REFERENCES image.historial_alerta(alertaid),
        CONSTRAINT FK_mensaje_analisis FOREIGN KEY (analisisid) REFERENCES image.analisis_imagen(analisisid),
        CONSTRAINT FK_mensaje_lote FOREIGN KEY (loteid) REFERENCES image.lote(loteid),
        CONSTRAINT FK_mensaje_usuario_origen FOREIGN KEY (usuario_origen) REFERENCES image.usuario(userid),
        CONSTRAINT FK_mensaje_usuario_destino FOREIGN KEY (usuario_destino) REFERENCES image.usuario(userid),
        CONSTRAINT CHK_tipo CHECK (tipo IN ('alerta_respuesta', 'comentario', 'nota_campo', 'general')),
        CONSTRAINT CHK_prioridad CHECK (prioridad IN ('baja', 'normal', 'alta', 'urgente'))
    );
    
    -- Índices para optimizar consultas
    CREATE NONCLUSTERED INDEX IX_mensaje_fecha 
        ON image.mensaje(datecreated DESC);
    
    CREATE NONCLUSTERED INDEX IX_mensaje_no_leidos 
        ON image.mensaje(usuario_destino, leido, datecreated DESC) WHERE leido = 0;
    
    CREATE NONCLUSTERED INDEX IX_mensaje_alerta 
        ON image.mensaje(alertaid, datecreated DESC);
    
    CREATE NONCLUSTERED INDEX IX_mensaje_lote 
        ON image.mensaje(loteid, datecreated DESC);
    
    PRINT '✅ Tabla image.mensaje creada con índices';
END
ELSE
BEGIN
    PRINT '⚠️ Tabla image.mensaje ya existe';
END
GO

-- =====================================================
-- SECCIÓN 7: VISTAS ÚTILES
-- =====================================================

-- Vista: Jerarquía completa (para dropdowns y filtros)
IF OBJECT_ID('image.v_jerarquia_completa', 'V') IS NOT NULL
    DROP VIEW image.v_jerarquia_completa;
GO

CREATE VIEW image.v_jerarquia_completa AS
SELECT 
    p.paisid,
    p.pais,
    p.paisabrev,
    e.empresaid,
    e.empresa,
    e.empresabrev,
    f.fundoid,
    f.fundo,
    f.fundobrev,
    s.sectorid,
    s.sector,
    s.sectorbrev,
    l.loteid,
    l.lote,
    l.lotebrev
FROM image.pais p
INNER JOIN image.empresa e ON p.paisid = e.paisid
INNER JOIN image.fundo f ON e.empresaid = f.empresaid
INNER JOIN image.sector s ON f.fundoid = s.fundoid
INNER JOIN image.lote l ON s.sectorid = l.sectorid
WHERE p.statusid = 1 
  AND e.statusid = 1 
  AND f.statusid = 1 
  AND s.statusid = 1 
  AND l.statusid = 1;
GO
PRINT '✅ Vista image.v_jerarquia_completa creada';

-- Vista: Resumen de análisis por lote
IF OBJECT_ID('image.v_resumen_analisis_lote', 'V') IS NOT NULL
    DROP VIEW image.v_resumen_analisis_lote;
GO

CREATE VIEW image.v_resumen_analisis_lote AS
SELECT 
    l.loteid,
    l.lote,
    s.sector,
    f.fundo,
    e.empresa,
    COUNT(a.analisisid) AS total_analisis,
    AVG(a.porcentaje_luz) AS promedio_luz,
    AVG(a.porcentaje_sombra) AS promedio_sombra,
    MIN(a.fecha_captura) AS primera_fecha,
    MAX(a.fecha_captura) AS ultima_fecha
FROM image.lote l
INNER JOIN image.sector s ON l.sectorid = s.sectorid
INNER JOIN image.fundo f ON s.fundoid = f.fundoid
INNER JOIN image.empresa e ON f.empresaid = e.empresaid
LEFT JOIN image.analisis_imagen a ON l.loteid = a.loteid AND a.statusid = 1
WHERE l.statusid = 1
GROUP BY l.loteid, l.lote, s.sector, f.fundo, e.empresa;
GO
PRINT '✅ Vista image.v_resumen_analisis_lote creada';

-- Vista: Alertas activas
IF OBJECT_ID('image.v_alertas_activas', 'V') IS NOT NULL
    DROP VIEW image.v_alertas_activas;
GO

CREATE VIEW image.v_alertas_activas AS
SELECT 
    h.alertaid,
    t.nombre AS tipo_alerta,
    t.categoria,
    h.mensaje,
    h.valor_actual,
    h.umbral_configurado,
    h.severidad,
    h.leida,
    h.resuelta,
    h.datecreated,
    l.lote,
    s.sector,
    f.fundo,
    e.empresa
FROM image.historial_alerta h
INNER JOIN image.tipo_alerta t ON h.tipoalertaid = t.tipoalertaid
LEFT JOIN image.lote l ON h.loteid = l.loteid
LEFT JOIN image.sector s ON l.sectorid = s.sectorid
LEFT JOIN image.fundo f ON s.fundoid = f.fundoid
LEFT JOIN image.empresa e ON f.empresaid = e.empresaid
WHERE h.resuelta = 0;
GO
PRINT '✅ Vista image.v_alertas_activas creada';

-- =====================================================
-- SECCIÓN 7: STORED PROCEDURES
-- =====================================================

-- SP: Registrar análisis de imagen
IF OBJECT_ID('image.sp_registrar_analisis', 'P') IS NOT NULL
    DROP PROCEDURE image.sp_registrar_analisis;
GO

CREATE PROCEDURE image.sp_registrar_analisis
    @loteid INT,
    @hilera NVARCHAR(50),
    @planta NVARCHAR(50),
    @filename NVARCHAR(500),
    @porcentaje_luz DECIMAL(5,2),
    @porcentaje_sombra DECIMAL(5,2),
    @latitud DECIMAL(10,8) = NULL,
    @longitud DECIMAL(11,8) = NULL,
    @fecha_captura DATETIME = NULL,
    @processed_image_url NVARCHAR(MAX) = NULL,
    @userid INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Insertar análisis
        INSERT INTO image.analisis_imagen (
            loteid, hilera, planta, filename, porcentaje_luz, porcentaje_sombra,
            latitud, longitud, fecha_captura, processed_image_url, usercreatedid
        )
        VALUES (
            @loteid, @hilera, @planta, @filename, @porcentaje_luz, @porcentaje_sombra,
            @latitud, @longitud, ISNULL(@fecha_captura, GETDATE()), @processed_image_url, @userid
        );
        
        DECLARE @analisisid INT = SCOPE_IDENTITY();
        
        -- Verificar alertas configuradas para este lote
        DECLARE @tipoalertaid INT;
        DECLARE @umbral_min DECIMAL(10,2);
        DECLARE @umbral_max DECIMAL(10,2);
        
        -- Alerta de sombra excesiva
        SELECT TOP 1 
            @tipoalertaid = c.tipoalertaid,
            @umbral_max = c.umbral_maximo
        FROM image.configuracion_alerta c
        WHERE c.activo = 1 
          AND (c.loteid = @loteid OR c.loteid IS NULL)
          AND c.tipoalertaid = 1 -- Sombra Excesiva
          AND @porcentaje_sombra > c.umbral_maximo;
        
        IF @tipoalertaid IS NOT NULL
        BEGIN
            INSERT INTO image.historial_alerta (tipoalertaid, loteid, mensaje, valor_actual, umbral_configurado, severidad)
            VALUES (
                @tipoalertaid,
                @loteid,
                'Sombra excesiva detectada: ' + CAST(@porcentaje_sombra AS NVARCHAR) + '%',
                @porcentaje_sombra,
                @umbral_max,
                CASE WHEN @porcentaje_sombra > @umbral_max + 10 THEN 'critical' ELSE 'warning' END
            );
        END
        
        SELECT @analisisid AS analisisid, 'OK' AS status;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS error, 'ERROR' AS status;
    END CATCH
END
GO
PRINT '✅ Stored Procedure image.sp_registrar_analisis creado';

-- =====================================================
-- RESUMEN FINAL
-- =====================================================

PRINT '';
PRINT '=====================================================';
PRINT '✅ SCHEMA IMAGE CREADO EXITOSAMENTE';
PRINT '=====================================================';
PRINT '';
PRINT '📊 Resumen:';
PRINT '   - Base de datos: AgricolaDB';
PRINT '   - Schema: image';
PRINT '   - Tablas creadas: 12';
PRINT '   - Vistas creadas: 3';
PRINT '   - Stored Procedures: 1';
PRINT '';
PRINT '📋 Tablas:';
PRINT '   1. pais';
PRINT '   2. empresa';
PRINT '   3. fundo';
PRINT '   4. sector';
PRINT '   5. lote';
PRINT '   6. usuario';
PRINT '   7. analisis_imagen';
PRINT '   8. estado_fenologico';
PRINT '   9. registro_fenologia';
PRINT '  10. tipo_alerta';
PRINT '  11. configuracion_alerta';
PRINT '  12. historial_alerta';
PRINT '  13. mensaje (NUEVA - Sistema de mensajería)';
PRINT '';
PRINT '🔄 Próximos pasos:';
PRINT '   1. Ejecutar: insert_jerarquia_organizacional.sql';
PRINT '   2. Configurar conexión en Next.js';
PRINT '   3. Probar endpoints de API';
PRINT '';
PRINT '=====================================================';
GO

