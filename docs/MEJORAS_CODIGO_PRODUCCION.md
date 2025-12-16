# 🔧 Mejoras de Código para Producción

Este documento contiene ejemplos de código para implementar las mejoras críticas recomendadas en `EVALUACION_PRE_DEPLOY.md`.

---

## 1. 🔒 Seguridad: Helmet.js y Rate Limiting

### Instalación
```bash
cd backend
npm install helmet express-rate-limit
npm install --save-dev @types/express-rate-limit
```

### Implementación en `backend/src/server.ts`

```typescript
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
// ... otros imports

const app = express();
const PORT = process.env.PORT || 3001;

// ===== SEGURIDAD =====
// Helmet.js - Headers de seguridad HTTP
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false, // Para permitir imágenes
}));

// Rate Limiting Global
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por IP por ventana
  message: 'Demasiadas solicitudes desde esta IP, intenta de nuevo más tarde.',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', limiter);

// Rate Limiting más estricto para endpoints de autenticación
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 intentos de login por IP
  message: 'Demasiados intentos de autenticación, intenta de nuevo más tarde.',
  skipSuccessfulRequests: true,
});

// Aplicar a rutas de autenticación después de definirlas
// app.use('/api/auth', authLimiter);
// app.use('/api/auth/web', authLimiter);

// ... resto del código
```

---

## 2. 📝 Logger Estructurado (Winston)

### Instalación
```bash
cd backend
npm install winston winston-daily-rotate-file
```

### Crear `backend/src/lib/logger.ts`

```typescript
import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';

const logDir = path.join(process.cwd(), 'logs');

// Formato de log
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Transporte para archivo (rotación diaria)
const fileRotateTransport = new DailyRotateFile({
  filename: path.join(logDir, 'application-%DATE%.log'),
  datePattern: 'YYYY-MM-DD',
  maxSize: '20m',
  maxFiles: '14d', // Mantener logs por 14 días
  format: logFormat,
});

// Transporte para errores (archivo separado)
const errorFileRotateTransport = new DailyRotateFile({
  filename: path.join(logDir, 'error-%DATE%.log'),
  datePattern: 'YYYY-MM-DD',
  level: 'error',
  maxSize: '20m',
  maxFiles: '30d', // Mantener errores por 30 días
  format: logFormat,
});

// Transporte para consola (solo en desarrollo)
const consoleTransport = new winston.transports.Console({
  format: winston.format.combine(
    winston.format.colorize(),
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
    fileRotateTransport,
    errorFileRotateTransport,
    // Solo mostrar en consola en desarrollo
    ...(process.env.NODE_ENV !== 'production' ? [consoleTransport] : []),
  ],
  exceptionHandlers: [
    new winston.transports.File({ filename: path.join(logDir, 'exceptions.log') }),
  ],
  rejectionHandlers: [
    new winston.transports.File({ filename: path.join(logDir, 'exceptions.log') }),
  ],
});

export default logger;
```

### Uso en el código

**Reemplazar `console.log`:**
```typescript
// ❌ Antes
console.log('✅ [DB] Conectado a SQL Server');
console.error('❌ [DB] Error:', error);

// ✅ Después
import logger from '../lib/logger';

logger.info('Conectado a SQL Server', { server: config.server, database: config.database });
logger.error('Error conectando a SQL Server', { error: error.message, code: error.code });
```

**Ejemplo en `backend/src/lib/db.ts`:**
```typescript
import logger from './logger';

export async function getConnection(): Promise<sql.ConnectionPool> {
  // ...
  try {
    pool = await sql.connect(config);
    
    logger.info('Conexión a SQL Server establecida', {
      server: config.server,
      database: config.database,
    });
    
    return pool;
  } catch (error: any) {
    logger.error('Error conectando a SQL Server', {
      error: error.message,
      code: error.code,
      server: config.server,
    });
    
    throw error;
  }
}
```

---

## 3. ✅ Validación de Variables de Entorno

### Instalación
```bash
cd backend
npm install zod
```

### Crear `backend/src/config/env.ts`

```typescript
import { z } from 'zod';
import dotenv from 'dotenv';
import path from 'path';

// Cargar variables de entorno
const rootPath = path.resolve(process.cwd(), '..');
dotenv.config({ path: path.join(rootPath, '.env.local') });
dotenv.config({ path: path.join(rootPath, '.env') });
dotenv.config();

// Esquema de validación
const envSchema = z.object({
  // SQL Server
  SQL_SERVER: z.string().min(1, 'SQL_SERVER es requerido'),
  SQL_DATABASE: z.string().min(1, 'SQL_DATABASE es requerido'),
  SQL_PORT: z.string().default('1433'),
  SQL_USER: z.string().min(1, 'SQL_USER es requerido'),
  SQL_PASSWORD: z.string().min(1, 'SQL_PASSWORD es requerido'),
  SQL_ENCRYPT: z.string().default('true'),
  
  // Server
  PORT: z.string().default('3001'),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  FRONTEND_URL: z.string().url('FRONTEND_URL debe ser una URL válida'),
  
  // Resend
  RESEND_API_KEY: z.string().min(1, 'RESEND_API_KEY es requerido'),
  RESEND_FROM_EMAIL: z.string().email('RESEND_FROM_EMAIL debe ser un email válido'),
  RESEND_FROM_NAME: z.string().default('Sistema de Alertas LuzSombra'),
  
  // JWT
  JWT_SECRET: z.string().min(32, 'JWT_SECRET debe tener al menos 32 caracteres'),
  JWT_EXPIRES_IN: z.string().default('24h'),
  
  // Data Source
  DATA_SOURCE: z.string().default('sql'),
  
  // Scheduler
  ENABLE_ALERT_SCHEDULER: z.string().default('true'),
  
  // Opcionales
  ALERTAS_EMAIL_DESTINATARIOS: z.string().optional(),
  ALERTAS_EMAIL_CC: z.string().optional(),
  BACKEND_BASE_URL: z.string().url().optional(),
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
});

// Validar y exportar
export type EnvConfig = z.infer<typeof envSchema>;

let env: EnvConfig;

try {
  env = envSchema.parse(process.env);
} catch (error) {
  if (error instanceof z.ZodError) {
    const missingVars = error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join('\n');
    throw new Error(
      `❌ Error validando variables de entorno:\n${missingVars}\n\n` +
      `Por favor, configura las variables en .env.local o Application Settings.`
    );
  }
  throw error;
}

// Exportar config validada
export default env;
```

### Uso en `backend/src/lib/db.ts`

```typescript
import env from '../config/env';

const config: sql.config = {
  user: env.SQL_USER,
  password: env.SQL_PASSWORD,
  server: env.SQL_SERVER,
  database: env.SQL_DATABASE,
  port: parseInt(env.SQL_PORT),
  options: {
    encrypt: env.SQL_ENCRYPT !== 'false',
    // ...
  },
};
```

---

## 4. 🛡️ Manejo de Errores Global

### Crear `backend/src/middleware/errorHandler.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import logger from '../lib/logger';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export class CustomError extends Error implements AppError {
  statusCode: number;
  isOperational: boolean;

  constructor(message: string, statusCode: number = 500, isOperational: boolean = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const statusCode = err.statusCode || 500;
  const isOperational = err.isOperational !== false;

  // Log error
  if (statusCode >= 500) {
    logger.error('Error del servidor', {
      error: err.message,
      stack: err.stack,
      path: req.path,
      method: req.method,
      ip: req.ip,
    });
  } else {
    logger.warn('Error del cliente', {
      error: err.message,
      path: req.path,
      method: req.method,
      ip: req.ip,
    });
  }

  // Respuesta al cliente
  const response: any = {
    success: false,
    error: isOperational ? err.message : 'Error interno del servidor',
  };

  // Solo incluir stack trace en desarrollo
  if (process.env.NODE_ENV === 'development' && err.stack) {
    response.stack = err.stack;
  }

  // Incluir detalles adicionales en desarrollo
  if (process.env.NODE_ENV === 'development') {
    response.details = {
      statusCode,
      isOperational,
      path: req.path,
      method: req.method,
    };
  }

  res.status(statusCode).json(response);
};
```

### Uso en `backend/src/server.ts`

```typescript
import { errorHandler } from './middleware/errorHandler';

// ... rutas ...

// Manejo de errores (debe ir al final, después de todas las rutas)
app.use(errorHandler);
```

### Uso en rutas

```typescript
import { CustomError } from '../middleware/errorHandler';

router.get('/example', async (req: Request, res: Response, next: NextFunction) => {
  try {
    // ...
    if (!data) {
      throw new CustomError('Recurso no encontrado', 404);
    }
    res.json({ success: true, data });
  } catch (error) {
    next(error); // Pasar al error handler
  }
});
```

---

## 5. 🏥 Health Check Mejorado

### Actualizar `backend/src/routes/health.ts`

```typescript
import express, { Request, Response } from 'express';
import { getConnection } from '../lib/db';
import { resendService } from '../services/resendService';
import logger from '../lib/logger';

const router = express.Router();

interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  uptime: number;
  services: {
    database: { status: 'ok' | 'error'; message?: string };
    resend: { status: 'ok' | 'error'; message?: string };
  };
  version: string;
}

router.get('/', async (req: Request, res: Response) => {
  const startTime = Date.now();
  const healthStatus: HealthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    services: {
      database: { status: 'ok' },
      resend: { status: 'ok' },
    },
    version: '2.0.0',
  };

  // Verificar conexión a BD
  try {
    const connection = await getConnection();
    if (!connection.connected) {
      healthStatus.services.database = {
        status: 'error',
        message: 'Conexión no establecida',
      };
      healthStatus.status = 'degraded';
    }
  } catch (error) {
    healthStatus.services.database = {
      status: 'error',
      message: error instanceof Error ? error.message : 'Error desconocido',
    };
    healthStatus.status = 'unhealthy';
  }

  // Verificar Resend API (opcional, puede ser lento)
  // Solo verificar si no hay error crítico
  if (healthStatus.status !== 'unhealthy') {
    try {
      // Verificar que el servicio está inicializado
      const resendInitialized = resendService.isInitialized();
      if (!resendInitialized) {
        healthStatus.services.resend = {
          status: 'error',
          message: 'Resend service no inicializado',
        };
        if (healthStatus.status === 'healthy') {
          healthStatus.status = 'degraded';
        }
      }
    } catch (error) {
      healthStatus.services.resend = {
        status: 'error',
        message: error instanceof Error ? error.message : 'Error desconocido',
      };
      if (healthStatus.status === 'healthy') {
        healthStatus.status = 'degraded';
      }
    }
  }

  const statusCode = healthStatus.status === 'unhealthy' ? 503 : 200;
  
  logger.info('Health check', {
    status: healthStatus.status,
    responseTime: Date.now() - startTime,
  });

  res.status(statusCode).json(healthStatus);
});

export default router;
```

---

## 6. 📦 Actualizar `.gitignore`

Agregar a `.gitignore`:
```
# Logs
logs/
*.log
```

---

## 7. 🔄 Actualizar `package.json` Scripts

Agregar a `backend/package.json`:
```json
{
  "scripts": {
    "dev": "nodemon src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "start:prod": "NODE_ENV=production node dist/server.js",
    "lint": "eslint src",
    "type-check": "tsc --noEmit"
  }
}
```

---

## 📝 Próximos Pasos

1. **Implementar mejoras críticas** (Fase 1)
2. **Probar localmente** con `NODE_ENV=production`
3. **Actualizar Azure Application Settings** con nuevas variables
4. **Configurar Azure Key Vault**
5. **Deploy y monitorear**

---

**Nota:** Estos ejemplos son guías. Ajusta según las necesidades específicas del proyecto.

