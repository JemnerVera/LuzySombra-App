# Cambios Necesarios en AgriQR - Mejoras de Seguridad

## 📋 Resumen

Después de implementar las mejoras de seguridad en el backend, **AgriQR necesita cambios mínimos**. El flujo de autenticación sigue siendo el mismo, pero se debe manejar el nuevo error de rate limiting.

---

## ✅ Cambios Necesarios

### 1. **Manejo de Error 429 (Rate Limiting)** ⚠️ **OBLIGATORIO**

**Contexto:**
- El backend ahora bloquea después de **5 intentos fallidos en 15 minutos**
- Retorna HTTP `429 Too Many Requests` con mensaje claro

**Cambio en AgriQR:**

**Archivo:** `AgriQR/app/src/main/java/com/migiva/etiquetafoto/data/remote/api/AuthService.kt` (o similar)

**Antes:**
```kotlin
when (response.code()) {
    401 -> throw AuthenticationException("Credenciales inválidas")
    403 -> throw AuthenticationException("Dispositivo deshabilitado")
    else -> throw NetworkException("Error de autenticación")
}
```

**Después:**
```kotlin
when (response.code()) {
    400 -> throw AuthenticationException("deviceId y apiKey son requeridos")
    401 -> throw AuthenticationException("Credenciales inválidas")
    403 -> throw AuthenticationException("Dispositivo deshabilitado")
    429 -> {
        // Nuevo: Rate limiting
        val retryAfter = response.headers()["Retry-After"]?.toLongOrNull() ?: 900L
        throw RateLimitException(
            message = "Demasiados intentos fallidos. Intenta nuevamente en ${retryAfter / 60} minutos.",
            retryAfterSeconds = retryAfter
        )
    }
    500 -> throw NetworkException("Error del servidor")
    else -> throw NetworkException("Error de autenticación")
}
```

**Nueva Excepción:**
```kotlin
// En: AgriQR/app/src/main/java/com/migiva/etiquetafoto/data/remote/exceptions/RateLimitException.kt
class RateLimitException(
    message: String,
    val retryAfterSeconds: Long
) : Exception(message)
```

**Manejo en UI:**
```kotlin
// En el Activity/Fragment que maneja el login
try {
    val token = authService.login(deviceId, apiKey)
    // Login exitoso
} catch (e: RateLimitException) {
    // Mostrar mensaje al usuario
    showErrorDialog(
        title = "Demasiados Intentos",
        message = e.message ?: "Intenta nuevamente en ${e.retryAfterSeconds / 60} minutos.",
        positiveButton = "Entendido"
    )
    // Opcional: Deshabilitar botón de login por X minutos
} catch (e: AuthenticationException) {
    showErrorDialog("Error de Autenticación", e.message ?: "Credenciales inválidas")
}
```

---

### 2. **Regeneración de API Keys** ⚠️ **REQUERIDO DESPUÉS DE MIGRACIÓN**

**Contexto:**
- Después de ejecutar la migración SQL, las API keys existentes se marcan como "necesitan regeneración"
- Las API keys antiguas **NO funcionarán** hasta que se regeneren desde la UI web

**Proceso:**

1. **DBA ejecuta scripts de creación de tablas:**
   ```sql
   -- Ejecutar: scripts/01_tables/07_evalImagen.Dispositivo.sql
   -- La tabla ya incluye apiKeyHash y apiKeyPlain
   ```

2. **Administrador regenera API keys desde la UI web:**
   - Ir a "Gestión de Dispositivos"
   - Para cada dispositivo, hacer clic en "Regenerar API Key"
   - **Copiar la nueva API key** (solo se muestra una vez)

3. **Actualizar AgriQR con la nueva API key:**
   - Opción A: Configurar manualmente en la app (si tiene configuración)
   - Opción B: Reinstalar app con nueva API key hardcodeada (no recomendado)
   - Opción C: Usar sistema de configuración remota (recomendado)

**Recomendación:**
- Implementar un sistema de configuración remota donde el administrador puede actualizar la API key sin reinstalar la app
- O permitir que el usuario ingrese la API key manualmente desde la configuración

---

## ❌ Cambios NO Necesarios

### 1. **API Keys Hasheadas** ✅

**NO requiere cambios en AgriQR:**
- AgriQR sigue enviando la API key en texto plano (eso es normal y seguro)
- El backend ahora compara el texto plano recibido con el hash almacenado
- El flujo de autenticación es **exactamente el mismo**

**Ejemplo (sin cambios):**
```kotlin
// AgriQR envía (igual que antes):
POST /api/auth/login
{
    "deviceId": "abc123...",
    "apiKey": "luzsombra_xyz..."  // ← Texto plano (OK, usa HTTPS)
}

// Backend compara internamente:
bcrypt.compare(apiKeyRecibida, apiKeyHashEnBD)  // ← Backend hace la magia
```

---

### 2. **JWT_SECRET** ✅

**NO afecta a AgriQR:**
- Es solo configuración del backend
- Los tokens JWT siguen funcionando igual
- No hay cambios en el formato del token

---

### 3. **Logging de Intentos** ✅

**NO requiere cambios:**
- Es solo auditoría en el backend
- No afecta el comportamiento de la app

---

## 📱 Flujo de Autenticación (Actualizado)

### **Escenario Normal (Sin Cambios):**

```
1. AgriQR → POST /api/auth/login { deviceId, apiKey }
2. Backend → Valida hash, genera JWT
3. Backend → Retorna { success: true, token, expiresIn }
4. AgriQR → Guarda token, usa en requests siguientes
```

### **Escenario con Rate Limiting (NUEVO):**

```
1. AgriQR → POST /api/auth/login { deviceId, apiKey } (intento 1-5)
2. Backend → Retorna 401 (credenciales inválidas)
3. AgriQR → Muestra error, permite reintentar

4. AgriQR → POST /api/auth/login { deviceId, apiKey } (intento 6)
5. Backend → Retorna 429 (Too Many Requests)
6. AgriQR → Muestra mensaje: "Demasiados intentos. Intenta en 15 minutos."
7. AgriQR → Deshabilita botón de login por 15 minutos (opcional)
```

---

## 🔧 Implementación Recomendada

### **1. Interceptor de Rate Limiting:**

```kotlin
// En: ApiClient.kt o AuthInterceptor.kt
class RateLimitInterceptor : Interceptor {
    private var lastRateLimitTime: Long = 0
    private var rateLimitDuration: Long = 0

    override fun intercept(chain: Interceptor.Chain): Response {
        val response = chain.proceed(chain.request())

        if (response.code == 429) {
            val retryAfter = response.header("Retry-After")?.toLongOrNull() ?: 900L
            lastRateLimitTime = System.currentTimeMillis()
            rateLimitDuration = retryAfter * 1000 // Convertir a millis
        }

        return response
    }

    fun isRateLimited(): Boolean {
        if (lastRateLimitTime == 0L) return false
        val elapsed = System.currentTimeMillis() - lastRateLimitTime
        return elapsed < rateLimitDuration
    }

    fun getRemainingTime(): Long {
        if (lastRateLimitTime == 0L) return 0
        val elapsed = System.currentTimeMillis() - lastRateLimitTime
        return maxOf(0, rateLimitDuration - elapsed) / 1000 // Segundos restantes
    }
}
```

### **2. UI con Contador:**

```kotlin
// En LoginActivity.kt
private fun handleRateLimit(retryAfterSeconds: Long) {
    val minutes = retryAfterSeconds / 60
    val seconds = retryAfterSeconds % 60
    
    binding.loginButton.isEnabled = false
    binding.rateLimitMessage.text = "Demasiados intentos. Intenta en $minutes:${seconds.toString().padStart(2, '0')}"
    binding.rateLimitMessage.visibility = View.VISIBLE
    
    // Contador regresivo
    val handler = Handler(Looper.getMainLooper())
    var remaining = retryAfterSeconds.toInt()
    
    val runnable = object : Runnable {
        override fun run() {
            if (remaining > 0) {
                val mins = remaining / 60
                val secs = remaining % 60
                binding.rateLimitMessage.text = "Intenta en $mins:${secs.toString().padStart(2, '0')}"
                remaining--
                handler.postDelayed(this, 1000)
            } else {
                binding.loginButton.isEnabled = true
                binding.rateLimitMessage.visibility = View.GONE
            }
        }
    }
    handler.post(runnable)
}
```

---

## 🧪 Testing

### **1. Probar Rate Limiting:**

```kotlin
// Test manual:
1. Intentar login 6 veces con credenciales incorrectas
2. Verificar que el 6to intento retorna 429
3. Verificar que se muestra mensaje de error
4. Esperar 15 minutos (o cambiar tiempo en BD para testing)
5. Verificar que vuelve a funcionar
```

### **2. Probar con API Key Regenerada:**

```kotlin
// Test manual:
1. Regenerar API key desde UI web
2. Actualizar API key en AgriQR
3. Intentar login
4. Verificar que funciona correctamente
```

---

## 📋 Checklist de Implementación

### **En AgriQR:**

- [ ] Agregar manejo de error 429 (Rate Limiting)
- [ ] Crear `RateLimitException` personalizada
- [ ] Actualizar UI para mostrar mensaje de rate limiting
- [ ] (Opcional) Implementar contador regresivo
- [ ] (Opcional) Deshabilitar botón de login durante rate limit
- [ ] Probar con 6 intentos fallidos consecutivos
- [ ] Verificar que el mensaje es claro para el usuario

### **Después de Migración SQL:**

- [ ] Regenerar todas las API keys desde UI web
- [ ] Actualizar API keys en dispositivos AgriQR
- [ ] Probar login con nueva API key
- [ ] Verificar que funciona correctamente

---

## 🚨 Notas Importantes

1. **API Keys Antiguas NO Funcionarán:**
   - Después de la migración, las API keys en texto plano no funcionan
   - **DEBEN regenerarse** desde la UI web

2. **Rate Limiting es por IP y DeviceId:**
   - Si un dispositivo intenta desde diferentes IPs, cada IP tiene su propio contador
   - Si múltiples dispositivos intentan desde la misma IP, comparten el límite

3. **HTTPS es Obligatorio:**
   - Las API keys se envían en texto plano, pero **solo por HTTPS**
   - Nunca usar HTTP en producción

---

## 📝 Resumen de Cambios

| Aspecto | Cambio Requerido | Prioridad |
|---------|------------------|-----------|
| Manejo Error 429 | ✅ SÍ | 🔴 Alta |
| Regenerar API Keys | ✅ SÍ (después de migración) | 🔴 Alta |
| API Keys Hasheadas | ❌ NO | - |
| JWT_SECRET | ❌ NO | - |
| Logging | ❌ NO | - |

---

**Fecha de actualización:** 2025-01-XX  
**Versión Backend:** 1.1.0  
**Versión AgriQR Requerida:** 1.1.0+

