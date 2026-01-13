import express, { Request, Response } from 'express';
import { query } from '../lib/db';

const router = express.Router();

/**
 * GET /api/lot-info/:lotID
 * Obtiene información del lote (empresa, fundo, sector, lote) desde lotID
 */
router.get('/:lotID', async (req: Request, res: Response) => {
  try {
    const lotID = parseInt(req.params.lotID);
    
    if (isNaN(lotID) || lotID <= 0) {
      return res.status(400).json({
        success: false,
        error: 'lotID inválido'
      });
    }

    // Primero verificar si el lote existe (sin filtros de status)
    const lotExists = await query<{ lotID: number; statusID: number; name: string }>(`
      SELECT lotID, statusID, name
      FROM GROWER.LOT WITH (NOLOCK)
      WHERE lotID = @lotID
    `, { lotID });

    if (!lotExists || lotExists.length === 0) {
      return res.status(404).json({
        success: false,
        error: `No se encontró el lote con lotID=${lotID} en la base de datos`
      });
    }

    // Ahora hacer la query completa con joins
    const lotInfo = await query<{
      empresa: string;
      fundo: string;
      sector: string;
      lote: string;
      lotStatusID: number;
      stageStatusID: number;
      farmStatusID: number;
      growerStatusID: number;
    }>(`
      SELECT 
        g.businessName as empresa,
        f.Description as fundo,
        s.stage as sector,
        l.name as lote,
        l.statusID as lotStatusID,
        s.statusID as stageStatusID,
        f.statusID as farmStatusID,
        g.statusID as growerStatusID
      FROM GROWER.LOT l WITH (NOLOCK)
      INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
      INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
      INNER JOIN GROWER.GROWERS g WITH (NOLOCK) ON s.growerID = g.growerID
      WHERE l.lotID = @lotID
    `, { lotID });

    if (!lotInfo || lotInfo.length === 0) {
      return res.status(404).json({
        success: false,
        error: `No se encontró información completa de lote para lotID=${lotID}. Verifique que el lote tenga stage, farm y grower asociados.`
      });
    }

    const result = lotInfo[0];
    
    // Verificar status de cada entidad
    const statusCheck = {
      lot: result.lotStatusID === 1,
      stage: result.stageStatusID === 1,
      farm: result.farmStatusID === 1,
      grower: result.growerStatusID === 1
    };

    // Devolver información incluso si no está activo, pero con warning
    if (!statusCheck.lot || !statusCheck.stage || !statusCheck.farm || !statusCheck.grower) {
      // Devolver la información de todas formas, pero con un warning
      return res.json({
        success: true,
        warning: `El lote lotID=${lotID} existe pero algunos elementos relacionados no están activos`,
        details: statusCheck,
        data: {
          empresa: result.empresa,
          fundo: result.fundo,
          sector: result.sector,
          lote: result.lote
        }
      });
    }

    res.json({
      success: true,
      data: {
        empresa: result.empresa,
        fundo: result.fundo,
        sector: result.sector,
        lote: result.lote
      }
    });
  } catch (error) {
    console.error('❌ Error getting lot info:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

