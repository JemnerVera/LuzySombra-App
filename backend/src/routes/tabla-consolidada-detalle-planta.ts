import express, { Request, Response } from 'express';
import { query } from '../lib/db';

const router = express.Router();

/**
 * GET /api/tabla-consolidada/detalle-planta
 * Obtiene el detalle de plantas para un lote y fecha específica
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const lotID = req.query.lotID ? parseInt(req.query.lotID as string) : undefined;
    const fecha = req.query.fecha as string;

    if (!lotID || isNaN(lotID)) {
      return res.status(400).json({
        success: false,
        error: 'lotID es requerido y debe ser un número válido'
      });
    }

    if (!fecha) {
      return res.status(400).json({
        success: false,
        error: 'fecha es requerida (formato: YYYY-MM-DD)'
      });
    }

    console.log(`📊 [tabla-consolidada/detalle-planta] Obteniendo plantas para lotID: ${lotID}, fecha: ${fecha}`);

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
        ai.processedImageUrl,
        ai.originalImageUrl
      FROM image.Analisis_Imagen ai WITH (NOLOCK)
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

