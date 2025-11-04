import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    
    const fundo = searchParams.get('fundo');
    const sector = searchParams.get('sector');
    const lote = searchParams.get('lote');
    const fecha = searchParams.get('fecha');

    if (!fundo || !sector || !lote || !fecha) {
      return NextResponse.json(
        {
          success: false,
          error: 'Faltan parámetros requeridos: fundo, sector, lote, fecha'
        },
        { status: 400 }
      );
    }

    console.log(`📊 [tabla-consolidada/detalle-planta] Obteniendo plantas para: ${fundo} - ${sector} - ${lote} - ${fecha}`);

    // Buscar el lotID
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

    // Obtener las entradas individuales para esa fecha
            const rows = await query<{
          analisisID: number;
          hilera: string | null;
          planta: string | null;
          porcentajeLuz: number;
          porcentajeSombra: number;
          filename: string;
          fechaCaptura: Date | null;
          processedImageUrl: string | null;
          originalImageUrl: string | null;
        }>(`
          SELECT
            ai.analisisID,
            ai.hilera,
            ai.planta,
            ai.porcentajeLuz,
            ai.porcentajeSombra,
            ai.filename,
            ai.fechaCaptura,
            ai.processedImageUrl,
            ai.originalImageUrl
          FROM image.Analisis_Imagen ai WITH (NOLOCK)
          WHERE ai.lotID = @lotID
            AND ai.statusID = 1
            AND CAST(COALESCE(ai.fechaCaptura, ai.fechaCreacion) AS DATE) = CAST(@fecha AS DATE)
          ORDER BY ai.hilera, ai.planta, ai.fechaCreacion
        `, { lotID, fecha });

        const data = rows.map(row => ({
          analisisID: row.analisisID,
          hilera: row.hilera || '-',
          planta: row.planta || '-',
          porcentajeLuz: row.porcentajeLuz,
          porcentajeSombra: row.porcentajeSombra,
          filename: row.filename,
          fechaCaptura: row.fechaCaptura?.toISOString() || null,
          processedImageUrl: row.processedImageUrl || null,
          originalImageUrl: row.originalImageUrl || null,
        }));

    console.log(`✅ [tabla-consolidada/detalle-planta] Obtenidas ${data.length} plantas para lotID ${lotID}, fecha ${fecha}`);

    return NextResponse.json({
      success: true,
      data
    }, { status: 200 });
  } catch (error) {
    console.error('❌ [tabla-consolidada/detalle-planta] Error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Error desconocido al obtener detalle de plantas';
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
