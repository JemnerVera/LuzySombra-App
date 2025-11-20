import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';

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

const app = express();
const PORT = process.env.PORT || 3001;

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

// NUEVAS RUTAS PARA AGRICQR
app.use('/api/auth', authRoutes);
app.use('/api/photos', photoUploadRoutes);

// RUTAS PARA ALERTAS
app.use('/api/alertas/consolidar', consolidarAlertasRoutes);
app.use('/api/alertas/enviar', enviarAlertasRoutes);

// Ruta raíz
app.get('/', (req, res) => {
  res.json({
    message: 'Agricola Backend API',
    version: '1.0.0',
    status: 'running'
  });
});

// Manejo de errores
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('❌ Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Backend server running on port ${PORT}`);
  console.log(`📡 Frontend URL: ${process.env.FRONTEND_URL || 'http://localhost:3000'}`);
});

// Manejo de cierre graceful
process.on('SIGTERM', async () => {
  console.log('🛑 SIGTERM received, closing server...');
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 SIGINT received, closing server...');
  process.exit(0);
});

export default app;

