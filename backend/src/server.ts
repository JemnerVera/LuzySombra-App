import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import logger from './lib/logger';

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
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por IP por ventana
  message: {
    error: 'Demasiadas solicitudes desde esta IP, intenta de nuevo más tarde.',
  },
  standardHeaders: true, // Incluir headers estándar (X-RateLimit-*)
  legacyHeaders: false, // No incluir headers legacy (Retry-After)
});

app.use('/api/', globalLimiter);

// Rate Limiting más estricto para endpoints de autenticación
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 5, // máximo 5 intentos de login por IP
  message: {
    error: 'Demasiados intentos de autenticación, intenta de nuevo más tarde.',
  },
  skipSuccessfulRequests: true, // No contar requests exitosos
});

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
app.use('/api/auth', authLimiter, authRoutes); // Dispositivos móviles (AgriQR)
app.use('/api/auth/web', authLimiter, authWebRoutes); // Usuarios web
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

// Iniciar servidor
app.listen(PORT, () => {
  const startMessage = `✅ Backend server iniciado en puerto ${PORT}`;
  console.log(startMessage); // Log directo a consola para Azure Log Stream
  logger.info('Backend server iniciado', {
    port: PORT,
    frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3000',
    nodeEnv: process.env.NODE_ENV || 'development',
  });
});

// Iniciar scheduler de alertas (si está habilitado)
import { alertScheduler } from './scheduler/alertScheduler';
// El scheduler se inicia automáticamente en su constructor

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

