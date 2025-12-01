-- DDL limpio para DbSchema - evalImagen.Contacto
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.Contacto (
    contactoID INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    telefono NVARCHAR(20) NULL,
    tipo VARCHAR(50) NOT NULL DEFAULT 'General',
    rol NVARCHAR(100) NULL,
    recibirAlertasCriticas BIT NOT NULL DEFAULT 1,
    recibirAlertasAdvertencias BIT NOT NULL DEFAULT 1,
    recibirAlertasNormales BIT NOT NULL DEFAULT 0,
    fundoID CHAR(4) NULL,
    sectorID INT NULL,
    prioridad INT NOT NULL DEFAULT 0,
    activo BIT NOT NULL DEFAULT 1,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    fechaActualizacion DATETIME NULL,
    usuarioCreaID INT NULL,
    usuarioActualizaID INT NULL,
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_Contacto PRIMARY KEY CLUSTERED (contactoID),
    CONSTRAINT UQ_Contacto_Email UNIQUE (email),
    CONSTRAINT CK_Contacto_Tipo CHECK (tipo IN ('General', 'Admin', 'Agronomo', 'Manager', 'Supervisor', 'Tecnico', 'Otro')),
    CONSTRAINT CK_Contacto_Email CHECK (email LIKE '%@%.%'),
    CONSTRAINT FK_Contacto_Farm FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
    CONSTRAINT FK_Contacto_Stage FOREIGN KEY (sectorID) REFERENCES GROWER.STAGE(stageID),
    CONSTRAINT FK_Contacto_UsuarioCrea FOREIGN KEY (usuarioCreaID) REFERENCES MAST.USERS(userID),
    CONSTRAINT FK_Contacto_UsuarioActualiza FOREIGN KEY (usuarioActualizaID) REFERENCES MAST.USERS(userID)
);

