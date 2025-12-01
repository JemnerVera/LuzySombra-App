# Flujo Completo: Alertas y Mensajes

## 📋 Resumen

Este documento explica cómo funciona el flujo completo desde que se procesa una imagen hasta que se envía un email de alerta.

## 🔄 Flujo Paso a Paso

### 1. **Procesamiento de Imagen** (Automático)
- Usuario sube imagen en la app
- Se procesa con TensorFlow.js
- Se guarda en `evalImagen.Analisis_Imagen`
- Se ejecuta `sp_CalcularLoteEvaluacion` para actualizar estadísticas

### 2. **Creación de Alertas** (Automático - Trigger SQL)
- El trigger `trg_LoteEvaluacion_Alerta` se activa cuando:
  - Se INSERTA un nuevo registro en `evalImagen.LoteEvaluacion` con `tipoUmbralActual = 'CriticoRojo'` o `'CriticoAmarillo'`
  - Se ACTUALIZA un registro y el `tipoUmbralActual` cambia a crítico
- El trigger crea automáticamente un registro en `evalImagen.Alerta` con:
  - `estado = 'Pendiente'`
  - `mensajeID = NULL` (todavía no hay mensaje)

### 3. **Creación de Mensajes** (Manual o Cron)
- **Opción A: Manualmente** - Llamar a la API:
  ```bash
  POST /api/alertas/procesar-mensajes
  ```
- **Opción B: Automáticamente** - Configurar cron job que llame:
  ```bash
  GET /api/alertas/cron?token=YOUR_SECRET_TOKEN
  ```

- El servicio `alertService.processAlertasSinMensaje()`:
  1. Busca alertas con `estado IN ('Pendiente', 'Enviada')` y `mensajeID IS NULL`
  2. Para cada alerta, crea un registro en `evalImagen.Mensaje` con:
     - `alertaID` (FK a la alerta)
     - `asunto` (generado con emoji y datos del lote)
     - `cuerpoHTML` (HTML formateado con información completa)
     - `cuerpoTexto` (versión texto plano)
     - `destinatarios` (JSON array desde `ALERTAS_EMAIL_DESTINATARIOS`)
     - `estado = 'Pendiente'`
  3. Actualiza la alerta con el `mensajeID` creado

### 4. **Envío de Emails** (Manual o Cron)
- El mismo endpoint `/api/alertas/procesar-mensajes` también procesa mensajes pendientes
- El servicio `resendService.processPendingMensajes()`:
  1. Busca mensajes con `estado = 'Pendiente'` y `intentosEnvio < 3`
  2. Para cada mensaje:
     - Actualiza `estado = 'Enviando'` e incrementa `intentosEnvio`
     - Envía email vía Resend API
     - Si es exitoso:
       - Actualiza `estado = 'Enviado'`
       - Guarda `resendMessageID` y `resendResponse`
       - Actualiza `fechaEnvio` en la alerta asociada
     - Si falla:
       - Actualiza `estado = 'Error'`
       - Guarda `errorMessage`
       - Puede reintentar hasta 3 veces

## 📊 Estado de las Tablas

### `evalImagen.Alerta`
- **Columnas NULL inicialmente:**
  - `mensajeID` → Se llena cuando se crea el mensaje
  - `fechaEnvio` → Se llena cuando se envía el email exitosamente
  - `fechaResolucion` → Se llena cuando el umbral vuelve a Normal
  - `usuarioResolvioID` → Se llena manualmente si se resuelve manualmente
  - `notas` → Opcional, para notas adicionales

### `evalImagen.Mensaje`
- Se crea cuando se ejecuta `alertService.processAlertasSinMensaje()`
- **Columnas que se llenan automáticamente:**
  - `alertaID` → FK a la alerta
  - `asunto`, `cuerpoHTML`, `cuerpoTexto` → Generados automáticamente
  - `destinatarios` → Desde variable de entorno `ALERTAS_EMAIL_DESTINATARIOS`
  - `estado` → 'Pendiente' → 'Enviando' → 'Enviado' o 'Error'
  - `resendMessageID` → ID retornado por Resend API
  - `fechaEnvio` → Cuando se envía exitosamente

## 🔧 Configuración Necesaria

### Variables de Entorno
```env
# Resend API
RESEND_API_KEY=re_xxxxxxxxxxxxx
RESEND_FROM_EMAIL=noreply@tudominio.com
RESEND_FROM_NAME=Sistema de Alertas

# Destinatarios (JSON array)
ALERTAS_EMAIL_DESTINATARIOS=["email1@example.com", "email2@example.com"]
ALERTAS_EMAIL_CC=["cc@example.com"]  # Opcional

# Token para proteger cron endpoint (opcional)
CRON_SECRET_TOKEN=tu_token_secreto
```

## 🚀 Cómo Probar

### 1. Verificar que se creó la alerta
```sql
SELECT * FROM evalImagen.Alerta WHERE estado = 'Pendiente' AND mensajeID IS NULL;
```

### 2. Crear mensajes manualmente
```bash
# Desde la terminal o Postman
curl -X POST http://localhost:3000/api/alertas/procesar-mensajes
```

### 3. Verificar mensajes creados
```sql
SELECT * FROM evalImagen.Mensaje WHERE estado = 'Pendiente';
```

### 4. Verificar que se enviaron
```sql
SELECT 
    a.alertaID,
    a.estado AS estadoAlerta,
    m.mensajeID,
    m.estado AS estadoMensaje,
    m.fechaEnvio,
    m.resendMessageID
FROM evalImagen.Alerta a
LEFT JOIN evalImagen.Mensaje m ON a.mensajeID = m.mensajeID
WHERE a.alertaID = 2;  -- ID de tu alerta
```

## 📝 Notas Importantes

1. **Las alertas se crean automáticamente** cuando el trigger detecta un umbral crítico
2. **Los mensajes NO se crean automáticamente** - necesitas ejecutar el procesamiento manualmente o configurar un cron job
3. **Los emails NO se envían automáticamente** - también necesitas ejecutar el procesamiento
4. **El flujo completo requiere 3 pasos:**
   - ✅ Trigger crea alerta (automático)
   - ⚠️ Servicio crea mensaje (manual/cron)
   - ⚠️ Servicio envía email (manual/cron)

## 🔄 Recomendación: Configurar Cron Job

Para automatizar completamente, configura un cron job que ejecute cada 5-15 minutos:

```javascript
// Vercel Cron (vercel.json)
{
  "crons": [{
    "path": "/api/alertas/cron?token=YOUR_SECRET_TOKEN",
    "schedule": "*/10 * * * *"  // Cada 10 minutos
  }]
}
```

O usar un servicio externo como:
- EasyCron
- Cron-job.org
- GitHub Actions (si está en GitHub)

## ❓ Preguntas Frecuentes

**P: ¿Por qué `mensajeID` está NULL en la alerta?**
R: Porque el mensaje se crea cuando ejecutas `/api/alertas/procesar-mensajes`. No se crea automáticamente.

**P: ¿Cómo hago que se procese automáticamente?**
R: Configura un cron job que llame a `/api/alertas/procesar-mensajes` cada X minutos.

**P: ¿Puedo procesar solo una alerta específica?**
R: Actualmente no, pero puedes modificar el código para aceptar un `alertaID` como parámetro.

**P: ¿Qué pasa si Resend API falla?**
R: El mensaje se marca como `estado = 'Error'` y se guarda el `errorMessage`. Puede reintentar hasta 3 veces.

