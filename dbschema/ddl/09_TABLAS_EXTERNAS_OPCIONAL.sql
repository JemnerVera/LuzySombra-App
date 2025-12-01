-- Tablas externas simplificadas (opcional)
-- Crear solo si quieres mostrar relaciones completas en el diagrama
-- Estas tablas solo tienen la PK para poder crear las Foreign Keys

-- GROWER.LOT
CREATE TABLE GROWER.LOT (
    lotID INT PRIMARY KEY
);

-- GROWER.FARMS
CREATE TABLE GROWER.FARMS (
    farmID CHAR(4) PRIMARY KEY
);

-- GROWER.STAGE
CREATE TABLE GROWER.STAGE (
    stageID INT PRIMARY KEY
);

-- GROWER.VARIETY
CREATE TABLE GROWER.VARIETY (
    varietyID INT PRIMARY KEY
);

-- GROWER.GROWERS
CREATE TABLE GROWER.GROWERS (
    growerID CHAR(4) PRIMARY KEY
);

-- MAST.USERS
CREATE TABLE MAST.USERS (
    userID INT PRIMARY KEY
);

