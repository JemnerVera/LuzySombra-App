import express, { Request, Response } from 'express';
import { sqlServerService } from '../services/sqlServerService';

const router = express.Router();

// Get statistics
router.get('/', async (req: Request, res: Response) => {
  try {
    // Get basic statistics from SQL Server
    const stats = await sqlServerService.getStatistics();
    
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('❌ Error getting statistics:', error);
    res.status(500).json({
      success: false,
      error: 'Error getting statistics',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

