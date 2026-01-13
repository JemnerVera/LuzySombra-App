// Logging inicial ANTES de cualquier import para capturar errores tempranos
import express from 'express';

import cors from 'cors';
import helmet from 'helmet';
// import rateLimit from 'express-rate-limit'; // TEMPORALMENTE DESHABILITADO - ver comentarios más abajo
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

import logger from './lib/logger';

// Manejo global de errores no capturados ANTES de que cualquier otro código se ejecute
process.on('uncaughtException', (error: Error) => {
  console.error('❌ UNCAUGHT EXCEPTION:', error);
  console.error('Stack:', error.stack);
  try {
    logger.error('Uncaught Exception', {
      error: error.message,
      stack: error.stack,
    });
  } catch (logError) {
    console.error('❌ Error al loguear exception:', logError);
  }
  // NO hacer process.exit() aquí, dejar que el proceso termine naturalmente
  // para que Azure pueda reiniciarlo automáticamente
});

process.on('unhandledRejection', (reason: any, promise: Promise<any>) => {
  console.error('❌ UNHANDLED REJECTION:', reason);
  try {
    logger.error('Unhandled Rejection', {
      reason: reason instanceof Error ? reason.message : String(reason),
      stack: reason instanceof Error ? reason.stack : undefined,
    });
  } catch (logError) {
    console.error('❌ Error al loguear rejection:', logError);
  }
});


// Cargar variables de entorno
// Buscar .env.local en la raíz del proyecto (un nivel arriba de backend/)
const rootPath = path.resolve(process.cwd(), '..');
dotenv.config({ path: path.join(rootPath, '.env.local') });
dotenv.config({ path: path.join(rootPath, '.env') }); // Fallback a .env si .env.local no existe
dotenv.config(); // También buscar en backend/.env.local y backend/.env (fallback)


// Importar rutas
import fieldDataRoutes from './routes/field-data';
import historialRoutes from './routes/historial';
import imageProcessingRoutes from './routes/image-processing';
import healthRoutes from './routes/health';
import testDbRoutes from './routes/test-db';
import tablaConsolidadaRoutes from './routes/tabla-consolidada';
import tablaConsolidadaDetalleRoutes from './routes/tabla-consolidada-detalle';
import tablaConsolidadaDetallePlantaRoutes from './routes/tabla-consolidada-detalle-planta';
import imagenRoutes from './routes/imagen';
import estadisticasRoutes from './routes/estadisticas';
import { testModelRouter, checkGpsInfoRouter } from './routes/image-processing';
import authRoutes from './routes/auth';
import photoUploadRoutes from './routes/photoUpload';
import consolidarAlertasRoutes from './routes/alertas/consolidar';
import enviarAlertasRoutes from './routes/alertas/enviar';
import mensajesAlertasRoutes from './routes/alertas/mensajes';
import listarAlertasRoutes from './routes/alertas/listar';
import umbralesRoutes from './routes/umbrales';
import contactosRoutes from './routes/contactos';
import authWebRoutes from './routes/auth-web';
import notificacionesRoutes from './routes/notificaciones';
import dispositivosRoutes from './routes/dispositivos';
import usuariosRoutes from './routes/usuarios';
import burroRoutes from './routes/burro';
import lotInfoRoutes from './routes/lot-info';
import extractLotIdRoutes from './routes/extract-lot-id';

const app = express();

// Configurar trust proxy para Azure App Service (detrás de proxy reverso)
// IMPORTANTE: Debe configurarse ANTES de cualquier middleware que use req.ip
// Azure App Service usa 1 proxy reverso, así que confiamos solo en 1 hop
// Esto es más seguro que 'true' y evita warnings de express-rate-limit
app.set('trust proxy', 1);

// Leer PORT de las variables de entorno (Azure lo configura automáticamente)
// Azure expone puertos 80 y 8080, pero permite configurar PORT personalizado
// El proxy de Azure redirige el tráfico al puerto que configuremos
// En desarrollo local, usar puerto 3001 por defecto (frontend espera este puerto)
const DEFAULT_PORT = process.env.NODE_ENV === 'production' ? '8080' : '3001';
const PORT = parseInt(process.env.PORT || DEFAULT_PORT, 10);

// ===== SEGURIDAD =====
// Helmet.js - Headers de seguridad HTTP
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: [
        "'self'",
        "'unsafe-inline'", // Necesario para algunos scripts inline
        "https://cdn.jsdelivr.net", // Permitir jsdelivr para EXIF.js y otras librerías
      ],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false, // Para permitir imágenes
}));

// Rate Limiting Global - TEMPORALMENTE DESHABILITADO
// TODO: Re-habilitar después de resolver problemas con express-rate-limit v8+
// El problema es que express-rate-limit v8+ tiene validaciones muy estrictas que
// requieren usar ipKeyGenerator helper, pero este helper no funciona bien con IPs que incluyen puerto
/*
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por IP por ventana
  message: {
    error: 'Demasiadas solicitudes desde esta IP, intenta de nuevo más tarde.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', globalLimiter);
*/

// Rate Limiting más estricto para endpoints de autenticación - TEMPORALMENTE DESHABILITADO
// TODO: Re-habilitar después de resolver problemas con express-rate-limit v8+
/*
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 intentos de login por IP
  message: {
    error: 'Demasiados intentos de autenticación, intenta de nuevo más tarde.',
  },
  skipSuccessfulRequests: true,
  standardHeaders: true,
  legacyHeaders: false,
});
*/

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Rutas
app.use('/api/field-data', fieldDataRoutes);
app.use('/api/historial', historialRoutes);
app.use('/api/procesar-imagen', imageProcessingRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/test-db', testDbRoutes);
app.use('/api/tabla-consolidada', tablaConsolidadaRoutes);
app.use('/api/tabla-consolidada/detalle', tablaConsolidadaDetalleRoutes);
app.use('/api/tabla-consolidada/detalle-planta', tablaConsolidadaDetallePlantaRoutes);
app.use('/api/imagen', imagenRoutes);
app.use('/api/estadisticas', estadisticasRoutes);
app.use('/api/test-model', testModelRouter);
app.use('/api/check-gps-info', checkGpsInfoRouter);

// AUTENTICACIÓN (con rate limiting estricto)
// TEMPORALMENTE DESHABILITADO: Rate limiting comentado para resolver errores de validación
// TODO: Re-habilitar después de resolver problemas con express-rate-limit
app.use('/api/auth', authRoutes); // Dispositivos móviles (AgriQR) - authLimiter temporalmente deshabilitado
app.use('/api/auth/web', authWebRoutes); // Usuarios web - authLimiter temporalmente deshabilitado
app.use('/api/photos', photoUploadRoutes);

// RUTAS PARA ALERTAS
app.use('/api/alertas/consolidar', consolidarAlertasRoutes);
app.use('/api/alertas/enviar', enviarAlertasRoutes);
app.use('/api/alertas/mensajes', mensajesAlertasRoutes);
app.use('/api/alertas', listarAlertasRoutes);

// RUTAS PARA UMBRALES
app.use('/api/umbrales', umbralesRoutes);

// RUTAS PARA CONTACTOS
app.use('/api/contactos', contactosRoutes);

// RUTAS PARA USUARIOS
app.use('/api/usuarios', usuariosRoutes);

// RUTAS PARA NOTIFICACIONES
app.use('/api/notificaciones', notificacionesRoutes);

// RUTAS PARA DISPOSITIVOS
app.use('/api/dispositivos', dispositivosRoutes);

// RUTAS PARA BURRO (Raspberry Pi)
app.use('/api/burro', burroRoutes);
app.use('/api/lot-info', lotInfoRoutes);
app.use('/api/extract-lot-id', extractLotIdRoutes);

// Servir archivos estáticos del frontend (si existen)
const frontendPath = path.join(__dirname, '../public');
if (fs.existsSync(frontendPath)) {
  app.use(express.static(frontendPath));
  
  // Para SPA: todas las rutas que no sean /api/* sirven index.html
  app.get('*', (req, res, next) => {
    // Si es una ruta de API, continuar
    if (req.path.startsWith('/api')) {
      return next();
    }
    // Si no, servir index.html (para React Router)
    res.sendFile(path.join(frontendPath, 'index.html'));
  });
} else {
  // Si no hay frontend, mostrar mensaje de API
  app.get('/', (req, res) => {
    res.json({
      message: 'Agricola Backend API',
      version: '1.0.0',
      status: 'running'
    });
  });
}

// Manejo de errores
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  logger.error('Error no manejado', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    ip: req.ip,
  });
  
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'production' ? 'Error interno del servidor' : err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// Iniciar servidor con manejo de errores
try {
  logger.info(`Iniciando servidor en puerto ${PORT}...`, { port: PORT });
  
  const server = app.listen(PORT, () => {
    logger.info('Backend server iniciado', {
      port: PORT,
      frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3000',
      nodeEnv: process.env.NODE_ENV || 'development',
    });
    
    // Iniciar scheduler de alertas después de que el servidor esté escuchando
    import('./scheduler/alertScheduler').then(() => {
    }).catch((schedulerError: any) => {
      console.error('⚠️ Error al inicializar scheduler (continuando sin scheduler):', schedulerError.message);
      // NO hacer process.exit() aquí - el servidor puede funcionar sin scheduler
    });
  });

  // Manejar errores del servidor HTTP
  server.on('error', (error: NodeJS.ErrnoException) => {
    logger.error('Error en servidor HTTP', {
      error: error.message,
      code: error.code,
      stack: error.stack,
    });
    
    // Si el error es EADDRINUSE, el puerto ya está en uso
    if (error.code === 'EADDRINUSE') {
      logger.error(`Puerto ${PORT} ya está en uso`, {
        port: PORT,
        suggestion: 'Cierra el proceso que está usando el puerto o cambia el puerto en .env'
      });
      process.exit(1);
    }
  });
} catch (error: any) {
  logger.error('Error al iniciar servidor', {
    error: error.message,
    stack: error.stack,
  });
  process.exit(1);
}

// El scheduler se iniciará dentro del callback de app.listen() para evitar problemas

// Manejo de cierre graceful
process.on('SIGTERM', async () => {
  logger.info('SIGTERM recibido, cerrando servidor...');
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT recibido, cerrando servidor...');
  process.exit(0);
});

export default app;

