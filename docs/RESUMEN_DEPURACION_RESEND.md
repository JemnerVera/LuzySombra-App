# Resumen de Depuración - Eliminación de Resend

## 🗑️ Archivos Eliminados

### Código
- ✅ `src/services/resendService.ts` - Servicio de Resend eliminado
- ✅ `src/jobs/processAlerts.ts` - Job que usaba Resend eliminado
- ✅ `src/app/api/alertas/cron/route.ts` - Endpoint de cron eliminado

### Documentación
- ✅ `docs/CONFIGURAR_RESEND.md` - Guía de Resend eliminada
- ✅ `docs/GUIA_RESEND.md` - Guía de Resend eliminada
- ✅ `docs/COMO_PROBAR_MENSAJES.md` - Guía de pruebas con Resend eliminada

## 📝 Archivos Modificados

### 1. `src/app/api/alertas/procesar-mensajes/route.ts`
- ❌ Removido: Import de `resendService`
- ❌ Removido: Lógica de envío de emails
- ✅ Mantenido: Creación de mensajes en `image.Mensaje`
- ✅ Agregado: Comentarios explicando que el Worker Service se encarga del envío

### 2. `src/services/alertService.ts`
- ✅ Agregado: Método `getMensajesPendientes()` para estadísticas
- ✅ Mantenido: Interfaz `Mensaje` (el Worker Service la usará)
- ✅ Mantenido: Método `createMensajeFromAlerta()` (solo crea mensajes)

### 3. `package.json`
- ❌ Removido: Dependencia `resend`

### 4. `env.example`
- ❌ Removido: Variables `RESEND_API_KEY`, `RESEND_FROM_EMAIL`, `RESEND_FROM_NAME`
- ✅ Mantenido: `ALERTAS_EMAIL_DESTINATARIOS` (fallback si no hay contactos en BD)

## ✅ Estado Actual

### Lo que hace Next.js ahora:
1. ✅ Crea alertas en `image.Alerta` (via trigger SQL)
2. ✅ Crea mensajes en `image.Mensaje` (via API `/api/alertas/procesar-mensajes`)
3. ✅ Obtiene destinatarios desde `image.Contacto` (filtrado por fundoID)
4. ✅ Guarda mensajes con `estado = 'Pendiente'`

### Lo que NO hace Next.js:
- ❌ NO envía emails
- ❌ NO llama a APIs externas de email
- ❌ NO requiere configuración de Resend

### Lo que hará el Worker Service (.NET):
1. ✅ Lee `image.Mensaje` con `estado = 'Pendiente'`
2. ✅ Envía emails (SMTP, Resend, o cualquier servicio)
3. ✅ Actualiza `estado = 'Enviado'` o `'Error'`
4. ✅ Maneja reintentos y errores
5. ✅ Logging independiente

## 📊 Tabla image.Mensaje

La tabla `image.Mensaje` está lista para ser usada por el Worker Service:

- ✅ `estado = 'Pendiente'` → Mensajes listos para enviar
- ✅ `destinatarios` → JSON array de emails
- ✅ `asunto`, `cuerpoHTML`, `cuerpoTexto` → Contenido del email
- ✅ `intentosEnvio` → Para controlar reintentos
- ✅ `resendMessageID` → Para tracking (puede ser ID de cualquier servicio)
- ✅ `errorMessage` → Para registrar errores

## 🚀 Próximos Pasos

1. **Crear Worker Service en .NET** (ver `docs/PLAN_IMPLEMENTACION_WORKER_SERVICE.md`)
2. **Implementar lectura de `image.Mensaje`**
3. **Implementar envío de emails (SMTP recomendado para servidor)**
4. **Instalar como servicio de Windows**
5. **Monitorear y ajustar**

## 📝 Notas

- El endpoint `/api/alertas/procesar-mensajes` sigue siendo útil para crear mensajes
- Puede llamarse manualmente o programarse (cron job)
- El Worker Service se ejecuta independientemente y lee la tabla directamente



