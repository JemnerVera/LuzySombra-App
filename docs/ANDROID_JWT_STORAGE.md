# 📱 Cómo Guardar JWT en Android (AgriQR)

## 🔐 Opción Recomendada: EncryptedSharedPreferences

### 1. Agregar Dependencia

En `build.gradle` (app level):

```gradle
dependencies {
    implementation "androidx.security:security-crypto:1.1.0-alpha06"
}
```

### 2. Clase Helper para Manejar JWT

```kotlin
import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

class AuthTokenManager(private val context: Context) {
    
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()
    
    private val encryptedPrefs = EncryptedSharedPreferences.create(
        context,
        "encrypted_auth_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    
    companion object {
        private const val KEY_JWT_TOKEN = "jwt_token"
        private const val KEY_DEVICE_ID = "device_id"
        private const val KEY_TOKEN_EXPIRY = "token_expiry"
    }
    
    /**
     * Guardar token JWT después del login
     */
    fun saveToken(token: String, deviceId: String, expiresIn: Long) {
        encryptedPrefs.edit()
            .putString(KEY_JWT_TOKEN, token)
            .putString(KEY_DEVICE_ID, deviceId)
            .putLong(KEY_TOKEN_EXPIRY, System.currentTimeMillis() + (expiresIn * 1000))
            .apply()
    }
    
    /**
     * Obtener token JWT guardado
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
     * Eliminar token (logout)
     */
    fun clearToken() {
        encryptedPrefs.edit()
            .remove(KEY_JWT_TOKEN)
            .remove(KEY_DEVICE_ID)
            .remove(KEY_TOKEN_EXPIRY)
            .apply()
    }
    
    /**
     * Obtener deviceId guardado
     */
    fun getDeviceId(): String? {
        return encryptedPrefs.getString(KEY_DEVICE_ID, null)
    }
}
```

### 3. Uso en el Login

```kotlin
class LoginActivity : AppCompatActivity() {
    
    private lateinit var authTokenManager: AuthTokenManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        authTokenManager = AuthTokenManager(this)
        
        // Si ya hay un token válido, ir directamente a la pantalla principal
        if (authTokenManager.hasValidToken()) {
            navigateToMainScreen()
            return
        }
    }
    
    private fun performLogin(deviceId: String, apiKey: String) {
        // Llamar al endpoint de login
        val loginRequest = LoginRequest(deviceId, apiKey)
        
        apiService.login(loginRequest).enqueue(object : Callback<LoginResponse> {
            override fun onResponse(call: Call<LoginResponse>, response: Response<LoginResponse>) {
                if (response.isSuccessful) {
                    val loginResponse = response.body()
                    
                    // Guardar token encriptado
                    authTokenManager.saveToken(
                        token = loginResponse!!.token,
                        deviceId = loginResponse.deviceId,
                        expiresIn = loginResponse.expiresIn
                    )
                    
                    // Navegar a pantalla principal
                    navigateToMainScreen()
                } else {
                    // Mostrar error
                    showError("Credenciales inválidas")
                }
            }
            
            override fun onFailure(call: Call<LoginResponse>, t: Throwable) {
                showError("Error de conexión")
            }
        })
    }
}
```

### 4. Interceptor para Agregar Token a Requests

```kotlin
class AuthInterceptor(private val authTokenManager: AuthTokenManager) : Interceptor {
    
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        // Obtener token
        val token = authTokenManager.getToken()
        
        // Si hay token y no está expirado, agregarlo al header
        if (token != null && !authTokenManager.isTokenExpired()) {
            val authenticatedRequest = originalRequest.newBuilder()
                .header("Authorization", "Bearer $token")
                .build()
            
            return chain.proceed(authenticatedRequest)
        } else {
            // Token expirado o no existe, hacer request sin token
            // El backend retornará 401 y la app deberá hacer login de nuevo
            return chain.proceed(originalRequest)
        }
    }
}
```

### 5. Configurar Retrofit con Interceptor

```kotlin
val authTokenManager = AuthTokenManager(context)

val okHttpClient = OkHttpClient.Builder()
    .addInterceptor(AuthInterceptor(authTokenManager))
    .addInterceptor(HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    })
    .build()

val retrofit = Retrofit.Builder()
    .baseUrl("https://tu-backend.com/api/")
    .client(okHttpClient)
    .addConverterFactory(GsonConverterFactory.create())
    .build()

val apiService = retrofit.create(ApiService::class.java)
```

### 6. Manejar Token Expirado

```kotlin
class TokenExpiredInterceptor(
    private val authTokenManager: AuthTokenManager,
    private val context: Context
) : Interceptor {
    
    override fun intercept(chain: Interceptor.Chain): Response {
        val response = chain.proceed(chain.request())
        
        // Si el backend retorna 401 (Unauthorized), el token expiró
        if (response.code == 401) {
            // Limpiar token
            authTokenManager.clearToken()
            
            // Navegar a pantalla de login
            val intent = Intent(context, LoginActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            context.startActivity(intent)
        }
        
        return response
    }
}
```

## 📋 Resumen del Flujo

1. **Login**: App envía `deviceId` + `apiKey` → Backend retorna JWT token
2. **Guardar**: App guarda token encriptado en `EncryptedSharedPreferences`
3. **Usar**: Interceptor agrega automáticamente `Authorization: Bearer {token}` a cada request
4. **Validar**: Si backend retorna 401, token expiró → hacer login de nuevo

## 🔒 Seguridad

- ✅ Token encriptado en almacenamiento
- ✅ Verificación de expiración
- ✅ Manejo automático de token expirado
- ✅ Token agregado automáticamente a requests

## ⚠️ Notas Importantes

1. **API Key**: Debe estar hardcodeada en la app o configurada por administrador
2. **Token Expiry**: El backend expira tokens después de 24 horas
3. **Renovación**: Si el token expira, el usuario debe hacer login de nuevo
4. **Producción**: Usar `EncryptedSharedPreferences` o `Android Keystore` (nunca `SharedPreferences` simple)

