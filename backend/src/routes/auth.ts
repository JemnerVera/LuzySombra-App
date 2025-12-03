import express, { Request, Response } from 'express';
import { deviceService } from '../services/deviceService';
import { rateLimitService } from '../services/rateLimitService';
import { query } from '../lib/db';
import { signToken } from '../lib/jwt';

const router = express.Router();

/**
 * POST /api/auth/login
 * Autenticación de dispositivo Android
 * 
 * Body:
 * - deviceId: ID único del dispositivo
 * - apiKey: API key del dispositivo
 */
router.post('/login', async (req: Request, res: Response) => {
  const ipAddress = rateLimitService.getClientIp(req);
  let deviceId: string | undefined;
  let motivoFallo: string | undefined;

  try {
    const { deviceId: reqDeviceId, apiKey } = req.body;
    deviceId = reqDeviceId;

    // Validaciones básicas
    if (!deviceId || !apiKey) {
      motivoFallo = 'Missing deviceId or apiKey';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(400).json({
        error: 'deviceId and apiKey are required'
      });
    }

    // Verificar rate limiting
    const rateLimit = await rateLimitService.checkRateLimit(deviceId, undefined, ipAddress);
    if (rateLimit.estaBloqueado) {
      motivoFallo = 'Rate limit exceeded';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(429).json({
        error: 'Too many failed login attempts. Please try again in 15 minutes.',
        retryAfter: 900 // 15 minutos en segundos
      });
    }

    // Obtener dispositivo con hash
    const device = await deviceService.getDeviceForAuth(deviceId);
    
    if (!device) {
      motivoFallo = 'Device not found';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Verificar que el dispositivo esté activo
    if (!device.activo) {
      motivoFallo = 'Device disabled';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(403).json({
        error: 'Device is disabled'
      });
    }

    // Comparar API key con hash usando bcrypt
    const apiKeyValid = await deviceService.compareApiKey(apiKey, device.apiKeyHash);
    
    if (!apiKeyValid) {
      motivoFallo = 'Invalid API key';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Login exitoso - actualizar último acceso
    await query(`
      UPDATE evalImagen.dispositivo
      SET ultimoAcceso = GETDATE()
      WHERE dispositivoID = @dispositivoID
    `, { dispositivoID: device.dispositivoID });

    // Registrar intento exitoso
    await rateLimitService.registrarIntento(true, ipAddress, deviceId);

    // Generar JWT token
    const token = signToken(
      { deviceId },
      { expiresIn: '24h' }
    );

    res.json({
      success: true,
      token,
      expiresIn: 86400, // 24 horas en segundos
      deviceId
    });
  } catch (error) {
    console.error('❌ Error in login:', error);
    
    // Registrar intento fallido si hay deviceId
    if (deviceId) {
      motivoFallo = error instanceof Error ? error.message : 'Unknown error';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
    }

    // Si es error de JWT_SECRET, retornar 500
    if (error instanceof Error && error.message.includes('JWT_SECRET')) {
      return res.status(500).json({
        error: 'Server configuration error',
        message: 'JWT_SECRET is not configured'
      });
    }

    res.status(500).json({
      error: 'Login error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/auth/activate
 * Activa un dispositivo usando código de activación del QR
 */
router.post('/activate', async (req: Request, res: Response) => {
  const ipAddress = rateLimitService.getClientIp(req);
  let deviceId: string | undefined;
  let motivoFallo: string | undefined;

  try {
    const { deviceId: reqDeviceId, activationCode } = req.body;
    deviceId = reqDeviceId;

    if (!deviceId || !activationCode) {
      motivoFallo = 'Missing deviceId or activationCode';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(400).json({
        error: 'deviceId and activationCode are required'
      });
    }

    // Verificar rate limiting
    const rateLimit = await rateLimitService.checkRateLimit(deviceId, undefined, ipAddress);
    if (rateLimit.estaBloqueado) {
      motivoFallo = 'Rate limit exceeded';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(429).json({
        error: 'Too many failed attempts. Please try again in 15 minutes.',
        retryAfter: 900
      });
    }

    // Validar código de activación
    const device = await deviceService.getDeviceByActivationCode(activationCode);
    
    if (!device) {
      motivoFallo = 'Invalid activation code';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(401).json({
        error: 'Invalid activation code or device ID'
      });
    }

    // Verificar que el deviceId coincida
    if (device.deviceId !== deviceId) {
      motivoFallo = 'Device ID mismatch';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(401).json({
        error: 'Invalid activation code or device ID'
      });
    }

    // Verificar que el código no haya expirado
    if (device.activationCodeExpires) {
      const now = new Date();
      const expiresAt = new Date(device.activationCodeExpires);
      
      if (now > expiresAt) {
        motivoFallo = 'Activation code expired';
        await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
        return res.status(401).json({
          error: 'Activation code expired'
        });
      }
    }

    // Verificar que el dispositivo esté activo
    if (!device.activo) {
      motivoFallo = 'Device disabled';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(403).json({
        error: 'Device is disabled'
      });
    }

    // Regenerar API key para este dispositivo (seguridad: nueva key al activar con QR)
    // Esto asegura que solo quien escanea el QR obtiene la API key
    const usuarioModificaID = 1; // Sistema (no hay usuario web en este contexto)
    const newApiKey = await deviceService.regenerateApiKey(device.dispositivoID, usuarioModificaID);

    // Generar JWT token directamente
    const token = signToken(
      { deviceId },
      { expiresIn: '24h' }
    );

    // Invalidar código de activación (solo se usa una vez)
    await deviceService.clearActivationCode(device.dispositivoID);

    // Registrar intento exitoso
    await rateLimitService.registrarIntento(true, ipAddress, deviceId);

    res.json({
      success: true,
      token: token,
      apiKey: newApiKey, // ⚠️ IMPORTANTE: Retornar API key solo esta vez
      expiresIn: 86400, // 24 horas en segundos
      deviceId: deviceId,
      message: 'Device activated successfully. Save the API key for future logins.'
    });

  } catch (error) {
    console.error('❌ Error in activation:', error);
    
    // Registrar intento fallido si hay deviceId
    if (deviceId) {
      motivoFallo = error instanceof Error ? error.message : 'Unknown error';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
    }

    // Si es error de JWT_SECRET, retornar 500
    if (error instanceof Error && error.message.includes('JWT_SECRET')) {
      return res.status(500).json({
        error: 'Server configuration error',
        message: 'JWT_SECRET is not configured'
      });
    }

    res.status(500).json({
      error: 'Activation error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

