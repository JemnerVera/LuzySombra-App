-- DDL limpio para DbSchema - evalImagen.MensajeAlerta
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.MensajeAlerta (
    mensajeID INT NOT NULL,
    alertaID INT NOT NULL,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_MensajeAlerta PRIMARY KEY (mensajeID, alertaID),
    CONSTRAINT FK_MensajeAlerta_Mensaje FOREIGN KEY (mensajeID) REFERENCES evalImagen.Mensaje(mensajeID),
    CONSTRAINT FK_MensajeAlerta_Alerta FOREIGN KEY (alertaID) REFERENCES evalImagen.Alerta(alertaID),
    CONSTRAINT UQ_MensajeAlerta_MensajeAlerta UNIQUE (mensajeID, alertaID)
);

