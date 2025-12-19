# ✅ Verificación de Variables de Entorno en Azure

## Variables Configuradas ✅

Todas las variables **críticas** están configuradas correctamente:

### ✅ Variables Críticas (Obligatorias)
- ✅ `SQL_SERVER` - Configurada
- ✅ `SQL_DATABASE` - Configurada
- ✅ `SQL_USER` - Configurada
- ✅ `SQL_PASSWORD` - Configurada
- ✅ `JWT_SECRET` - Configurada
- ✅ `RESEND_API_KEY` - Configurada
- ✅ `RESEND_FROM_EMAIL` - Configurada
- ✅ `FRONTEND_URL` - Configurada
- ✅ `BACKEND_BASE_URL` - Configurada
- ✅ `NODE_ENV` - Configurada
- ✅ `DATA_SOURCE` - Configurada

### ✅ Variables Opcionales (Con valores por defecto)
- ✅ `PORT` - Configurada (default: 3001)
- ✅ `SQL_PORT` - Configurada (default: 1433)
- ✅ `SQL_ENCRYPT` - Configurada (default: true)
- ✅ `JWT_EXPIRES_IN` - Configurada (default: 24h)
- ✅ `BCRYPT_ROUNDS` - Configurada (default: 10)
- ✅ `LOG_LEVEL` - Configurada (default: info)
- ✅ `RESEND_FROM_NAME` - Configurada (default: Sistema de Alertas)

### ✅ Variables de Azure (Automáticas)
- ✅ `APPLICATIONINSIGHTS_CONNECTION_STRING` - Azure Application Insights
- ✅ `ApplicationInsightsAgent_EXTENSION_VERSION` - Azure Application Insights
- ✅ `XDT_MicrosoftApplicationInsights_Mode` - Azure Application Insights

---

## ⚠️ Variable Opcional Faltante (Solo si se necesita)

### `ENABLE_ALERT_SCHEDULER`
- **Tipo**: Opcional
- **Valor por defecto**: `true` (habilitado)
- **Descripción**: Controla si el scheduler automático de alertas está activo
- **Cuándo configurar**: Solo si quieres **deshabilitar** el scheduler automático
- **Valores**: `true` o `false`

**Nota**: Si no se configura, el scheduler estará **habilitado por defecto**, lo cual es lo recomendado para producción.

---

## 📧 Variables Opcionales de Fallback (Solo si se necesita)

Estas variables solo se usan si **NO hay contactos** en la tabla `evalImagen.contacto`:

### `ALERTAS_EMAIL_DESTINATARIOS`
- **Tipo**: Opcional (solo fallback)
- **Formato**: JSON array de strings
- **Ejemplo**: `["admin@example.com", "agronomo@example.com"]`
- **Cuándo usar**: Solo si no hay contactos configurados en la base de datos

### `ALERTAS_EMAIL_CC`
- **Tipo**: Opcional (solo fallback)
- **Formato**: JSON array de strings
- **Ejemplo**: `["manager@example.com"]`
- **Cuándo usar**: Solo si no hay contactos configurados en la base de datos

**Nota**: Si tienes contactos configurados en `evalImagen.contacto`, estas variables **NO son necesarias**.

---

## ✅ Conclusión

**Todas las variables críticas están configuradas correctamente.** ✅

### Recomendaciones:

1. **`ENABLE_ALERT_SCHEDULER`**: 
   - Si quieres que el scheduler esté activo (recomendado), **NO es necesario** configurarlo (default: `true`)
   - Si quieres deshabilitarlo, agregar: `ENABLE_ALERT_SCHEDULER=false`

2. **`ALERTAS_EMAIL_DESTINATARIOS` y `ALERTAS_EMAIL_CC`**:
   - Solo necesarias si **NO** hay contactos en `evalImagen.contacto`
   - Si ya tienes contactos configurados, **NO son necesarias**

3. **Verificar valores**:
   - `FRONTEND_URL` debe ser: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net`
   - `BACKEND_BASE_URL` debe ser: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/`
   - `NODE_ENV` debe ser: `production`

---

## 🚀 Próximos Pasos

1. ✅ Verificar que `FRONTEND_URL` y `BACKEND_BASE_URL` tengan las URLs correctas de producción
2. ✅ Verificar que `NODE_ENV=production`
3. ✅ (Opcional) Configurar `ENABLE_ALERT_SCHEDULER=false` solo si quieres deshabilitar el scheduler
4. ✅ Verificar que el **Startup Command** esté configurado: `node dist/server.js`
5. ✅ Configurar el secret `AZURE_WEBAPP_PUBLISH_PROFILE` en GitHub (si no está ya configurado)

---

**Estado**: ✅ **Listo para deploy**

