# Configurar AgriQR para Producción (Azure)

## 📋 Objetivo

Configurar la app AgriQR para que funcione desde el campo agrícola y envíe datos a LuzSombra desplegado en Azure App Service cuando haya conexión WiFi.

---

## 🔧 Cambios Necesarios

### **1. Actualizar URL Base del Backend**

**Archivo:** `AgriQR/app/src/main/java/com/migiva/etiquetafoto/data/remote/api/ApiClient.kt`

**Cambio necesario:**

```kotlin
// Antes (desarrollo local)
private const val BASE_URL = "http://192.168.18.52:3001/api/"

// Después (producción)
private const val BASE_URL = "https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/"
```

**O mejor aún, hacerlo configurable:**

```kotlin
object ApiClient {
    // URL base configurable
    private val BASE_URL = BuildConfig.BASE_URL ?: "https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/"
    
    // ... resto del código
}
```

Y en `build.gradle.kts`:

```kotlin
android {
    buildTypes {
        getByName("release") {
            buildConfigField("String", "BASE_URL", "\"https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/\"")
        }
        getByName("debug") {
            buildConfigField("String", "BASE_URL", "\"http://192.168.18.52:3001/api/\"")
        }
    }
}
```

---

### **2. Mantener Configuración Manual (Recomendado)**

**Ventaja:** Permite cambiar la URL sin recompilar la app.

**Archivo:** `AgriQR/app/src/main/java/com/migiva/etiquetafoto/data/security/DeviceConfigManager.kt`

Ya tienes la funcionalidad de configurar la URL manualmente. Solo necesitas:

1. **Actualizar URL por defecto:**
   ```kotlin
   private const val DEFAULT_BASE_URL = "https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/"
   ```

2. **Asegurar que la app guarda la URL:**
   - La URL se guarda en `EncryptedSharedPreferences`
   - Los usuarios pueden cambiarla desde la configuración inicial

---

### **3. Manejo de Conexión Offline/Online**

**Mejora recomendada:** Guardar fotos localmente cuando no hay WiFi y enviarlas cuando se conecte.

**Archivo:** `AgriQR/app/src/main/java/com/migiva/etiquetafoto/MainActivity.kt`

**Cambios sugeridos:**

```kotlin
// Detectar conexión
private fun isNetworkAvailable(): Boolean {
    val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val network = connectivityManager.activeNetwork ?: return false
    val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
    return capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
           capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
}

// Al capturar foto
private fun handlePhotoCapture(photoFile: File, plantId: String) {
    // Guardar foto permanentemente
    val savedPhoto = fileManager.savePhoto(photoFile, plantId)
    
    if (isNetworkAvailable()) {
        // Intentar subir inmediatamente
        uploadPhoto(savedPhoto, plantId)
    } else {
        // Guardar para subir después
        savePhotoForLaterUpload(savedPhoto, plantId)
        showMessage("Foto guardada. Se subirá cuando haya conexión WiFi.")
    }
}

// Subir fotos pendientes cuando hay conexión
private fun uploadPendingPhotos() {
    if (isNetworkAvailable()) {
        // Obtener fotos pendientes de la base de datos local
        val pendingPhotos = getPendingPhotos()
        for (photo in pendingPhotos) {
            uploadPhoto(photo.file, photo.plantId)
        }
    }
}
```

---

### **4. Configurar HTTPS**

**Importante:** Azure App Service usa HTTPS por defecto, pero asegúrate de:

1. **Verificar certificado SSL:**
   - Azure proporciona certificado SSL automáticamente
   - Si usas dominio personalizado, configurar certificado

2. **Configurar OkHttp para HTTPS:**
   ```kotlin
   // En ApiClient.kt
   private val okHttpClient = OkHttpClient.Builder()
       .addInterceptor(AuthInterceptor())
       .connectTimeout(30, TimeUnit.SECONDS)
       .readTimeout(30, TimeUnit.SECONDS)
       .writeTimeout(30, TimeUnit.SECONDS)
       // HTTPS está habilitado por defecto
       .build()
   ```

---

## 📱 Flujo de Trabajo en el Campo

### **Escenario 1: Con WiFi Disponible**

1. Usuario abre AgriQR
2. Escanea QR code de la planta
3. Toma foto
4. **App detecta WiFi disponible**
5. Sube foto inmediatamente a Azure
6. Muestra confirmación: "Foto subida exitosamente"

### **Escenario 2: Sin WiFi (Offline)**

1. Usuario abre AgriQR
2. Escanea QR code de la planta
3. Toma foto
4. **App detecta que NO hay WiFi**
5. Guarda foto localmente
6. Muestra mensaje: "Foto guardada. Se subirá cuando haya WiFi"
7. Cuando hay WiFi, sube automáticamente

---

## 🔒 Seguridad

### **1. JWT Authentication**

Ya está implementado:
- Login con `deviceId` y `apiKey`
- Token JWT se guarda en `EncryptedSharedPreferences`
- Token se envía en cada request

### **2. HTTPS**

- Azure App Service usa HTTPS automáticamente
- Certificado SSL válido
- Conexión encriptada

### **3. Validación de Certificados**

OkHttp valida certificados SSL por defecto. No necesitas configuración adicional.

---

## 🧪 Testing

### **1. Testing Local (Desarrollo)**

```kotlin
// En build.gradle.kts
buildTypes {
    getByName("debug") {
        buildConfigField("String", "BASE_URL", "\"http://192.168.18.52:3001/api/\"")
    }
}
```

### **2. Testing en Producción**

1. **Configurar URL de Azure en la app:**
   - Abrir configuración inicial
   - Ingresar: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/`

2. **Probar funcionalidades:**
   - Login
   - Escanear QR
   - Tomar foto
   - Subir foto
   - Verificar en SQL Server que se guardó

### **3. Testing Offline**

1. **Desactivar WiFi:**
   - Tomar foto
   - Verificar que se guarda localmente
   - Verificar mensaje: "Se subirá cuando haya WiFi"

2. **Activar WiFi:**
   - Verificar que sube automáticamente
   - Verificar confirmación

---

## 📋 Checklist de Deploy

### **Antes de Publicar APK:**

- [ ] URL base actualizada a Azure (o configurable)
- [ ] HTTPS configurado correctamente
- [ ] Manejo de offline implementado (opcional pero recomendado)
- [ ] Testing en producción realizado
- [ ] Certificado SSL válido en Azure

### **Después de Publicar APK:**

- [ ] Probar en dispositivo real
- [ ] Verificar que puede conectarse a Azure
- [ ] Verificar que las fotos se suben correctamente
- [ ] Verificar que se guardan en SQL Server
- [ ] Monitorear logs en Azure

---

## 🚨 Troubleshooting

### **Problema: "Failed to connect to Azure"**

**Soluciones:**
1. Verificar que la URL es correcta: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/`
2. Verificar que Azure App Service está corriendo
3. Verificar conexión a Internet/WiFi
4. Verificar que no hay firewall bloqueando

### **Problema: "SSL Certificate Error"**

**Soluciones:**
1. Verificar que Azure tiene certificado SSL válido
2. Verificar fecha/hora del dispositivo (certificados SSL requieren fecha correcta)
3. Verificar que el dominio es correcto

### **Problema: "401 Unauthorized"**

**Soluciones:**
1. Verificar que `deviceId` y `apiKey` son correctos
2. Verificar que el token JWT no expiró
3. Verificar que el backend valida correctamente
4. **NUEVO:** Si la API key fue regenerada después de la migración, usar la nueva API key

### **Problema: "429 Too Many Requests" (NUEVO)**

**Causa:**
- Se excedió el límite de 5 intentos fallidos en 15 minutos

**Soluciones:**
1. Esperar 15 minutos antes de intentar nuevamente
2. Verificar que las credenciales (`deviceId` y `apiKey`) son correctas
3. Si el problema persiste, contactar al administrador para verificar el estado del dispositivo en la BD

---

## 📝 Próximos Pasos

1. **Actualizar código de AgriQR:**
   - Cambiar URL base a Azure
   - Implementar manejo offline (opcional)

2. **Hacer build de APK:**
   - Build de release
   - Firmar APK
   - Probar en dispositivo

3. **Distribuir APK:**
   - Subir a Google Play (si aplica)
   - O distribuir manualmente

4. **Monitorear:**
   - Verificar logs en Azure
   - Verificar que las fotos se suben correctamente
   - Verificar que se guardan en SQL Server

---

**Fecha de creación**: 2024-11-17

