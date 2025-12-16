# Guía: Crear Tablas del Schema evalImagen

## 📋 Resumen

Esta guía explica cómo crear todas las tablas del schema `evalImagen` en la base de datos `[TU_BASE_DE_DATOS]`.

---

## ✅ Prerrequisitos

1. **Acceso a SQL Server Management Studio (SSMS)** o herramienta similar
2. **Credenciales de base de datos:**
   - **Desarrollo:** Contactar al administrador para obtener credenciales
   - **Producción:** Contactar al administrador para obtener credenciales
3. **Base de datos:** `[TU_BASE_DE_DATOS]` (o la base de datos correspondiente)
4. **Permisos:** Usuario debe tener permisos de `CREATE TABLE`, `CREATE SCHEMA`, `CREATE INDEX`

---

## 📁 Ubicación de Scripts

Todos los scripts de creación de tablas están en:
```
scripts/01_tables/
```

---

## 🔢 Orden de Ejecución

**IMPORTANTE:** Ejecutar los scripts en el orden indicado para respetar las dependencias de Foreign Keys.

### **1. Tabla Base (crea el schema)**
```
01_evalImagen.AnalisisImagen.sql
```
- ✅ Crea el schema `evalImagen` si no existe
- ✅ Crea la tabla `evalImagen.AnalisisImagen`
- ⚠️ **Debe ejecutarse PRIMERO**

### **2. Tablas de Configuración**
```
02_evalImagen.UmbralLuz.sql
```
- ✅ Crea `evalImagen.UmbralLuz` (umbrales de luz/sombra)
- ⚠️ Requerida por `LoteEvaluacion` y `Alerta`

### **3. Tabla de Evaluación**
```
03_evalImagen.LoteEvaluacion.sql
```
- ✅ Crea `evalImagen.LoteEvaluacion` (estadísticas agregadas por lote)
- ⚠️ Requiere: `UmbralLuz`, `GROWER.LOT`, `GROWER.VARIETY`, `GROWER.FARMS`, `GROWER.STAGE`

### **4. Tabla de Alertas**
```
04_evalImagen.Alerta.sql
```
- ✅ Crea `evalImagen.Alerta` (alertas generadas por umbrales)
- ⚠️ Requiere: `LoteEvaluacion`, `UmbralLuz`

### **5. Tabla de Mensajes**
```
05_evalImagen.Mensaje.sql
```
- ✅ Crea `evalImagen.Mensaje` (logs de mensajes enviados)
- ⚠️ Requiere: `Alerta`, `GROWER.FARMS`

### **6. Tabla de Contactos**
```
06_evalImagen.Contacto.sql
```
- ✅ Crea `evalImagen.Contacto` (destinatarios de alertas)
- ⚠️ Requiere: `GROWER.FARMS`, `GROWER.STAGE`

### **7. Tabla de Dispositivos**
```
07_evalImagen.Dispositivo.sql
```
- ✅ Crea `evalImagen.Dispositivo` (dispositivos Android autorizados)
- ⚠️ No tiene dependencias de otras tablas del schema

### **8. Tabla de Relación (Junction Table)**
```
08_evalImagen.MensajeAlerta.sql
```
- ✅ Crea `evalImagen.MensajeAlerta` (relación muchos-a-muchos entre Mensaje y Alerta)
- ⚠️ Requiere: `Mensaje`, `Alerta`
- ⚠️ **Debe ejecutarse ÚLTIMO**

---

## 🚀 Pasos para Ejecutar

### **Opción 1: Script Maestro (Recomendado)**

1. Abrir SQL Server Management Studio
2. Conectarse al servidor: `[TU_SERVIDOR_SQL]` (o el servidor correspondiente)
3. Abrir el archivo:
   ```
   scripts/00_setup/00_SCRIPT_MAESTRO_RECREAR_TABLAS.sql
   ```
4. Verificar que la base de datos sea `[TU_BASE_DE_DATOS]` (o la correcta)
5. Ejecutar el script completo (F5)

El script maestro ejecuta todos los scripts en el orden correcto automáticamente.

---

### **Opción 2: Ejecución Manual**

Si prefieres ejecutar cada script individualmente:

1. **Abrir SSMS** y conectarse al servidor
2. **Seleccionar la base de datos:** `[TU_BASE_DE_DATOS]`
3. **Ejecutar cada script en orden:**
   - Abrir `scripts/01_tables/01_evalImagen.AnalisisImagen.sql`
   - Ejecutar (F5)
   - Verificar que no haya errores
   - Repetir con el siguiente script

---

## ✅ Verificación Post-Ejecución

### **1. Verificar Schema Creado**
```sql
SELECT * FROM sys.schemas WHERE name = 'evalImagen';
```

### **2. Verificar Tablas Creadas**
```sql
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = t.TABLE_SCHEMA 
     AND TABLE_NAME = t.TABLE_NAME) AS COLUMN_COUNT
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_SCHEMA = 'evalImagen'
ORDER BY TABLE_NAME;
```

**Resultado esperado:** 8 tablas
- `AnalisisImagen`
- `UmbralLuz`
- `LoteEvaluacion`
- `Alerta`
- `Mensaje`
- `Contacto`
- `Dispositivo`
- `MensajeAlerta`

### **3. Verificar Foreign Keys**
```sql
SELECT 
    fk.name AS FK_NAME,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS PARENT_SCHEMA,
    OBJECT_NAME(fk.parent_object_id) AS PARENT_TABLE,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS REFERENCED_SCHEMA,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE
FROM sys.foreign_keys fk
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'evalImagen'
ORDER BY PARENT_TABLE, FK_NAME;
```

### **4. Verificar Índices**
```sql
SELECT 
    OBJECT_SCHEMA_NAME(i.object_id) AS SCHEMA_NAME,
    OBJECT_NAME(i.object_id) AS TABLE_NAME,
    i.name AS INDEX_NAME,
    i.type_desc AS INDEX_TYPE
FROM sys.indexes i
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'evalImagen'
  AND i.type > 0  -- Excluir índices clustered (PK)
ORDER BY TABLE_NAME, INDEX_NAME;
```

---

## ⚠️ Errores Comunes

### **Error: "Schema 'evalImagen' does not exist"**
- **Causa:** El script `01_evalImagen.AnalisisImagen.sql` no se ejecutó primero
- **Solución:** Ejecutar `01_evalImagen.AnalisisImagen.sql` primero (crea el schema)

### **Error: "Foreign key constraint failed"**
- **Causa:** Se ejecutó un script antes de crear la tabla referenciada
- **Solución:** Verificar el orden de ejecución y ejecutar las tablas dependientes primero

### **Error: "Table already exists"**
- **Causa:** La tabla ya fue creada anteriormente
- **Solución:** Los scripts usan `IF NOT EXISTS`, así que es seguro ejecutarlos de nuevo. Si necesitas recrear, eliminar primero la tabla.

### **Error: "Permission denied"**
- **Causa:** El usuario no tiene permisos de CREATE TABLE
- **Solución:** Solicitar permisos al DBA o usar un usuario con permisos adecuados

---

## 📝 Notas Importantes

1. **Los scripts son idempotentes:** Pueden ejecutarse múltiples veces sin problemas (usan `IF NOT EXISTS`)

2. **No se eliminan datos:** Los scripts solo crean objetos, no eliminan datos existentes

3. **Dependencias externas:** Las tablas dependen de schemas existentes:
   - `GROWER.LOT`
   - `GROWER.STAGE`
   - `GROWER.FARMS`
   - `GROWER.GROWERS`
   - `GROWER.VARIETY`
   - `GROWER.PLANTATION`
   - `MAST.USERS`

4. **Nomenclatura:** 
   - Schema: `evalImagen` (camelCase)
   - Tablas: PascalCase (ej: `AnalisisImagen`, `LoteEvaluacion`)
   - Índices: `IDX_[Tabla]_[Columna]_[Número]`
   - Constraints: `PK_[Tabla]`, `FK_[Tabla]_[Referencia]_[Número]`

---

## 🔄 Recrear Tablas (Si es Necesario)

Si necesitas eliminar y recrear las tablas:

1. **⚠️ ADVERTENCIA:** Esto eliminará todos los datos
2. Ejecutar scripts de eliminación en orden inverso:
   - Primero eliminar tablas con Foreign Keys
   - Luego eliminar tablas base
3. O usar el script maestro que maneja esto automáticamente

---

## 📚 Scripts Relacionados

Después de crear las tablas, puedes ejecutar:

- **Stored Procedures:** `scripts/03_stored_procedures/`
- **Triggers:** `scripts/05_triggers/`
- **Views:** `scripts/02_views/`
- **Datos de ejemplo:** `scripts/07_utilities/` (opcional)

---

## ✅ Checklist de Ejecución

- [ ] Conectado al servidor correcto
- [ ] Base de datos seleccionada: `[TU_BASE_DE_DATOS]`
- [ ] Usuario con permisos adecuados
- [ ] Script maestro ejecutado o scripts individuales en orden
- [ ] Sin errores en la ejecución
- [ ] Schema `evalImagen` verificado
- [ ] 8 tablas creadas y verificadas
- [ ] Foreign Keys verificadas
- [ ] Índices verificados

---

**Última actualización:** 2025-11-21

