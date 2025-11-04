import { NextResponse } from 'next/server';
import { sqlServerService } from '@/services/sqlServerService';

/**
 * GET /api/historial
 * 
 * Obtiene el historial de procesamientos de imágenes desde SQL Server
 * 
 * Query params opcionales:
 * - empresa: filtrar por empresa
 * - fundo: filtrar por fundo
 * - sector: filtrar por sector
 * - lote: filtrar por lote
 * - page: número de página (default 1)
 * - pageSize: registros por página (default 50, max 500)
 * - limit: límite de registros (obsoleto, usar pageSize)
 */
export async function GET(request: Request) {
  const startTime = Date.now();

  try {
    // Obtener query params
    const { searchParams } = new URL(request.url);
    const page = searchParams.get('page') ? parseInt(searchParams.get('page')!) : 1;
    const pageSizeParam = searchParams.get('pageSize') || searchParams.get('limit');
    const pageSize = pageSizeParam ? Math.min(parseInt(pageSizeParam), 500) : 50; // Max 500 por página
    
    const filters = {
      empresa: searchParams.get('empresa') || undefined,
      fundo: searchParams.get('fundo') || undefined,
      sector: searchParams.get('sector') || undefined,
      lote: searchParams.get('lote') || undefined,
      page,
      pageSize
    };

    console.log(`📊 [historial] Fetching from SQL Server, Filters:`, filters);

    const historial = await sqlServerService.getHistorial(filters);
    const responseTime = Date.now() - startTime;
    
    console.log(`✅ [historial] SQL Server response in ${responseTime}ms (${historial.procesamientos.length} records)`);
    
    return NextResponse.json({
      ...historial,
      source: 'sql_server',
      responseTime,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ [historial] Error:', error);
    const responseTime = Date.now() - startTime;
    
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        responseTime,
        timestamp: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}
