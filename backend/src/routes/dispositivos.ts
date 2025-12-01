import express, { Request, Response } from 'express';
import { authenticateWebUser, requirePermission } from '../middleware/auth-web';
import { deviceService } from '../services/deviceService';

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

    res.status(201).json({
      success: true,
      dispositivoID: result.dispositivoID,
      apiKey: result.apiKey, // Mostrar API key solo al crear
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
 * Regenera la API key de un dispositivo
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

    const newApiKey = await deviceService.regenerateApiKey(dispositivoID, usuarioModificaID);

    res.json({
      success: true,
      apiKey: newApiKey,
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

export default router;

