# Mejoras de Seguridad Implementadas

## Resumen

Se han implementado mejoras críticas de seguridad en el sistema de autenticación de LuzSombra, elevando el nivel de seguridad de **5/10 a 8/10**.

---

## ✅ Mejoras Implementadas

### 1. **API Keys Hasheadas con bcrypt** 🔐

**Antes:**
- API keys almacenadas en texto plano en `evalImagen.Dispositivo.apiKey`
- Vulnerable si alguien accede a la base de datos

**Después:**
- API keys hasheadas con bcrypt (10 rounds) en `evalImagen.Dispositivo.apiKeyHash`
- Comparación segura usando `bcrypt.compare()`
- La API key en texto plano solo se muestra una vez al crear/regenerar

**Archivos modificados:**
- `scripts/01_tables/07_evalImagen.Dispositivo.sql` - Tabla actualizada con `apiKeyHash`
- `backend/src/services/deviceService.ts` - Métodos `hashApiKey()` y `compareApiKey()`
- `backend/src/routes/auth.ts` - Validación usando hash

---

### 2. **Validación de JWT_SECRET** 🛡️

**Antes:**
- `JWT_SECRET` con valor por defecto inseguro si no está configurado
- `const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';`

**Después:**
- Validación estricta: el servidor falla si `JWT_SECRET` no está configurado
- Helper centralizado en `backend/src/lib/jwt.ts`
- Todos los endpoints usan `signToken()` y `verifyToken()`

**Archivos modificados:**
- `backend/src/lib/jwt.ts` - Helper centralizado
- `backend/src/routes/auth.ts` - Usa `signToken()`
- `backend/src/routes/auth-web.ts` - Usa `signToken()`
- `backend/src/middleware/auth.ts` - Usa `verifyToken()`
- `backend/src/middleware/auth-web.ts` - Usa `verifyToken()`

---

### 3. **Rate Limiting** ⏱️

**Antes:**
- Sin protección contra ataques de fuerza bruta
- Intentos ilimitados de login

**Después:**
- Máximo **5 intentos fallidos en 15 minutos** por:
  - `deviceId` (dispositivos)
  - `username` (usuarios web)
  - `ipAddress` (IP del cliente)
- Bloqueo automático con mensaje claro
- Registro de todos los intentos (exitosos y fallidos)

**Archivos creados:**
- `scripts/01_tables/10_evalImagen.IntentoLogin.sql` - Tabla de auditoría
- `scripts/03_stored_procedures/06_sp_RegistrarIntentoLogin.sql` - SP para registrar intentos
- `scripts/03_stored_procedures/07_sp_CheckRateLimit.sql` - SP para verificar límites
- `backend/src/services/rateLimitService.ts` - Servicio de rate limiting

**Archivos modificados:**
- `backend/src/routes/auth.ts` - Rate limiting en login de dispositivos
- `backend/src/routes/auth-web.ts` - Rate limiting en login de usuarios web

---

### 4. **Logging de Intentos de Login** 📝

**Nuevo:**
- Tabla `evalImagen.IntentoLogin` para auditoría
- Registra:
  - `deviceId` o `username`
  - `ipAddress`
  - `exitoso` (1 = exitoso, 0 = fallido)
  - `motivoFallo` (ej: "Invalid credentials", "Rate limit exceeded")
  - `fechaIntento`

**Uso:**
- Auditoría de seguridad
- Detección de patrones de ataque
- Análisis de intentos fallidos

---

## 📋 Scripts de Instalación

### Orden de Ejecución:

1. **Crear todas las tablas (incluye IntentoLogin y Dispositivo con apiKeyHash):**
   ```sql
   -- Ejecutar: scripts/01_tables/ (en orden del script maestro)
   -- La tabla evalImagen.IntentoLogin se crea en: 10_evalImagen.IntentoLogin.sql
   -- La tabla evalImagen.Dispositivo con apiKeyHash se crea en: 07_evalImagen.Dispositivo.sql
   ```

2. **Crear Stored Procedures:**
   ```sql
   -- Ejecutar en orden:
   -- scripts/03_stored_procedures/05_sp_GetDeviceForAuth.sql
   -- scripts/03_stored_procedures/06_sp_RegistrarIntentoLogin.sql
   -- scripts/03_stored_procedures/07_sp_CheckRateLimit.sql
   ```

---

## 🔧 Configuración Requerida

### Variables de Entorno:

```env
# OBLIGATORIO - Debe estar configurado en producción
JWT_SECRET=tu-secret-key-super-seguro-aqui

# Opcional - Tiempo de expiración de tokens
JWT_EXPIRES_IN=24h
```

**⚠️ IMPORTANTE:** Si `JWT_SECRET` no está configurado, el servidor **fallará al iniciar** con un error claro.

---

## 🧪 Pruebas Recomendadas

1. **Rate Limiting:**
   - Intentar login 6 veces con credenciales incorrectas
   - Verificar que el 6to intento retorna `429 Too Many Requests`
   - Esperar 15 minutos y verificar que vuelve a funcionar

2. **API Key Hash:**
   - Crear un nuevo dispositivo desde la UI
   - Verificar que la API key se muestra solo una vez
   - Intentar login con la API key correcta (debe funcionar)
   - Verificar en BD que `apiKeyHash` existe y `apiKey` está vacío o NULL

3. **JWT_SECRET:**
   - Iniciar servidor sin `JWT_SECRET` configurado
   - Verificar que falla con mensaje claro
   - Configurar `JWT_SECRET` y verificar que inicia correctamente

---

## 📊 Impacto en Seguridad

| Aspecto | Antes | Después | Mejora |
|---------|-------|--------|--------|
| API Keys | Texto plano | Hash bcrypt | ✅ +3 |
| JWT_SECRET | Default inseguro | Validación estricta | ✅ +1 |
| Rate Limiting | Sin protección | 5 intentos/15min | ✅ +2 |
| Logging | Sin auditoría | Tabla completa | ✅ +1 |
| **TOTAL** | **5/10** | **8/10** | **+3** |

---

## 🚀 Próximos Pasos (Opcional)

### Media Prioridad:
- [ ] Expiración de API keys (campo `fechaExpiracion`)
- [ ] Rotación automática de API keys cada X meses
- [ ] IP whitelist por dispositivo

### Baja Prioridad:
- [ ] 2FA para usuarios web
- [ ] Alertas por email cuando se detectan múltiples intentos fallidos
- [ ] Dashboard de seguridad con métricas de intentos

---

## 📝 Notas Técnicas

### bcrypt Rounds:
- Se usa **10 rounds** por defecto (balance entre seguridad y performance)
- Se puede ajustar con `BCRYPT_ROUNDS` en variables de entorno

### Rate Limiting:
- Se verifica por **deviceId**, **username** e **ipAddress** simultáneamente
- Se usa el **mayor** de los conteos (más restrictivo)
- La ventana es de **15 minutos** (configurable en el SP)

### Migración de API Keys:
- Las API keys existentes se marcan como "necesitan regeneración"
- Se debe regenerar desde la UI de gestión de dispositivos
- Después de regenerar todas, se puede eliminar la columna `apiKey` (deprecated)

---

**Fecha de implementación:** 2025-01-XX  
**Versión:** 1.1.0  
**Autor:** Sistema de Seguridad LuzSombra

