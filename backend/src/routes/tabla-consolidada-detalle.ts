import express, { Request, Response } from 'express';
import { sqlServerService } from '../services/sqlServerService';

const router = express.Router();

/**
 * GET /api/tabla-consolidada/detalle
 * Obtiene el detalle histórico de evaluaciones agrupadas por fecha para un lote
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const lotID = req.query.lotID ? parseInt(req.query.lotID as string) : undefined;

    if (!lotID || isNaN(lotID)) {
      return res.status(400).json({
        success: false,
        error: 'lotID es requerido y debe ser un número válido'
      });
    }

    console.log(`📊 [tabla-consolidada/detalle] Obteniendo detalle histórico para lotID: ${lotID}`);

    const result = await sqlServerService.getLoteDetalleHistorial(lotID);

    res.json(result);
  } catch (error) {
    console.error('❌ [tabla-consolidada/detalle] Error:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

