import express from 'express';
import { query } from '../lib/db';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const result = await query<{
      total_lotes: number;
      total_analisis: number;
      total_alertas: number;
    }>(`
      SELECT 
        (SELECT COUNT(*) FROM GROWER.LOT WHERE statusID = 1) as total_lotes,
        (SELECT COUNT(*) FROM image.Analisis_Imagen WHERE statusID = 1) as total_analisis,
        (SELECT COUNT(*) FROM image.Alerta WHERE statusID = 1) as total_alertas
    `);

    res.json({
      success: true,
      data: result[0]
    });
  } catch (error) {
    console.error('❌ Error testing database:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

