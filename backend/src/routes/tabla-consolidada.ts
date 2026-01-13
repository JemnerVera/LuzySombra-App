import express, { Request, Response } from 'express';
import { sqlServerService } from '../services/sqlServerService';

const router = express.Router();

router.get('/', async (req: Request, res: Response) => {
  try {
    const { fundo, sector, lote, page, pageSize } = req.query;

    const filters: {
      fundo?: string;
      sector?: string;
      lote?: string;
      page?: number;
      pageSize?: number;
    } = {};

    if (fundo) filters.fundo = fundo as string;
    if (sector) filters.sector = sector as string;
    if (lote) filters.lote = lote as string;
    if (page) filters.page = parseInt(page as string);
    if (pageSize) filters.pageSize = parseInt(pageSize as string);

    const result = await sqlServerService.getConsolidatedTable(filters);

    res.json(result);
  } catch (error) {
    console.error('❌ [tabla-consolidada] Error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Error desconocido al obtener tabla consolidada';
    
    res.status(500).json({
      success: false,
      error: errorMessage,
      ...(process.env.NODE_ENV === 'development' && { 
        stack: error instanceof Error ? error.stack : undefined 
      }),
    });
  }
});

export default router;

