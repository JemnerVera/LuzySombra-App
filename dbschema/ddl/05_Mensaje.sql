-- DDL limpio para DbSchema - evalImagen.Mensaje
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.Mensaje (
    mensajeID INT IDENTITY(1,1) NOT NULL,
    alertaID INT NULL,
    fundoID CHAR(4) NULL,
    tipoMensaje VARCHAR(50) NOT NULL DEFAULT 'Email',
    asunto NVARCHAR(200) NOT NULL,
    cuerpoHTML NVARCHAR(MAX) NOT NULL,
    cuerpoTexto NVARCHAR(MAX) NULL,
    destinatarios NVARCHAR(MAX) NOT NULL,
    destinatariosCC NVARCHAR(MAX) NULL,
    destinatariosBCC NVARCHAR(MAX) NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    fechaEnvio DATETIME NULL,
    intentosEnvio INT NOT NULL DEFAULT 0,
    ultimoIntentoEnvio DATETIME NULL,
    resendMessageID NVARCHAR(100) NULL,
    resendResponse NVARCHAR(MAX) NULL,
    errorMessage NVARCHAR(500) NULL,
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_Mensaje PRIMARY KEY CLUSTERED (mensajeID),
    CONSTRAINT FK_Mensaje_Alerta FOREIGN KEY (alertaID) REFERENCES evalImagen.Alerta(alertaID),
    CONSTRAINT FK_Mensaje_Farm FOREIGN KEY (fundoID) REFERENCES GROWER.FARMS(farmID),
    CONSTRAINT CK_Mensaje_Estado CHECK (estado IN ('Pendiente', 'Enviando', 'Enviado', 'Error')),
    CONSTRAINT CK_Mensaje_Tipo CHECK (tipoMensaje IN ('Email', 'SMS', 'Push'))
);

