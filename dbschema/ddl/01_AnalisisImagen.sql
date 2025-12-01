-- DDL limpio para DbSchema - evalImagen.AnalisisImagen
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.AnalisisImagen (
    analisisID INT IDENTITY(1,1) NOT NULL,
    lotID INT NOT NULL,
    hilera NVARCHAR(50) NULL,
    planta NVARCHAR(50) NULL,
    filename NVARCHAR(500) NOT NULL,
    fechaCaptura DATETIME NULL,
    porcentajeLuz DECIMAL(5,2) NOT NULL,
    porcentajeSombra DECIMAL(5,2) NOT NULL,
    latitud DECIMAL(10,8) NULL,
    longitud DECIMAL(11,8) NULL,
    processedImageUrl NVARCHAR(MAX) NULL,
    originalImageUrl NVARCHAR(MAX) NULL,
    modeloVersion NVARCHAR(50) NULL DEFAULT 'heuristic_v1',
    statusID INT NOT NULL DEFAULT 1,
    usuarioCreaID INT NOT NULL DEFAULT 1,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_AnalisisImagen PRIMARY KEY (analisisID),
    CONSTRAINT FK_AnalisisImagen_LOT_01 FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
    CONSTRAINT UQ_AnalisisImagen_FilenameLot_01 UNIQUE (filename, lotID)
);
