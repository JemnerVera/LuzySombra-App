import { NextResponse } from 'next/server';
import { query } from '../../../lib/db';

export async function GET() {
  try {
    // Test: Contar registros en tablas GROWER y MAST de AgroMigiva
    const counts = await query(`
      SELECT 
        (SELECT COUNT(*) FROM GROWER.GROWERS WHERE statusID = 1) as empresas,
        (SELECT COUNT(*) FROM GROWER.FARMS WHERE statusID = 1) as fundos,
        (SELECT COUNT(*) FROM GROWER.STAGE WHERE statusID = 1) as sectores,
        (SELECT COUNT(*) FROM GROWER.LOT WHERE statusID = 1) as lotes,
        (SELECT COUNT(*) FROM MAST.USERS WHERE statusID = 1) as usuarios,
        (SELECT COUNT(*) FROM IMAGE.ANALISIS_IMAGEN WHERE statusID = 1) as analisis_imagenes
    `);

    // Test: Obtener algunas empresas como ejemplo
    const empresas = await query(`
      SELECT TOP 5 growerID, abbreviation, businessName as empresa
      FROM GROWER.GROWERS 
      WHERE statusID = 1
      ORDER BY businessName
    `);

    return NextResponse.json({
      success: true,
      message: 'Conexión exitosa a SQL Server',
      timestamp: new Date().toISOString(),
      database: process.env.SQL_DATABASE || 'unknown',
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
