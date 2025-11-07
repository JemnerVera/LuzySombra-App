# Guía de Pruebas - Sistema de Alertas

## 🎯 Objetivo

Verificar que todo el flujo funciona correctamente:
1. Procesamiento de imagen → Guarda en `image.Analisis_Imagen`
2. SP actualiza `image.LoteEvaluacion`
3. Trigger crea alerta en `image.Alerta` (si cambió umbral)
4. Tabla consolidada muestra datos correctamente

---

## 📋 Checklist Pre-Pruebas

Antes de probar, verifica:

- [ ] ✅ Tablas creadas (`image.Analisis_Imagen`, `image.LoteEvaluacion`, `image.Alerta`, etc.)
- [ ] ✅ Vista creada (`dbo.vwc_CianamidaFenologia`)
- [ ] ✅ SP creado (`image.sp_CalcularLoteEvaluacion`)
- [ ] ✅ Trigger creado (`image.trg_LoteEvaluacion_Alerta`)
- [ ] ✅ Umbrales insertados (`image.UmbralLuz` con datos)

---

## 🧪 Prueba 1: Verificar Estado Inicial

### **Ejecutar en SQL Server:**

```sql
-- Verificar que el trigger existe
SELECT * FROM sys.triggers 
WHERE name = 'trg_LoteEvaluacion_Alerta';

-- Ver estado actual de alertas
SELECT COUNT(*) AS TotalAlertas,
       SUM(CASE WHEN estado = 'Pendiente' THEN 1 ELSE 0 END) AS Pendientes
FROM image.Alerta
WHERE statusID = 1;

-- Ver lotes con evaluaciones
SELECT TOP 5
    lotID,
    tipoUmbralActual,
    porcentajeLuzPromedio,
    totalEvaluaciones
FROM image.LoteEvaluacion
WHERE statusID = 1
ORDER BY fechaUltimaEvaluacion DESC;
```

**✅ Resultado esperado:**
- Trigger existe
- Puede haber alertas previas o ninguna
- Hay lotes con evaluaciones

---

## 🧪 Prueba 2: Procesar Imagen desde la App

### **Pasos:**

1. **Abrir la app** en el navegador
2. **Ir a la pestaña "Analizar"**
3. **Seleccionar:**
   - Empresa
   - Fundo
   - Sector
   - Lote
   - Hilera y Planta (opcional)
4. **Subir una imagen**
5. **Click en "Procesar Imagen"**
6. **Esperar a que termine el procesamiento**

### **Verificar en consola del navegador:**

Deberías ver logs como:
```
📊 Actualizando estadísticas de lote para lotID XXX...
✅ Estadísticas de lote actualizadas en XXXms
```

---

## 🧪 Prueba 3: Verificar que se Actualizó LoteEvaluacion

### **Ejecutar en SQL Server (después de procesar imagen):**

```sql
-- Ver el lote que acabas de procesar
DECLARE @LotID INT = [ID_DEL_LOTE_QUE_PROCESASTE]; -- Cambiar

SELECT 
    le.lotID,
    l.name AS lote,
    le.tipoUmbralActual,
    le.porcentajeLuzPromedio,
    le.porcentajeLuzMin,
    le.porcentajeLuzMax,
    le.totalEvaluaciones,
    le.fechaUltimaEvaluacion,
    le.fechaUltimaActualizacion
FROM image.LoteEvaluacion le
INNER JOIN GROWER.LOT l ON le.lotID = l.lotID
WHERE le.lotID = @LotID;
```

**✅ Resultado esperado:**
- `totalEvaluaciones` debería aumentar
- `fechaUltimaEvaluacion` debería ser reciente
- `tipoUmbralActual` debería estar calculado (CriticoRojo, CriticoAmarillo, o Normal)

---

## 🧪 Prueba 4: Verificar que se Creó Alerta (si aplica)

### **Ejecutar en SQL Server:**

```sql
-- Ver alertas recientes
SELECT TOP 5
    a.alertaID,
    a.lotID,
    l.name AS lote,
    a.tipoUmbral,
    a.severidad,
    a.porcentajeLuzEvaluado,
    a.estado,
    a.fechaCreacion
FROM image.Alerta a
INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
WHERE a.statusID = 1
ORDER BY a.fechaCreacion DESC;

-- Verificar alerta para el lote específico
DECLARE @LotID INT = [ID_DEL_LOTE_QUE_PROCESASTE]; -- Cambiar

SELECT *
FROM image.Alerta
WHERE lotID = @LotID
  AND statusID = 1
ORDER BY fechaCreacion DESC;
```

**✅ Resultado esperado:**

- **Si el umbral cambió a CriticoRojo o CriticoAmarillo:**
  - Debería haber una alerta nueva con `estado = 'Pendiente'`
  - `fechaCreacion` debería ser reciente (justo después de procesar la imagen)

- **Si el umbral es Normal o no cambió:**
  - No debería haber alerta nueva
  - Esto es correcto

---

## 🧪 Prueba 5: Verificar Tabla Consolidada en la App

### **Pasos:**

1. **Ir a la pestaña "Detalle" → "Evaluación por lote"**
2. **Verificar que:**
   - La tabla se carga correctamente
   - Muestra estadísticas de luz/sombra (Min, Prom, Max)
   - Muestra el tipo de umbral actual (si hay)
   - Muestra fecha de última evaluación

**✅ Resultado esperado:**
- Tabla se carga sin errores
- Muestra datos correctos
- Los porcentajes coinciden con lo que procesaste

---

## 🧪 Prueba 6: Simular Cambio de Umbral (Opcional)

Si quieres probar que el trigger funciona cuando cambia el umbral:

### **Opción A: Procesar múltiples imágenes**

1. Procesar varias imágenes del mismo lote
2. Si el promedio cambia y cruza un umbral, debería crear alerta

### **Opción B: Actualizar manualmente (para testing)**

```sql
-- ⚠️ SOLO PARA TESTING - Actualizar manualmente para probar trigger
DECLARE @LotID INT = [ID_DEL_LOTE]; -- Cambiar

-- Ver estado actual
SELECT lotID, tipoUmbralActual, porcentajeLuzPromedio
FROM image.LoteEvaluacion
WHERE lotID = @LotID;

-- Actualizar a CriticoRojo (para probar)
UPDATE image.LoteEvaluacion
SET tipoUmbralActual = 'CriticoRojo',
    umbralIDActual = (SELECT TOP 1 umbralID FROM image.UmbralLuz WHERE tipo = 'CriticoRojo' AND activo = 1),
    porcentajeLuzPromedio = 5.0 -- Muy bajo para ser crítico
WHERE lotID = @LotID;

-- Verificar que se creó alerta
SELECT *
FROM image.Alerta
WHERE lotID = @LotID
  AND statusID = 1
ORDER BY fechaCreacion DESC;
```

---

## 🐛 Troubleshooting

### **Problema: No se crean alertas**

**Verificar:**
1. ¿El trigger existe?
   ```sql
   SELECT * FROM sys.triggers WHERE name = 'trg_LoteEvaluacion_Alerta';
   ```

2. ¿El trigger está habilitado?
   ```sql
   SELECT is_disabled FROM sys.triggers 
   WHERE name = 'trg_LoteEvaluacion_Alerta';
   -- Si is_disabled = 1, habilitarlo:
   -- ALTER TABLE image.LoteEvaluacion ENABLE TRIGGER trg_LoteEvaluacion_Alerta;
   ```

3. ¿El tipoUmbralActual cambió?
   ```sql
   -- Ver historial de cambios (si tienes auditoría)
   SELECT * FROM image.LoteEvaluacion 
   WHERE lotID = [tu_lotID]
   ORDER BY fechaUltimaActualizacion DESC;
   ```

4. ¿Ya existe una alerta pendiente del mismo tipo?
   ```sql
   SELECT * FROM image.Alerta
   WHERE lotID = [tu_lotID]
     AND estado IN ('Pendiente', 'Enviada')
     AND statusID = 1;
   ```

### **Problema: Error al ejecutar SP**

**Verificar:**
1. ¿El SP existe?
   ```sql
   SELECT * FROM sys.procedures 
   WHERE name = 'sp_CalcularLoteEvaluacion';
   ```

2. ¿Las tablas existen?
   ```sql
   SELECT * FROM sys.tables 
   WHERE name IN ('Analisis_Imagen', 'LoteEvaluacion', 'UmbralLuz');
   ```

### **Problema: Tabla consolidada no muestra datos**

**Verificar:**
1. ¿Hay datos en `image.LoteEvaluacion`?
   ```sql
   SELECT COUNT(*) FROM image.LoteEvaluacion WHERE statusID = 1;
   ```

2. ¿Hay errores en la consola del navegador?
   - Abrir DevTools (F12)
   - Ver pestaña "Console"
   - Buscar errores en rojo

---

## ✅ Checklist Final

- [ ] ✅ Trigger existe y está habilitado
- [ ] ✅ Procesar imagen funciona
- [ ] ✅ `image.LoteEvaluacion` se actualiza correctamente
- [ ] ✅ Alerta se crea cuando cambia umbral (si aplica)
- [ ] ✅ Tabla consolidada muestra datos correctamente
- [ ] ✅ No hay errores en consola del navegador
- [ ] ✅ No hay errores en logs del servidor

---

## 📊 Script de Test Completo

Ejecuta el script de test SQL:
```sql
-- scripts/06_tests/02_test_trigger_alerta.sql
```

Este script verifica todo automáticamente y te muestra un resumen.

