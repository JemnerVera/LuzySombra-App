-- DDL limpio para DbSchema - evalImagen.Dispositivo
-- Solo CREATE TABLE y constraints esenciales

CREATE TABLE evalImagen.Dispositivo (
    dispositivoID INT IDENTITY(1,1) NOT NULL,
    deviceId NVARCHAR(100) NOT NULL,
    apiKey NVARCHAR(255) NOT NULL,
    nombreDispositivo NVARCHAR(200) NULL,
    modeloDispositivo NVARCHAR(100) NULL,
    versionApp NVARCHAR(50) NULL,
    activo BIT NOT NULL DEFAULT 1,
    fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    ultimoAcceso DATETIME NULL,
    statusID INT NOT NULL DEFAULT 1,
    usuarioCreaID INT NOT NULL DEFAULT 1,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    usuarioModificaID INT NULL,
    fechaModificacion DATETIME NULL,
    
    CONSTRAINT PK_Dispositivo PRIMARY KEY (dispositivoID),
    CONSTRAINT UQ_Dispositivo_DeviceId UNIQUE (deviceId),
    CONSTRAINT UQ_Dispositivo_ApiKey UNIQUE (apiKey),
    CONSTRAINT CK_Dispositivo_DeviceId CHECK (LEN(deviceId) >= 3),
    CONSTRAINT CK_Dispositivo_ApiKey CHECK (LEN(apiKey) >= 10)
);

