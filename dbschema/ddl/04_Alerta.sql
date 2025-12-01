-- DDL limpio para DbSchema - evalImagen.Alerta
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.Alerta (
    alertaID INT IDENTITY(1,1) NOT NULL,
    lotID INT NOT NULL,
    loteEvaluacionID INT NULL,
    umbralID INT NOT NULL,
    variedadID INT NULL,
    porcentajeLuzEvaluado DECIMAL(5,2) NOT NULL,
    tipoUmbral VARCHAR(20) NOT NULL,
    severidad VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    fechaEnvio DATETIME NULL,
    fechaResolucion DATETIME NULL,
    mensajeID INT NULL,
    usuarioResolvioID INT NULL,
    notas NVARCHAR(500) NULL,
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_Alerta PRIMARY KEY CLUSTERED (alertaID),
    CONSTRAINT FK_Alerta_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
    CONSTRAINT FK_Alerta_LoteEvaluacion FOREIGN KEY (loteEvaluacionID) REFERENCES evalImagen.LoteEvaluacion(loteEvaluacionID),
    CONSTRAINT FK_Alerta_Umbral FOREIGN KEY (umbralID) REFERENCES evalImagen.UmbralLuz(umbralID),
    CONSTRAINT FK_Alerta_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
    CONSTRAINT FK_Alerta_UsuarioResolvio FOREIGN KEY (usuarioResolvioID) REFERENCES MAST.USERS(userID),
    CONSTRAINT CK_Alerta_Estado CHECK (estado IN ('Pendiente', 'Enviada', 'Resuelta', 'Ignorada')),
    CONSTRAINT CK_Alerta_TipoUmbral CHECK (tipoUmbral IN ('CriticoRojo', 'CriticoAmarillo', 'Normal')),
    CONSTRAINT CK_Alerta_Severidad CHECK (severidad IN ('Critica', 'Advertencia', 'Info')),
    CONSTRAINT CK_Alerta_PorcentajeLuz CHECK (porcentajeLuzEvaluado >= 0 AND porcentajeLuzEvaluado <= 100)
);

