import { NextRequest, NextResponse } from 'next/server';
import { sqlServerService } from '@/services/sqlServerService';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    
    const filters = {
      fundo: searchParams.get('fundo') || undefined,
      sector: searchParams.get('sector') || undefined,
      lote: searchParams.get('lote') || undefined,
      page: parseInt(searchParams.get('page') || '1', 10),
      pageSize: parseInt(searchParams.get('pageSize') || '50', 10),
    };

    console.log('📊 [tabla-consolidada] Fetching consolidated table with filters:', filters);

    const result = await sqlServerService.getConsolidatedTable(filters);

    console.log('✅ [tabla-consolidada] Success:', {
      records: result.data.length,
      total: result.total,
      page: result.page,
      totalPages: result.totalPages
    });

    return NextResponse.json(result, { status: 200 });
  } catch (error) {
    console.error('❌ [tabla-consolidada] Error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Error desconocido al obtener tabla consolidada';
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
