import express from 'express';
import { sqlServerService } from '../services/sqlServerService';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const { empresa, fundo, sector, lote, fechaDesde, fechaHasta, porcentajeLuzMin, porcentajeLuzMax, page, pageSize, limit } = req.query;

    const filters: {
      empresa?: string;
      fundo?: string;
      sector?: string;
      lote?: string;
      fechaDesde?: string;
      fechaHasta?: string;
      porcentajeLuzMin?: number;
      porcentajeLuzMax?: number;
      page?: number;
      pageSize?: number;
      limit?: number;
    } = {};

    if (empresa) filters.empresa = empresa as string;
    if (fundo) filters.fundo = fundo as string;
    if (sector) filters.sector = sector as string;
    if (lote) filters.lote = lote as string;
    if (fechaDesde) filters.fechaDesde = fechaDesde as string;
    if (fechaHasta) filters.fechaHasta = fechaHasta as string;
    if (porcentajeLuzMin) filters.porcentajeLuzMin = parseFloat(porcentajeLuzMin as string);
    if (porcentajeLuzMax) filters.porcentajeLuzMax = parseFloat(porcentajeLuzMax as string);
    if (page) filters.page = parseInt(page as string);
    if (pageSize) filters.pageSize = parseInt(pageSize as string);
    if (limit) filters.limit = parseInt(limit as string);

    const result = await sqlServerService.getHistorial(filters);

    res.json(result);
  } catch (error) {
    console.error('❌ Error obteniendo historial:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

