import express, { Request, Response } from 'express';
import { query } from '../../lib/db';

const router = express.Router();

/**
 * GET /api/alertas/mensajes
 * Obtiene mensajes consolidados (pendientes y enviados)
 * Query params:
 *   - estado: Pendiente, Enviando, Enviado, Error
 *   - fundoID: ID del fundo
 *   - page: Número de página (default: 1)
 *   - pageSize: Tamaño de página (default: 50)
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const { estado, fundoID, page = '1', pageSize = '50' } = req.query;
    
    const pageNum = parseInt(page as string);
    const pageSizeNum = parseInt(pageSize as string);
    const offset = (pageNum - 1) * pageSizeNum;

    const condiciones: string[] = ['m.statusID = 1'];
    const params: Record<string, unknown> = { offset, pageSize: pageSizeNum };

    if (estado) {
      condiciones.push('m.estado = @estado');
      params.estado = estado;
    }

    if (fundoID) {
      condiciones.push('RTRIM(m.fundoID) = @fundoID');
      params.fundoID = (fundoID as string).trim();
    }

    const whereClause = condiciones.length > 0 ? 'WHERE ' + condiciones.join(' AND ') : '';

    // Query para obtener mensajes con información del fundo
    const mensajes = await query<{
      mensajeID: number;
      fundoID: string | null;
      fundoNombre: string | null;
      tipoMensaje: string;
      asunto: string;
      estado: string;
      fechaCreacion: Date;
      fechaEnvio: Date | null;
      intentosEnvio: number;
      resendMessageID: string | null;
      errorMessage: string | null;
      totalAlertas: number;
    }>(`
      SELECT 
        m.mensajeID,
        m.fundoID,
        f.Description AS fundoNombre,
        m.tipoMensaje,
        m.asunto,
        m.estado,
        m.fechaCreacion,
        m.fechaEnvio,
        m.intentosEnvio,
        m.resendMessageID,
        m.errorMessage,
        COUNT(DISTINCT ma.alertaID) AS totalAlertas
      FROM evalImagen.mensaje m
      LEFT JOIN GROWER.FARMS f ON RTRIM(m.fundoID) = f.farmID
      LEFT JOIN evalImagen.mensajeAlerta ma ON m.mensajeID = ma.mensajeID AND ma.statusID = 1
      ${whereClause}
      GROUP BY 
        m.mensajeID,
        m.fundoID,
        f.Description,
        m.tipoMensaje,
        m.asunto,
        m.estado,
        m.fechaCreacion,
        m.fechaEnvio,
        m.intentosEnvio,
        m.resendMessageID,
        m.errorMessage
      ORDER BY m.fechaCreacion DESC
      OFFSET @offset ROWS
      FETCH NEXT @pageSize ROWS ONLY
    `, params);

    // Query para contar total
    const countResult = await query<{ total: number }>(`
      SELECT COUNT(DISTINCT m.mensajeID) AS total
      FROM evalImagen.mensaje m
      ${whereClause}
    `, params);

    const total = countResult[0]?.total || 0;
    const totalPages = Math.ceil(total / pageSizeNum);

    res.json({
      success: true,
      mensajes,
      total,
      page: pageNum,
      pageSize: pageSizeNum,
      totalPages
    });
  } catch (error) {
    console.error('❌ Error obteniendo mensajes:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/alertas/mensajes/:id
 * Obtiene detalles de un mensaje específico con sus alertas asociadas
 */
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const mensajeID = parseInt(req.params.id);

    if (isNaN(mensajeID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de mensaje inválido'
      });
    }

    // Obtener mensaje
    const mensaje = await query<{
      mensajeID: number;
      fundoID: string | null;
      fundoNombre: string | null;
      tipoMensaje: string;
      asunto: string;
      cuerpoHTML: string;
      cuerpoTexto: string | null;
      destinatarios: string;
      estado: string;
      fechaCreacion: Date;
      fechaEnvio: Date | null;
      intentosEnvio: number;
      resendMessageID: string | null;
      errorMessage: string | null;
    }>(`
      SELECT 
        m.mensajeID,
        m.fundoID,
        f.Description AS fundoNombre,
        m.tipoMensaje,
        m.asunto,
        m.cuerpoHTML,
        m.cuerpoTexto,
        m.destinatarios,
        m.estado,
        m.fechaCreacion,
        m.fechaEnvio,
        m.intentosEnvio,
        m.resendMessageID,
        m.errorMessage
      FROM evalImagen.mensaje m
      LEFT JOIN GROWER.FARMS f ON RTRIM(m.fundoID) = f.farmID
      WHERE m.mensajeID = @mensajeID
        AND m.statusID = 1
    `, { mensajeID });

    if (mensaje.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Mensaje no encontrado'
      });
    }

    // Obtener alertas asociadas
    const alertas = await query<{
      alertaID: number;
      lotID: number;
      loteNombre: string;
      sectorNombre: string;
      tipoUmbral: string;
      porcentajeLuzEvaluado: number;
      fechaCreacion: Date;
    }>(`
      SELECT 
        a.alertaID,
        a.lotID,
        l.name AS loteNombre,
        s.stage AS sectorNombre,
        a.tipoUmbral,
        a.porcentajeLuzEvaluado,
        a.fechaCreacion
      FROM evalImagen.mensajeAlerta ma
      INNER JOIN evalImagen.alerta a ON ma.alertaID = a.alertaID
      INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
      INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
      WHERE ma.mensajeID = @mensajeID
        AND ma.statusID = 1
        AND a.statusID = 1
      ORDER BY a.fechaCreacion DESC
    `, { mensajeID });

    res.json({
      success: true,
      mensaje: mensaje[0],
      alertas
    });
  } catch (error) {
    console.error('❌ Error obteniendo mensaje:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

