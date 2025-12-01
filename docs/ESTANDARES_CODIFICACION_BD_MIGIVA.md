# 📋 Estándares de Codificación de Bases de Datos (Migiva)

## Objetivo
Definir un lenguaje común para objetos de BD que facilite entendimiento y mantenimiento.

## Alcance
Aplica a todos los proyectos y áreas relacionados con desarrollo y mantenimiento de BD.

---

## Nomenclatura

- Uso de CamelCase en español, evitando caracteres especiales y números.
- Prefijos y abreviaturas estandarizadas (ej. AGRI, CLI, COS, PKG, etc.).

---

## Usuarios

- Owner → `UCOWN_[Servicio]`
- Servicio → `UCSER_[Servicio]`
- Soporte → `UCSOP_[Inicial+Apellido]`
- Responsabilidad → `UCRES_[Inicial+Apellido]`
- Link Server → `UCLNK_[BD]_[Instancia]`
- Temporales → `TMP` según caso.

---

## Esquemas

Definidos por área/proceso (ej. `planta`, `packing`, `calidadAgricola`, `sales`, `util`, etc.).

---

## Tablas

- **Comunes:** `nombreDescripción`
- **Externas:** `nombreDescripción_ext`
- **Temporales:** `nombreDescripción_tmp` o `#tempXXX_nombre`

---

## Constraints

- **PK:** `PK_[nombreTabla]`
- **FK:** `FK_[tabla]_[tablaRef]_XX`
- **UQ:** `UQ_[tabla]_[columna]_XX`
- **CK:** `CK_[tabla]_[regla]_XX`
- **DF:** `DF_[tabla]_[columna]_XX`

---

## Índices

`IDX_[tabla]_[columnas]_XXX`

---

## Triggers

`trg_[tabla][Tipo][DML]` (AF, IO / I, U, D)

---

## Vistas

- **Primarias:** `vwp_[Módulo]_[Tabla]`
- **Compuestas:** `vwc_[Módulo]_[Nombre]`

---

## Procedimientos Almacenados

`usp_[Prefijo]_[Acción/Tabla]` (ins, upd, del, sel)

---

## Funciones

- **Escalar:** `ufn_[Prefijo]_[Descripción]`
- **Tabla:** `uft_[Prefijo]_[Descripción]`

---

## Secuencias

`seq_[Tabla]XX` o `seqG[Servicio]_XX`

---

## Types

`uTyp_[Prefijo]_[Descripción]`

---

## Consultas SQL

- Evitar `SELECT *`, usar columnas explícitas.
- Uso de `WITH (NOLOCK)` solo en reportes.
- No usar funciones en filtros `WHERE`.

---

## Diseño de Tablas

- **Tipos de datos:** `date`, `datetime`, `time`, `varchar`, `decimal(18,4)`, `bit`.
- **PK:** `INT IDENTITY(1,1)`.
- **FK obligatorio.**
- **Columnas NOT NULL** salvo justificación.
- Definir `CHECK` e índices según reglas de negocio.

---

## Procedimientos y Funciones

- **Parámetros:** `pln_` (IN), `pOu_` (OUT), `plO_` (INOUT).
- **Variables:** prefijo `v`.
- **Manejo de errores:** `TRY-CATCH`, `THROW`.
- **Instrucciones SET:** `NOCOUNT`, `ARITHABORT`, `ANSI_NULLS`, `XACT_ABORT`.

---

## Documentación

- Comentarios extendidos en tablas y columnas.
- Campos de auditoría: `usuarioCreaID`, `fechaCreacion`, `usuarioModificaID`, `fechaModificacion`.
- Encabezado obligatorio en SP, triggers, funciones y vistas con datos de cliente, sistema, autor, fecha, descripción y revisiones.

---

## Scripts

- Extensión `.sql`
- `CREATE` para nuevos objetos, `CREATE OR REPLACE` para modificaciones.
- Nombres: orden, número de proyecto, `nombreScript.sql`
- Sentencias DML terminan en `;`.

