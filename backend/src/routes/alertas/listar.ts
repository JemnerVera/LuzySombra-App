import express, { Request, Response } from 'express';
import { alertService } from '../../services/alertService';

const router = express.Router();

/**
 * GET /api/alertas
 * Obtiene todas las alertas con filtros opcionales
 * Query params:
 *   - estado: Pendiente, Enviada, Resuelta, Ignorada
 *   - tipoUmbral: CriticoRojo, CriticoAmarillo, Normal
 *   - fundoID: ID del fundo
 *   - fechaDesde: Fecha desde (ISO string)
 *   - fechaHasta: Fecha hasta (ISO string)
 *   - page: Número de página (default: 1)
 *   - pageSize: Tamaño de página (default: 50)
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const {
      estado,
      tipoUmbral,
      fundoID,
      fechaDesde,
      fechaHasta,
      page,
      pageSize
    } = req.query;

    const filters: any = {};
    if (estado) filters.estado = estado;
    if (tipoUmbral) filters.tipoUmbral = tipoUmbral;
    if (fundoID) filters.fundoID = fundoID as string;
    if (fechaDesde) filters.fechaDesde = new Date(fechaDesde as string);
    if (fechaHasta) filters.fechaHasta = new Date(fechaHasta as string);
    if (page) filters.page = parseInt(page as string);
    if (pageSize) filters.pageSize = parseInt(pageSize as string);

    const result = await alertService.getAllAlertas(filters);

    res.json({
      success: true,
      ...result
    });
  } catch (error) {
    console.error('❌ Error obteniendo alertas:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/alertas/estadisticas
 * Obtiene estadísticas de alertas
 */
router.get('/estadisticas', async (req: Request, res: Response) => {
  try {
    const stats = await alertService.getEstadisticasAlertas();

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('❌ Error obteniendo estadísticas:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * PUT /api/alertas/:id/resolver
 * Resuelve una alerta
 */
router.put('/:id/resolver', async (req: Request, res: Response) => {
  try {
    const alertaID = parseInt(req.params.id);
    const { usuarioResolvioID, notas } = req.body;

    if (isNaN(alertaID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de alerta inválido'
      });
    }

    if (!usuarioResolvioID) {
      return res.status(400).json({
        success: false,
        error: 'usuarioResolvioID es requerido'
      });
    }

    await alertService.resolverAlerta(alertaID, parseInt(usuarioResolvioID), notas);

    res.json({
      success: true,
      message: 'Alerta resuelta exitosamente'
    });
  } catch (error) {
    console.error('❌ Error resolviendo alerta:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * PUT /api/alertas/:id/ignorar
 * Ignora una alerta
 */
router.put('/:id/ignorar', async (req: Request, res: Response) => {
  try {
    const alertaID = parseInt(req.params.id);
    const { usuarioResolvioID, notas } = req.body;

    if (isNaN(alertaID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de alerta inválido'
      });
    }

    if (!usuarioResolvioID) {
      return res.status(400).json({
        success: false,
        error: 'usuarioResolvioID es requerido'
      });
    }

    await alertService.ignorarAlerta(alertaID, parseInt(usuarioResolvioID), notas);

    res.json({
      success: true,
      message: 'Alerta ignorada exitosamente'
    });
  } catch (error) {
    console.error('❌ Error ignorando alerta:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

