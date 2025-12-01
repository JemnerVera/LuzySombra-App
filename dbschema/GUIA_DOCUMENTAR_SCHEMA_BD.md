# Guía: Documentar Schema de Base de Datos

## 📋 Resumen

Esta guía explica cómo documentar y visualizar el schema `evalImagen` de la base de datos usando diferentes herramientas.

**⚠️ IMPORTANTE:** Estas herramientas se usan **SOLO para visualización y documentación local**. Los scripts SQL se ejecutan **manualmente en SQL Server Management Studio (SSMS)**. Estas herramientas NO se usan para ejecutar scripts ni modificar la base de datos.

---

## 🎯 Opciones de Documentación

### **1. SQL Server Management Studio (SSMS) - Diagrama de Base de Datos**

**Ventajas:**
- ✅ Integrado con SQL Server
- ✅ Genera diagramas visuales automáticamente
- ✅ Permite editar relaciones

**Pasos:**

1. **Abrir SSMS** y conectarse al servidor
2. **Expandir la base de datos:** `BD_PACKING_AGROMIGIVA_DESA`
3. **Expandir "Database Diagrams"**
4. **Crear nuevo diagrama:**
   - Click derecho en "Database Diagrams" → "New Database Diagram"
   - Seleccionar las tablas del schema `evalImagen`:
     - `evalImagen.AnalisisImagen`
     - `evalImagen.UmbralLuz`
     - `evalImagen.LoteEvaluacion`
     - `evalImagen.Alerta`
     - `evalImagen.Mensaje`
     - `evalImagen.Contacto`
     - `evalImagen.Dispositivo`
     - `evalImagen.MensajeAlerta`
   - Click en "Add"
5. **Guardar el diagrama:**
   - File → Save → Nombre: "ERD_evalImagen"
6. **Exportar como imagen:**
   - Click derecho en el diagrama → "Copy Diagram to Clipboard"
   - Pegar en Paint/Photoshop y guardar como PNG/JPEG

---

### **2. dbdiagram.io (Herramienta Online)**

**Ventajas:**
- ✅ Gratis y online
- ✅ Sintaxis simple (DBML)
- ✅ Exporta a PNG, PDF, SQL
- ✅ Colaborativo

**Pasos:**

1. **Ir a:** https://dbdiagram.io/
2. **Crear nuevo diagrama**
3. **Usar sintaxis DBML:**

```dbml
// Schema evalImagen
Table evalImagen.AnalisisImagen {
  analisisID int [pk, increment]
  lotID int [not null, ref: > GROWER.LOT.lotID]
  hilera nvarchar(50)
  planta nvarchar(50)
  filename nvarchar(500) [not null]
  fechaCaptura datetime
  porcentajeLuz decimal(5,2) [not null]
  porcentajeSombra decimal(5,2) [not null]
  latitud decimal(10,8)
  longitud decimal(11,8)
  processedImageUrl nvarchar(max)
  originalImageUrl nvarchar(max)
  modeloVersion nvarchar(50)
  statusID int [not null, default: 1]
  usuarioCreaID int [not null, default: 1]
  fechaCreacion datetime [not null, default: `GETDATE()`]
  
  indexes {
    (lotID, fechaCreacion) [name: 'IDX_AnalisisImagen_Lot_01']
    (hilera, planta) [name: 'IDX_AnalisisImagen_Ubicacion_01']
  }
}

Table evalImagen.UmbralLuz {
  umbralID int [pk, increment]
  descripcion nvarchar(200) [not null]
  porcentajeMin decimal(5,2) [not null]
  porcentajeMax decimal(5,2) [not null]
  tipoUmbral varchar(20) [not null] // CriticoRojo, CriticoAmarillo, Normal
  colorHex varchar(7)
  activo bit [not null, default: 1]
  statusID int [not null, default: 1]
  fechaCreacion datetime [not null, default: `GETDATE()`]
  
  indexes {
    tipoUmbral [name: 'IDX_UmbralLuz_Tipo_01']
  }
}

Table evalImagen.LoteEvaluacion {
  loteEvaluacionID int [pk, increment]
  lotID int [not null, unique, ref: > GROWER.LOT.lotID]
  variedadID int [ref: > GROWER.VARIETY.varietyID]
  fundoID char(4) [ref: > GROWER.FARMS.farmID]
  sectorID int [ref: > GROWER.STAGE.stageID]
  porcentajeLuzPromedio decimal(5,2) [not null]
  porcentajeLuzMin decimal(5,2)
  porcentajeLuzMax decimal(5,2)
  porcentajeSombraPromedio decimal(5,2) [not null]
  porcentajeSombraMin decimal(5,2)
  porcentajeSombraMax decimal(5,2)
  tipoUmbralActual varchar(20) // CriticoRojo, CriticoAmarillo, Normal
  umbralIDActual int [ref: > evalImagen.UmbralLuz.umbralID]
  fechaUltimaEvaluacion datetime
  fechaPrimeraEvaluacion datetime
  totalEvaluaciones int [not null, default: 0]
  periodoEvaluacionDias int [not null, default: 30]
  fechaUltimaActualizacion datetime [not null, default: `GETDATE()`]
  statusID int [not null, default: 1]
  
  indexes {
    lotID [name: 'IDX_LoteEvaluacion_LotID']
    fundoID [name: 'IDX_LoteEvaluacion_FundoID']
    tipoUmbralActual [name: 'IDX_LoteEvaluacion_TipoUmbral']
  }
}

Table evalImagen.Alerta {
  alertaID int [pk, increment]
  lotID int [not null, ref: > GROWER.LOT.lotID]
  loteEvaluacionID int [ref: > evalImagen.LoteEvaluacion.loteEvaluacionID]
  umbralID int [not null, ref: > evalImagen.UmbralLuz.umbralID]
  variedadID int [ref: > GROWER.VARIETY.varietyID]
  porcentajeLuzEvaluado decimal(5,2) [not null]
  tipoUmbral varchar(20) [not null] // CriticoRojo, CriticoAmarillo, Normal
  severidad varchar(20) [not null] // Critica, Advertencia, Info
  estado varchar(20) [not null, default: 'Pendiente'] // Pendiente, Enviada, Resuelta, Ignorada
  fechaCreacion datetime [not null, default: `GETDATE()`]
  fechaEnvio datetime
  fechaResolucion datetime
  mensajeID int [ref: > evalImagen.Mensaje.mensajeID]
  statusID int [not null, default: 1]
  
  indexes {
    loteEvaluacionID [name: 'IDX_Alerta_LoteEvaluacionID']
    estado [name: 'IDX_Alerta_Estado']
    tipoUmbral [name: 'IDX_Alerta_TipoUmbral']
  }
}

Table evalImagen.Mensaje {
  mensajeID int [pk, increment]
  alertaID int [ref: > evalImagen.Alerta.alertaID] // NULL para mensajes consolidados
  fundoID char(4) [ref: > GROWER.FARMS.farmID] // Para mensajes consolidados
  tipoMensaje varchar(50) [not null, default: 'Email'] // Email, SMS, Push
  asunto nvarchar(200) [not null]
  cuerpoHTML nvarchar(max) [not null]
  cuerpoTexto nvarchar(max)
  destinatarios nvarchar(max) [not null] // JSON array
  destinatariosCC nvarchar(max)
  destinatariosBCC nvarchar(max)
  estado varchar(20) [not null, default: 'Pendiente'] // Pendiente, Enviando, Enviado, Error
  fechaCreacion datetime [not null, default: `GETDATE()`]
  fechaEnvio datetime
  intentosEnvio int [not null, default: 0]
  resendMessageID nvarchar(100)
  resendResponse nvarchar(max) // JSON response
  errorMessage nvarchar(500)
  statusID int [not null, default: 1]
  
  indexes {
    alertaID [name: 'IDX_Mensaje_AlertaID']
    fundoID [name: 'IDX_Mensaje_FundoID']
    estado [name: 'IDX_Mensaje_Estado']
  }
}

Table evalImagen.Contacto {
  contactoID int [pk, increment]
  nombre nvarchar(200) [not null]
  email nvarchar(200) [not null]
  tipo varchar(50) [not null] // Administrador, Supervisor, Técnico
  fundoID char(4) [ref: > GROWER.FARMS.farmID] // NULL = todos los fundos
  sectorID int [ref: > GROWER.STAGE.stageID] // NULL = todos los sectores
  recibirAlertasCriticas bit [not null, default: 1]
  recibirAlertasAdvertencias bit [not null, default: 1]
  recibirAlertasNormales bit [not null, default: 0]
  prioridad int [not null, default: 0] // Mayor = más importante
  activo bit [not null, default: 1]
  fechaCreacion datetime [not null, default: `GETDATE()`]
  statusID int [not null, default: 1]
  
  indexes {
    email [name: 'IDX_Contacto_Email']
    fundoID [name: 'IDX_Contacto_FundoID']
    activo [name: 'IDX_Contacto_Activo']
  }
}

Table evalImagen.Dispositivo {
  dispositivoID int [pk, increment]
  deviceId nvarchar(100) [not null, unique]
  apiKey nvarchar(200) [not null]
  nombreDispositivo nvarchar(200)
  activo bit [not null, default: 1]
  ultimoAcceso datetime
  fechaCreacion datetime [not null, default: `GETDATE()`]
  statusID int [not null, default: 1]
  
  indexes {
    deviceId [name: 'IDX_Dispositivo_DeviceID']
    apiKey [name: 'IDX_Dispositivo_ApiKey']
  }
}

Table evalImagen.MensajeAlerta {
  mensajeAlertaID int [pk, increment]
  mensajeID int [not null, ref: > evalImagen.Mensaje.mensajeID]
  alertaID int [not null, ref: > evalImagen.Alerta.alertaID]
  fechaCreacion datetime [not null, default: `GETDATE()`]
  statusID int [not null, default: 1]
  
  indexes {
    (mensajeID, alertaID) [unique, name: 'UQ_MensajeAlerta_MensajeAlerta']
    mensajeID [name: 'IDX_MensajeAlerta_MensajeID']
    alertaID [name: 'IDX_MensajeAlerta_AlertaID']
  }
}

// Tablas externas (referencias)
Table GROWER.LOT {
  lotID int [pk]
  name nvarchar(200)
  stageID int
  statusID int
}

Table GROWER.FARMS {
  farmID char(4) [pk]
  Description nvarchar(200)
  statusID int
}

Table GROWER.STAGE {
  stageID int [pk]
  stage nvarchar(200)
  farmID char(4)
  statusID int
}

Table GROWER.VARIETY {
  varietyID int [pk]
  name nvarchar(200)
  statusID int
}
```

4. **Exportar:**
   - Click en "Export" → "Export to PNG" o "Export to PDF"

---

### **3. Generar Documentación desde SQL Server (Script SQL)**

**Ventajas:**
- ✅ Información completa y actualizada
- ✅ Incluye índices, constraints, tipos de datos

**Script SQL para generar documentación:**

```sql
-- Generar documentación completa del schema evalImagen
USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Tablas
SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    ep.value AS DESCRIPTION
FROM INFORMATION_SCHEMA.TABLES t
INNER JOIN INFORMATION_SCHEMA.COLUMNS c 
    ON t.TABLE_SCHEMA = c.TABLE_SCHEMA 
    AND t.TABLE_NAME = c.TABLE_NAME
LEFT JOIN sys.extended_properties ep
    ON ep.major_id = OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME)
    AND ep.minor_id = c.ORDINAL_POSITION
    AND ep.name = 'MS_Description'
WHERE t.TABLE_SCHEMA = 'evalImagen'
ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION;
```

---

### **4. Herramientas de Terceros**

#### **A. SQLDoc (Gratis)**
- Descargar desde: https://github.com/sql-doc/sql-doc
- Genera documentación HTML desde SQL Server

#### **B. ApexSQL Doc (Comercial)**
- Genera documentación profesional
- Incluye diagramas ERD

#### **C. Redgate SQL Doc (Comercial)**
- Integración con SQL Server
- Exporta a múltiples formatos

---

## 📝 Documentación Actual

Ya existe documentación en texto plano:

- **ERD en texto:** `scripts/00_setup/ERD_SCHEMA_IMAGE.txt`
- **Guía de creación:** `scripts/00_setup/GUIA_CREAR_TABLAS_EVALIMAGEN.md`
- **Estructura de BD:** `docs/ESTRUCTURA_BD_PRODUCCION.md`

---

## ✅ Recomendación

**Para uso rápido:** dbdiagram.io (gratis, online, fácil de usar)

**Para documentación completa:** SSMS Database Diagram + exportar a imagen

**Para documentación técnica:** Script SQL + exportar a Excel/CSV

---

**Última actualización:** 2025-11-21

