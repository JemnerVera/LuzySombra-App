import express, { Request, Response } from 'express';
import { authenticateWebUser } from '../middleware/auth-web';
import { query } from '../lib/db';

const router = express.Router();

/**
 * GET /api/notificaciones/contador
 * Obtiene el número de alertas nuevas desde la última consulta
 * 
 * Query params:
 * - ultimaConsulta: Timestamp de la última consulta (opcional)
 */
router.get('/contador', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    const ultimaConsulta = req.query.ultimaConsulta 
      ? new Date(parseInt(req.query.ultimaConsulta as string))
      : new Date(Date.now() - 24 * 60 * 60 * 1000); // Últimas 24 horas por defecto

    // Contar alertas nuevas (pendientes o enviadas)
    const result = await query<{ total: number }>(`
      SELECT COUNT(*) as total
      FROM evalImagen.alerta
      WHERE estado IN ('Pendiente', 'Enviada')
        AND fechaCreacion > @ultimaConsulta
        AND statusID = 1
    `, { ultimaConsulta });

    const nuevasAlertas = result.length > 0 ? result[0].total : 0;

    res.json({
      success: true,
      nuevasAlertas,
      timestamp: Date.now()
    });
  } catch (error) {
    console.error('❌ Error obteniendo contador de notificaciones:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * GET /api/notificaciones/lista
 * Obtiene lista de notificaciones recientes
 * 
 * Query params:
 * - limit: Número de notificaciones a retornar (default: 10)
 */
router.get('/lista', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    const limit = parseInt(req.query.limit as string) || 10;

    const notificaciones = await query<{
      alertaID: number;
      tipoUmbral: string;
      severidad: string;
      estado: string;
      fechaCreacion: Date;
      porcentajeLuzEvaluado: number;
      lotID: number;
    }>(`
      SELECT TOP (@limit)
        a.alertaID,
        a.tipoUmbral,
        a.severidad,
        a.estado,
        a.fechaCreacion,
        a.porcentajeLuzEvaluado,
        a.lotID
      FROM evalImagen.alerta a
      WHERE a.statusID = 1
      ORDER BY a.fechaCreacion DESC
    `, { limit });

    res.json({
      success: true,
      notificaciones: notificaciones.map(n => ({
        id: n.alertaID,
        tipo: n.tipoUmbral,
        severidad: n.severidad,
        estado: n.estado,
        fecha: n.fechaCreacion,
        porcentajeLuz: n.porcentajeLuzEvaluado,
        lotID: n.lotID
      }))
    });
  } catch (error) {
    console.error('❌ Error obteniendo lista de notificaciones:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

export default router;

