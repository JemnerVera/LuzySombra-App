import express, { Request, Response } from 'express';
import { resendService } from '../../services/resendService';

const router = express.Router();

/**
 * POST /api/alertas/enviar
 * Procesa mensajes pendientes y los envía vía Resend API
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    console.log('📧 Iniciando envío de mensajes pendientes...');
    const resultado = await resendService.processPendingMensajes();
    
    res.json({
      success: true,
      exitosos: resultado.exitosos,
      errores: resultado.errores,
      mensaje: `Procesados ${resultado.exitosos + resultado.errores} mensaje(s): ${resultado.exitosos} exitoso(s), ${resultado.errores} error(es)`
    });
  } catch (error) {
    console.error('❌ Error enviando mensajes:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/alertas/enviar/:mensajeID
 * Envía un mensaje específico por ID
 */
router.post('/:mensajeID', async (req: Request, res: Response) => {
  try {
    const mensajeID = parseInt(req.params.mensajeID);
    
    if (isNaN(mensajeID)) {
      return res.status(400).json({
        success: false,
        error: 'mensajeID debe ser un número'
      });
    }

    console.log(`📧 Enviando mensaje ${mensajeID}...`);
    const exito = await resendService.enviarMensajePorID(mensajeID);
    
    if (exito) {
      res.json({
        success: true,
        mensaje: `Mensaje ${mensajeID} enviado exitosamente`
      });
    } else {
      res.status(500).json({
        success: false,
        error: `Error enviando mensaje ${mensajeID}`
      });
    }
  } catch (error) {
    console.error('❌ Error enviando mensaje:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

