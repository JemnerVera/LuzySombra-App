# Flujo Completo del Sistema de Alertas

## 📋 Resumen del Flujo

### 1. **Procesamiento de Imagen** → `analisisImagen`
- **Ubicación**: `frontend/src/components/ImageUploadForm.tsx` → `backend/src/routes/image-processing.ts`
- **Proceso**:
  1. Usuario sube imagen en "Analizar Imágenes"
  2. Frontend procesa imagen con TensorFlow.js (calcula %Luz y %Sombra)
  3. Frontend extrae EXIF (fecha, GPS)
  4. Backend recibe imagen y datos
  5. Backend llama a `usp_evalImagen_insertAnalisisImagen`
  6. Se inserta registro en `evalImagen.analisisImagen`

### 2. **Cálculo de Evaluación del Lote** → `loteEvaluacion`
- **Stored Procedure**: `evalImagen.usp_evalImagen_calcularLoteEvaluacion`
- **Cuándo se ejecuta**: 
  - Automáticamente después de insertar análisis (línea 223 de `02_sp_insertAnalisisImagen.sql`)
  - Manualmente para recalcular
- **Qué hace**:
  1. Agrupa todos los análisis del lote (últimos 30 días por defecto)
  2. Calcula estadísticas: Min, Max, Promedio de %Luz y %Sombra
  3. Busca umbrales en `evalImagen.umbralLuz` que apliquen al %Luz promedio
  4. Asigna `tipoUmbralActual` (CriticoRojo, CriticoAmarillo, Normal)
  5. Hace MERGE en `evalImagen.loteEvaluacion` (INSERT si no existe, UPDATE si existe)

### 3. **Generación de Alerta** → `alerta`
- **Trigger**: `evalImagen.trg_loteEvaluacionAlerta_AF_IU`
- **Cuándo se ejecuta**: AFTER INSERT o UPDATE en `evalImagen.loteEvaluacion`
- **Condiciones para crear alerta**:
  - ✅ `tipoUmbralActual` debe ser `CriticoRojo` o `CriticoAmarillo`
  - ✅ NO debe existir una alerta `Pendiente` o `Enviada` del mismo tipo para ese lote
  - ✅ `statusID = 1`
- **Qué hace**:
  1. Inserta registro en `evalImagen.alerta` con estado `Pendiente`
  2. Si `tipoUmbralActual` vuelve a `Normal`, resuelve alertas existentes

### 4. **Consolidación de Alertas** → `mensaje`
- **Endpoint**: `POST /api/alertas/consolidar`
- **Servicio**: `alertService.consolidarAlertasPorFundo()`
- **Cuándo se ejecuta**:
  - Manualmente desde frontend (botón "Consolidar Alertas")
  - Automáticamente vía cron job (8:00 AM diario)
- **Qué hace**:
  1. Busca alertas `Pendiente` o `Enviada` sin mensaje asociado (últimas 24 horas)
  2. Agrupa alertas por `fundoID`
  3. Para cada fundo, crea un `mensaje` consolidado con:
     - HTML con tabla de todas las alertas
     - Links seguros por cada lote
     - Min/Max/Prom de %Luz
     - Color del umbral
  4. Inserta en `evalImagen.mensaje` con estado `Pendiente`
  5. Crea relaciones en `evalImagen.mensajeAlerta` (muchos a muchos)

### 5. **Envío de Correos** → Resend API
- **Endpoint**: `POST /api/alertas/enviar`
- **Servicio**: `resendService.processPendingMensajes()`
- **Cuándo se ejecuta**:
  - Manualmente desde frontend (botón "Enviar Mensajes")
  - Automáticamente vía cron job (cada hora)
- **Qué hace**:
  1. Busca mensajes con estado `Pendiente`
  2. Obtiene destinatarios desde `evalImagen.contacto` (match por `fundoID`, `sectorID`, tipo de umbral)
  3. Envía email vía Resend API con:
     - HTML mejorado con tabla Min/Max/Prom
     - Links seguros con tokens JWT (válidos 7 días)
     - Color del umbral
  4. Actualiza `mensaje.estado` a `Enviada`
  5. Actualiza `mensaje.fechaEnvio`
  6. Incrementa `mensaje.intentosEnvio`

## 🔍 Diagnóstico de Problemas

### Problema: No se genera alerta para lotID 1301

**Posibles causas**:

1. **El SP `calcularLoteEvaluacion` no se ejecutó**
   - Verificar que se llamó después del INSERT
   - Verificar logs del backend
   - Ejecutar manualmente: `EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion @LotID = 1301`

2. **No hay evaluación en `loteEvaluacion`**
   - Verificar que existe registro para lotID 1301
   - Verificar que `tipoUmbralActual` no es NULL

3. **El `tipoUmbralActual` no es crítico**
   - Verificar umbrales configurados
   - Verificar que el %Luz promedio cae dentro de un umbral crítico
   - El umbral debe tener `activo = 1` y `statusID = 1`

4. **Ya existe una alerta activa**
   - El trigger NO crea alerta si ya existe una `Pendiente` o `Enviada` del mismo tipo
   - Verificar alertas existentes para lotID 1301

5. **El trigger está deshabilitado**
   - Verificar: `SELECT is_disabled FROM sys.triggers WHERE name = 'trg_loteEvaluacionAlerta_AF_IU'`
   - Habilitar: `ALTER TABLE evalImagen.loteEvaluacion ENABLE TRIGGER trg_loteEvaluacionAlerta_AF_IU`

6. **El período de evaluación no incluye el análisis**
   - Por defecto, el SP usa últimos 30 días
   - Si el análisis es más antiguo, no se incluirá

## 📊 Scripts de Diagnóstico

1. **Diagnóstico general**: `scripts/07_utilities/04_diagnosticar_alertas.sql`
2. **Diagnóstico por lote**: `scripts/07_utilities/05_diagnosticar_lote_1301.sql`

## 🔧 Soluciones Rápidas

### Forzar recálculo de evaluación:
```sql
EXEC evalImagen.usp_evalImagen_calcularLoteEvaluacion 
    @LotID = 1301, 
    @PeriodoDias = 30, 
    @ForzarRecalculo = 1;
```

### Verificar trigger:
```sql
SELECT is_disabled 
FROM sys.triggers 
WHERE name = 'trg_loteEvaluacionAlerta_AF_IU';
```

### Habilitar trigger si está deshabilitado:
```sql
ALTER TABLE evalImagen.loteEvaluacion 
ENABLE TRIGGER trg_loteEvaluacionAlerta_AF_IU;
```

### Crear alerta manualmente (si es necesario):
```sql
-- Solo si realmente no se generó automáticamente
INSERT INTO evalImagen.alerta (
    lotID, loteEvaluacionID, umbralID, porcentajeLuzEvaluado,
    tipoUmbral, severidad, estado, fechaCreacion, statusID
)
SELECT 
    le.lotID,
    le.loteEvaluacionID,
    le.umbralIDActual,
    le.porcentajeLuzPromedio,
    le.tipoUmbralActual,
    CASE WHEN le.tipoUmbralActual = 'CriticoRojo' THEN 'Critica' ELSE 'Advertencia' END,
    'Pendiente',
    GETDATE(),
    1
FROM evalImagen.loteEvaluacion le
WHERE le.lotID = 1301
    AND le.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo')
    AND le.statusID = 1
    AND NOT EXISTS (
        SELECT 1 FROM evalImagen.alerta a
        WHERE a.lotID = le.lotID
            AND a.tipoUmbral = le.tipoUmbralActual
            AND a.estado IN ('Pendiente', 'Enviada')
            AND a.statusID = 1
    );
```

