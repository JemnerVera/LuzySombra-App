# DbSchema - Documentación del Schema evalImagen

Esta carpeta contiene documentación y archivos relacionados con **DbSchema** para el schema `evalImagen`.

## 📁 Contenido

- **`GUIA_DBSCHEMA.md`** - Guía completa paso a paso para usar DbSchema
- **`GUIA_DOCUMENTAR_SCHEMA_BD.md`** - Guía de otras herramientas para documentar el schema (SSMS, dbdiagram.io, etc.)
- **`ddl/`** - Scripts DDL limpios optimizados para DbSchema (9 archivos)
  - `00_CREATE_SCHEMA.sql` - Crear schema evalImagen
  - `01_AnalisisImagen.sql` a `08_MensajeAlerta.sql` - Scripts de tablas
- **`LuzSombra_evalImagen.dbs`** - Archivo de proyecto DbSchema (guardar aquí después de crear)

## ⚠️ Importante

**DbSchema se usa SOLO para visualización y documentación local.** Los scripts SQL se ejecutan **manualmente en SQL Server Management Studio (SSMS)**. DbSchema NO se usa para ejecutar scripts ni modificar la base de datos.

## 🚀 Inicio Rápido

1. Leer la guía: `GUIA_DBSCHEMA.md`
2. Instalar DbSchema: https://dbschema.com/download.html
3. Abrir DbSchema → **File → New Project** (sin conectar a BD)
4. **File → Import → SQL Script**
5. Importar scripts desde `ddl/` en orden (01 a 08)
6. Crear diagrama ERD
7. Guardar proyecto en esta carpeta

## 📊 Información de Conexión

**Desarrollo:**
```
Host: 10.1.10.4
Port: 1433
Database: BD_PACKING_AGROMIGIVA_DESA
User: ucser_luzsombra_desa
Password: D3s4S3r12
Schema: evalImagen
```

**Producción:**
```
Host: [Servidor de producción]
Port: 1433
Database: BD_PACKING_AGROMIGIVA_PROD
User: ucser_luzSombra
Password: [Password de producción]
Schema: evalImagen
```

## 📝 Tablas del Schema

El schema `evalImagen` contiene 8 tablas:

1. `AnalisisImagen` - Resultados de análisis de imágenes
2. `UmbralLuz` - Configuración de umbrales de luz/sombra
3. `LoteEvaluacion` - Estadísticas agregadas por lote
4. `Alerta` - Alertas generadas por umbrales
5. `Mensaje` - Logs de mensajes enviados
6. `Contacto` - Destinatarios de alertas
7. `Dispositivo` - Dispositivos Android autorizados
8. `MensajeAlerta` - Relación muchos-a-muchos (junction table)

## 🔗 Relaciones Principales

- `AnalisisImagen` → `GROWER.LOT` (via `lotID`)
- `LoteEvaluacion` → `GROWER.LOT` (via `lotID`)
- `LoteEvaluacion` → `UmbralLuz` (via `umbralIDActual`)
- `Alerta` → `LoteEvaluacion` (via `loteEvaluacionID`)
- `Alerta` → `UmbralLuz` (via `umbralID`)
- `Mensaje` → `Alerta` (via `alertaID`, opcional)
- `MensajeAlerta` → `Mensaje` y `Alerta` (junction table)

## 📤 Exportar Documentación

Después de crear el diagrama en DbSchema:

1. **Exportar como imagen:** PNG o PDF para presentaciones
2. **Exportar HTML:** Documentación interactiva completa
3. **Guardar proyecto:** Archivo `.dbs` en esta carpeta

## 🔧 Ejecutar Scripts SQL

**Los scripts SQL se ejecutan manualmente en SSMS:**

1. Abrir SQL Server Management Studio
2. Conectarse al servidor
3. Abrir el script desde `scripts/01_tables/`
4. Ejecutar el script (F5)

**Ver guía completa:** `scripts/00_setup/GUIA_CREAR_TABLAS_EVALIMAGEN.md`

## ⚠️ Notas

- El archivo `.dbs` contiene la conexión a la BD (puede incluir credenciales)
- Considerar usar variables de entorno o configuración externa para credenciales
- Sincronizar regularmente con la BD para mantener diagrama actualizado

