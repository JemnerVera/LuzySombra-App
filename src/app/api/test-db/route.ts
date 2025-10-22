import { NextResponse } from 'next/server';
import { query } from '../../../lib/db';

export async function GET() {
  try {
    // Test: Contar registros en todas las tablas principales
    const counts = await query(`
      SELECT 
        (SELECT COUNT(*) FROM image.pais WHERE statusid = 1) as paises,
        (SELECT COUNT(*) FROM image.empresa WHERE statusid = 1) as empresas,
        (SELECT COUNT(*) FROM image.fundo WHERE statusid = 1) as fundos,
        (SELECT COUNT(*) FROM image.sector WHERE statusid = 1) as sectores,
        (SELECT COUNT(*) FROM image.lote WHERE statusid = 1) as lotes,
        (SELECT COUNT(*) FROM image.usuario WHERE activo = 1) as usuarios,
        (SELECT COUNT(*) FROM image.estado_fenologico WHERE statusid = 1) as estados_fenologicos,
        (SELECT COUNT(*) FROM image.tipo_alerta WHERE statusid = 1) as tipos_alerta
    `);

    // Test: Obtener algunas empresas como ejemplo
    const empresas = await query(`
      SELECT TOP 5 empresaid, empresabrev, empresa 
      FROM image.empresa 
      WHERE statusid = 1
      ORDER BY empresa
    `);

    return NextResponse.json({
      success: true,
      message: 'Conexión exitosa a SQL Server',
      timestamp: new Date().toISOString(),
      database: 'AgricolaDB',
      counts: counts[0],
      sample_empresas: empresas,
    });
  } catch (error: any) {
    console.error('Error en test-db:', error);
    
    return NextResponse.json(
      {
        success: false,
        message: 'Error conectando a SQL Server',
        error: error.message,
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
      },
      { status: 500 }
    );
  }
}
