# 📱 Configuración de API Keys en Dispositivos Android

## 🎯 Problema

Cada dispositivo Android necesita tener su propia `apiKey` única para autenticarse. Si hay múltiples dispositivos usando la app, necesitamos una forma de configurar cada uno.

---

## 🔄 Estrategias de Configuración

### **Opción 1: Pantalla de Configuración Inicial (RECOMENDADO)**

La app muestra una pantalla de configuración la primera vez que se abre, donde el usuario ingresa su `apiKey`.

#### Ventajas:
- ✅ Una sola versión de la app para todos los dispositivos
- ✅ Fácil de configurar
- ✅ No requiere rebuilds
- ✅ El usuario puede cambiar la apiKey si es necesario

#### Desventajas:
- ⚠️ Requiere que el usuario ingrese la apiKey manualmente
- ⚠️ Posible error de tipeo

#### Implementación:

```kotlin
// 1. Clase para guardar configuración
class DeviceConfigManager(private val context: Context) {
    
    private val encryptedPrefs = EncryptedSharedPreferences.create(
        context,
        "device_config",
        masterKey,
        ...
    )
    
    companion object {
        private const val KEY_API_KEY = "api_key"
        private const val KEY_DEVICE_ID = "device_id"
        private const val KEY_IS_CONFIGURED = "is_configured"
    }
    
    /**
     * Guardar apiKey y deviceId
     */
    fun saveCredentials(deviceId: String, apiKey: String) {
        encryptedPrefs.edit()
            .putString(KEY_DEVICE_ID, deviceId)
            .putString(KEY_API_KEY, apiKey)
            .putBoolean(KEY_IS_CONFIGURED, true)
            .apply()
    }
    
    /**
     * Obtener apiKey guardada
     */
    fun getApiKey(): String? {
        return encryptedPrefs.getString(KEY_API_KEY, null)
    }
    
    /**
     * Obtener deviceId guardado
     */
    fun getDeviceId(): String? {
        return encryptedPrefs.getString(KEY_DEVICE_ID, null)
    }
    
    /**
     * Verificar si ya está configurado
     */
    fun isConfigured(): Boolean {
        return encryptedPrefs.getBoolean(KEY_IS_CONFIGURED, false)
    }
    
    /**
     * Limpiar configuración (para reset)
     */
    fun clearConfiguration() {
        encryptedPrefs.edit()
            .remove(KEY_API_KEY)
            .remove(KEY_DEVICE_ID)
            .remove(KEY_IS_CONFIGURED)
            .apply()
    }
}
```

```kotlin
// 2. Activity de Configuración
class SetupActivity : AppCompatActivity() {
    
    private lateinit var configManager: DeviceConfigManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configManager = DeviceConfigManager(this)
        
        setContentView(R.layout.activity_setup)
        
        val btnSave = findViewById<Button>(R.id.btnSave)
        val etDeviceId = findViewById<EditText>(R.id.etDeviceId)
        val etApiKey = findViewById<EditText>(R.id.etApiKey)
        
        btnSave.setOnClickListener {
            val deviceId = etDeviceId.text.toString().trim()
            val apiKey = etApiKey.text.toString().trim()
            
            if (deviceId.isEmpty() || apiKey.isEmpty()) {
                Toast.makeText(this, "Por favor completa todos los campos", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
            // Guardar configuración
            configManager.saveCredentials(deviceId, apiKey)
            
            // Probar login
            testLogin(deviceId, apiKey)
        }
    }
    
    private fun testLogin(deviceId: String, apiKey: String) {
        // Intentar hacer login para verificar que las credenciales son correctas
        apiService.login(LoginRequest(deviceId, apiKey)).enqueue(object : Callback<LoginResponse> {
            override fun onResponse(call: Call<LoginResponse>, response: Response<LoginResponse>) {
                if (response.isSuccessful) {
                    // Credenciales válidas, ir a pantalla principal
                    startActivity(Intent(this@SetupActivity, MainActivity::class.java))
                    finish()
                } else {
                    // Credenciales inválidas
                    Toast.makeText(this@SetupActivity, "Credenciales inválidas", Toast.LENGTH_LONG).show()
                }
            }
            
            override fun onFailure(call: Call<LoginResponse>, t: Throwable) {
                Toast.makeText(this@SetupActivity, "Error de conexión", Toast.LENGTH_LONG).show()
            }
        })
    }
}
```

```kotlin
// 3. MainActivity - Verificar si está configurado
class MainActivity : AppCompatActivity() {
    
    private lateinit var configManager: DeviceConfigManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configManager = DeviceConfigManager(this)
        
        // Si no está configurado, ir a pantalla de setup
        if (!configManager.isConfigured()) {
            startActivity(Intent(this, SetupActivity::class.java))
            finish()
            return
        }
        
        // Si está configurado, continuar normalmente
        setContentView(R.layout.activity_main)
        // ... resto del código
    }
}
```

---

### **Opción 2: Escanear QR Code**

El administrador genera un QR code con `deviceId` y `apiKey`, y el usuario lo escanea.

#### Ventajas:
- ✅ Muy fácil para el usuario (solo escanear)
- ✅ No hay errores de tipeo
- ✅ Una sola versión de la app

#### Desventajas:
- ⚠️ Requiere implementar escáner QR
- ⚠️ El administrador debe generar QR codes

#### Implementación:

```kotlin
// 1. Generar QR Code (en backend o herramienta administrativa)
// Formato JSON: {"deviceId": "device-001", "apiKey": "agriqr-device-001-secret-key-2024"}

// 2. Escanear QR en Android
class QRScannerActivity : AppCompatActivity() {
    
    private lateinit var qrCodeScanner: BarcodeScanner
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Usar biblioteca como ZXing o ML Kit
        qrCodeScanner = BarcodeScanner.Builder(this)
            .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
            .build()
        
        // Escanear QR
        qrCodeScanner.scan().addOnSuccessListener { barcode ->
            val qrContent = barcode.rawValue
            
            try {
                val json = JSONObject(qrContent)
                val deviceId = json.getString("deviceId")
                val apiKey = json.getString("apiKey")
                
                // Guardar configuración
                configManager.saveCredentials(deviceId, apiKey)
                
                // Ir a pantalla principal
                startActivity(Intent(this, MainActivity::class.java))
                finish()
            } catch (e: Exception) {
                Toast.makeText(this, "QR Code inválido", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
```

#### Generar QR Code (Backend o Script):

```typescript
// Generar QR Code para un dispositivo
import QRCode from 'qrcode';

async function generateQRCode(deviceId: string, apiKey: string) {
  const data = JSON.stringify({ deviceId, apiKey });
  const qrCode = await QRCode.toDataURL(data);
  return qrCode; // Retornar como imagen base64
}
```

---

### **Opción 3: Auto-Registro con DeviceId Único**

El dispositivo genera su propio `deviceId` único (basado en Android ID) y se auto-registra en el backend.

#### Ventajas:
- ✅ No requiere configuración manual
- ✅ Experiencia de usuario fluida
- ✅ DeviceId único garantizado

#### Desventajas:
- ⚠️ Requiere endpoint de auto-registro en backend
- ⚠️ El administrador debe aprobar dispositivos

#### Implementación:

```kotlin
// 1. Obtener DeviceId único del dispositivo
class DeviceIdManager(private val context: Context) {
    
    fun getDeviceId(): String {
        // Usar Android ID (único por dispositivo)
        val androidId = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        )
        
        // Prefijo para identificar dispositivos AgriQR
        return "agriqr-$androidId"
    }
}
```

```kotlin
// 2. Auto-registro en backend
class AutoRegisterActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val deviceId = DeviceIdManager(this).getDeviceId()
        
        // Intentar auto-registro
        apiService.autoRegister(AutoRegisterRequest(deviceId)).enqueue(object : Callback<AutoRegisterResponse> {
            override fun onResponse(call: Call<AutoRegisterResponse>, response: Response<AutoRegisterResponse>) {
                if (response.isSuccessful) {
                    val responseBody = response.body()
                    
                    // Backend retorna apiKey generada
                    configManager.saveCredentials(deviceId, responseBody!!.apiKey)
                    
                    // Ir a pantalla principal
                    startActivity(Intent(this@AutoRegisterActivity, MainActivity::class.java))
                    finish()
                } else {
                    // Auto-registro falló (dispositivo no aprobado)
                    // Mostrar mensaje o ir a pantalla de configuración manual
                    showRegistrationFailed()
                }
            }
            
            override fun onFailure(call: Call<AutoRegisterResponse>, t: Throwable) {
                showConnectionError()
            }
        })
    }
}
```

```typescript
// Backend: Endpoint de auto-registro
router.post('/auto-register', async (req: Request, res: Response) => {
  const { deviceId } = req.body;
  
  // Verificar si el dispositivo ya existe
  const existing = await query(`
    SELECT * FROM image.Dispositivo 
    WHERE deviceId = @deviceId
  `, { deviceId });
  
  if (existing.length > 0) {
    // Dispositivo ya registrado, retornar apiKey existente
    return res.json({
      success: true,
      apiKey: existing[0].apiKey,
      deviceId: existing[0].deviceId
    });
  }
  
  // Generar nueva apiKey
  const apiKey = generateSecureApiKey();
  
  // Insertar en BD (pendiente de aprobación)
  await query(`
    INSERT INTO image.Dispositivo (deviceId, apiKey, activo)
    VALUES (@deviceId, @apiKey, 0)  -- activo = 0 (pendiente aprobación)
  `, { deviceId, apiKey });
  
  res.json({
    success: true,
    apiKey,
    deviceId,
    pendingApproval: true  // Requiere aprobación del administrador
  });
});
```

---

### **Opción 4: Archivo de Configuración**

El administrador crea un archivo JSON con las credenciales y lo copia al dispositivo.

#### Ventajas:
- ✅ Fácil para administradores
- ✅ Puede incluir múltiples configuraciones

#### Desventajas:
- ⚠️ Requiere acceso físico al dispositivo
- ⚠️ Menos seguro

#### Implementación:

```kotlin
// Leer archivo de configuración desde almacenamiento externo
class ConfigFileManager(private val context: Context) {
    
    fun loadConfigFromFile(): Pair<String, String>? {
        val file = File(context.getExternalFilesDir(null), "agriqr_config.json")
        
        if (!file.exists()) {
            return null
        }
        
        val json = JSONObject(file.readText())
        val deviceId = json.getString("deviceId")
        val apiKey = json.getString("apiKey")
        
        return Pair(deviceId, apiKey)
    }
}
```

---

## 🎯 Recomendación: Opción 1 + Opción 2 (Híbrida)

**Combinar pantalla de configuración manual + escáner QR:**

```kotlin
class SetupActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_setup)
        
        // Botón para escanear QR
        findViewById<Button>(R.id.btnScanQR).setOnClickListener {
            startActivity(Intent(this, QRScannerActivity::class.java))
        }
        
        // Botón para ingresar manualmente
        findViewById<Button>(R.id.btnManual).setOnClickListener {
            // Mostrar campos de texto
            showManualInput()
        }
    }
}
```

---

## 📋 Flujo Completo Recomendado

```
1. Usuario abre la app por primera vez
   ↓
2. App verifica si está configurada
   ↓
3. Si NO está configurada:
   → Mostrar pantalla de setup
   → Opción A: Escanear QR Code
   → Opción B: Ingresar manualmente
   ↓
4. Guardar deviceId y apiKey en EncryptedSharedPreferences
   ↓
5. Intentar login para verificar credenciales
   ↓
6. Si login exitoso → Ir a pantalla principal
   Si login falla → Mostrar error, permitir reintentar
```

---

## 🔒 Seguridad

### ✅ Buenas Prácticas:

1. **Encriptar apiKey en almacenamiento**:
   ```kotlin
   // Usar EncryptedSharedPreferences (ya implementado)
   encryptedPrefs.putString("api_key", apiKey)
   ```

2. **No hardcodear apiKeys**:
   ```kotlin
   // ❌ MAL
   const val API_KEY = "hardcoded-key"
   
   // ✅ BIEN
   val apiKey = configManager.getApiKey()
   ```

3. **Validar credenciales antes de guardar**:
   ```kotlin
   // Intentar login antes de guardar
   if (loginSuccessful) {
       configManager.saveCredentials(deviceId, apiKey)
   }
   ```

4. **Permitir reset de configuración**:
   ```kotlin
   // En configuración avanzada
   btnReset.setOnClickListener {
       configManager.clearConfiguration()
       startActivity(Intent(this, SetupActivity::class.java))
   }
   ```

---

## 📝 Resumen

| Opción | Facilidad Usuario | Facilidad Admin | Seguridad | Recomendado |
|--------|------------------|-----------------|-----------|-------------|
| **Pantalla Configuración** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ Sí |
| **QR Code** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ Sí |
| **Auto-Registro** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⚠️ Depende |
| **Archivo Config** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ❌ No |

**Recomendación Final**: **Pantalla de Configuración + QR Code** (híbrida)

---

## 🚀 Implementación Rápida

Para empezar rápido, usa la **Opción 1 (Pantalla de Configuración)**:

1. Crear `DeviceConfigManager` (guardar en EncryptedSharedPreferences)
2. Crear `SetupActivity` (pantalla de configuración)
3. Verificar en `MainActivity` si está configurado
4. Si no está configurado → mostrar SetupActivity
5. Si está configurado → usar apiKey guardada para login

¿Quieres que implemente alguna de estas opciones en detalle?

