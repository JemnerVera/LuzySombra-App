import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { verifyToken } from '../lib/jwt';

export interface UserPayload {
  usuarioID: number;
  username: string;
  rol: string;
  permisos: string[];
  iat?: number;
  exp?: number;
}

/**
 * Middleware de autenticación para usuarios web
 * Verifica que el request tenga un token JWT válido
 */
export function authenticateWebUser(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    // Obtener token del header Authorization
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'No se proporcionó token de autenticación'
      });
    }

    // Verificar token
    const decoded = verifyToken(token) as UserPayload;

    // Agregar información del usuario al request
    (req as any).user = decoded;

    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(403).json({
        success: false,
        error: 'Token inválido'
      });
    }
    
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(403).json({
        success: false,
        error: 'Token expirado. Por favor, inicia sesión nuevamente.'
      });
    }

    return res.status(500).json({
      success: false,
      error: 'Error de autenticación'
    });
  }
}

/**
 * Middleware de autorización
 * Verifica que el usuario tenga el permiso necesario
 */
export function requirePermission(permission: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user as UserPayload;

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no autenticado'
      });
    }

    // Admin tiene todos los permisos
    if (user.permisos.includes('*')) {
      return next();
    }

    // Verificar permiso específico
    if (!user.permisos.includes(permission)) {
      return res.status(403).json({
        success: false,
        error: 'No tienes permisos para realizar esta acción'
      });
    }

    next();
  };
}

/**
 * Middleware para verificar rol específico
 */
export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user as UserPayload;

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no autenticado'
      });
    }

    if (!roles.includes(user.rol)) {
      return res.status(403).json({
        success: false,
        error: 'No tienes el rol necesario para esta acción'
      });
    }

    next();
  };
}

