# 📱 Integración AgriQR con Autenticación Web

Este documento explica cómo funciona la integración entre AgriQR (app móvil) y el sistema de autenticación web, asegurando que **NO haya conflictos** entre ambos sistemas.

---

## 🔑 Punto Clave: Dos Sistemas de Autenticación Separados

### ✅ **NO HAY CONFLICTO** - Son sistemas independientes:

| Sistema | Endpoint | Usuarios | Propósito |
|---------|----------|----------|-----------|
| **Dispositivos Móviles** | `/api/auth/login` | AgriQR (Android) | Autenticación de dispositivos con `deviceId` + `apiKey` |
| **Usuarios Web** | `/api/auth/web/login` | Personas (navegador) | Autenticación de usuarios web con `username` + `password` |

---

## 📱 Flujo Actual de AgriQR (NO CAMBIA)

### 1. **Autenticación Inicial (cuando hay WiFi)**

```
AgriQR App
    ↓
POST /api/auth/login
Body: {
  deviceId: "abc123...",
  apiKey: "luzsombra_xyz..."
}
    ↓
Backend valida contra evalImagen.Dispositivo
    ↓
Response: {
  success: true,
  token: "eyJhbGc...",
  expiresIn: 86400
}
    ↓
AgriQR guarda token localmente (SharedPreferences)
```

### 2. **Funcionamiento Offline**

```
Usuario toma fotos en campo (sin WiFi)
    ↓
Fotos se guardan localmente en el dispositivo
    ↓
Metadatos guardados en SQLite local:
  - plantId
  - timestamp
  - GPS (si disponible)
  - Estado: "pendiente_upload"
    ↓
Usuario continúa trabajando normalmente
```

### 3. **Sincronización cuando hay WiFi**

```
AgriQR detecta conexión WiFi
    ↓
Verifica si el token JWT sigue válido
    ↓
Si expiró:
  → Re-autentica con /api/auth/login
  → Obtiene nuevo token
    ↓
Para cada foto pendiente:
  POST /api/photos/upload
  Headers: {
    Authorization: "Bearer <token>"
  }
  Body (multipart/form-data): {
    file: <imagen>,
    plantId: "00805221",
    timestamp: "2025-01-15T10:30:00Z"
  }
    ↓
Backend procesa y guarda en BD
    ↓
AgriQR marca foto como "sincronizada"
```

---

## 🌐 Flujo de Autenticación Web (NUEVO - No afecta AgriQR)

### 1. **Login de Usuario Web**

```
Usuario abre navegador → https://luzsombra-backend.azurewebsites.net
    ↓
Redirige a página de login
    ↓
POST /api/auth/web/login
Body: {
  username: "admin",
  password: "mi_contraseña"
}
    ↓
Backend valida contra evalImagen.UsuarioWeb
    ↓
Response: {
  success: true,
  token: "eyJhbGc...",
  user: { id, username, rol, permisos }
}
    ↓
Frontend guarda token en localStorage
    ↓
Usuario accede a la aplicación web
```

### 2. **Uso de la Aplicación Web**

```
Usuario navega por la app web
    ↓
Cada request incluye:
  Headers: {
    Authorization: "Bearer <token_web>"
  }
    ↓
Backend valida con middleware authenticateWebUser
    ↓
Verifica permisos según rol
    ↓
Retorna datos
```

---

## 🔐 Middleware de Autenticación - Separación Clara

### Backend - `server.ts`

```typescript
// RUTAS PÚBLICAS (sin autenticación)
app.use('/api/health', healthRoutes);
app.use('/api/test-db', testDbRoutes);

// AUTENTICACIÓN DE DISPOSITIVOS MÓVILES (AgriQR)
app.use('/api/auth/login', authRoutes); // ← NO CAMBIA
app.use('/api/photos/upload', authenticateToken, photoUploadRoutes); // ← NO CAMBIA

// AUTENTICACIÓN DE USUARIOS WEB (nuevo)
app.use('/api/auth/web', authWebRoutes); // ← NUEVO

// RUTAS PROTEGIDAS PARA USUARIOS WEB
app.use('/api/umbrales', authenticateWebUser, umbralesRoutes); // ← NUEVO
app.use('/api/contactos', authenticateWebUser, contactosRoutes); // ← NUEVO
app.use('/api/alertas', authenticateWebUser, alertasRoutes); // ← NUEVO

// RUTAS PÚBLICAS PARA USUARIOS WEB (sin autenticación)
app.use('/api/historial', historialRoutes); // Puede ser público o protegido
app.use('/api/estadisticas', estadisticasRoutes); // Puede ser público o protegido
```

### Middleware Separados

```typescript
// backend/src/middleware/auth.ts
// Para dispositivos móviles (AgriQR)
export function authenticateToken(req, res, next) {
  // Verifica token JWT con deviceId
  // Usado por: /api/photos/upload
}

// backend/src/middleware/auth-web.ts
// Para usuarios web
export function authenticateWebUser(req, res, next) {
  // Verifica token JWT con usuarioID
  // Usado por: /api/umbrales, /api/contactos, etc.
}
```

---

## 📊 Tabla de Comparación

| Aspecto | AgriQR (Dispositivos) | Usuarios Web |
|--------|----------------------|--------------|
| **Endpoint Login** | `/api/auth/login` | `/api/auth/web/login` |
| **Credenciales** | `deviceId` + `apiKey` | `username` + `password` |
| **Tabla BD** | `evalImagen.Dispositivo` | `evalImagen.UsuarioWeb` |
| **Token Payload** | `{ deviceId }` | `{ usuarioID, username, rol, permisos }` |
| **Middleware** | `authenticateToken` | `authenticateWebUser` |
| **Rutas Protegidas** | `/api/photos/upload` | `/api/umbrales`, `/api/contactos`, etc. |
| **Funcionamiento** | Offline-first | Requiere conexión |
| **Almacenamiento Token** | SharedPreferences (Android) | localStorage (navegador) |

---

## ✅ Garantías de No Conflicto

### 1. **Endpoints Separados**

- ✅ `/api/auth/login` → Solo para dispositivos (NO cambia)
- ✅ `/api/auth/web/login` → Solo para usuarios web (NUEVO)

### 2. **Middleware Separados**

- ✅ `authenticateToken` → Solo valida tokens de dispositivos
- ✅ `authenticateWebUser` → Solo valida tokens de usuarios web

### 3. **Tablas Separadas**

- ✅ `evalImagen.Dispositivo` → Dispositivos móviles
- ✅ `evalImagen.UsuarioWeb` → Usuarios web

### 4. **Tokens JWT Diferentes**

Los tokens tienen payloads diferentes, por lo que no hay confusión:

```typescript
// Token de dispositivo (AgriQR)
{
  deviceId: "abc123...",
  iat: 1234567890,
  exp: 1234654290
}

// Token de usuario web
{
  usuarioID: 1,
  username: "admin",
  rol: "Admin",
  permisos: ["*"],
  iat: 1234567890,
  exp: 1234654290
}
```

---

## 🔄 Flujo Completo de AgriQR (Sin Cambios)

### Escenario: Usuario toma 10 fotos sin WiFi

```
1. Usuario abre AgriQR
   → App verifica token guardado
   → Si no hay token o expiró:
      → Intenta login con deviceId + apiKey
      → Si no hay WiFi: guarda intento para más tarde
      → Si hay WiFi: obtiene token y lo guarda

2. Usuario toma 10 fotos
   → Cada foto se guarda localmente
   → Estado: "pendiente_upload"
   → Metadatos guardados en SQLite local

3. Usuario termina trabajo
   → Cierra app
   → Fotos siguen guardadas localmente

4. Usuario llega a zona con WiFi
   → Abre AgriQR
   → App detecta WiFi
   → Verifica token (puede estar expirado)
   
5. Si token expiró:
   → POST /api/auth/login (con WiFi disponible)
   → Obtiene nuevo token
   → Guarda token

6. Para cada foto pendiente:
   → POST /api/photos/upload
   → Headers: Authorization: Bearer <token>
   → Si éxito: marca como "sincronizada"
   → Si error 401 (token expirado):
      → Re-autentica
      → Reintenta upload
   → Si error 403 (dispositivo desactivado):
      → Muestra error al usuario
      → No puede subir más fotos

7. Usuario puede seguir trabajando normalmente
```

---

## 🛡️ Seguridad - Ambos Sistemas

### Dispositivos (AgriQR)

- ✅ Token JWT con expiración (24h)
- ✅ Validación de `deviceId` + `apiKey` en BD
- ✅ Verificación de dispositivo activo
- ✅ Actualización de último acceso

### Usuarios Web

- ✅ Token JWT con expiración (24h)
- ✅ Hash bcrypt de contraseñas
- ✅ Bloqueo por intentos fallidos (5 intentos = 15 min)
- ✅ Roles y permisos granulares
- ✅ Refresh automático de tokens

---

## 📝 Cambios Necesarios en Backend

### ✅ **NO se requiere cambiar nada en:**

- `backend/src/routes/auth.ts` → Sigue igual
- `backend/src/middleware/auth.ts` → Sigue igual
- `backend/src/routes/photoUpload.ts` → Sigue igual

### ✅ **Solo se agrega (nuevo):**

- `backend/src/routes/auth-web.ts` → Nuevo
- `backend/src/middleware/auth-web.ts` → Nuevo
- `backend/src/services/userService.ts` → Nuevo
- `scripts/01_tables/08_image.UsuarioWeb.sql` → Nuevo

---

## 🧪 Testing - Verificar que No Hay Conflictos

### Test 1: AgriQR sigue funcionando

```bash
# 1. Login de dispositivo
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "test-device-123",
    "apiKey": "test-api-key"
  }'

# Debe retornar token de dispositivo

# 2. Upload de foto (con token de dispositivo)
curl -X POST http://localhost:3001/api/photos/upload \
  -H "Authorization: Bearer <token_dispositivo>" \
  -F "file=@test.jpg" \
  -F "plantId=00805221"

# Debe funcionar normalmente
```

### Test 2: Usuario web funciona independientemente

```bash
# 1. Login de usuario web
curl -X POST http://localhost:3001/api/auth/web/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'

# Debe retornar token de usuario web

# 2. Acceder a umbrales (con token de usuario web)
curl -X GET http://localhost:3001/api/umbrales \
  -H "Authorization: Bearer <token_usuario_web>"

# Debe funcionar normalmente
```

### Test 3: Tokens no son intercambiables

```bash
# Intentar usar token de dispositivo en ruta web
curl -X GET http://localhost:3001/api/umbrales \
  -H "Authorization: Bearer <token_dispositivo>"

# Debe retornar 401 (token inválido para esta ruta)

# Intentar usar token de usuario web en ruta de dispositivo
curl -X POST http://localhost:3001/api/photos/upload \
  -H "Authorization: Bearer <token_usuario_web>" \
  -F "file=@test.jpg"

# Debe retornar 401 (token inválido para esta ruta)
```

---

## 📱 Consideraciones para AgriQR

### 1. **Manejo de Token Expirado**

AgriQR debe manejar tokens expirados:

```kotlin
// Pseudocódigo Android
fun uploadPhoto(photo: Photo) {
    var token = getStoredToken()
    
    if (token == null || isTokenExpired(token)) {
        token = reAuthenticate() // POST /api/auth/login
        if (token == null) {
            showError("No se pudo autenticar")
            return
        }
    }
    
    val response = uploadWithToken(photo, token)
    
    if (response.code == 401) {
        // Token expirado, re-autenticar
        token = reAuthenticate()
        if (token != null) {
            uploadWithToken(photo, token) // Reintentar
        }
    }
}
```

### 2. **Verificación de Dispositivo Activo**

Si el dispositivo es desactivado desde la UI web:

```kotlin
// Si login retorna 403 (Device is disabled)
if (response.code == 403) {
    showError("Dispositivo desactivado. Contacta al administrador.")
    disableApp() // No permitir más uploads
}
```

### 3. **Sincronización en Background**

AgriQR puede sincronizar en background cuando detecta WiFi:

```kotlin
// Service en background
class PhotoSyncService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (isWifiConnected()) {
            syncPendingPhotos()
        }
        return START_STICKY
    }
}
```

---

## 🎯 Resumen

### ✅ **AgriQR NO se ve afectado porque:**

1. ✅ Usa endpoint diferente (`/api/auth/login` vs `/api/auth/web/login`)
2. ✅ Usa middleware diferente (`authenticateToken` vs `authenticateWebUser`)
3. ✅ Usa tabla diferente (`evalImagen.Dispositivo` vs `evalImagen.UsuarioWeb`)
4. ✅ Tokens JWT tienen payloads diferentes
5. ✅ Rutas protegidas son diferentes

### ✅ **La autenticación web es completamente independiente:**

- Solo afecta a usuarios que acceden desde navegador
- No requiere cambios en AgriQR
- No afecta el flujo offline de AgriQR
- No afecta la sincronización de fotos

### ✅ **Ambos sistemas pueden coexistir sin problemas:**

- Dispositivos móviles → `/api/auth/login` → `authenticateToken`
- Usuarios web → `/api/auth/web/login` → `authenticateWebUser`

---

## 📋 Checklist de Implementación

### Backend
- [x] Crear tabla `evalImagen.UsuarioWeb`
- [ ] Crear servicio `userService.ts`
- [ ] Crear rutas `auth-web.ts`
- [ ] Crear middleware `auth-web.ts`
- [ ] Proteger rutas web con `authenticateWebUser`
- [ ] **NO modificar** `auth.ts` (dispositivos)
- [ ] **NO modificar** `photoUpload.ts` (dispositivos)
- [ ] **NO modificar** `middleware/auth.ts` (dispositivos)

### Frontend
- [ ] Crear `AuthContext.tsx`
- [ ] Crear página `Login.tsx`
- [ ] Crear `ProtectedRoute.tsx`
- [ ] Actualizar `App.tsx` con routing
- [ ] Actualizar interceptor de axios

### Testing
- [ ] Verificar que AgriQR sigue funcionando
- [ ] Verificar que login web funciona
- [ ] Verificar que tokens no son intercambiables
- [ ] Verificar que rutas están protegidas correctamente

---

## 🚨 Importante

**NO se requiere ningún cambio en AgriQR.** El sistema de autenticación web es completamente independiente y no afecta el funcionamiento de la app móvil.

Si tienes dudas sobre la implementación o necesitas ayuda con algún aspecto específico, no dudes en preguntar.

