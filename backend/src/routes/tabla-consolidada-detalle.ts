import express, { Request, Response } from 'express';
import { query } from '../lib/db';
import { sqlServerService } from '../services/sqlServerService';

const router = express.Router();

/**
 * GET /api/tabla-consolidada/detalle
 * Obtiene el detalle histórico de evaluaciones agrupadas por fecha para un lote
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const { fundo, sector, lote } = req.query;

    if (!fundo || !sector || !lote) {
      return res.status(400).json({
        success: false,
        error: 'Faltan parámetros requeridos: fundo, sector, lote'
      });
    }


    // Buscar el lotID desde el nombre del lote, sector y fundo
    const lotResult = await query<{ lotID: number }>(`
      SELECT l.lotID
      FROM GROWER.LOT l WITH (NOLOCK)
      INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
      INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
      WHERE f.Description = @fundo
        AND s.stage = @sector
        AND l.name = @lote
        AND l.statusID = 1
        AND s.statusID = 1
        AND f.statusID = 1
    `, { fundo, sector, lote });

    if (!lotResult || lotResult.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Lote no encontrado'
      });
    }

    const lotID = lotResult[0].lotID;

    // Obtener el detalle histórico
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

