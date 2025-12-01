# ¿Por Qué Necesitamos FRONTEND_URL?

## 🎯 Propósito Principal: **CORS (Cross-Origin Resource Sharing)**

### **¿Qué es CORS?**

CORS es un mecanismo de seguridad del navegador que **bloquea requests** desde un dominio diferente al del servidor.

**Ejemplo del problema:**
```
Frontend:  https://luzsombra-frontend.azurestaticapps.net
Backend:   http://agromigiva-luzysombra.azurewebsites.net

❌ El navegador BLOQUEA las requests porque son dominios diferentes
```

---

## 🔧 Cómo Funciona en Nuestro Código

**Ubicación:** `backend/src/server.ts` (línea 34-37)

```typescript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
```

**¿Qué hace esto?**
- ✅ **Permite** que el frontend (desde `FRONTEND_URL`) haga requests al backend
- ✅ **Bloquea** requests desde otros dominios (seguridad)
- ✅ **Permite** enviar cookies/credenciales (`credentials: true`)

---

## 📊 Escenarios

### **Escenario 1: Desarrollo Local**

```env
FRONTEND_URL=http://localhost:3000
```

**Resultado:**
- Frontend en `http://localhost:3000` ✅ Puede hacer requests
- Cualquier otro dominio ❌ Bloqueado

---

### **Escenario 2: Producción (Frontend en Azure Static Web Apps)**

```env
FRONTEND_URL=https://luzsombra-frontend.azurestaticapps.net
```

**Resultado:**
- Frontend en `https://luzsombra-frontend.azurestaticapps.net` ✅ Puede hacer requests
- Cualquier otro dominio ❌ Bloqueado

---

### **Escenario 3: Sin FRONTEND_URL Configurado**

```env
# FRONTEND_URL no configurado
```

**Resultado:**
- Usa fallback: `http://localhost:3000`
- En producción, el frontend real ❌ **BLOQUEADO**
- Solo funciona en desarrollo local

---

## ⚠️ ¿Qué Pasa Si NO Configuras FRONTEND_URL en Producción?

**Error en el navegador:**
```
Access to fetch at 'http://agromigiva-luzysombra.azurewebsites.net/api/health' 
from origin 'https://luzsombra-frontend.azurestaticapps.net' has been blocked by CORS policy: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

**Síntomas:**
- ❌ Frontend no puede hacer requests al backend
- ❌ Todas las llamadas API fallan
- ❌ La aplicación no funciona

---

## ✅ Solución

**Configurar `FRONTEND_URL` en Azure:**

```env
FRONTEND_URL=https://luzsombra-frontend.azurestaticapps.net
```

**O si el frontend está en otro dominio:**
```env
FRONTEND_URL=https://tu-dominio-personalizado.com
```

---

## 🔒 Seguridad

**¿Por qué es importante?**

Sin CORS configurado correctamente:
- ❌ Cualquier sitio web podría hacer requests a tu backend
- ❌ Posibles ataques CSRF (Cross-Site Request Forgery)
- ❌ Exposición de datos sensibles

Con CORS configurado:
- ✅ Solo el frontend autorizado puede hacer requests
- ✅ Protección contra ataques desde otros dominios
- ✅ Control total sobre quién accede a tu API

---

## 📝 Resumen

| Aspecto | Detalle |
|---------|---------|
| **¿Para qué?** | Configurar CORS para permitir requests del frontend |
| **¿Dónde se usa?** | `backend/src/server.ts` (middleware CORS) |
| **¿Es obligatorio?** | ⚠️ **SÍ en producción** (si no, el frontend no funciona) |
| **Valor por defecto** | `http://localhost:3000` (solo desarrollo) |
| **En producción** | URL completa del frontend (ej: `https://luzsombra-frontend.azurestaticapps.net`) |

---

## 🎯 Conclusión

**`FRONTEND_URL` es necesario porque:**

1. ✅ **CORS:** Permite que el frontend haga requests al backend
2. ✅ **Seguridad:** Bloquea requests desde otros dominios
3. ✅ **Producción:** Sin esto, el frontend NO puede comunicarse con el backend

**⚠️ IMPORTANTE:** Si no configuras `FRONTEND_URL` en producción, **la aplicación no funcionará**.

---

**Última actualización:** 2025-11-19


