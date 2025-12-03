import express from 'express';
import { query, connectDb } from '../lib/db';
import dotenv from 'dotenv';

dotenv.config();

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const connection = await connectDb();
    
    // Verificar información de la conexión
    const serverInfo = await query<{
      Version: string;
      CurrentDatabase: string;
      CurrentUser: string;
      ServerName: string;
    }>(`
      SELECT 
        @@VERSION AS Version,
        DB_NAME() AS CurrentDatabase,
        SYSTEM_USER AS CurrentUser,
        @@SERVERNAME AS ServerName
    `);
    
    // Probar query de conteo
    const result = await query<{
      total_lotes: number;
      total_analisis: number;
      total_alertas: number;
    }>(`
      SELECT 
        (SELECT COUNT(*) FROM GROWER.LOT WHERE statusID = 1) as total_lotes,
        (SELECT COUNT(*) FROM evalImagen.analisisImagen WHERE statusID = 1) as total_analisis,
        (SELECT COUNT(*) FROM evalImagen.alerta WHERE statusID = 1) as total_alertas
    `);
    
    res.json({
      success: true,
      message: 'Conexión a base de datos exitosa',
      serverInfo: {
        serverName: serverInfo[0]?.ServerName,
        currentDatabase: serverInfo[0]?.CurrentDatabase,
        currentUser: serverInfo[0]?.CurrentUser,
        version: serverInfo[0]?.Version?.substring(0, 50) + '...',
      },
      data: result[0]
    });
  } catch (error: any) {
    console.error('❌ [TEST-DB] Error:', error.message || error);
    
    const errorResponse: any = {
      success: false,
      message: 'Error conectando a base de datos',
      error: error.message || 'Unknown error',
      errorCode: error.code || 'UNKNOWN',
    };
    
    // Agregar información de diagnóstico solo si es necesario
    if (error.code === 'ESOCKET') {
      errorResponse.diagnosis = {
        type: 'Socket Error',
        suggestion: 'Verificar VPN conectada y accesibilidad del servidor'
      };
    } else if (error.code === 'ELOGIN') {
      errorResponse.diagnosis = {
        type: 'Authentication Error',
        suggestion: 'Verificar credenciales en .env'
      };
    }
    
    res.status(500).json(errorResponse);
  }
});

export default router;

