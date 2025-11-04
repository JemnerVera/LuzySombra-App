# 📚 Catálogo de Schemas - Tablas Existentes AgroMigiva
## Base de Datos
**BD_PACKING_AGROMIGIVA_DESA** en servidor `10.1.10.4`
**Generado automáticamente** el 2025-11-02 19:59:09

---
## 📊 Tabla de Contenido
1. [MAST.USERS](#1-mastusers) - USUARIO
2. [MAST.ORIGIN](#2-mastorigin) - PAIS
3. [GROWER.GROWERS](#3-growergrowers) - EMPRESA
4. [GROWER.FARMS](#4-growerfarms) - FUNDO
5. [GROWER.STAGE](#5-growerstage) - SECTOR
6. [GROWER.LOT](#6-growerlot) - LOTE
7. [GROWER.PLANTATION](#7-growerplantation) - UNION PLANTAS
8. [GROWER.PLANT](#8-growerplant) - PLANTAS POR LOTE
9. [GROWER.VARIETY](#9-growervariety) - VARIEDAD
10. [PPP.ESTADOFENOLOGICO](#10-pppestadofenologico) - ESTADO_FENOLOGICO
11. [PPP.GRUPOFENOLOGICO](#11-pppgrupofenologico) - GRUPO_FENOLOGICO
12. [GROWER.CAMPAIGN](#12-growercampaign) - CAMPAÑA

---

## 1. MAST.USERS - USUARIO

**Propósito**: USUARIO

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **userID** | INT(10) |  | NO |  | **PK** |
| **login** | VARCHAR(20) | 20 | NO |  |  |
| **DNI** | INT(10) |  | NO |  |  |
| **paternalLastName** | VARCHAR(50) | 50 | NO |  |  |
| **maternalLastName** | VARCHAR(50) | 50 | NO |  |  |
| **firstName** | VARCHAR(50) | 50 | NO |  |  |
| **secondName** | VARCHAR(50) | 50 | YES |  |  |
| **originalDate** | DATE |  | NO |  |  |
| **lastEntryDate** | DATE |  | NO |  |  |
| **email** | VARCHAR(50) | 50 | YES |  |  |
| **passwdSalt** | VARCHAR(50) | 50 | YES |  |  |
| **passwdHash** | VARCHAR(250) | 250 | YES |  |  |
| **statusID** | INT(10) |  | NO |  | **Estado** |
| **phone** | VARCHAR(18) | 18 | YES |  |  |
| **userErp** | VARCHAR(100) | 100 | YES |  |  |

### Primary Keys

- `userID` (int)

### Índices

- `IDXU_usersLogin` (UNIQUE NONCLUSTERED) - Columnas: login
- `pk_usuario` (UNIQUE CLUSTERED) - Columnas: userID

### Estadísticas

- **Total de registros**: 1,492

---

## 2. MAST.ORIGIN - PAIS

**Propósito**: PAIS

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **originID** | CHAR(3) | 3 | NO |  | **PK** |
| **description** | VARCHAR(100) | 100 | NO |  |  |
| **statusID** | INT(10) |  | NO |  | **Estado** |
| **marketID** | CHAR(3) | 3 | YES |  |  |
| **abrev** | CHAR(3) | 3 | YES |  |  |
| **abrev2** | CHAR(2) | 2 | YES |  |  |

### Primary Keys

- `originID` (char)

### Índices

- `pk_Origen` (UNIQUE CLUSTERED) - Columnas: originID

### Estadísticas

- **Total de registros**: 34

---

## 3. GROWER.GROWERS - EMPRESA

**Propósito**: EMPRESA

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **growerID** | CHAR(3) | 3 | NO |  | **PK** |
| **region** | VARCHAR(20) | 20 | NO |  |  |
| **abbreviation** | VARCHAR(10) | 10 | NO |  |  |
| **businessName** | VARCHAR(100) | 100 | NO |  |  |
| **originID** | CHAR(3) | 3 | NO |  | FK → mast.origin.originID |
| **address** | VARCHAR(150) | 150 | NO |  |  |
| **statusID** | INT(10) |  | NO |  | **Estado** |
| **produceName** | VARCHAR(100) | 100 | YES | ('') |  |
| **equivalentErp** | NCHAR(11) | 11 | YES |  |  |
| **tradename** | VARCHAR(100) | 100 | YES |  |  |
| **codigoProveedor** | INT(10) |  | YES |  |  |
| **prefijo** | VARCHAR(100) | 100 | YES |  |  |
| **creadoPor** | INT(10) |  | YES |  |  |
| **fechaCreacion** | DATETIME |  | YES | (getdate()) |  |
| **actualizadoPor** | INT(10) |  | YES |  |  |
| **fechaActualizado** | DATETIME |  | YES |  |  |
| **idUbigeo** | INT(10) |  | YES |  | FK → Comercial.ubigeo.idUbigeo |

### Primary Keys

- `growerID` (char)

### Foreign Keys

- `idUbigeo` → `Comercial.ubigeo.idUbigeo`
- `originID` → `mast.origin.originID`

### Índices

- `pk_growers` (UNIQUE CLUSTERED) - Columnas: growerID

### Estadísticas

- **Total de registros**: 15

---

## 4. GROWER.FARMS - FUNDO

**Propósito**: FUNDO

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **farmID** | CHAR(4) | 4 | NO |  | **PK** |
| **Description** | VARCHAR(100) | 100 | NO |  |  |
| **statusID** | INT(10) |  | NO |  | **Estado** |
| **originID** | CHAR(3) | 3 | NO |  | FK → mast.origin.originID |
| **farmCode** | VARCHAR(20) | 20 | YES |  |  |
| **equivalentErp** | VARCHAR(16) | 16 | YES |  |  |
| **creadoPor** | INT(10) |  | YES |  |  |
| **fechaCreacion** | DATETIME |  | YES |  |  |
| **actualizadoPor** | INT(10) |  | YES |  |  |
| **fechaActualizado** | DATETIME |  | YES |  |  |
| **on_premID** | INT(10) |  | YES |  |  |
| **direccion** | VARCHAR(2200) | 2200 | YES |  |  |
| **idUbigeo** | INT(10) |  | YES |  | FK → Comercial.ubigeo.idUbigeo |

### Primary Keys

- `farmID` (char)

### Foreign Keys

- `originID` → `mast.origin.originID`
- `idUbigeo` → `Comercial.ubigeo.idUbigeo`

### Índices

- `pk_farms` (UNIQUE CLUSTERED) - Columnas: farmID

### Estadísticas

- **Total de registros**: 30

---

## 5. GROWER.STAGE - SECTOR

**Propósito**: SECTOR

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **stageID** | INT(10) |  | NO |  | **PK** |
| **stage** | VARCHAR(50) | 50 | NO |  |  |
| **farmID** | CHAR(4) | 4 | NO |  | FK → grower.farms.farmID |
| **growerID** | CHAR(3) | 3 | NO |  |  |
| **districtID** | INT(10) |  | YES |  |  |
| **statusID** | INT(10) |  | YES | ((1)) | **Estado** |
| **currentUpload** | BIT |  | YES |  |  |
| **stageIDERP** | VARCHAR(20) | 20 | YES |  |  |
| **userID** | INT(10) |  | YES |  |  |
| **dateCreated** | DATETIME |  | YES |  |  |
| **userModifiedID** | INT(10) |  | YES |  |  |
| **dateModified** | DATETIME |  | YES |  |  |
| **stageOriginal** | VARCHAR(50) | 50 | YES |  |  |
| **growerCode** | VARCHAR(100) | 100 | YES |  |  |
| **jefeCampoID** | INT(10) |  | YES |  | FK → mast.users.userID |
| **IdHuerto** | INT(10) |  | YES |  | FK → cultivador.huerto.IdHuerto |

### Primary Keys

- `stageID` (int)

### Foreign Keys

- `farmID` → `grower.farms.farmID`
- `IdHuerto` → `cultivador.huerto.IdHuerto`
- `jefeCampoID` → `mast.users.userID`

### Índices

- `NonClusteredIndex-20230208-095019` (NONCLUSTERED) - Columnas: stage, statusID, stageID
- `pk_etapas` (UNIQUE CLUSTERED) - Columnas: stageID

### Estadísticas

- **Total de registros**: 980

---

## 6. GROWER.LOT - LOTE

**Propósito**: LOTE

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **lotID** | INT(10) |  | NO |  | **PK** |
| **name** | VARCHAR(30) | 30 | NO |  |  |
| **stageID** | INT(10) |  | YES |  |  |
| **creationDate** | DATE |  | YES |  |  |
| **statusID** | INT(10) |  | YES |  | **Estado** |
| **number** | INT(10) |  | NO | ((0)) |  |
| **forecast** | INT(10) |  | YES | ((0)) |  |
| **currentUpload** | BIT |  | YES | ((1)) |  |

### Primary Keys

- `lotID` (int)

### Índices

- `pk_lotes` (UNIQUE CLUSTERED) - Columnas: lotID

### Estadísticas

- **Total de registros**: 1,657

---

## 7. GROWER.PLANTATION - UNION PLANTAS

**Propósito**: UNION PLANTAS

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **plantationID** | INT(10) |  | NO |  | **PK** |
| **lotID** | INT(10) |  | NO |  | FK → grower.lot.lotID |
| **varietyID** | INT(10) |  | NO |  |  |
| **seedTime** | DATE |  | YES |  |  |
| **dateIni** | DATE |  | YES |  |  |
| **hectares** | DECIMAL(18,2) |  | YES |  |  |
| **rowSpace** | VARCHAR(50) | 50 | YES |  |  |
| **plantSpace** | VARCHAR(50) | 50 | YES |  |  |
| **rowTotal** | INT(10) |  | YES |  |  |
| **plantsTotalRow** | INT(10) |  | YES |  |  |
| **patronID** | INT(10) |  | YES |  |  |
| **conductionID** | INT(10) |  | YES |  |  |
| **statusID** | INT(10) |  | NO | ((1)) | **Estado** |
| **conditionID** | INT(10) |  | YES | ((1)) |  |
| **currentUpload** | BIT |  | YES | ((1)) |  |

### Primary Keys

- `plantationID` (int)

### Foreign Keys

- `lotID` → `grower.lot.lotID`

### Índices

- `IDXU_loteID` (NONCLUSTERED) - Columnas: lotID
- `pk_plantacion` (UNIQUE CLUSTERED) - Columnas: plantationID

### Estadísticas

- **Total de registros**: 1,138

---

## 8. GROWER.PLANT - PLANTAS POR LOTE

**Propósito**: PLANTAS POR LOTE

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **plantID** | INT(10) |  | NO |  | **PK** |
| **plant** | INT(10) |  | NO |  |  |
| **datePlant** | DATETIME |  | YES |  |  |
| **plantationID** | INT(10) |  | NO |  | FK → grower.plantation.plantationID |
| **numberLine** | INT(10) |  | NO |  |  |
| **position** | INT(10) |  | NO |  |  |
| **statusID** | INT(10) |  | NO | ((1)) | **Estado** |

### Primary Keys

- `plantID` (int)

### Foreign Keys

- `plantationID` → `grower.plantation.plantationID`

### Índices

- `IDX_grower_plant_sp_plant_save` (NONCLUSTERED) - Columnas: plantationID, statusID, numberLine
- `IDX_grower_plant_sp_plant_save_plant` (NONCLUSTERED) - Columnas: plant
- `pk_plant` (UNIQUE CLUSTERED) - Columnas: plantID

### Estadísticas

- **Total de registros**: 10,472,193

---

## 9. GROWER.VARIETY - VARIEDAD

**Propósito**: VARIEDAD

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **varietyID** | INT(10) |  | NO |  | **PK** |
| **name** | VARCHAR(30) | 30 | NO |  |  |
| **cropID** | CHAR(3) | 3 | NO |  | FK → grower.crops.cropID |
| **vegetativeMaterialTypeID** | INT(10) |  | YES |  |  |
| **abbreviation** | VARCHAR(20) | 20 | YES |  |  |
| **tradeMark** | VARCHAR(100) | 100 | YES |  |  |
| **statusID** | INT(10) |  | NO | ((1)) | **Estado** |
| **varietyIDERP** | VARCHAR(20) | 20 | NO | ('') |  |
| **currentUpload** | BIT |  | YES |  |  |
| **clarifruitID** | INT(10) |  | YES |  |  |
| **pluCode** | VARCHAR(5) | 5 | YES |  |  |
| **typeOfGrape** | VARCHAR(64) | 64 | YES |  |  |
| **rawMaterialID** | VARCHAR(50) | 50 | YES |  |  |
| **fieldDiscardID** | VARCHAR(50) | 50 | YES |  |  |
| **plantDiscardID** | VARCHAR(50) | 50 | YES |  |  |
| **decreaseID** | VARCHAR(50) | 50 | YES |  |  |
| **pluGenerico** | VARCHAR(5) | 5 | YES |  |  |
| **alternativeName** | VARCHAR(256) | 256 | YES |  |  |
| **nombreMateriaPrima** | VARCHAR(150) | 150 | YES |  |  |
| **nombreDescarteCampo** | VARCHAR(150) | 150 | YES |  |  |
| **nombreDescartePacking** | VARCHAR(150) | 150 | YES |  |  |
| **nombreMerma** | VARCHAR(150) | 150 | YES |  |  |
| **SufijoVariedad** | VARCHAR(100) | 100 | YES |  |  |
| **CreadoPor** | INT(10) |  | YES |  |  |
| **FechaCreacion** | DATETIME |  | YES |  |  |
| **ActualizadoPor** | INT(10) |  | YES |  |  |
| **FechaActualizado** | DATETIME |  | YES |  |  |

### Primary Keys

- `varietyID` (int)

### Foreign Keys

- `cropID` → `grower.crops.cropID`

### Índices

- `pk_variedades` (UNIQUE CLUSTERED) - Columnas: varietyID

### Estadísticas

- **Total de registros**: 55

---

## 10. PPP.ESTADOFENOLOGICO - ESTADO_FENOLOGICO

**Propósito**: ESTADO_FENOLOGICO

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **estadofenologicoID** | INT(10) |  | NO |  | **PK** |
| **cfdescripcion** | VARCHAR(150) | 150 | NO |  |  |
| **grupofenologicoID** | INT(10) |  | YES |  | FK → ppp.grupofenologico.grupofenologicoID |
| **isfenologico** | INT(10) |  | YES |  |  |
| **diasFenolog** | INT(10) |  | YES |  |  |
| **estadoID** | INT(10) |  | YES |  |  |
| **userCreatedID** | INT(10) |  | YES |  |  |
| **fechaCreacion** | DATETIME |  | YES |  |  |
| **userModifiedID** | INT(10) |  | YES |  |  |
| **fechaModificacion** | DATETIME |  | YES |  |  |

### Primary Keys

- `estadofenologicoID` (int)

### Foreign Keys

- `grupofenologicoID` → `ppp.grupofenologico.grupofenologicoID`

### Índices

- `PK_estadofenologico` (UNIQUE CLUSTERED) - Columnas: estadofenologicoID

### Estadísticas

- **Total de registros**: 292

---

## 11. PPP.GRUPOFENOLOGICO - GRUPO_FENOLOGICO

**Propósito**: GRUPO_FENOLOGICO

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **grupofenologicoID** | INT(10) |  | NO |  | **PK** |
| **gfdescripcion** | VARCHAR(150) | 150 | NO |  |  |
| **growerID** | CHAR(3) | 3 | YES |  |  |
| **estadoID** | INT(10) |  | YES |  |  |
| **userCreatedID** | INT(10) |  | YES |  |  |
| **fechaCreacion** | DATETIME |  | YES |  |  |
| **userModifiedID** | INT(10) |  | YES |  |  |
| **fechaModificacion** | DATETIME |  | YES |  |  |

### Primary Keys

- `grupofenologicoID` (int)

### Índices

- `PK_grupofenologicoID` (UNIQUE CLUSTERED) - Columnas: grupofenologicoID

### Estadísticas

- **Total de registros**: 51

---

## 12. GROWER.CAMPAIGN - CAMPAÑA

**Propósito**: CAMPAÑA

### Estructura

| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |
|-------------|-----------|------------|-------------|---------|-------|
| **campaignID** | INT(10) |  | NO |  | **PK** |
| **description** | VARCHAR(50) | 50 | YES |  |  |
| **cropID** | CHAR(3) | 3 | NO |  | FK → grower.crops.cropID |
| **projectedWeekID_ini** | INT(10) |  | NO |  | FK → grower.projectedWeek.projectedWeekID |
| **projectedweekID_fin** | INT(10) |  | NO |  | FK → grower.projectedWeek.projectedWeekID |
| **statusID** | INT(10) |  | YES |  | **Estado** |
| **fechaidERP** | CHAR(4) | 4 | YES |  |  |
| **growerID** | CHAR(3) | 3 | YES |  |  |
| **currentUpload** | BIT |  | YES |  |  |
| **name** | VARCHAR(50) | 50 | YES |  |  |
| **sispacking** | INT(10) |  | YES | ((0)) |  |
| **agrocom** | INT(10) |  | YES | ((0)) |  |
| **agroamigo** | INT(10) |  | YES |  |  |
| **periodoOperacionId** | INT(10) |  | YES |  |  |
| **fechaModified** | DATETIME |  | NO | (getdate()) |  |
| **fechaCreated** | DATETIME |  | NO | (getdate()) |  |
| **userCreator** | INT(10) |  | NO | ((1)) |  |
| **userModifier** | INT(10) |  | NO | ((1)) |  |

### Primary Keys

- `campaignID` (int)

### Foreign Keys

- `cropID` → `grower.crops.cropID`
- `projectedweekID_fin` → `grower.projectedWeek.projectedWeekID`
- `projectedWeekID_ini` → `grower.projectedWeek.projectedWeekID`

### Índices

- `pk_campaign` (UNIQUE CLUSTERED) - Columnas: campaignID

### Estadísticas

- **Total de registros**: 41

---

## 🔗 Relaciones Entre Tablas

```
GROWER.GROWERS (empresa)
  └─ GROWER.FARMS (fundo)
      └─ GROWER.STAGE (sector)
          └─ GROWER.LOT (lote)
              ├─ GROWER.PLANTATION (relación lote-variedad)
              │   └─ GROWER.VARIETY (variedad)
              └─ image.Analisis_Imagen (nuestra tabla nueva)

MAST.USERS (usuarios)
```

