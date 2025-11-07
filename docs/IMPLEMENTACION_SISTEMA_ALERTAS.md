# Implementación del Sistema de Alertas - Guía Completa

## ✅ Estado de Implementación

### **Completado:**
1. ✅ Trigger SQL para crear alertas automáticamente
2. ✅ Servicio de alertas (`alertService.ts`)
3. ✅ Servicio de Resend (`resendService.ts`)
4. ✅ API Routes para procesar mensajes
5. ✅ Job para procesar alertas periódicamente

---

## 📋 Archivos Creados

### **SQL:**
- `scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql` - Trigger que crea alertas automáticamente

### **TypeScript:**
- `src/services/alertService.ts` - Servicio para manejar alertas y crear mensajes
- `src/services/resendService.ts` - Servicio para enviar emails via Resend API
- `src/jobs/processAlerts.ts` - Job para procesar alertas periódicamente
- `src/app/api/alertas/procesar-mensajes/route.ts` - API para procesar mensajes
- `src/app/api/alertas/cron/route.ts` - API para ejecutar job de alertas

---

## 🔄 Flujo Completo

```
1. Usuario sube imagen
   ↓
2. App guarda en image.Analisis_Imagen
   ↓
3. App ejecuta: EXEC image.sp_CalcularLoteEvaluacion @LotID = @lotID
   ↓
4. SP actualiza image.LoteEvaluacion
   ↓
5. TRIGGER trg_LoteEvaluacion_Alerta detecta cambio de tipoUmbralActual
   ↓
6. Si cambió a CriticoRojo/CriticoAmarillo → Crea alerta en image.Alerta
   ↓
7. Job/API procesa alertas sin mensaje → Crea mensaje en image.Mensaje
   ↓
8. Job/API procesa mensajes pendientes → Envía email via Resend API
```

---

## 🚀 Configuración

### **1. Variables de Entorno**

Agrega a `.env.local`:

```env
# Resend API
RESEND_API_KEY=re_tu_api_key_aqui
RESEND_FROM_EMAIL=noreply@tudominio.com
RESEND_FROM_NAME=Sistema de Alertas

# Destinatarios (JSON array)
ALERTAS_EMAIL_DESTINATARIOS=["admin@example.com", "agronomo@example.com"]
ALERTAS_EMAIL_CC=["manager@example.com"]

# Opcional: Token para proteger endpoint de cron
CRON_SECRET_TOKEN=tu_secret_token_aqui
```

### **2. Ejecutar Trigger SQL**

```sql
-- Ejecutar después de crear las tablas
EXEC scripts/05_triggers/01_trg_LoteEvaluacion_Alerta.sql
```

---

## 🎯 Uso

### **Opción A: Procesamiento Manual**

```typescript
// Llamar desde cualquier lugar
import { processAlerts } from '@/jobs/processAlerts';
await processAlerts();
```

### **Opción B: API Endpoint**

```bash
# Procesar alertas y mensajes
POST /api/alertas/procesar-mensajes

# Ver estadísticas
GET /api/alertas/procesar-mensajes

# Ejecutar job (para cron externo)
GET /api/alertas/cron?token=YOUR_SECRET_TOKEN
```

### **Opción C: Cron Job Automático**

#### **Vercel Cron (Recomendado para Vercel):**

Crea `vercel.json`:

```json
{
  "crons": [{
    "path": "/api/alertas/cron?token=YOUR_SECRET_TOKEN",
    "schedule": "*/5 * * * *"
  }]
}
```

#### **Otras plataformas:**

Usa un servicio de cron externo (cron-job.org, etc.) que llame a:
```
GET https://tu-dominio.com/api/alertas/cron?token=YOUR_SECRET_TOKEN
```

---

## 📊 Ejemplos de Uso

### **1. Procesar Alertas Manualmente**

```typescript
import { alertService } from '@/services/alertService';

// Procesar alertas sin mensaje
const procesadas = await alertService.processAlertasSinMensaje();
console.log(`Procesadas ${procesadas} alertas`);
```

### **2. Enviar Mensajes Manualmente**

```typescript
import { resendService } from '@/services/resendService';

// Procesar mensajes pendientes
const resultado = await resendService.processPendingMensajes();
console.log(`Enviados: ${resultado.exitosos}, Errores: ${resultado.errores}`);
```

### **3. Verificar Estado**

```bash
# Ver estadísticas
curl http://localhost:3000/api/alertas/procesar-mensajes
```

---

## 🔍 Verificación

### **Verificar que el trigger funciona:**

```sql
-- Ver alertas creadas
SELECT * FROM image.Alerta
ORDER BY fechaCreacion DESC;

-- Ver mensajes creados
SELECT * FROM image.Mensaje
ORDER BY fechaCreacion DESC;
```

### **Verificar logs:**

Los servicios generan logs detallados:
- `✅` = Éxito
- `⚠️` = Advertencia
- `❌` = Error

---

## 🐛 Troubleshooting

### **Problema: Alertas no se crean**

**Solución:**
1. Verificar que el trigger existe: `SELECT * FROM sys.triggers WHERE name = 'trg_LoteEvaluacion_Alerta'`
2. Verificar que `image.LoteEvaluacion` se actualiza correctamente
3. Revisar logs del trigger (si está habilitado)

### **Problema: Mensajes no se envían**

**Solución:**
1. Verificar `RESEND_API_KEY` está configurada
2. Verificar que `ALERTAS_EMAIL_DESTINATARIOS` está configurada
3. Verificar logs de `resendService`

### **Problema: Emails no llegan**

**Solución:**
1. Verificar que `RESEND_FROM_EMAIL` está verificado en Resend
2. Verificar que los destinatarios son válidos
3. Revisar `resendResponse` en `image.Mensaje` para ver respuesta de Resend

---

## 📝 Próximos Pasos

1. ✅ Ejecutar trigger SQL en producción
2. ✅ Configurar variables de entorno
3. ✅ Configurar cron job (Vercel o externo)
4. ✅ Probar el flujo completo
5. ⚠️ Crear dashboard de alertas (futuro)
6. ⚠️ Implementar notificaciones push (futuro)

---

## 🔗 Referencias

- [Resend API Docs](https://resend.com/docs)
- [Vercel Cron Jobs](https://vercel.com/docs/cron-jobs)
- Documentación de tablas: `docs/DISEÑO_SISTEMA_ALERTAS.md`

