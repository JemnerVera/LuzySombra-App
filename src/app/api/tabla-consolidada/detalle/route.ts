import { NextRequest, NextResponse } from 'next/server';
import { sqlServerService } from '@/services/sqlServerService';
import { query } from '@/lib/db';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    
    const fundo = searchParams.get('fundo');
    const sector = searchParams.get('sector');
    const lote = searchParams.get('lote');

    if (!fundo || !sector || !lote) {
      return NextResponse.json(
        {
          success: false,
          error: 'Faltan parámetros requeridos: fundo, sector, lote'
        },
        { status: 400 }
      );
    }

    console.log(`📊 [tabla-consolidada/detalle] Obteniendo lotID para: ${fundo} - ${sector} - ${lote}`);

    // Buscar el lotID desde el nombre del lote, sector y fundo
    const lotResult = await query<{ lotID: number }>(`
      SELECT l.lotID
      FROM GROWER.LOT l WITH (NOLOCK)
      INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
      INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
      WHERE f.Description = @fundo
        AND s.stage = @sector
        AND l.name = @lote
        AND l.statusID = 1
        AND s.statusID = 1
        AND f.statusID = 1
    `, { fundo, sector, lote });

    if (!lotResult || lotResult.length === 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Lote no encontrado'
        },
        { status: 404 }
      );
    }

    const lotID = lotResult[0].lotID;
    console.log(`📊 [tabla-consolidada/detalle] lotID encontrado: ${lotID}`);

    // Obtener el detalle histórico
    const result = await sqlServerService.getLoteDetalleHistorial(lotID);

    return NextResponse.json(result, { status: 200 });
  } catch (error) {
    console.error('❌ [tabla-consolidada/detalle] Error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Error desconocido al obtener detalle histórico';
    const errorStack = error instanceof Error ? error.stack : undefined;
    
    return NextResponse.json(
      {
        success: false,
        error: errorMessage,
        ...(process.env.NODE_ENV === 'development' && { stack: errorStack }),
      },
      { status: 500 }
    );
  }
}
