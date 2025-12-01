# Scripts DDL para DbSchema

Esta carpeta contiene scripts SQL **limpios y resumidos** con solo lo necesario para importar en DbSchema.

## 📋 Contenido

9 scripts DDL en orden de ejecución:

1. `00_CREATE_SCHEMA.sql` - Crear schema evalImagen (opcional)
2. `01_AnalisisImagen.sql` - Tabla base de análisis de imágenes
3. `02_UmbralLuz.sql` - Tabla de umbrales de luz/sombra
4. `03_LoteEvaluacion.sql` - Tabla de estadísticas agregadas por lote
5. `04_Alerta.sql` - Tabla de alertas generadas
6. `05_Mensaje.sql` - Tabla de mensajes enviados
7. `06_Contacto.sql` - Tabla de contactos/destinatarios
8. `07_Dispositivo.sql` - Tabla de dispositivos Android
9. `08_MensajeAlerta.sql` - Tabla de relación (junction table)

**Opcional:**
- `09_TABLAS_EXTERNAS_OPCIONAL.sql` - Tablas externas simplificadas (solo PKs) para mostrar relaciones completas

## 🎯 Características

Estos scripts contienen **SOLO**:
- ✅ `CREATE TABLE` statements
- ✅ Definición de columnas con tipos de datos
- ✅ Constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- ✅ Valores DEFAULT

**NO contienen:**
- ❌ `IF NOT EXISTS` (DbSchema puede manejar esto)
- ❌ `GO` statements
- ❌ `PRINT` statements
- ❌ Comentarios extensos
- ❌ Índices (opcionales para diagrama)
- ❌ Extended Properties
- ❌ INSERTs de datos
- ❌ Verificaciones y validaciones

## 🚀 Uso en DbSchema

1. Abrir DbSchema
2. **File → Import → SQL Script**
3. Seleccionar cada script en orden (01 a 08)
4. DbSchema creará las tablas automáticamente

## ⚠️ Notas

- **Orden de importación:** Importar en el orden numérico para respetar dependencias de Foreign Keys
- **Tablas externas:** Las FKs a `GROWER.*` y `MAST.USERS` pueden generar errores si no existen. 
  - **Solución:** Importar `09_TABLAS_EXTERNAS_OPCIONAL.sql` antes de importar las tablas principales
  - O eliminar temporalmente esas FKs y agregarlas después manualmente en DbSchema
- **Schema:** Importar `00_CREATE_SCHEMA.sql` primero o crear el schema manualmente en DbSchema
- **FK Circular:** La FK `FK_Alerta_Mensaje` se crea después de crear la tabla `Mensaje`. Si importas `04_Alerta.sql` primero, puedes agregar esta FK manualmente después en DbSchema.

## 📝 Scripts Completos

Los scripts completos con índices, extended properties y validaciones están en:
`scripts/01_tables/` (para ejecutar en SQL Server)

Estos scripts DDL son solo para **visualización en DbSchema**.

