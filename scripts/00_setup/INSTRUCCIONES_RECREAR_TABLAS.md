# 📋 Instrucciones: Recrear Tablas del Schema evalImagen

## ✅ Los scripts están actualizados

Los scripts en `01_tables` ya incluyen todas las modificaciones necesarias:
- ✅ `originalImageUrl` ya está en `01_evalImagen.AnalisisImagen.sql`
- ✅ `fundoID` ya está en `03_evalImagen.LoteEvaluacion.sql`
- ✅ `fundoID` y `alertaID NULL` ya están en `05_evalImagen.Mensaje.sql`

**NO necesitas ejecutar los scripts de `04_modifications`.**

---

## 📝 Orden de Ejecución

### 1️⃣ TABLAS (obligatorio)

Ejecutar en este orden exacto:

```sql
1. scripts/01_tables/01_evalImagen.AnalisisImagen.sql      (crea schema evalImagen)
2. scripts/01_tables/02_evalImagen.UmbralLuz.sql             
3. scripts/01_tables/03_evalImagen.LoteEvaluacion.sql       
4. scripts/01_tables/04_evalImagen.Alerta.sql               
5. scripts/01_tables/05_evalImagen.Mensaje.sql              
6. scripts/01_tables/06_evalImagen.Contacto.sql             
7. scripts/01_tables/07_evalImagen.Dispositivo.sql          
8. scripts/01_tables/08_evalImagen.MensajeAlerta.sql        (nueva - tabla de relación)
```

**Nota:** Todos los scripts tienen `IF NOT EXISTS`, así que son seguros de ejecutar múltiples veces.

---

### 2️⃣ STORED PROCEDURES (obligatorio)

```sql
scripts/03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql
```

---

### 3️⃣ TRIGGERS (obligatorio)

```sql
scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql
```

---

### 4️⃣ VERIFICACIÓN (recomendado)

```sql
scripts/00_setup/01_verificar_sistema_alertas.sql
```

---

## ⚠️ Scripts que NO necesitas ejecutar

- ❌ `04_modifications/01_add_originalImageUrl_column.sql` (ya está en la tabla)
- ❌ `04_modifications/03_add_fundoID_to_LoteEvaluacion.sql` (ya está en la tabla)
- ❌ `02_alter_tables/01_modificar_Mensaje_consolidacion.sql` (ya está en la tabla)
- ❌ `04_modifications/02_insert_contactos_ejemplo.sql` (solo datos de prueba)
- ❌ `04_modifications/04_insert_dispositivos_ejemplo.sql` (solo datos de prueba)

---

## 🔧 Usuario SQL

- **DESA:** `ucser_luzsombra_desa`
- **PROD:** `ucser_luzSombra`
- **Base de datos:** `***REMOVED***`
- **Servidor:** `***REMOVED***`
- **Schema:** `evalImagen`

---

## ✅ Resumen rápido

**Solo necesitas ejecutar:**
1. Los 8 scripts de `01_tables` (en orden)
2. El stored procedure de `03_stored_procedures`
3. El trigger de `05_triggers`
4. La verificación de `00_setup`

**Total: 11 scripts** (8 tablas + 1 SP + 1 trigger + 1 verificación)

---

## 📋 Cambios Importantes

- **Schema:** `image` → `evalImagen`
- **Tabla:** `Analisis_Imagen` → `AnalisisImagen` (sin guión bajo)
- **Nueva tabla:** `MensajeAlerta` (tabla de relación para mensajes consolidados)
- **Usuario:** `ucser_luzsombra_desa` (DESA) / `ucser_luzSombra` (PROD)

