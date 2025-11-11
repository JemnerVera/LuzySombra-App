# 🔐 Cómo Funciona el JWT en Android - Explicación Completa

## ❓ Pregunta Frecuente

**"¿Se debe insertar el JWT manualmente en el dispositivo? ¿Cómo funciona si cambia cada 24 horas?"**

**Respuesta:** ❌ **NO se inserta manualmente**. El JWT se obtiene automáticamente del backend y se renueva cuando expira.

---

## 🔄 Flujo Completo del JWT

### **Diferencia Clave: apiKey vs JWT**

| Aspecto | **apiKey** | **JWT Token** |
|---------|------------|---------------|
| **¿Se inserta manualmente?** | ✅ Sí (una sola vez) | ❌ No (se obtiene automáticamente) |
| **¿Dónde se guarda?** | EncryptedSharedPreferences | EncryptedSharedPreferences |
| **¿Cuándo se usa?** | Solo en el login | En cada request protegido |
| **¿Expira?** | ❌ No (permanente) | ✅ Sí (24 horas) |
| **¿Quién lo genera?** | Administrador/Backend | Backend (después de login) |

---

## 📱 Flujo Completo en la App Android

### **Paso 1: Configuración Inicial (UNA SOLA VEZ)**

```
Usuario abre la app por primera vez
  ↓
App muestra pantalla de configuración
  ↓
Usuario ingresa:
  - Device ID: "device-001"
  - API Key: "agriqr-device-001-secret-key-2024"
  ↓
App guarda en EncryptedSharedPreferences:
  ✅ deviceId: "device-001" (permanente)
  ✅ apiKey: "agriqr-device-001-secret-key-2024" (permanente)
```

**Código:**
```kotlin
// SetupActivity.kt
configManager.saveCredentials(deviceId, apiKey)
// Esto se hace UNA SOLA VEZ, nunca más
```

---

### **Paso 2: Login Automático (Cada vez que se abre la app)**

```
App se abre
  ↓
App verifica: ¿Hay token JWT válido?
  ↓
SI hay token válido:
  → Usar app normalmente
  ↓
SI NO hay token (o expiró):
  → Hacer login automático
  ↓
POST /api/auth/login
{
  "deviceId": "device-001",  ← Lee de EncryptedSharedPreferences
  "apiKey": "agriqr-device-001..."  ← Lee de EncryptedSharedPreferences
}
  ↓
Backend valida credenciales
  ↓
Backend GENERA nuevo JWT token
  ↓
Backend retorna:
{
  "token": "eyJhbGciOiJIUzI1NiIs...",  ← NUEVO token (válido 24h)
  "expiresIn": 86400
}
  ↓
App guarda token en EncryptedSharedPreferences:
  ✅ jwt_token: "eyJhbGciOiJIUzI1NiIs..." (temporal, 24h)
  ✅ token_expiry: 1705366400000 (timestamp de expiración)
```

**Código:**
```kotlin
// MainActivity.kt - Al abrir la app
override fun onCreate(savedInstanceState: Bundle?) {
    // Verificar si hay token válido
    if (!configManager.hasValidToken()) {
        // Token expirado o no existe, hacer login automático
        performAutoLogin()
    }
}

private fun performAutoLogin() {
    val deviceId = configManager.getDeviceId()  // Lee de storage
    val apiKey = configManager.getApiKey()      // Lee de storage
    
    apiService.login(LoginRequest(deviceId, apiKey)).enqueue(...)
}
```

---

### **Paso 3: Usar el Token (Automático en cada request)**

```
Usuario toma foto y quiere subirla
  ↓
App llama: POST /api/photos/upload
  ↓
Interceptor automáticamente:
  1. Lee token de EncryptedSharedPreferences
  2. Verifica si está expirado
  3. Si es válido → Agrega header: Authorization: Bearer {token}
  4. Si expiró → Hace login automático primero
  ↓
Request se envía con token
  ↓
Backend valida token
  ↓
Si válido → Procesa foto
Si inválido → Retorna 401
```

**Código:**
```kotlin
// AuthInterceptor.kt - Se ejecuta AUTOMÁTICAMENTE
override fun intercept(chain: Interceptor.Chain): Response {
    val token = configManager.getToken()
    
    if (token != null && !configManager.isTokenExpired()) {
        // Token válido, agregarlo al header
        val request = chain.request().newBuilder()
            .header("Authorization", "Bearer $token")
            .build()
        return chain.proceed(request)
    } else {
        // Token expirado, hacer login primero
        refreshToken()
        // ... luego reintentar request
    }
}
```

---

### **Paso 4: Renovación Automática (Cuando expira)**

```
Token expiró (después de 24 horas)
  ↓
App intenta hacer request
  ↓
Interceptor detecta: token expirado
  ↓
App hace login automático:
  POST /api/auth/login
  {
    "deviceId": "device-001",  ← Lee de storage (permanente)
    "apiKey": "agriqr-device-001..."  ← Lee de storage (permanente)
  }
  ↓
Backend genera NUEVO token
  ↓
App guarda NUEVO token
  ↓
App reintenta el request original con nuevo token
```

**Código:**
```kotlin
// TokenExpiredInterceptor.kt
override fun intercept(chain: Interceptor.Chain): Response {
    val response = chain.proceed(chain.request())
    
    if (response.code == 401) {
        // Token expirado, renovar automáticamente
        val deviceId = configManager.getDeviceId()
        val apiKey = configManager.getApiKey()
        
        // Hacer login para obtener nuevo token
        val loginResponse = apiService.login(LoginRequest(deviceId, apiKey)).execute()
        
        if (loginResponse.isSuccessful) {
            // Guardar nuevo token
            configManager.saveToken(
                loginResponse.body()!!.token,
                loginResponse.body()!!.expiresIn
            )
            
            // Reintentar request original con nuevo token
            val newRequest = chain.request().newBuilder()
                .header("Authorization", "Bearer ${configManager.getToken()}")
                .build()
            return chain.proceed(newRequest)
        }
    }
    
    return response
}
```

---

## 📊 Diagrama de Flujo Completo

```
┌─────────────────────────────────────────────────────────┐
│  CONFIGURACIÓN INICIAL (UNA SOLA VEZ)                   │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  Usuario ingresa:                                       │
│  - deviceId: "device-001"                               │
│  - apiKey: "agriqr-device-001-secret-key-2024"         │
│                                                          │
│  App guarda en EncryptedSharedPreferences:              │
│  ✅ deviceId (permanente)                               │
│  ✅ apiKey (permanente)                                 │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  LOGIN AUTOMÁTICO (Cada vez que se abre la app)         │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  App lee de storage:                                    │
│  - deviceId: "device-001"                               │
│  - apiKey: "agriqr-device-001-secret-key-2024"         │
│                                                          │
│  POST /api/auth/login                                   │
│  { deviceId, apiKey }                                   │
│                                                          │
│  Backend genera JWT token                               │
│                                                          │
│  App guarda en EncryptedSharedPreferences:              │
│  ✅ jwt_token: "eyJhbGciOiJIUzI1NiIs..." (24h)          │
│  ✅ token_expiry: 1705366400000                         │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  USO DEL TOKEN (Automático en cada request)             │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  Usuario sube foto                                      │
│  ↓                                                       │
│  Interceptor lee token de storage                       │
│  ↓                                                       │
│  Verifica: ¿Token válido?                               │
│  ↓                                                       │
│  SI válido:                                             │
│    → Agrega: Authorization: Bearer {token}             │
│    → Envía request                                      │
│                                                          │
│  SI expirado:                                           │
│    → Hace login automático                              │
│    → Obtiene nuevo token                                │
│    → Reintenta request                                  │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Ciclo de Vida del Token

```
┌─────────────────────────────────────────────────────────┐
│  DÍA 1 - 10:00 AM                                       │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  Usuario abre app                                       │
│  → Login automático                                     │
│  → Obtiene token (expira: DÍA 2 - 10:00 AM)           │
│  → Guarda token                                         │
│  → Usa app normalmente                                  │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  DÍA 1 - 2:00 PM                                       │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  Usuario sube foto                                      │
│  → Interceptor lee token                                │
│  → Token aún válido (faltan 20 horas)                  │
│  → Usa token existente                                 │
│  → Foto subida exitosamente                            │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  DÍA 2 - 10:01 AM (Token expiró)                       │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  Usuario intenta subir foto                             │
│  → Interceptor detecta: token expirado                  │
│  → Hace login automático                                │
│  → Obtiene NUEVO token (expira: DÍA 3 - 10:01 AM)     │
│  → Guarda nuevo token                                  │
│  → Reintenta subir foto con nuevo token                │
│  → Foto subida exitosamente                            │
└─────────────────────────────────────────────────────────┘
```

---

## 💾 ¿Qué se Guarda en el Dispositivo?

### **Almacenamiento Permanente (No cambia):**

```kotlin
EncryptedSharedPreferences {
    "device_id": "device-001",                    // ✅ Permanente
    "api_key": "agriqr-device-001-secret-key-2024", // ✅ Permanente
    "is_configured": true                         // ✅ Permanente
}
```

### **Almacenamiento Temporal (Cambia cada 24h):**

```kotlin
EncryptedSharedPreferences {
    "jwt_token": "eyJhbGciOiJIUzI1NiIs...",      // ⏰ Temporal (24h)
    "token_expiry": 1705366400000                 // ⏰ Temporal (24h)
}
```

---

## 🔧 Implementación Completa

### **1. Clase para Gestionar Tokens**

```kotlin
class DeviceConfigManager(private val context: Context) {
    
    // Guardar credenciales (UNA SOLA VEZ)
    fun saveCredentials(deviceId: String, apiKey: String) {
        encryptedPrefs.edit()
            .putString("device_id", deviceId)      // Permanente
            .putString("api_key", apiKey)          // Permanente
            .putBoolean("is_configured", true)
            .apply()
    }
    
    // Guardar token JWT (después de cada login)
    fun saveToken(token: String, expiresIn: Long) {
        val expiryTime = System.currentTimeMillis() + (expiresIn * 1000)
        encryptedPrefs.edit()
            .putString("jwt_token", token)         // Temporal (24h)
            .putLong("token_expiry", expiryTime)   // Temporal (24h)
            .apply()
    }
    
    // Verificar si token está expirado
    fun isTokenExpired(): Boolean {
        val expiryTime = encryptedPrefs.getLong("token_expiry", 0)
        return System.currentTimeMillis() >= expiryTime
    }
    
    // Obtener token (si es válido)
    fun getToken(): String? {
        return if (isTokenExpired()) {
            null  // Token expirado
        } else {
            encryptedPrefs.getString("jwt_token", null)
        }
    }
}
```

### **2. Login Automático al Abrir App**

```kotlin
class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val configManager = DeviceConfigManager(this)
        
        // Si no hay token válido, hacer login automático
        if (!configManager.hasValidToken()) {
            performAutoLogin(configManager)
        }
    }
    
    private fun performAutoLogin(configManager: DeviceConfigManager) {
        val deviceId = configManager.getDeviceId()  // Lee permanente
        val apiKey = configManager.getApiKey()      // Lee permanente
        
        apiService.login(LoginRequest(deviceId, apiKey)).enqueue(
            object : Callback<LoginResponse> {
                override fun onResponse(
                    call: Call<LoginResponse>,
                    response: Response<LoginResponse>
                ) {
                    if (response.isSuccessful) {
                        val loginResponse = response.body()!!
                        
                        // Guardar NUEVO token (temporal, 24h)
                        configManager.saveToken(
                            loginResponse.token,
                            loginResponse.expiresIn
                        )
                    }
                }
                
                override fun onFailure(call: Call<LoginResponse>, t: Throwable) {
                    // Manejar error
                }
            }
        )
    }
}
```

### **3. Interceptor con Renovación Automática**

```kotlin
class AuthInterceptor(
    private val configManager: DeviceConfigManager,
    private val apiService: ApiService
) : Interceptor {
    
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        // Obtener token
        var token = configManager.getToken()
        
        // Si no hay token o expiró, renovar
        if (token == null || configManager.isTokenExpired()) {
            token = refreshToken()
        }
        
        // Agregar token al header
        val authenticatedRequest = if (token != null) {
            originalRequest.newBuilder()
                .header("Authorization", "Bearer $token")
                .build()
        } else {
            originalRequest
        }
        
        var response = chain.proceed(authenticatedRequest)
        
        // Si token expiró (401), renovar y reintentar
        if (response.code == 401) {
            val newToken = refreshToken()
            if (newToken != null) {
                val retryRequest = originalRequest.newBuilder()
                    .header("Authorization", "Bearer $newToken")
                    .build()
                response = chain.proceed(retryRequest)
            }
        }
        
        return response
    }
    
    private fun refreshToken(): String? {
        val deviceId = configManager.getDeviceId() ?: return null
        val apiKey = configManager.getApiKey() ?: return null
        
        try {
            val loginResponse = apiService.login(
                LoginRequest(deviceId, apiKey)
            ).execute()
            
            if (loginResponse.isSuccessful) {
                val token = loginResponse.body()!!.token
                configManager.saveToken(token, loginResponse.body()!!.expiresIn)
                return token
            }
        } catch (e: Exception) {
            // Manejar error
        }
        
        return null
    }
}
```

---

## ✅ Resumen

### **¿Se inserta el JWT manualmente?**
❌ **NO**. El JWT se obtiene automáticamente del backend después del login.

### **¿Qué se inserta manualmente?**
✅ Solo el **deviceId** y **apiKey** (una sola vez en la configuración inicial).

### **¿Cómo funciona si cambia cada 24 horas?**
✅ La app **renueva automáticamente** el token cuando expira:
1. Detecta que el token expiró
2. Hace login automático usando `deviceId` y `apiKey` (permanentes)
3. Obtiene nuevo token del backend
4. Guarda nuevo token
5. Continúa usando la app normalmente

### **¿El usuario nota algo?**
✅ **NO**. Todo es automático y transparente para el usuario.

---

## 🎯 Flujo Simplificado

```
1. Configuración inicial (UNA VEZ):
   Usuario → Ingresa deviceId + apiKey → App guarda (permanente)

2. Cada vez que se abre la app:
   App → Lee deviceId + apiKey → Login automático → Obtiene JWT → Guarda (24h)

3. Cada request:
   App → Lee JWT → Si válido: usa | Si expiró: renueva automáticamente → usa

4. Cada 24 horas:
   JWT expira → App detecta → Login automático → Nuevo JWT → Continúa
```

**El usuario NO necesita hacer nada después de la configuración inicial.**

