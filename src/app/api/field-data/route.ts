import { NextResponse } from 'next/server';
import { sqlServerService } from '@/services/sqlServerService';
import { googleSheetsService } from '@/services/googleSheetsService';

/**
 * GET /api/field-data
 * 
 * Obtiene los datos de jerarquía (empresa, fundo, sector, lote)
 * Prioriza SQL Server, con fallback a Google Sheets
 */
export async function GET() {
  const startTime = Date.now();
  const dataSource = process.env.DATA_SOURCE || 'sql'; // 'sql', 'sheets', 'hybrid'

  try {
    console.log(`📊 [field-data] Data source: ${dataSource}`);

    // Intentar SQL Server primero (a menos que esté configurado solo para Sheets)
    if (dataSource !== 'sheets') {
      try {
        const fieldData = await sqlServerService.getFieldData();
        const responseTime = Date.now() - startTime;
        
        console.log(`✅ [field-data] SQL Server response in ${responseTime}ms`);
        console.log(`📊 [field-data] Data summary:`, {
          empresas: fieldData.empresa?.length || 0,
          fundos: fieldData.fundo?.length || 0,
          sectores: fieldData.sector?.length || 0,
          lotes: fieldData.lote?.length || 0,
          sampleEmpresas: fieldData.empresa?.slice(0, 3) || [],
          sampleFundos: fieldData.fundo?.slice(0, 3) || []
        });
        
        // Preparar respuesta
        const jsonStartTime = Date.now();
        const responseData = {
          success: true,
          source: 'sql_server',
          data: fieldData,
          responseTime,
          timestamp: new Date().toISOString()
        };
        
        const jsonPrepTime = Date.now() - jsonStartTime;
        console.log(`📊 [field-data] JSON prepared in ${jsonPrepTime}ms`);
        
        const response = NextResponse.json(responseData, {
          headers: {
            'Content-Type': 'application/json',
            'Cache-Control': 'public, s-maxage=300, stale-while-revalidate=600',
          },
        });
        
        const totalTime = Date.now() - startTime;
        console.log(`📊 [field-data] Total response time: ${totalTime}ms`);
        
        return response;
      } catch (sqlError) {
        console.error('❌ [field-data] SQL Server error:', sqlError);
        
        // Si es modo híbrido, intentar con Google Sheets
        if (dataSource === 'hybrid' || dataSource === 'sql') {
          console.log('🔄 [field-data] Fallback to Google Sheets...');
        } else {
          // Si es solo SQL, lanzar error
          throw sqlError;
        }
      }
    }

    // Fallback o modo Sheets
    const fieldData = await googleSheetsService.getFieldData();
    const responseTime = Date.now() - startTime;
    
    console.log(`✅ [field-data] Google Sheets response in ${responseTime}ms`);
    
    return NextResponse.json({
      success: true,
      source: 'google_sheets',
      data: fieldData,
      responseTime,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ [field-data] Error:', error);
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

