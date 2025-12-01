-- DDL limpio para DbSchema - evalImagen.UmbralLuz
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.UmbralLuz (
    umbralID INT IDENTITY(1,1) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    minPorcentajeLuz DECIMAL(5,2) NOT NULL,
    maxPorcentajeLuz DECIMAL(5,2) NOT NULL,
    variedadID INT NULL,
    descripcion NVARCHAR(200) NULL,
    colorHex VARCHAR(7) NULL,
    orden INT NOT NULL DEFAULT 0,
    activo BIT NOT NULL DEFAULT 1,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    usuarioCreaID INT NULL,
    fechaActualizacion DATETIME NULL,
    usuarioActualizaID INT NULL,
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_UmbralLuz PRIMARY KEY CLUSTERED (umbralID),
    CONSTRAINT FK_UmbralLuz_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
    CONSTRAINT FK_UmbralLuz_UsuarioCrea FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
    CONSTRAINT FK_UmbralLuz_UsuarioActualiza FOREIGN KEY (usuarioActualizaID) REFERENCES MAST.USERS(userID),
    CONSTRAINT CK_UmbralLuz_Tipo CHECK (tipo IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
    CONSTRAINT CK_UmbralLuz_Porcentaje CHECK (minPorcentajeLuz >= 0 AND maxPorcentajeLuz <= 100 AND minPorcentajeLuz <= maxPorcentajeLuz)
);

