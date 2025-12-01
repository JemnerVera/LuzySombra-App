-- DDL limpio para DbSchema - evalImagen.LoteEvaluacion
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.LoteEvaluacion (
    loteEvaluacionID INT IDENTITY(1,1) NOT NULL,
    lotID INT NOT NULL,
    variedadID INT NULL,
    fundoID CHAR(4) NULL,
    sectorID INT NULL,
    porcentajeLuzPromedio DECIMAL(5,2) NOT NULL,
    porcentajeLuzMin DECIMAL(5,2) NULL,
    porcentajeLuzMax DECIMAL(5,2) NULL,
    porcentajeSombraPromedio DECIMAL(5,2) NOT NULL,
    porcentajeSombraMin DECIMAL(5,2) NULL,
    porcentajeSombraMax DECIMAL(5,2) NULL,
    tipoUmbralActual VARCHAR(20) NULL,
    umbralIDActual INT NULL,
    fechaUltimaEvaluacion DATETIME NULL,
    fechaPrimeraEvaluacion DATETIME NULL,
    totalEvaluaciones INT NOT NULL DEFAULT 0,
    periodoEvaluacionDias INT NOT NULL DEFAULT 30,
    fechaUltimaActualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_LoteEvaluacion PRIMARY KEY CLUSTERED (loteEvaluacionID),
    CONSTRAINT FK_LoteEvaluacion_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
    CONSTRAINT FK_LoteEvaluacion_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
    CONSTRAINT FK_LoteEvaluacion_Farm FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
    CONSTRAINT FK_LoteEvaluacion_Stage FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID),
    CONSTRAINT FK_LoteEvaluacion_Umbral FOREIGN KEY (umbralIDActual) REFERENCES evalImagen.UmbralLuz(umbralID),
    CONSTRAINT UQ_LoteEvaluacion_LOT UNIQUE (lotID),
    CONSTRAINT CK_LoteEvaluacion_TipoUmbral CHECK (tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo', 'Normal') OR tipoUmbralActual IS NULL),
    CONSTRAINT CK_LoteEvaluacion_PorcentajeLuz CHECK (porcentajeLuzPromedio >= 0 AND porcentajeLuzPromedio <= 100),
    CONSTRAINT CK_LoteEvaluacion_PorcentajeSombra CHECK (porcentajeSombraPromedio >= 0 AND porcentajeSombraPromedio <= 100)
);

