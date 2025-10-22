import { NextResponse } from 'next/server';
import { sqlServerService } from '@/services/sqlServerService';
import { googleSheetsService } from '@/services/googleSheetsService';

/**
 * GET /api/historial
 * 
 * Obtiene el historial de procesamientos de imágenes
 * Prioriza SQL Server, con fallback a Google Sheets
 * 
 * Query params opcionales:
 * - empresa: filtrar por empresa
 * - fundo: filtrar por fundo
 * - sector: filtrar por sector
 * - lote: filtrar por lote
 * - limit: límite de registros (default 500)
 */
export async function GET(request: Request) {
  const startTime = Date.now();
  const dataSource = process.env.DATA_SOURCE || 'sql'; // 'sql', 'sheets', 'hybrid'

  try {
    // Obtener query params
    const { searchParams } = new URL(request.url);
    const filters = {
      empresa: searchParams.get('empresa') || undefined,
      fundo: searchParams.get('fundo') || undefined,
      sector: searchParams.get('sector') || undefined,
      lote: searchParams.get('lote') || undefined,
      limit: searchParams.get('limit') ? parseInt(searchParams.get('limit')!) : undefined
    };

    console.log(`📊 [historial] Data source: ${dataSource}, Filters:`, filters);

    // Intentar SQL Server primero (a menos que esté configurado solo para Sheets)
    if (dataSource !== 'sheets') {
      try {
        const historial = await sqlServerService.getHistorial(filters);
        const responseTime = Date.now() - startTime;
        
        console.log(`✅ [historial] SQL Server response in ${responseTime}ms (${historial.procesamientos.length} records)`);
        
        return NextResponse.json({
          ...historial,
          source: 'sql_server',
          responseTime,
          timestamp: new Date().toISOString()
        });
      } catch (sqlError) {
        console.error('❌ [historial] SQL Server error:', sqlError);
        
        // Si es modo híbrido, intentar con Google Sheets
        if (dataSource === 'hybrid' || dataSource === 'sql') {
          console.log('🔄 [historial] Fallback to Google Sheets...');
        } else {
          // Si es solo SQL, lanzar error
          throw sqlError;
        }
      }
    }

    // Fallback o modo Sheets (Google Sheets no soporta filtros avanzados)
    const historial = await googleSheetsService.getHistorial();
    const responseTime = Date.now() - startTime;
    
    console.log(`✅ [historial] Google Sheets response in ${responseTime}ms (${historial.procesamientos.length} records)`);
    
    return NextResponse.json({
      ...historial,
      source: 'google_sheets',
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
