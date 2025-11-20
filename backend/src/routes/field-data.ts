import express from 'express';
import { sqlServerService } from '../services/sqlServerService';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const fieldData = await sqlServerService.getFieldData();
    res.json({
      success: true,
      data: fieldData
    });
  } catch (error) {
    console.error('❌ Error obteniendo field data:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

