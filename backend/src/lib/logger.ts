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

