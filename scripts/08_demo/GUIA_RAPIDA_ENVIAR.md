# 🚀 Guía Rápida: Enviar Alertas con Resend

## ✅ Verificación Previa

Antes de enviar, verifica que:

1. **Tienes alertas pendientes**:
   ```sql
   SELECT COUNT(*) AS alertas_pendientes
   FROM evalImagen.alerta
   WHERE estado = 'Pendiente' AND statusID = 1;
   ```

2. **Tienes contactos configurados**:
   ```sql
   SELECT nombre, email, fundoID, recibirAlertasCriticas, recibirAlertasAdvertencias
   FROM evalImagen.contacto
   WHERE activo = 1 AND statusID = 1;
   ```

3. **RESEND_API_KEY está configurado**:
   - Verifica que existe en `.env.local` (backend)
   - Reinicia el backend después de agregarlo

## 📧 Proceso de Envío (2 Pasos)

### Paso 1: Consolidar Alertas

Agrupa las alertas pendientes en mensajes por fundo:

**Opción A: Script automático (Windows)**
```bash
cd scripts/08_demo
08_enviar_alertas_resend.bat
```

**Opción B: API manual**
```bash
curl -X POST "http://localhost:3001/api/alertas/consolidar?horasAtras=24"
```

**Resultado esperado:**
```json
{
  "success": true,
  "mensajesCreados": 1,
  "horasAtras": 24,
  "alertasSinMensaje": 1,
  "mensaje": "Se consolidaron alertas en 1 mensaje(s)"
}
```

### Paso 2: Enviar Mensajes

Envía los mensajes consolidados vía Resend API:

**Opción A: Script automático (Windows)**
```bash
# Ya incluido en 08_enviar_alertas_resend.bat
```

**Opción B: API manual**
```bash
curl -X POST "http://localhost:3001/api/alertas/enviar"
```

**Resultado esperado:**
```json
{
  "success": true,
  "exitosos": 1,
  "errores": 0,
  "mensaje": "Procesados 1 mensaje(s): 1 exitoso(s), 0 error(es)"
}
```

## 🔍 Verificar Envío

### 1. Verificar en Base de Datos

```sql
-- Ver mensajes enviados
SELECT 
    mensajeID,
    fundoID,
    asunto,
    estado,
    fechaEnvio,
    resendMessageID,
    errorMessage
FROM evalImagen.mensaje
WHERE statusID = 1
ORDER BY fechaCreacion DESC;

-- Ver alertas actualizadas
SELECT 
    a.alertaID,
    a.estado,
    a.fechaEnvio,
    m.mensajeID,
    m.estado AS mensajeEstado
FROM evalImagen.alerta a
LEFT JOIN evalImagen.mensajeAlerta ma ON a.alertaID = ma.alertaID
LEFT JOIN evalImagen.mensaje m ON ma.mensajeID = m.mensajeID
WHERE a.statusID = 1
ORDER BY a.fechaCreacion DESC;
```

### 2. Verificar en Resend Dashboard

- Ve a https://resend.com/emails
- Busca el email enviado usando el `resendMessageID` de la base de datos

### 3. Verificar en el Correo

- Revisa la bandeja de entrada de `jemner.vera@agricolaandrea.com`
- El correo debe tener:
  - Asunto: "⚠️ X Advertencia(s) en Fundo X - Y lote(s) afectado(s)"
  - Contenido HTML con tabla de alertas
  - Información del lote, sector, porcentaje de luz, etc.

## ❌ Solución de Problemas

### Error: "Resend no está configurado"

**Solución:**
1. Agrega `RESEND_API_KEY` a `.env.local` en el directorio `backend/`
2. Reinicia el backend

### Error: "No hay destinatarios"

**Solución:**
1. Verifica que el contacto tenga `activo = 1` y `statusID = 1`
2. Verifica que el contacto tenga `recibirAlertasCriticas = 1` o `recibirAlertasAdvertencias = 1`
3. Verifica que el `fundoID` del contacto coincida con el `fundoID` de las alertas

### Error: "String or binary data would be truncated"

**Solución:**
- Verifica que el `fundoID` del contacto sea válido (CHAR(4) con padding)
- Ejecuta `00_verificar_fundos.sql` para ver fundos disponibles

### Mensaje en estado "Error"

**Solución:**
1. Revisa `errorMessage` en la tabla `evalImagen.mensaje`
2. Verifica que el dominio de `RESEND_FROM_EMAIL` esté verificado en Resend
3. Verifica que la API key tenga permisos de envío

## 📝 Notas

- Los mensajes se consolidan **por fundo** (un mensaje por fundo con todas sus alertas)
- Si no hay destinatarios para un fundo, no se crea mensaje para ese fundo
- Los mensajes se envían secuencialmente (uno por uno)
- Si un mensaje falla, se marca como "Error" y se puede reintentar
- Máximo 3 intentos por mensaje

