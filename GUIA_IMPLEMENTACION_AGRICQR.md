# 📱 Guía de Implementación - Integración AgriQR con Luz&Sombra

## 📋 Resumen Ejecutivo

Este documento contiene toda la información necesaria para integrar la app Android **AgriQR** con el backend **Luz&Sombra**. La integración permite que los dispositivos Android suban fotos que serán procesadas automáticamente para análisis de luz/sombra.

---

## ✅ Estado del Backend (Luz&Sombra)

### **Endpoints Implementados y Listos:**

1. ✅ **POST /api/auth/login** - Autenticación de dispositivos
2. ✅ **POST /api/photos/upload** - Subida de fotos con procesamiento automático
3. ✅ **Middleware JWT** - Validación de tokens
4. ✅ **Tabla SQL Server** - Gestión de dispositivos (`image.Dispositivo`)

### **Funcionalidades del Backend:**

- ✅ Autenticación JWT con validación desde SQL Server
- ✅ Procesamiento automático de imágenes (clasificación luz/sombra)
- ✅ Guardado automático en SQL Server
- ✅ Mapeo automático de `plantId` a información del lote
- ✅ Extracción de metadatos EXIF (GPS, fecha/hora)
- ✅ Generación de thumbnails optimizados

---

## 🔗 Endpoints Disponibles

### **1. Autenticación: POST /api/auth/login**

**URL Base:** `https://tu-backend.com/api/auth/login` (o `http://localhost:3001/api/auth/login` en desarrollo)

**Método:** `POST`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "deviceId": "device-001",
  "apiKey": "agriqr-device-001-secret-key-2024"
}
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 86400,
  "deviceId": "device-001"
}
```

**Respuestas de Error:**

- **400 Bad Request:**
```json
{
  "error": "deviceId and apiKey are required"
}
```

- **401 Unauthorized:**
```json
{
  "error": "Invalid credentials"
}
```

- **403 Forbidden:**
```json
{
  "error": "Device is disabled"
}
```

---

### **2. Subida de Fotos: POST /api/photos/upload**

**URL Base:** `https://tu-backend.com/api/photos/upload`

**Método:** `POST`

**Headers:**
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: multipart/form-data
```

**Body (multipart/form-data):**
- `file`: Archivo de imagen (JPEG, PNG, máximo 10MB)
- `plantId`: ID de la planta (string, requerido, ej: "00805221")
- `timestamp`: Fecha/hora ISO 8601 (opcional, ej: "2024-01-15T10:30:00Z")

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "photoId": "123",
  "processed": true,
  "message": "Foto procesada y guardada en BD",
  "porcentaje_luz": 65.5,
  "porcentaje_sombra": 34.5
}
```

**Respuestas de Error:**

- **400 Bad Request:**
```json
{
  "error": "No file provided",
  "processed": false
}
```

```json
{
  "error": "plantId is required",
  "processed": false
}
```

- **401 Unauthorized:**
```json
{
  "error": "No token provided",
  "processed": false
}
```

- **403 Forbidden:**
```json
{
  "error": "Invalid token",
  "processed": false
}
```

- **404 Not Found:**
```json
{
  "error": "Plant ID 00805221 not found in database",
  "processed": false
}
```

- **500 Internal Server Error:**
```json
{
  "error": "Error processing image",
  "message": "Error details...",
  "processed": false
}
```

---

## 🏗️ Arquitectura de la Integración

```
┌─────────────────────────────────────────────────────────┐
│  App Android (AgriQR)                                   │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  1. Configuración Inicial:                              │
│     - Usuario ingresa deviceId y apiKey                 │
│     - App guarda en EncryptedSharedPreferences         │
│                                                          │
│  2. Login:                                              │
│     POST /api/auth/login                                │
│     { deviceId, apiKey }                                │
│     → Recibe JWT token                                 │
│     → Guarda token encriptado                          │
│                                                          │
│  3. Subida de Fotos:                                    │
│     POST /api/photos/upload                             │
│     Headers: Authorization: Bearer {token}              │
│     Body: file, plantId, timestamp                      │
│     → Recibe confirmación con porcentajes              │
│     → Elimina foto del dispositivo                      │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Backend (Luz&Sombra)                                   │
│  ────────────────────────────────────────────────────── │
│                                                          │
│  1. Valida JWT token                                    │
│  2. Valida plantId en SQL Server                        │
│  3. Procesa imagen (algoritmo luz/sombra)              │
│  4. Guarda en SQL Server (image.Analisis_Imagen)        │
│  5. Retorna resultado con porcentajes                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📱 Implementación en Android (Kotlin)

### **Paso 1: Dependencias**

Agregar en `build.gradle` (app level):

```gradle
dependencies {
    // HTTP Client
    implementation "com.squareup.retrofit2:retrofit:2.9.0"
    implementation "com.squareup.retrofit2:converter-gson:2.9.0"
    implementation "com.squareup.okhttp3:okhttp:4.11.0"
    implementation "com.squareup.okhttp3:logging-interceptor:4.11.0"
    
    // Encriptación para guardar tokens
    implementation "androidx.security:security-crypto:1.1.0-alpha06"
    
    // Para manejar imágenes
    implementation "com.github.bumptech.glide:glide:4.15.1"
}
```

---

### **Paso 2: Modelos de Datos**

```kotlin
// LoginRequest.kt
data class LoginRequest(
    val deviceId: String,
    val apiKey: String
)

// LoginResponse.kt
data class LoginResponse(
    val success: Boolean,
    val token: String,
    val expiresIn: Long,
    val deviceId: String
)

// PhotoUploadRequest.kt
data class PhotoUploadRequest(
    val file: File,
    val plantId: String,
    val timestamp: String? = null
)

// PhotoUploadResponse.kt
data class PhotoUploadResponse(
    val success: Boolean,
    val photoId: String,
    val processed: Boolean,
    val message: String,
    val porcentaje_luz: Double,
    val porcentaje_sombra: Double
)

// ErrorResponse.kt
data class ErrorResponse(
    val error: String,
    val processed: Boolean? = null,
    val message: String? = null
)
```

---

### **Paso 3: Gestión de Configuración y Tokens**

```kotlin
// DeviceConfigManager.kt
import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

class DeviceConfigManager(private val context: Context) {
    
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()
    
    private val encryptedPrefs = EncryptedSharedPreferences.create(
        context,
        "agriqr_encrypted_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    
    companion object {
        private const val KEY_DEVICE_ID = "device_id"
        private const val KEY_API_KEY = "api_key"
        private const val KEY_JWT_TOKEN = "jwt_token"
        private const val KEY_TOKEN_EXPIRY = "token_expiry"
        private const val KEY_IS_CONFIGURED = "is_configured"
    }
    
    /**
     * Guardar credenciales del dispositivo
     */
    fun saveCredentials(deviceId: String, apiKey: String) {
        encryptedPrefs.edit()
            .putString(KEY_DEVICE_ID, deviceId)
            .putString(KEY_API_KEY, apiKey)
            .putBoolean(KEY_IS_CONFIGURED, true)
            .apply()
    }
    
    /**
     * Guardar token JWT después del login
     */
    fun saveToken(token: String, expiresIn: Long) {
        val expiryTime = System.currentTimeMillis() + (expiresIn * 1000)
        encryptedPrefs.edit()
            .putString(KEY_JWT_TOKEN, token)
            .putLong(KEY_TOKEN_EXPIRY, expiryTime)
            .apply()
    }
    
    /**
     * Obtener token JWT
     */
    fun getToken(): String? {
        return encryptedPrefs.getString(KEY_JWT_TOKEN, null)
    }
    
    /**
     * Verificar si el token está expirado
     */
    fun isTokenExpired(): Boolean {
        val expiryTime = encryptedPrefs.getLong(KEY_TOKEN_EXPIRY, 0)
        return System.currentTimeMillis() >= expiryTime
    }
    
    /**
     * Verificar si hay un token válido
     */
    fun hasValidToken(): Boolean {
        val token = getToken()
        return token != null && !isTokenExpired()
    }
    
    /**
     * Obtener deviceId
     */
    fun getDeviceId(): String? {
        return encryptedPrefs.getString(KEY_DEVICE_ID, null)
    }
    
    /**
     * Obtener apiKey
     */
    fun getApiKey(): String? {
        return encryptedPrefs.getString(KEY_API_KEY, null)
    }
    
    /**
     * Verificar si está configurado
     */
    fun isConfigured(): Boolean {
        return encryptedPrefs.getBoolean(KEY_IS_CONFIGURED, false)
    }
    
    /**
     * Limpiar configuración (logout/reset)
     */
    fun clearAll() {
        encryptedPrefs.edit()
            .clear()
            .apply()
    }
}
```

---

### **Paso 4: API Service (Retrofit)**

```kotlin
// ApiService.kt
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.*

interface ApiService {
    
    /**
     * Login del dispositivo
     */
    @POST("auth/login")
    fun login(@Body request: LoginRequest): Call<LoginResponse>
    
    /**
     * Subir foto
     */
    @Multipart
    @POST("photos/upload")
    fun uploadPhoto(
        @Header("Authorization") token: String,
        @Part file: MultipartBody.Part,
        @Part("plantId") plantId: RequestBody,
        @Part("timestamp") timestamp: RequestBody?
    ): Call<PhotoUploadResponse>
}
```

---

### **Paso 5: Interceptor para Agregar Token Automáticamente**

```kotlin
// AuthInterceptor.kt
import okhttp3.Interceptor
import okhttp3.Response

class AuthInterceptor(
    private val configManager: DeviceConfigManager
) : Interceptor {
    
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        // Obtener token válido
        val token = if (configManager.hasValidToken()) {
            configManager.getToken()
        } else {
            null
        }
        
        // Agregar token al header si existe
        val authenticatedRequest = if (token != null) {
            originalRequest.newBuilder()
                .header("Authorization", "Bearer $token")
                .build()
        } else {
            originalRequest
        }
        
        val response = chain.proceed(authenticatedRequest)
        
        // Si el token expiró (401), limpiar token
        if (response.code == 401) {
            configManager.clearAll()
        }
        
        return response
    }
}
```

---

### **Paso 6: Configurar Retrofit**

```kotlin
// ApiClient.kt
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object ApiClient {
    
    private const val BASE_URL = "https://tu-backend.com/api/"  // Cambiar en producción
    
    fun createApiService(configManager: DeviceConfigManager): ApiService {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        
        val okHttpClient = OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor(configManager))
            .addInterceptor(loggingInterceptor)
            .build()
        
        val retrofit = Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        
        return retrofit.create(ApiService::class.java)
    }
}
```

---

### **Paso 7: Pantalla de Configuración Inicial**

```kotlin
// SetupActivity.kt
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class SetupActivity : AppCompatActivity() {
    
    private lateinit var configManager: DeviceConfigManager
    private lateinit var apiService: ApiService
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_setup)
        
        configManager = DeviceConfigManager(this)
        apiService = ApiClient.createApiService(configManager)
        
        val etDeviceId = findViewById<EditText>(R.id.etDeviceId)
        val etApiKey = findViewById<EditText>(R.id.etApiKey)
        val btnSave = findViewById<Button>(R.id.btnSave)
        
        btnSave.setOnClickListener {
            val deviceId = etDeviceId.text.toString().trim()
            val apiKey = etApiKey.text.toString().trim()
            
            if (deviceId.isEmpty() || apiKey.isEmpty()) {
                Toast.makeText(this, "Por favor completa todos los campos", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            // Guardar credenciales
            configManager.saveCredentials(deviceId, apiKey)
            
            // Intentar login para verificar
            performLogin(deviceId, apiKey)
        }
    }
    
    private fun performLogin(deviceId: String, apiKey: String) {
        val loginRequest = LoginRequest(deviceId, apiKey)
        
        apiService.login(loginRequest).enqueue(object : Callback<LoginResponse> {
            override fun onResponse(call: Call<LoginResponse>, response: Response<LoginResponse>) {
                if (response.isSuccessful) {
                    val loginResponse = response.body()!!
                    
                    // Guardar token
                    configManager.saveToken(loginResponse.token, loginResponse.expiresIn)
                    
                    // Ir a pantalla principal
                    startActivity(Intent(this@SetupActivity, MainActivity::class.java))
                    finish()
                } else {
                    // Credenciales inválidas
                    Toast.makeText(
                        this@SetupActivity,
                        "Credenciales inválidas. Verifica deviceId y apiKey",
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
            
            override fun onFailure(call: Call<LoginResponse>, t: Throwable) {
                Toast.makeText(
                    this@SetupActivity,
                    "Error de conexión: ${t.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
        })
    }
}
```

---

### **Paso 8: Subida de Fotos**

```kotlin
// PhotoUploadService.kt
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class PhotoUploadService(
    private val apiService: ApiService,
    private val configManager: DeviceConfigManager
) {
    
    /**
     * Subir foto al servidor
     */
    fun uploadPhoto(
        photoFile: File,
        plantId: String,
        timestamp: Date? = null,
        onSuccess: (PhotoUploadResponse) -> Unit,
        onError: (String) -> Unit
    ) {
        // Verificar que hay token válido
        if (!configManager.hasValidToken()) {
            onError("No hay token válido. Por favor inicia sesión.")
            return
        }
        
        // Preparar archivo
        val requestFile = photoFile.asRequestBody("image/jpeg".toMediaTypeOrNull())
        val filePart = MultipartBody.Part.createFormData("file", photoFile.name, requestFile)
        
        // Preparar plantId
        val plantIdPart = plantId.toRequestBody("text/plain".toMediaTypeOrNull())
        
        // Preparar timestamp (opcional)
        val timestampPart = timestamp?.let {
            val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            isoFormat.timeZone = TimeZone.getTimeZone("UTC")
            isoFormat.format(it).toRequestBody("text/plain".toMediaTypeOrNull())
        }
        
        // Subir foto
        apiService.uploadPhoto(
            token = "Bearer ${configManager.getToken()}", // El interceptor también lo agrega
            file = filePart,
            plantId = plantIdPart,
            timestamp = timestampPart
        ).enqueue(object : Callback<PhotoUploadResponse> {
            override fun onResponse(
                call: Call<PhotoUploadResponse>,
                response: Response<PhotoUploadResponse>
            ) {
                if (response.isSuccessful) {
                    val uploadResponse = response.body()!!
                    onSuccess(uploadResponse)
                } else {
                    // Manejar errores
                    val errorBody = response.errorBody()?.string()
                    val errorMessage = when (response.code()) {
                        400 -> "Datos inválidos: $errorBody"
                        401 -> "Token expirado. Por favor inicia sesión de nuevo."
                        404 -> "Plant ID no encontrado en la base de datos."
                        500 -> "Error del servidor: $errorBody"
                        else -> "Error desconocido: ${response.code()}"
                    }
                    onError(errorMessage)
                }
            }
            
            override fun onFailure(call: Call<PhotoUploadResponse>, t: Throwable) {
                onError("Error de conexión: ${t.message}")
            }
        })
    }
}
```

---

### **Paso 9: Uso en la App**

```kotlin
// MainActivity.kt (ejemplo de uso)
class MainActivity : AppCompatActivity() {
    
    private lateinit var configManager: DeviceConfigManager
    private lateinit var photoUploadService: PhotoUploadService
    private lateinit var apiService: ApiService
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        configManager = DeviceConfigManager(this)
        apiService = ApiClient.createApiService(configManager)
        photoUploadService = PhotoUploadService(apiService, configManager)
        
        // Verificar si está configurado
        if (!configManager.isConfigured()) {
            startActivity(Intent(this, SetupActivity::class.java))
            finish()
            return
        }
        
        // Verificar si hay token válido, si no, hacer login
        if (!configManager.hasValidToken()) {
            performAutoLogin()
        }
        
        setContentView(R.layout.activity_main)
        // ... resto del código
    }
    
    private fun performAutoLogin() {
        val deviceId = configManager.getDeviceId() ?: return
        val apiKey = configManager.getApiKey() ?: return
        
        apiService.login(LoginRequest(deviceId, apiKey)).enqueue(object : Callback<LoginResponse> {
            override fun onResponse(call: Call<LoginResponse>, response: Response<LoginResponse>) {
                if (response.isSuccessful) {
                    val loginResponse = response.body()!!
                    configManager.saveToken(loginResponse.token, loginResponse.expiresIn)
                }
            }
            
            override fun onFailure(call: Call<LoginResponse>, t: Throwable) {
                // Manejar error
            }
        })
    }
    
    /**
     * Ejemplo: Subir foto después de tomarla
     */
    private fun onPhotoTaken(photoFile: File, plantId: String) {
        photoUploadService.uploadPhoto(
            photoFile = photoFile,
            plantId = plantId,
            timestamp = Date(), // Fecha actual
            onSuccess = { response ->
                // Foto subida exitosamente
                runOnUiThread {
                    Toast.makeText(
                        this,
                        "Foto procesada: ${response.porcentaje_luz}% luz, ${response.porcentaje_sombra}% sombra",
                        Toast.LENGTH_LONG
                    ).show()
                    
                    // Eliminar foto del dispositivo
                    photoFile.delete()
                }
            },
            onError = { error ->
                // Error al subir
                runOnUiThread {
                    Toast.makeText(this, "Error: $error", Toast.LENGTH_LONG).show()
                }
            }
        )
    }
}
```

---

## 🧪 Testing

### **1. Probar Login con cURL**

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "device-001",
    "apiKey": "agriqr-device-001-secret-key-2024"
  }'
```

### **2. Probar Subida de Foto con cURL**

```bash
# Primero obtener token
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Subir foto
curl -X POST http://localhost:3001/api/photos/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test-photo.jpg" \
  -F "plantId=00805221" \
  -F "timestamp=2024-01-15T10:30:00Z"
```

---

## 📋 Checklist de Implementación

### **Backend (Luz&Sombra) - ✅ COMPLETADO**

- [x] Endpoint `/api/auth/login` implementado
- [x] Endpoint `/api/photos/upload` implementado
- [x] Middleware JWT implementado
- [x] Tabla `image.Dispositivo` creada
- [x] Validación de dispositivos desde SQL Server
- [x] Procesamiento de imágenes implementado
- [x] Guardado en SQL Server implementado

### **Android (AgriQR) - ⏳ PENDIENTE**

- [ ] Agregar dependencias (Retrofit, EncryptedSharedPreferences)
- [ ] Crear modelos de datos (LoginRequest, LoginResponse, etc.)
- [ ] Implementar `DeviceConfigManager`
- [ ] Crear `ApiService` (Retrofit)
- [ ] Implementar `AuthInterceptor`
- [ ] Crear `SetupActivity` (configuración inicial)
- [ ] Implementar `PhotoUploadService`
- [ ] Integrar subida de fotos en la app
- [ ] Manejar errores y casos edge
- [ ] Testing con backend real

---

## 🔧 Configuración Necesaria

### **1. URL del Backend**

Configurar la URL base del backend en `ApiClient.kt`:

```kotlin
// Desarrollo
private const val BASE_URL = "http://TU_IP_LOCAL:3001/api/"

// Producción
private const val BASE_URL = "https://tu-backend-azure.com/api/"
```

### **2. Dispositivos en SQL Server**

Antes de usar la app, cada dispositivo debe estar registrado en SQL Server:

```sql
INSERT INTO image.Dispositivo (deviceId, apiKey, nombreDispositivo, activo)
VALUES ('device-001', 'agriqr-device-001-secret-key-2024', 'Tablet Campo 1', 1);
```

### **3. Configuración en la App**

El usuario debe ingresar:
- **Device ID**: `device-001` (debe coincidir con SQL Server)
- **API Key**: `agriqr-device-001-secret-key-2024` (debe coincidir con SQL Server)

---

## ⚠️ Notas Importantes

1. **Token Expiración**: Los tokens JWT expiran después de 24 horas. La app debe manejar la renovación automática.

2. **PlantId**: El `plantId` debe existir en la base de datos. Si no existe, el backend retornará 404.

3. **Tamaño de Imagen**: Máximo 10MB por foto.

4. **Formato de Imagen**: JPEG o PNG recomendados.

5. **Timestamp**: Si no se proporciona, el backend intentará extraerlo de los metadatos EXIF.

6. **Seguridad**: Las apiKeys y tokens se guardan encriptados usando `EncryptedSharedPreferences`.

---

## 📞 Soporte

Para dudas o problemas:
- Revisar documentación en `docs/` del proyecto Luz&Sombra
- Verificar logs del backend
- Probar endpoints con Postman/cURL primero

---

## 🚀 Próximos Pasos

1. **Implementar en Android** siguiendo esta guía
2. **Configurar dispositivos** en SQL Server
3. **Probar integración** con backend de desarrollo
4. **Desplegar a producción** cuando esté listo

---

**Última actualización:** 2024-01-15  
**Versión del Backend:** 1.0.0  
**Estado:** ✅ Backend listo, Android pendiente de implementación

