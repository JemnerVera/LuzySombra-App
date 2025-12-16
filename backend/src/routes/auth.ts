import express, { Request, Response } from 'express';
import { deviceService } from '../services/deviceService';
import { rateLimitService } from '../services/rateLimitService';
import { query } from '../lib/db';
import { signToken, verifyToken } from '../lib/jwt';

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
        error: 'Server configuration error'
      });
    }

    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

/**
 * POST /api/auth/activate
 * Activación de dispositivo usando código de activación (desde QR)
 * 
 * Body:
 * - deviceId: ID único del dispositivo
 * - activationCode: Código de activación del QR
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
        error: 'Too many failed login attempts. Please try again in 15 minutes.',
        retryAfter: 900
      });
    }

    // Obtener dispositivo por código de activación
    const device = await deviceService.getDeviceByActivationCode(activationCode);
    
    if (!device) {
      motivoFallo = 'Invalid activation code';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(401).json({
        error: 'Invalid activation code'
      });
    }

    // Verificar que el deviceId coincida
    if (device.deviceId !== deviceId) {
      motivoFallo = 'Device ID mismatch';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
      return res.status(401).json({
        error: 'Device ID does not match activation code'
      });
    }

    // Verificar que el código no haya expirado
    if (device.activationCodeExpires) {
      const expiresAt = new Date(device.activationCodeExpires);
      if (expiresAt < new Date()) {
        motivoFallo = 'Activation code expired';
        await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
        return res.status(401).json({
          error: 'Activation code has expired'
        });
      }
    }

    // Generar nueva API key
    const newApiKey = await deviceService.generateApiKey();
    const apiKeyHash = await deviceService.hashApiKey(newApiKey);

    // Actualizar dispositivo con nueva API key y limpiar código de activación
    await query(`
      UPDATE evalImagen.dispositivo
      SET apiKeyHash = @apiKeyHash,
          activationCode = NULL,
          activationCodeExpires = NULL,
          fechaModificacion = GETDATE()
      WHERE dispositivoID = @dispositivoID
        AND statusID = 1
    `, { 
      dispositivoID: device.dispositivoID,
      apiKeyHash 
    });

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
      apiKey: newApiKey, // ⚠️ IMPORTANTE: Retornar API key solo esta vez
      expiresIn: 86400,
      deviceId: deviceId,
      message: 'Device activated successfully. Save the API key, it will not be shown again.'
    });
  } catch (error) {
    console.error('❌ Error in activate:', error);
    
    // Registrar intento fallido si hay deviceId
    if (deviceId) {
      motivoFallo = error instanceof Error ? error.message : 'Unknown error';
      await rateLimitService.registrarIntento(false, ipAddress, deviceId, undefined, motivoFallo);
    }

    res.status(500).json({
      error: 'Internal server error'
    });
  }
});

/**
 * GET /api/auth/verify-lote-token
 * Verifica un token JWT para acceso a evaluación de lote
 * Usado para links seguros en emails de alertas
 * 
 * Query params:
 * - token: JWT token con información del lote
 */
router.get('/verify-lote-token', async (req: Request, res: Response) => {
  try {
    const { token } = req.query;

    console.log('🔍 [verify-lote-token] Verificando token...', { 
      hasToken: !!token, 
      tokenType: typeof token,
      tokenLength: token ? (typeof token === 'string' ? token.length : 'N/A') : 0
    });

    if (!token || typeof token !== 'string') {
      console.error('❌ [verify-lote-token] Token no válido o faltante');
      return res.status(400).json({
        success: false,
        error: 'Token is required'
      });
    }

    // Verificar token
    let decoded: any;
    try {
      decoded = verifyToken(token) as any;
      console.log('✅ [verify-lote-token] Token decodificado:', { 
        type: decoded.type, 
        lotID: decoded.lotID,
        hasLote: !!decoded.lote,
        hasSector: !!decoded.sector,
        hasFundo: !!decoded.fundo
      });
    } catch (verifyError: any) {
      console.error('❌ [verify-lote-token] Error verificando token:', verifyError.message);
      throw verifyError;
    }

    // Validar que sea un token de tipo lote-access
    if (decoded.type !== 'lote-access' || !decoded.lotID) {
      console.error('❌ [verify-lote-token] Token no es de tipo lote-access o falta lotID:', {
        type: decoded.type,
        hasLotID: !!decoded.lotID
      });
      return res.status(401).json({
        success: false,
        error: 'Invalid token type'
      });
    }

    // Obtener información del lote para validar
    const loteInfo = await query<{
      lotID: number;
      lote: string;
      sector: string;
      fundo: string;
    }>(`
      SELECT 
        l.lotID,
        l.name AS lote,
        s.stage AS sector,
        f.Description AS fundo
      FROM GROWER.LOT l
      INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
      INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
      WHERE l.lotID = @lotID
        AND l.statusID = 1
        AND s.statusID = 1
        AND f.statusID = 1
    `, { lotID: decoded.lotID });

    if (loteInfo.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Lote not found'
      });
    }

    const lote = loteInfo[0];

    // Validar que los datos del token coincidan con la BD
    if (lote.lote !== decoded.lote || lote.sector !== decoded.sector || lote.fundo !== decoded.fundo) {
      console.error('❌ [verify-lote-token] Datos del token no coinciden con BD:', {
        token: { lote: decoded.lote, sector: decoded.sector, fundo: decoded.fundo },
        bd: { lote: lote.lote, sector: lote.sector, fundo: lote.fundo }
      });
      return res.status(401).json({
        success: false,
        error: 'Token data mismatch'
      });
    }

    console.log('✅ [verify-lote-token] Token válido, retornando información del lote');
    // Token válido - retornar información del lote
    res.json({
      success: true,
      data: {
        lotID: decoded.lotID,
        lote: decoded.lote,
        sector: decoded.sector,
        fundo: decoded.fundo,
        expiresAt: decoded.exp
      }
    });
  } catch (error) {
    console.error('❌ Error verifying lote token:', error);
    
    if (error instanceof Error && error.message.includes('expired')) {
      return res.status(401).json({
        success: false,
        error: 'Token has expired'
      });
    }

    if (error instanceof Error && error.message.includes('invalid')) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token'
      });
    }

    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

export default router;
