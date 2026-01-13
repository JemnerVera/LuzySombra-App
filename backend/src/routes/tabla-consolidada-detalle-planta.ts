import express, { Request, Response } from 'express';
import { query } from '../lib/db';

const router = express.Router();

/**
 * GET /api/tabla-consolidada/detalle-planta
 * Obtiene el detalle de plantas para un lote y fecha específica
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const { fundo, sector, lote, fecha } = req.query;

    if (!fundo || !sector || !lote || !fecha) {
      return res.status(400).json({
        success: false,
        error: 'Faltan parámetros requeridos: fundo, sector, lote, fecha'
      });
    }


    // Buscar el lotID
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

    const rows = await query<{
      hilera: string | null;
      planta: string | null;
      filename: string;
      porcentajeLuz: number;
      porcentajeSombra: number;
      analisisID: number;
      processedImageUrl: string | null;
      originalImageUrl: string | null;
    }>(`
      SELECT 
        ai.hilera,
        ai.planta,
        ai.filename,
        ai.porcentajeLuz,
        ai.porcentajeSombra,
        ai.analisisID,
        mi.processedImageUrl,
        mi.originalImageUrl
      FROM evalImagen.analisisImagen ai WITH (NOLOCK)
      LEFT JOIN evalImagen.metadataImagen mi WITH (NOLOCK) ON ai.analisisID = mi.analisisID
      WHERE ai.lotID = @lotID
        AND CAST(COALESCE(ai.fechaCaptura, ai.fechaCreacion) AS DATE) = @fecha
        AND ai.statusID = 1
      ORDER BY ai.hilera, ai.planta
    `, { lotID, fecha });

    const data = rows.map(row => ({
      hilera: row.hilera || '',
      planta: row.planta || '',
      filename: row.filename,
      porcentajeLuz: row.porcentajeLuz,
      porcentajeSombra: row.porcentajeSombra,
      analisisID: row.analisisID,
      processedImageUrl: row.processedImageUrl || null,
      originalImageUrl: row.originalImageUrl || null,
    }));

    res.json({
      success: true,
      data
    });
  } catch (error) {
    console.error('❌ [tabla-consolidada/detalle-planta] Error:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

