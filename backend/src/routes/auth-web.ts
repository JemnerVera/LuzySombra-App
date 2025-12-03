import express, { Request, Response } from 'express';
import { userService } from '../services/userService';
import { authenticateWebUser } from '../middleware/auth-web';
import { signToken } from '../lib/jwt';
import { rateLimitService } from '../services/rateLimitService';

const router = express.Router();

/**
 * POST /api/auth/web/login
 * Autenticación de usuario web
 * 
 * Body:
 * - username: Nombre de usuario
 * - password: Contraseña
 */
router.post('/login', async (req: Request, res: Response) => {
  const ipAddress = rateLimitService.getClientIp(req);
  let username: string | undefined;

  try {
    const { username: reqUsername, password } = req.body;
    username = reqUsername;

    // Validaciones
    if (!username || !password) {
      await rateLimitService.registrarIntento(false, ipAddress, undefined, username, 'Missing username or password');
      return res.status(400).json({
        success: false,
        error: 'username y password son requeridos'
      });
    }

    // Verificar rate limiting
    const rateLimit = await rateLimitService.checkRateLimit(undefined, username, ipAddress);
    if (rateLimit.estaBloqueado) {
      await rateLimitService.registrarIntento(false, ipAddress, undefined, username, 'Rate limit exceeded');
      return res.status(429).json({
        success: false,
        error: 'Demasiados intentos fallidos. Intenta nuevamente en 15 minutos.',
        retryAfter: 900
      });
    }

    // Buscar usuario
    const usuario = await userService.findByUsername(username);

    if (!usuario) {
      await rateLimitService.registrarIntento(false, ipAddress, undefined, username, 'User not found');
      return res.status(401).json({
        success: false,
        error: 'Credenciales inválidas'
      });
    }

    // Verificar si está activo
    if (!usuario.activo) {
      await rateLimitService.registrarIntento(false, ipAddress, undefined, username, 'User disabled');
      return res.status(403).json({
        success: false,
        error: 'Usuario desactivado. Contacta al administrador.'
      });
    }

    // Verificar si está bloqueado (bloqueo por intentos fallidos en UsuarioWeb)
    const isBlocked = await userService.isUserBlocked(usuario.usuarioID);
    if (isBlocked) {
      await rateLimitService.registrarIntento(false, ipAddress, undefined, username, 'User temporarily blocked');
      return res.status(423).json({
        success: false,
        error: 'Usuario temporalmente bloqueado por múltiples intentos fallidos. Intenta en 15 minutos.'
      });
    }

    // Verificar contraseña
    const passwordValid = await userService.verifyPassword(
      password,
      usuario.passwordHash
    );

    if (!passwordValid) {
      // Incrementar intentos fallidos (en UsuarioWeb)
      await userService.incrementFailedAttempts(usuario.usuarioID);
      // Registrar intento fallido (en IntentoLogin)
      await rateLimitService.registrarIntento(false, ipAddress, undefined, username, 'Invalid password');
      
      return res.status(401).json({
        success: false,
        error: 'Credenciales inválidas'
      });
    }

    // Login exitoso - resetear intentos
    await userService.resetFailedAttempts(usuario.usuarioID);
    await userService.updateLastAccess(usuario.usuarioID);

    // Registrar intento exitoso
    await rateLimitService.registrarIntento(true, ipAddress, undefined, username);

    // Generar JWT token
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    const token = signToken(
      {
        usuarioID: usuario.usuarioID,
        username: usuario.username,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      },
      { expiresIn }
    );

    // Calcular expiración en segundos
    const expiresInSeconds = expiresIn === '24h' ? 86400 : 
                            expiresIn === '7d' ? 604800 : 3600;

    res.json({
      success: true,
      token,
      expiresIn: expiresInSeconds,
      user: {
        id: usuario.usuarioID,
        username: usuario.username,
        email: usuario.email,
        nombreCompleto: usuario.nombreCompleto,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      }
    });
  } catch (error) {
    console.error('❌ Error en login:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/auth/web/logout
 * Cerrar sesión (principalmente para logging/auditoría)
 */
router.post('/logout', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    // Aquí podrías invalidar el token en una blacklist
    // Por ahora solo confirmamos el logout
    res.json({
      success: true,
      message: 'Sesión cerrada exitosamente'
    });
  } catch (error) {
    console.error('❌ Error en logout:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * GET /api/auth/web/me
 * Obtener información del usuario actual
 */
router.get('/me', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    const usuarioID = (req as any).user.usuarioID;

    // Buscar usuario actualizado
    const usuario = await userService.findByUsername((req as any).user.username);
    
    if (!usuario || !usuario.activo) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no encontrado o desactivado'
      });
    }

    res.json({
      success: true,
      user: {
        id: usuario.usuarioID,
        username: usuario.username,
        email: usuario.email,
        nombreCompleto: usuario.nombreCompleto,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      }
    });
  } catch (error) {
    console.error('❌ Error obteniendo usuario:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/auth/web/refresh
 * Refrescar token (extender sesión)
 */
router.post('/refresh', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    // Verificar que el usuario sigue activo
    const usuario = await userService.findByUsername(user.username);
    
    if (!usuario || !usuario.activo) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no encontrado o desactivado'
      });
    }

    // Generar nuevo token
    const token = signToken(
      {
        usuarioID: usuario.usuarioID,
        username: usuario.username,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      },
      { expiresIn }
    );

    const expiresInSeconds = expiresIn === '24h' ? 86400 : 
                            expiresIn === '7d' ? 604800 : 3600;

    res.json({
      success: true,
      token,
      expiresIn: expiresInSeconds
    });
  } catch (error) {
    console.error('❌ Error refrescando token:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

export default router;

