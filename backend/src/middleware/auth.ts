import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

// Interfaz para el payload del JWT
interface JwtPayload {
  deviceId: string;
  iat?: number;
  exp?: number;
}

/**
 * Middleware de autenticación JWT
 * Verifica que el request tenga un token válido
 */
export function authenticateToken(req: Request, res: Response, next: NextFunction) {
  try {
    // Obtener token del header Authorization
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'No token provided',
        processed: false
      });
    }

    // Verificar token
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const decoded = jwt.verify(token, jwtSecret) as JwtPayload;

    // Agregar información del dispositivo al request
    (req as any).deviceId = decoded.deviceId;

    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(403).json({
        error: 'Invalid token',
        processed: false
      });
    }
    
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(403).json({
        error: 'Token expired',
        processed: false
      });
    }

    return res.status(500).json({
      error: 'Authentication error',
      processed: false
    });
  }
}

