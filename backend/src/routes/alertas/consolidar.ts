import express, { Request, Response } from 'express';
import { alertService } from '../../services/alertService';

const router = express.Router();

/**
 * POST /api/alertas/consolidar
 * Consolida alertas pendientes por fundo
 * Query params:
 *   - horasAtras: número de horas hacia atrás (default: 24)
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const horasAtras = parseInt(req.query.horasAtras as string) || 24;
    
    console.log(`🔄 Iniciando consolidación de alertas (últimas ${horasAtras} horas)...`);
    
    // Debug: Ver alertas sin mensaje primero
    const alertasSinMensaje = await alertService.getAlertasSinMensaje();
    console.log(`📊 Alertas sin mensaje encontradas: ${alertasSinMensaje.length}`);
    
    const mensajesCreados = await alertService.consolidarAlertasPorFundo(horasAtras);
    
    res.json({
      success: true,
      mensajesCreados,
      horasAtras,
      alertasSinMensaje: alertasSinMensaje.length,
      mensaje: `Se consolidaron alertas en ${mensajesCreados} mensaje(s)`
    });
  } catch (error) {
    console.error('❌ Error consolidando alertas:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/alertas/consolidar
 * Obtiene estadísticas de alertas pendientes por fundo
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const alertas = await alertService.getAlertasSinMensaje();
    
    // Agrupar por fundo
    const alertasPorFundo = new Map<string, number>();
    for (const alerta of alertas) {
      const alertaWithLocation = alerta as typeof alerta & { fundoID?: string | null };
      const fundoID = alertaWithLocation.fundoID || 'Sin fundo';
      alertasPorFundo.set(fundoID, (alertasPorFundo.get(fundoID) || 0) + 1);
    }

    const estadisticas = Array.from(alertasPorFundo.entries()).map(([fundoID, count]) => ({
      fundoID,
      totalAlertas: count
    }));

    res.json({
      success: true,
      totalAlertas: alertas.length,
      totalFundos: alertasPorFundo.size,
      estadisticasPorFundo: estadisticas
    });
  } catch (error) {
    console.error('❌ Error obteniendo estadísticas de alertas:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

