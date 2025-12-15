import express, { Request, Response } from 'express';
import QRCode from 'qrcode';
import { authenticateWebUser, requirePermission } from '../middleware/auth-web';
import { deviceService } from '../services/deviceService';
import { query } from '../lib/db';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(authenticateWebUser);

/**
 * GET /api/dispositivos
 * Lista todos los dispositivos
 */
router.get('/', requirePermission('dispositivos:read'), async (req: Request, res: Response) => {
  try {
    const dispositivos = await deviceService.getAllDevices();
    
    // Ocultar API keys por seguridad (solo mostrar últimos 4 caracteres)
    const dispositivosSeguros = dispositivos.map(d => ({
      ...d,
      apiKey: d.apiKey ? `***${d.apiKey.slice(-4)}` : null
    }));

    res.json({
      success: true,
      dispositivos: dispositivosSeguros
    });
  } catch (error) {
    console.error('❌ Error obteniendo dispositivos:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * GET /api/dispositivos/:id
 * Obtiene un dispositivo por ID
 */
router.get('/:id', requirePermission('dispositivos:read'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    const dispositivo = await deviceService.getDeviceById(dispositivoID);

    if (!dispositivo) {
      return res.status(404).json({
        success: false,
        error: 'Dispositivo no encontrado'
      });
    }

    // Ocultar API key
    const dispositivoSeguro = {
      ...dispositivo,
      apiKey: dispositivo.apiKey ? `***${dispositivo.apiKey.slice(-4)}` : null
    };

    res.json({
      success: true,
      dispositivo: dispositivoSeguro
    });
  } catch (error) {
    console.error('❌ Error obteniendo dispositivo:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/dispositivos
 * Crea un nuevo dispositivo
 */
router.post('/', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const { nombreDispositivo, modeloDispositivo, versionApp } = req.body;
    const usuarioCreaID = (req as any).user.usuarioID;

    if (!nombreDispositivo) {
      return res.status(400).json({
        success: false,
        error: 'nombreDispositivo es requerido'
      });
    }

    const result = await deviceService.createDevice({
      nombreDispositivo,
      modeloDispositivo,
      versionApp,
      usuarioCreaID
    });

    // Obtener dispositivo para generar QR
    const device = await deviceService.getDeviceById(result.dispositivoID);
    
    if (!device) {
      return res.status(500).json({
        success: false,
        error: 'Error obteniendo dispositivo después de crear'
      });
    }

    // Generar código de activación y QR
    const { activationCode, expiresAt } = await deviceService.generateActivationCode(
      result.dispositivoID,
      undefined, // operarioNombre (opcional)
      usuarioCreaID
    );

    // Crear objeto con datos para QR
    const baseUrl = process.env.BACKEND_BASE_URL || process.env.FRONTEND_URL?.replace('/frontend', '') || 'https://luzsombra-backend.azurewebsites.net/api/';
    const qrData = {
      type: 'agriqr-setup',
      version: '1.0',
      baseUrl: baseUrl,
      deviceId: device.deviceId,
      apiKey: result.apiKey, // Incluir API key en el QR
      activationCode: activationCode,
      expiresAt: expiresAt.toISOString()
    };

    // Generar QR Code como imagen base64
    console.log('📱 Generando QR code para dispositivo:', device.deviceId);
    const qrCodeBase64 = await QRCode.toDataURL(JSON.stringify(qrData), {
      errorCorrectionLevel: 'M',
      type: 'image/png',
      width: 512
    });
    console.log('✅ QR code generado exitosamente, tamaño:', qrCodeBase64.length, 'caracteres');

    res.status(201).json({
      success: true,
      dispositivoID: result.dispositivoID,
      apiKey: result.apiKey, // Mostrar API key solo al crear
      qrCodeUrl: qrCodeBase64,  // Data URL: "data:image/png;base64,..."
      qrData: qrData,            // Datos para debugging
      expiresAt: expiresAt,
      message: 'Dispositivo creado exitosamente. Guarda la API key, no se mostrará nuevamente.'
    });
  } catch (error) {
    console.error('❌ Error creando dispositivo:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * PUT /api/dispositivos/:id
 * Actualiza un dispositivo
 */
router.put('/:id', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    const { nombreDispositivo, modeloDispositivo, versionApp, activo } = req.body;

    await deviceService.updateDevice(dispositivoID, {
      nombreDispositivo,
      modeloDispositivo,
      versionApp,
      activo,
      usuarioModificaID
    });

    res.json({
      success: true,
      message: 'Dispositivo actualizado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error actualizando dispositivo:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/dispositivos/:id/regenerate-key
 * Regenera la API key de un dispositivo y genera QR code
 */
router.post('/:id/regenerate-key', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    // Regenerar API key
    const newApiKey = await deviceService.regenerateApiKey(dispositivoID, usuarioModificaID);

    // Obtener dispositivo para generar QR
    const device = await deviceService.getDeviceById(dispositivoID);
    
    if (!device) {
      return res.status(404).json({
        success: false,
        error: 'Dispositivo no encontrado'
      });
    }

    // Generar código de activación y QR
    const { activationCode, expiresAt } = await deviceService.generateActivationCode(
      dispositivoID,
      undefined, // operarioNombre (opcional)
      usuarioModificaID
    );

    // Crear objeto con datos para QR
    const baseUrl = process.env.BACKEND_BASE_URL || process.env.FRONTEND_URL?.replace('/frontend', '') || 'https://luzsombra-backend.azurewebsites.net/api/';
    const qrData = {
      type: 'agriqr-setup',
      version: '1.0',
      baseUrl: baseUrl,
      deviceId: device.deviceId,
      apiKey: newApiKey, // Incluir API key en el QR
      activationCode: activationCode,
      expiresAt: expiresAt.toISOString()
    };

    // Generar QR Code como imagen base64
    console.log('📱 Generando QR code para regeneración de API key:', device.deviceId);
    const qrCodeBase64 = await QRCode.toDataURL(JSON.stringify(qrData), {
      errorCorrectionLevel: 'M',
      type: 'image/png',
      width: 512
    });
    console.log('✅ QR code generado exitosamente, tamaño:', qrCodeBase64.length, 'caracteres');

    res.json({
      success: true,
      apiKey: newApiKey,
      qrCodeUrl: qrCodeBase64,  // Data URL: "data:image/png;base64,..."
      qrData: qrData,            // Datos para debugging
      expiresAt: expiresAt,
      message: 'API key regenerada exitosamente. Guarda la nueva API key, no se mostrará nuevamente.'
    });
  } catch (error) {
    console.error('❌ Error regenerando API key:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * DELETE /api/dispositivos/:id
 * Elimina un dispositivo (soft delete)
 */
router.delete('/:id', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    await deviceService.deleteDevice(dispositivoID, usuarioModificaID);

    res.json({
      success: true,
      message: 'Dispositivo eliminado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error eliminando dispositivo:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * GET /api/dispositivos/:id/stats
 * Obtiene estadísticas de uso de un dispositivo
 */
router.get('/:id/stats', requirePermission('dispositivos:read'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    const stats = await deviceService.getDeviceStats(dispositivoID);

    res.json({
      success: true,
      stats
    });
  } catch (error) {
    console.error('❌ Error obteniendo estadísticas:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/dispositivos/:id/generate-qr
 * Genera un QR Code con código de activación temporal
 */
router.post('/:id/generate-qr', requirePermission('dispositivos:read'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const { operarioNombre } = req.body;
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    // Obtener dispositivo
    const device = await deviceService.getDeviceById(dispositivoID);
    
    if (!device) {
      return res.status(404).json({
        success: false,
        error: 'Dispositivo no encontrado'
      });
    }

    // Verificar que esté activo
    if (!device.activo) {
      return res.status(400).json({
        success: false,
        error: 'Dispositivo está desactivado'
      });
    }

    // Generar código de activación
    const { activationCode, expiresAt } = await deviceService.generateActivationCode(
      dispositivoID,
      operarioNombre,
      usuarioModificaID
    );

    // Crear objeto con datos para QR
    const baseUrl = process.env.BACKEND_BASE_URL || process.env.FRONTEND_URL?.replace('/frontend', '') || 'https://luzsombra-backend.azurewebsites.net/api/';
    const qrData = {
      type: 'agriqr-setup',
      version: '1.0',
      baseUrl: baseUrl,
      deviceId: device.deviceId,
      activationCode: activationCode,
      expiresAt: expiresAt.toISOString()
    };

    // Generar QR Code como imagen base64
    const qrCodeBase64 = await QRCode.toDataURL(JSON.stringify(qrData), {
      errorCorrectionLevel: 'M',
      type: 'image/png',
      width: 512
    });

    res.json({
      success: true,
      qrCodeUrl: qrCodeBase64,  // Data URL: "data:image/png;base64,..."
      qrData: qrData,            // Datos para debugging
      expiresAt: expiresAt,
      operarioNombre: operarioNombre || null,
      message: 'QR Code generado exitosamente. Válido por 24 horas.'
    });

  } catch (error) {
    console.error('❌ Error generando QR Code:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * PUT /api/dispositivos/:id/revoke
 * Revoca acceso de un dispositivo (desactiva)
 */
router.put('/:id/revoke', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    // Verificar que el dispositivo existe
    const device = await deviceService.getDeviceById(dispositivoID);
    if (!device) {
      return res.status(404).json({
        success: false,
        error: 'Dispositivo no encontrado'
      });
    }

    // Desactivar dispositivo y revocar acceso
    await query(`
      UPDATE evalImagen.dispositivo
      SET activo = 0,
          fechaRevocacion = GETDATE(),
          activationCode = NULL,
          activationCodeExpires = NULL,
          usuarioModificaID = @usuarioModificaID,
          fechaModificacion = GETDATE()
      WHERE dispositivoID = @dispositivoID
        AND statusID = 1
    `, { dispositivoID, usuarioModificaID });

    res.json({
      success: true,
      message: 'Acceso revocado exitosamente. El dispositivo ya no podrá autenticarse.'
    });

  } catch (error) {
    console.error('❌ Error revocando acceso:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * PUT /api/dispositivos/:id/reassign
 * Reasigna dispositivo a otro operario
 */
router.put('/:id/reassign', requirePermission('dispositivos:write'), async (req: Request, res: Response) => {
  try {
    const dispositivoID = parseInt(req.params.id);
    const { operarioNombre } = req.body;
    const usuarioModificaID = (req as any).user.usuarioID;

    if (isNaN(dispositivoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de dispositivo inválido'
      });
    }

    if (!operarioNombre || operarioNombre.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'operarioNombre es requerido'
      });
    }

    // Verificar que el dispositivo existe
    const device = await deviceService.getDeviceById(dispositivoID);
    if (!device) {
      return res.status(404).json({
        success: false,
        error: 'Dispositivo no encontrado'
      });
    }

    // Reasignar dispositivo
    await query(`
      UPDATE evalImagen.dispositivo
      SET operarioNombre = @operarioNombre,
          fechaAsignacion = GETDATE(),
          fechaRevocacion = NULL,
          activo = 1,
          activationCode = NULL,
          activationCodeExpires = NULL,
          usuarioModificaID = @usuarioModificaID,
          fechaModificacion = GETDATE()
      WHERE dispositivoID = @dispositivoID
        AND statusID = 1
    `, { dispositivoID, operarioNombre: operarioNombre.trim(), usuarioModificaID });

    res.json({
      success: true,
      message: `Dispositivo reasignado a ${operarioNombre.trim()}. Genera un nuevo QR Code para configurar.`
    });

  } catch (error) {
    console.error('❌ Error reasignando dispositivo:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

export default router;

