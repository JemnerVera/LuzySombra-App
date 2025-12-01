# Guía Completa: DbSchema - Documentar Schema evalImagen

## 📋 Resumen

Esta guía explica paso a paso cómo usar **DbSchema** para documentar y visualizar el schema `evalImagen` de la base de datos `BD_PACKING_AGROMIGIVA_DESA`.

**DbSchema** es una herramienta profesional que permite:
- ✅ Conectarse a bases de datos SQL Server
- ✅ Importar esquemas automáticamente
- ✅ Crear diagramas ERD visuales
- ✅ Documentar tablas, columnas y relaciones
- ✅ Exportar documentación en múltiples formatos

**⚠️ IMPORTANTE:** DbSchema se usa **SOLO para visualización y documentación local**. Los scripts SQL se ejecutan **manualmente en SQL Server Management Studio (SSMS)**. DbSchema NO se usa para ejecutar scripts ni modificar la base de datos.

**📝 NOTA:** Esta guía explica cómo importar tablas desde los scripts SQL existentes, **SIN necesidad de conectarse a la base de datos**.

---

## 🚀 Inicio Rápido (Método Más Fácil)

**La forma más fácil de crear las tablas en DbSchema:**

1. **Abrir DbSchema** → **File → New Project** (sin conectar a BD)
2. **File → Import → SQL Script**
3. Importar cada script en orden desde `dbschema/ddl/`:
   - `00_CREATE_SCHEMA.sql` (opcional, crear schema primero)
   - `01_AnalisisImagen.sql`
   - `02_UmbralLuz.sql`
   - `03_LoteEvaluacion.sql`
   - `04_Alerta.sql`
   - `05_Mensaje.sql`
   - `06_Contacto.sql`
   - `07_Dispositivo.sql`
   - `08_MensajeAlerta.sql`
4. **Crear diagrama:** Layout → New Layout → Agregar todas las tablas
5. **Listo!** Ya tienes el diagrama ERD sin conectarte a la BD

**💡 Recomendación:** Usa los scripts de `dbschema/ddl/` (versiones limpias) en lugar de `scripts/01_tables/` (versiones completas con IF NOT EXISTS, GO, etc.). Los scripts DDL están optimizados para DbSchema.

**Si la importación automática falla**, ver sección **Paso 2.3** para método alternativo (copiar CREATE TABLE).

---

## 🚀 Paso 1: Instalación y Configuración Inicial

### **1.1 Descargar DbSchema**

1. Ir a: https://dbschema.com/download.html
2. Descargar la versión para Windows
3. Instalar el software (versión gratuita disponible con limitaciones)

### **1.2 Abrir DbSchema**

1. Ejecutar DbSchema
2. En la pantalla de bienvenida, seleccionar **"New Project"** o **"File → New Project"**
3. **NO es necesario conectarse a la base de datos**

---

## 📥 Paso 2: Importar Tablas desde Scripts SQL

### **2.1 Método Recomendado: Importar desde Scripts DDL Limpios**

Esta es la forma **más fácil** de crear las tablas en DbSchema sin conectarse a la BD:

1. **File → Import → SQL Script** o **Tools → Import → SQL Script**
2. Seleccionar los scripts desde `dbschema/ddl/` en orden:
   - `00_CREATE_SCHEMA.sql` (opcional, crear schema primero)
   - `01_AnalisisImagen.sql` → Crea `AnalisisImagen`
   - `02_UmbralLuz.sql` → Crea `UmbralLuz`
   - `03_LoteEvaluacion.sql` → Crea `LoteEvaluacion`
   - `04_Alerta.sql` → Crea `Alerta`
   - `05_Mensaje.sql` → Crea `Mensaje`
   - `06_Contacto.sql` → Crea `Contacto`
   - `07_Dispositivo.sql` → Crea `Dispositivo`
   - `08_MensajeAlerta.sql` → Crea `MensajeAlerta`
3. DbSchema leerá cada script y creará las tablas automáticamente

**💡 Ventajas de usar `dbschema/ddl/`:**
- ✅ Scripts limpios sin `IF NOT EXISTS`, `GO`, `PRINT`
- ✅ Solo DDL esencial (CREATE TABLE + constraints)
- ✅ Optimizados para importación en DbSchema
- ✅ Sin comentarios extensos ni código adicional

**⚠️ Importante:** Importar en este orden para respetar las dependencias de Foreign Keys.

**Alternativa:** Si prefieres usar los scripts completos, están en `scripts/01_tables/` pero pueden requerir limpieza manual.

### **2.2 Método Alternativo: Crear Tablas Manualmente**

Si la importación automática no funciona bien:

1. **Click derecho en el panel "Tables"** → **"New Table"**
2. Nombre: `AnalisisImagen`
3. Schema: `evalImagen`
4. Agregar columnas manualmente copiando desde el script SQL
5. Repetir para cada tabla

### **2.3 Método Avanzado: Copiar y Pegar CREATE TABLE**

1. Abrir el script SQL en un editor de texto
2. Copiar solo la parte del `CREATE TABLE` (sin los `IF NOT EXISTS`, `GO`, etc.)
3. En DbSchema: **Tools → SQL Editor** o **View → SQL Editor**
4. Pegar el CREATE TABLE
5. Ejecutar (DbSchema interpretará y creará la tabla)

**Ejemplo de CREATE TABLE limpio:**
```sql
CREATE TABLE evalImagen.AnalisisImagen (
    analisisID INT IDENTITY(1,1) NOT NULL,
    lotID INT NOT NULL,
    hilera NVARCHAR(50) NULL,
    planta NVARCHAR(50) NULL,
    filename NVARCHAR(500) NOT NULL,
    fechaCaptura DATETIME NULL,
    porcentajeLuz DECIMAL(5,2) NOT NULL,
    porcentajeSombra DECIMAL(5,2) NOT NULL,
    latitud DECIMAL(10,8) NULL,
    longitud DECIMAL(11,8) NULL,
    processedImageUrl NVARCHAR(MAX) NULL,
    originalImageUrl NVARCHAR(MAX) NULL,
    modeloVersion NVARCHAR(50) NULL DEFAULT 'heuristic_v1',
    statusID INT NOT NULL DEFAULT 1,
    usuarioCreaID INT NOT NULL DEFAULT 1,
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_AnalisisImagen PRIMARY KEY (analisisID),
    CONSTRAINT FK_AnalisisImagen_LOT_01 
        FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
    CONSTRAINT UQ_AnalisisImagen_FilenameLot_01 
        UNIQUE (filename, lotID)
);
```

### **2.4 Verificar Tablas Importadas**

Después de importar todas las tablas:

1. En el panel izquierdo, expandir **"Tables"**
2. Verificar que aparecen las 8 tablas:
   - `evalImagen.AnalisisImagen`
   - `evalImagen.UmbralLuz`
   - `evalImagen.LoteEvaluacion`
   - `evalImagen.Alerta`
   - `evalImagen.Mensaje`
   - `evalImagen.Contacto`
   - `evalImagen.Dispositivo`
   - `evalImagen.MensajeAlerta`

---

## 🎨 Paso 4: Crear Diagrama ERD

### **4.1 Crear Nuevo Layout**

1. Click en **"Layout" → "New Layout"** o **Ctrl+N**
2. Nombre: `ERD_evalImagen`
3. Tipo: **"Relational Diagram"**

### **4.2 Agregar Tablas al Diagrama**

**Opción A: Automático**
- DbSchema puede agregar todas las tablas relacionadas automáticamente
- Click en una tabla → **"Add Related Tables"**

**Opción B: Manual**
- Arrastrar tablas desde el panel izquierdo al diagrama
- O seleccionar tablas y click derecho → **"Add to Layout"**

### **4.3 Organizar Tablas**

1. **Arrastrar tablas** para organizarlas visualmente
2. **Agrupar por funcionalidad:**
   - **Grupo 1: Datos Base**
     - `AnalisisImagen`
     - `LoteEvaluacion`
   - **Grupo 2: Configuración**
     - `UmbralLuz`
     - `Contacto`
     - `Dispositivo`
   - **Grupo 3: Alertas y Mensajes**
     - `Alerta`
     - `Mensaje`
     - `MensajeAlerta`

3. **Ajustar tamaño:** Click en tabla → arrastrar esquinas

### **4.4 Visualizar y Agregar Relaciones**

**Si las Foreign Keys se importaron correctamente**, se mostrarán automáticamente como líneas conectando tablas:

- **Línea sólida:** Foreign Key obligatoria (NOT NULL)
- **Línea punteada:** Foreign Key opcional (NULL)
- **Cardinalidad:** Se muestra automáticamente (1:1, 1:N, N:M)

**Si las relaciones NO se muestran automáticamente**, agregarlas manualmente:

1. **Click derecho en la tabla origen** (ej: `AnalisisImagen`)
2. **"Add Foreign Key"** o **"Edit Table" → "Foreign Keys"**
3. Configurar:
   - **Referenced Table:** Tabla destino (ej: `GROWER.LOT` o crear tabla externa)
   - **Local Column:** Columna FK (ej: `lotID`)
   - **Referenced Column:** Columna PK de destino (ej: `lotID`)
4. Click **"OK"**

**Relaciones principales a agregar:**
- `AnalisisImagen.lotID` → `GROWER.LOT.lotID` (tabla externa)
- `LoteEvaluacion.lotID` → `GROWER.LOT.lotID` (tabla externa)
- `LoteEvaluacion.umbralIDActual` → `UmbralLuz.umbralID`
- `Alerta.loteEvaluacionID` → `LoteEvaluacion.loteEvaluacionID`
- `Alerta.umbralID` → `UmbralLuz.umbralID`
- `Mensaje.alertaID` → `Alerta.alertaID` (opcional, puede ser NULL)
- `MensajeAlerta.mensajeID` → `Mensaje.mensajeID`
- `MensajeAlerta.alertaID` → `Alerta.alertaID`

**FK Circular (importante):**
- `Alerta.mensajeID` → `Mensaje.mensajeID` (se crea después de crear `Mensaje`)
- Si importas los scripts DDL, esta FK puede no crearse automáticamente
- **Solución:** Agregar manualmente después de importar ambas tablas, o importar `05_Mensaje.sql` primero y luego agregar la FK en `Alerta`

**Nota sobre tablas externas (GROWER.LOT, etc.):**
- Importar `ddl/09_TABLAS_EXTERNAS_OPCIONAL.sql` antes de las tablas principales
- O crear tablas simplificadas solo con la PK para mostrar las relaciones
- O marcar las FKs como "External Reference" sin crear la tabla completa

---

## 📝 Paso 5: Documentar Tablas y Columnas

### **5.1 Agregar Descripciones a Tablas**

1. **Click derecho en una tabla** → **"Edit Table"** o **F2**
2. En la pestaña **"Description"**, agregar:
   - Propósito de la tabla
   - Uso en el sistema
   - Notas importantes

**Ejemplo para `AnalisisImagen`:**
```
Almacena resultados de análisis de imágenes para clasificación de luz/sombra en campos agrícolas.
Cada registro representa una imagen procesada con porcentajes de luz y sombra calculados.
Incluye metadatos GPS, fecha de captura, y URLs de imágenes procesadas (Base64).
```

### **5.2 Agregar Descripciones a Columnas**

1. En el editor de tabla, seleccionar una **columna**
2. En el campo **"Description"**, agregar descripción

**Ejemplos:**
- `analisisID`: "Identificador único del análisis de imagen (auto-incremental)"
- `lotID`: "Foreign Key al lote donde se tomó la imagen (GROWER.LOT)"
- `porcentajeLuz`: "Porcentaje de área clasificada como luz (0-100)"
- `processedImageUrl`: "Thumbnail optimizado en Base64 (JPEG, ~100-200KB). Imagen procesada con Machine Learning."

### **5.3 Agregar Notas y Tags**

- **Tags:** Para categorizar tablas (ej: "Core", "Alertas", "Configuración")
- **Notes:** Notas adicionales sobre la tabla

---

## 🎯 Paso 6: Personalizar Vista del Diagrama

### **6.1 Configurar Vista de Tablas**

1. **Click derecho en tabla** → **"Table Properties"**
2. Configurar qué mostrar:
   - ✅ **Primary Keys** (siempre visible)
   - ✅ **Foreign Keys** (siempre visible)
   - ✅ **Columns** (todas o solo importantes)
   - ✅ **Indexes** (opcional)
   - ✅ **Data Types** (opcional)

### **6.2 Colores y Estilos**

1. **Seleccionar tabla** → Click derecho → **"Table Style"**
2. Configurar:
   - **Color de fondo:** Por grupo funcional
   - **Color de borde:** Por tipo de tabla
   - **Fuente:** Tamaño y estilo

**Sugerencia de colores:**
- **Azul claro:** Tablas de datos base (`AnalisisImagen`, `LoteEvaluacion`)
- **Verde claro:** Tablas de configuración (`UmbralLuz`, `Contacto`, `Dispositivo`)
- **Naranja claro:** Tablas de alertas (`Alerta`, `Mensaje`, `MensajeAlerta`)

### **6.3 Configurar Vista de Relaciones**

1. **Click en una relación (línea)**
2. Propiedades:
   - **Estilo de línea:** Sólida, punteada, etc.
   - **Color:** Por tipo de relación
   - **Etiquetas:** Mostrar nombres de FK

---

## 📊 Paso 7: Agregar Tablas Externas (Referencias) - Opcional

### **7.1 Crear Tablas Externas Simplificadas**

Para mostrar relaciones completas con tablas externas (GROWER.*), puedes crear versiones simplificadas:

1. **Click derecho en "Tables"** → **"New Table"**
2. Nombre: `GROWER.LOT`
3. Schema: `GROWER`
4. Agregar solo la columna PK: `lotID INT PRIMARY KEY`
5. Repetir para otras tablas externas si es necesario:
   - `GROWER.FARMS` (solo `farmID CHAR(4) PRIMARY KEY`)
   - `GROWER.STAGE` (solo `stageID INT PRIMARY KEY`)
   - `GROWER.VARIETY` (solo `varietyID INT PRIMARY KEY`)

### **7.2 Estilizar Tablas Externas**

- **Color gris:** Para indicar que son tablas externas
- **Borde punteado:** Para diferenciarlas de tablas del schema `evalImagen`
- **Nota:** Agregar descripción "Tabla externa - Schema GROWER"

**Alternativa:** Si no quieres crear las tablas externas, simplemente no agregues las FKs que referencian a GROWER.*, o márcalas como "External Reference" sin crear la tabla.

---

## 💾 Paso 8: Guardar Proyecto

### **8.1 Guardar Archivo DbSchema**

1. **File → Save Project** o **Ctrl+S**
2. Nombre: `LuzSombra_evalImagen.dbs`
3. Ubicación: `dbschema/` (carpeta del proyecto)

**El archivo `.dbs` contiene:**
- Conexión a la base de datos
- Layout del diagrama
- Documentación de tablas y columnas
- Configuraciones de vista

### **8.2 Sincronizar con Base de Datos**

1. **File → Synchronize with Database**
2. DbSchema comparará el proyecto con la BD actual
3. Mostrará diferencias y permitirá actualizar

---

## 📤 Paso 9: Exportar Documentación

### **9.1 Exportar Diagrama como Imagen**

1. **File → Export → Image**
2. Formatos disponibles:
   - **PNG** (recomendado para presentaciones)
   - **JPEG**
   - **SVG** (vectorial, escalable)
   - **PDF** (para documentación)
3. Configurar:
   - **Resolution:** 300 DPI (alta calidad)
   - **Size:** Ajustar según necesidad
   - **Background:** Blanco o transparente

### **9.2 Exportar Documentación HTML**

1. **File → Export → HTML Documentation**
2. Se generará un sitio web completo con:
   - Diagrama interactivo
   - Descripción de cada tabla
   - Lista de columnas con tipos
   - Relaciones entre tablas
   - Índices y constraints

### **9.3 Exportar a PDF**

1. **File → Export → PDF**
2. Incluye:
   - Diagrama ERD
   - Documentación de tablas
   - Lista de relaciones

### **9.4 Exportar a SQL Script**

1. **File → Export → SQL Script**
2. Genera scripts CREATE TABLE con toda la estructura

---

## 🔄 Paso 10: Actualizar Tablas desde Scripts SQL

### **10.1 Actualizar Tabla Existente**

Si modificas un script SQL y quieres actualizar la tabla en DbSchema:

1. **Click derecho en la tabla** → **"Edit Table"** o **F2**
2. Hacer cambios manualmente según el script actualizado
3. O eliminar la tabla y re-importar desde el script actualizado

### **10.2 Re-importar desde Script Actualizado**

1. **Click derecho en tabla** → **"Delete Table"** (solo del proyecto, no de la BD)
2. **File → Import → SQL Script**
3. Seleccionar el script actualizado
4. La tabla se recreará con la nueva estructura

**⚠️ Nota:** Como no estás conectado a la BD, las actualizaciones son manuales. Siempre importa desde los scripts SQL más recientes.

---

## 🎨 Consejos y Mejores Prácticas

### **Organización del Diagrama**

1. **Agrupar tablas relacionadas** cerca unas de otras
2. **Evitar cruces de líneas** cuando sea posible
3. **Usar colores consistentes** por tipo de tabla
4. **Mantener diagrama legible** (no demasiadas tablas a la vez)

### **Documentación**

1. **Describir propósito** de cada tabla claramente
2. **Explicar relaciones** complejas en notas
3. **Documentar campos importantes** (PKs, FKs, campos calculados)
4. **Agregar ejemplos** cuando sea útil

### **Mantenimiento**

1. **Sincronizar regularmente** con la BD
2. **Versionar el archivo `.dbs`** en Git
3. **Exportar documentación** después de cambios importantes
4. **Compartir con el equipo** para mantener consistencia

---

## ⚠️ Solución de Problemas

### **Error: "Cannot parse SQL script"**

**Causas:**
- El script tiene sintaxis específica de SQL Server que DbSchema no reconoce
- Comandos `GO`, `IF NOT EXISTS`, etc.

**Solución:**
1. **Copiar solo el CREATE TABLE** sin los comandos adicionales
2. **Eliminar:** `IF NOT EXISTS`, `GO`, `PRINT`, comentarios `--`
3. **Mantener solo:** `CREATE TABLE`, columnas, constraints
4. Pegar en SQL Editor de DbSchema

### **Error: "Foreign Key reference not found"**

**Causa:** La tabla referenciada (ej: `GROWER.LOT`) no existe en DbSchema

**Solución:**
1. **Opción 1:** Crear tabla externa simplificada (solo con PK)
2. **Opción 2:** Eliminar temporalmente la FK y agregarla después
3. **Opción 3:** Marcar como "External Table" en DbSchema

### **Relaciones no se muestran**

**Causa:** Foreign Keys no detectadas automáticamente

**Solución:**
1. **Sincronizar con BD:** File → Synchronize
2. **Verificar FKs en BD:** 
   ```sql
   SELECT * FROM sys.foreign_keys 
   WHERE OBJECT_SCHEMA_NAME(parent_object_id) = 'evalImagen'
   ```
3. **Agregar manualmente:** Click derecho en tabla → "Add Foreign Key"

### **Diagrama muy grande y difícil de navegar**

**Solución:**
1. **Crear múltiples layouts:**
   - Layout 1: Tablas principales
   - Layout 2: Tablas de alertas
   - Layout 3: Tablas de configuración
2. **Usar zoom:** Ctrl + Mouse Wheel
3. **Ocultar columnas menos importantes:** Table Properties → Hide Columns

---

## 📚 Recursos Adicionales

- **Documentación oficial:** https://dbschema.com/documentation/
- **Tutoriales:** https://dbschema.com/tutorials/
- **Foro de soporte:** https://dbschema.com/forum/

---

## ✅ Checklist de Configuración

- [ ] DbSchema instalado
- [ ] Proyecto nuevo creado (sin conexión a BD)
- [ ] 8 scripts SQL importados desde `scripts/01_tables/`
- [ ] 8 tablas creadas en DbSchema:
  - [ ] `AnalisisImagen`
  - [ ] `UmbralLuz`
  - [ ] `LoteEvaluacion`
  - [ ] `Alerta`
  - [ ] `Mensaje`
  - [ ] `Contacto`
  - [ ] `Dispositivo`
  - [ ] `MensajeAlerta`
- [ ] Tablas agregadas al diagrama
- [ ] Relaciones (Foreign Keys) visibles
- [ ] Tablas organizadas y coloreadas
- [ ] Descripciones agregadas a tablas principales
- [ ] Descripciones agregadas a columnas importantes
- [ ] Proyecto guardado (`LuzSombra_evalImagen.dbs`)
- [ ] Diagrama exportado como PNG/PDF
- [ ] Documentación HTML exportada (opcional)

---

## 🎯 Próximos Pasos

1. **Compartir diagrama** con el equipo
2. **Actualizar documentación** cuando cambie la estructura
3. **Usar diagrama** como referencia durante desarrollo
4. **Incluir en documentación** del proyecto

---

**Última actualización:** 2025-11-21

