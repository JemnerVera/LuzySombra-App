import { query, connectDb } from '../lib/db';
import sql from 'mssql';

// Re-exportar interfaces y tipos para uso en otros módulos
export interface FieldData {
  empresa: string[];
  fundo: string[];
  sector: string[];
  lote: string[];
  hierarchical: Record<string, Record<string, Record<string, string[]>>>;
}

export interface ProcessingRecord {
  id: string;
  fecha: string;
  hora: string;
  imagen: string;
  nombre_archivo: string;
  imagen_url?: string | null;
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  hilera: string;
  numero_planta: string;
  latitud: number | null;
  longitud: number | null;
  porcentaje_luz: number;
  porcentaje_sombra: number;
  dispositivo: string;
  software: string;
  direccion: string;
  timestamp: string;
}

interface JerarquiaRow {
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  growerID?: string;
  farmID?: string;
  stageID?: number;
  lotID?: number;
}

interface AnalisisRow {
  analisisid: number;
  fecha_procesamiento: Date;
  nombre_archivo_original: string;
  tieneImagen: number;
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  hilera: string | null;
  numero_planta: string | null;
  latitud: number | null;
  longitud: number | null;
  porcentajeLuz: number;
  porcentajeSombra: number;
  dispositivo: string | null;
  software: string | null;
  direccion: string | null;
}

class SqlServerService {
  private fieldDataCache: { data: FieldData; timestamp: number } | null = null;
  private historialCache: { data: ProcessingRecord[]; timestamp: number } | null = null;
  private cacheTimeout = 300000; // 5 minutes cache

  async getFieldData(): Promise<FieldData> {
    try {
      if (this.fieldDataCache && (Date.now() - this.fieldDataCache.timestamp) < this.cacheTimeout) {
        console.log('📊 Using cached field data from SQL Server');
        return this.fieldDataCache.data;
      }

      console.log('📊 Fetching field data from SQL Server...');
      const startTime = Date.now();

      const rows = await query<JerarquiaRow>(`
        SELECT 
          g.businessName as [empresa],
          f.Description as [fundo],
          s.stage as [sector],
          l.name as [lote],
          g.growerID,
          f.farmID,
          s.stageID,
          l.lotID
        FROM GROWER.LOT l
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
        WHERE l.statusID = 1 
          AND s.statusID = 1 
          AND f.statusID = 1 
          AND g.statusID = 1
        ORDER BY g.businessName, f.Description, s.stage, l.name
      `);

      const fetchTime = Date.now() - startTime;
      console.log(`📊 SQL Server fetch completed in ${fetchTime}ms (${rows.length} records)`);

      if (rows.length === 0) {
        console.warn('⚠️ No data found in SQL Server, returning empty structure');
        return {
          empresa: [],
          fundo: [],
          sector: [],
          lote: [],
          hierarchical: {}
        };
      }

      const processedData = this.processFieldData(rows);

      this.fieldDataCache = {
        data: processedData,
        timestamp: Date.now()
      };

      console.log(`✅ Field data processed: ${processedData.empresa.length} empresas, ${processedData.fundo.length} fundos`);

      return processedData;
    } catch (error) {
      console.error('❌ Error obteniendo datos de campo desde SQL Server:', error);
      throw error;
    }
  }

  async getHistorial(filters?: {
    empresa?: string;
    fundo?: string;
    sector?: string;
    lote?: string;
    limit?: number;
    page?: number;
    pageSize?: number;
  }): Promise<{ success: boolean; procesamientos: ProcessingRecord[]; total: number; page: number; pageSize: number; totalPages: number }> {
    try {
      const pageSize = filters?.pageSize || filters?.limit || 50;
      const page = filters?.page || 1;

      if (!filters?.empresa && !filters?.fundo && !filters?.sector && !filters?.lote && !filters?.page && this.historialCache && (Date.now() - this.historialCache.timestamp) < this.cacheTimeout) {
        console.log('📊 Using cached history data from SQL Server');
        const cachedData = this.historialCache.data;
        if (page === 1) {
          return { 
            success: true, 
            procesamientos: cachedData.slice(0, pageSize),
            total: cachedData.length,
            page: 1,
            pageSize,
            totalPages: Math.ceil(cachedData.length / pageSize)
          };
        }
      }

      console.log('📊 Fetching history data from SQL Server...');
      const startTime = Date.now();
      const offset = (page - 1) * pageSize;

      let whereClause = 'WHERE a.statusID = 1';
      const params: Record<string, string | number> = {};

      if (filters?.empresa) {
        whereClause += ' AND g.businessName = @empresa';
        params.empresa = filters.empresa;
      }
      if (filters?.fundo) {
        whereClause += ' AND f.Description = @fundo';
        params.fundo = filters.fundo;
      }
      if (filters?.sector) {
        whereClause += ' AND s.stage = @sector';
        params.sector = filters.sector;
      }
      if (filters?.lote) {
        whereClause += ' AND l.name = @lote';
        params.lote = filters.lote;
      }

      const countQuery = `
        SELECT COUNT(*) as total
        FROM image.Analisis_Imagen a
        INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
        ${whereClause}
      `;

      const countResult = await query<{ total: number }>(countQuery, params);
      const total = countResult[0]?.total || 0;
      const totalPages = Math.ceil(total / pageSize);

      const queryStr = `
        SELECT 
          a.analisisID as analisisid,
          a.fechaCreacion as fecha_procesamiento,
          a.filename as nombre_archivo_original,
          CASE WHEN a.processedImageUrl IS NOT NULL THEN 1 ELSE 0 END as tieneImagen,
          g.businessName as empresa,
          f.Description as fundo,
          s.stage as sector,
          l.name as lote,
          a.hilera,
          a.planta as numero_planta,
          a.latitud,
          a.longitud,
          a.porcentajeLuz,
          a.porcentajeSombra,
          '' as dispositivo,
          '' as software,
          '' as direccion
        FROM image.Analisis_Imagen a
        INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
        ${whereClause}
        ORDER BY a.fechaCreacion DESC
        OFFSET @offset ROWS
        FETCH NEXT @pageSize ROWS ONLY
      `;

      params.offset = offset;
      params.pageSize = pageSize;

      const rows = await query<AnalisisRow>(queryStr, params);

      const fetchTime = Date.now() - startTime;
      console.log(`📊 SQL Server history fetch completed in ${fetchTime}ms (${rows.length} records)`);

      const historial: ProcessingRecord[] = rows.map((row) => {
        const fecha = new Date(row.fecha_procesamiento);
        const tieneImagen = row.tieneImagen ?? 0;
        const imagenUrl = tieneImagen === 1
          ? `/api/imagen/${row.analisisid}`
          : null;
        
        return {
          id: row.analisisid.toString(),
          fecha: fecha.toLocaleDateString('es-ES'),
          hora: fecha.toLocaleTimeString('es-ES'),
          imagen: row.nombre_archivo_original || '',
          nombre_archivo: row.nombre_archivo_original || '',
          imagen_url: imagenUrl,
          empresa: row.empresa || '',
          fundo: row.fundo || '',
          sector: row.sector || '',
          lote: row.lote || '',
          hilera: row.hilera || '',
          numero_planta: row.numero_planta || '',
          latitud: row.latitud ?? null,
          longitud: row.longitud ?? null,
          porcentaje_luz: row.porcentajeLuz ?? 0,
          porcentaje_sombra: row.porcentajeSombra ?? 0,
          dispositivo: row.dispositivo || '',
          software: row.software || '',
          direccion: row.direccion || '',
          timestamp: row.fecha_procesamiento.toISOString()
        };
      });

      if (!filters) {
        this.historialCache = {
          data: historial,
          timestamp: Date.now()
        };
      }

      return {
        success: true,
        procesamientos: historial,
        total,
        page,
        pageSize,
        totalPages
      };
    } catch (error) {
      console.error('❌ Error obteniendo historial desde SQL Server:', error);
      throw error;
    }
  }

  async saveProcessingResult(result: {
    fileName: string;
    image_name: string;
    hilera: string;
    numero_planta: string;
    porcentaje_luz: number;
    porcentaje_sombra: number;
    fundo: string;
    sector: string;
    lote: string;
    empresa: string;
    latitud: number | null;
    longitud: number | null;
    processed_image: string;
    timestamp: string;
    exifDateTime?: { date: string; time: string } | null;
    thumbnail?: string;
    originalThumbnail?: string;
  }): Promise<number> {
    try {
      console.log('💾 Saving processing result to SQL Server...');
      const startTime = Date.now();

      const empresaResult = await query<{ growerID: string }>(`
        SELECT growerID FROM GROWER.GROWERS 
        WHERE businessName = @empresa AND statusID = 1
      `, { empresa: result.empresa });

      if (empresaResult.length === 0) {
        throw new Error(`Empresa no encontrada: ${result.empresa}`);
      }
      const growerID = empresaResult[0].growerID;

      const fundoResult = await query<{ farmID: string }>(`
        SELECT DISTINCT f.farmID 
        FROM GROWER.FARMS f
        INNER JOIN GROWER.STAGE s ON f.farmID = s.farmID
        WHERE f.Description = @fundo 
          AND s.growerID = @growerID 
          AND f.statusID = 1 
          AND s.statusID = 1
      `, { fundo: result.fundo, growerID });

      if (fundoResult.length === 0) {
        throw new Error(`Fundo no encontrado: ${result.fundo} en empresa ${result.empresa}`);
      }
      const farmID = fundoResult[0].farmID;

      const sectorResult = await query<{ stageID: number }>(`
        SELECT stageID FROM GROWER.STAGE 
        WHERE stage = @sector AND farmID = @farmID AND statusID = 1
      `, { sector: result.sector, farmID });

      if (sectorResult.length === 0) {
        throw new Error(`Sector no encontrado: ${result.sector} en fundo ${result.fundo}`);
      }
      const stageID = sectorResult[0].stageID;

      const loteResult = await query<{ lotID: number }>(`
        SELECT lotID FROM GROWER.LOT 
        WHERE name = @lote AND stageID = @stageID AND statusID = 1
      `, { lote: result.lote, stageID });

      if (loteResult.length === 0) {
        throw new Error(`Lote no encontrado: ${result.lote} en sector ${result.sector}`);
      }
      const lotID = loteResult[0].lotID;

      let userCreatedID = 1;
      try {
        const usuarioResult = await query<{ userID: number }>(`
          SELECT TOP 1 userID 
          FROM MAST.USERS 
          WHERE statusID = 1 
          ORDER BY userID
        `);
        
        if (usuarioResult.length > 0 && usuarioResult[0].userID) {
          userCreatedID = Number(usuarioResult[0].userID);
        }
      } catch (userError) {
        console.warn('⚠️ Error al obtener usuario de MAST.USERS, usando valor por defecto:', userError);
      }

      const pool = await connectDb();
      const request = pool.request();

      request.input('lotID', sql.Int, lotID);
      request.input('hilera', sql.NVarChar(50), result.hilera || '');
      request.input('planta', sql.NVarChar(50), result.numero_planta || '');
      request.input('filename', sql.NVarChar(500), result.fileName);
      request.input('processedImageUrl', sql.NVarChar(sql.MAX), result.thumbnail || null);
      request.input('originalImageUrl', sql.NVarChar(sql.MAX), result.originalThumbnail || null);
      
      let fechaCaptura = null;
      if (result.exifDateTime) {
        try {
          const [day, month, year] = result.exifDateTime.date.split('/');
          const [hour, minute, second] = result.exifDateTime.time.split(':');
          fechaCaptura = new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}`);
        } catch (e) {
          console.warn('⚠️ Error parsing EXIF date:', e);
        }
      }
      
      request.input('fechaCaptura', sql.DateTime, fechaCaptura);
      request.input('porcentajeLuz', sql.Decimal(5, 2), parseFloat(result.porcentaje_luz.toFixed(2)));
      request.input('porcentajeSombra', sql.Decimal(5, 2), parseFloat(result.porcentaje_sombra.toFixed(2)));
      request.input('latitud', sql.Decimal(10, 8), result.latitud);
      request.input('longitud', sql.Decimal(11, 8), result.longitud);
      request.input('usuarioCreaID', sql.Int, userCreatedID);

      const insertResult = await request.query(`
        INSERT INTO image.Analisis_Imagen (
          lotID, hilera, planta, filename, fechaCaptura,
          porcentajeLuz, porcentajeSombra, latitud, longitud,
          processedImageUrl, originalImageUrl, usuarioCreaID, statusID
        )
        OUTPUT INSERTED.analisisID
        VALUES (
          @lotID, @hilera, @planta, @filename, @fechaCaptura,
          @porcentajeLuz, @porcentajeSombra, @latitud, @longitud,
          @processedImageUrl, @originalImageUrl, @usuarioCreaID, 1
        )
      `);

      const analisisID = insertResult.recordset[0].analisisID;
      const saveTime = Date.now() - startTime;

      console.log(`✅ Processing result saved to SQL Server in ${saveTime}ms (ID: ${analisisID})`);

      try {
        await query(`EXEC image.sp_CalcularLoteEvaluacion @LotID = @lotID`, { lotID });
      } catch (updateError) {
        console.warn('⚠️ Error actualizando image.LoteEvaluacion (continuando):', updateError);
      }

      this.historialCache = null;

      return analisisID;
    } catch (error: unknown) {
      console.error('❌ Error saving processing result to SQL Server:', error);
      
      const sqlError = error as { number?: number; message?: string };
      if (sqlError.number === 2627 || sqlError.number === 2601) {
        throw new Error(`Esta imagen ya fue procesada anteriormente para el lote "${result.lote}". Archivo: ${result.fileName}`);
      }
      
      throw error;
    }
  }

  private processFieldData(rawData: JerarquiaRow[]): FieldData {
    const empresas = [...new Set(rawData.map(item => item.empresa).filter(Boolean))].sort();
    const fundos = [...new Set(rawData.map(item => item.fundo).filter(Boolean))].sort();
    const sectores = [...new Set(rawData.map(item => item.sector).filter(Boolean))].sort();
    const lotes = [...new Set(rawData.map(item => item.lote).filter(Boolean))].sort();

    const hierarchical: Record<string, Record<string, Record<string, string[]>>> = {};

    for (const item of rawData) {
      const { empresa, fundo, sector, lote } = item;
      if (!empresa || !fundo || !sector || !lote) continue;

      if (!hierarchical[empresa]) {
        hierarchical[empresa] = {};
      }
      if (!hierarchical[empresa][fundo]) {
        hierarchical[empresa][fundo] = {};
      }
      if (!hierarchical[empresa][fundo][sector]) {
        hierarchical[empresa][fundo][sector] = [];
      }
      if (!hierarchical[empresa][fundo][sector].includes(lote)) {
        hierarchical[empresa][fundo][sector].push(lote);
      }
    }

    for (const empresa in hierarchical) {
      for (const fundo in hierarchical[empresa]) {
        for (const sector in hierarchical[empresa][fundo]) {
          hierarchical[empresa][fundo][sector].sort();
        }
      }
    }

    return {
      empresa: empresas,
      fundo: fundos,
      sector: sectores,
      lote: lotes,
      hierarchical
    };
  }

  async getConsolidatedTable(filters?: {
    fundo?: string;
    sector?: string;
    lote?: string;
    page?: number;
    pageSize?: number;
  }): Promise<{
    success: boolean;
    data: Array<{
      fundo: string;
      sector: string;
      lote: string;
      variedad: string | null;
      estadoFenologico: string | null;
      diasCianamida: number | null;
      fechaUltimaEvaluacion: string | null;
      porcentajeLuzMin: number | null;
      porcentajeLuzMax: number | null;
      porcentajeLuzProm: number | null;
      porcentajeSombraMin: number | null;
      porcentajeSombraMax: number | null;
      porcentajeSombraProm: number | null;
    }>;
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
  }> {
    try {
      const startTime = Date.now();
      console.log('📊 [getConsolidatedTable] Iniciando...');
      
      const page = filters?.page || 1;
      const pageSize = filters?.pageSize || 50;
      const offset = (page - 1) * pageSize;

      const whereConditions: string[] = [];
      const params: Record<string, unknown> = {};

      whereConditions.push('l.statusID = 1');
      whereConditions.push('s.statusID = 1');
      whereConditions.push('f.statusID = 1');

      if (filters?.fundo) {
        whereConditions.push('f.Description = @fundo');
        params.fundo = filters.fundo;
      }

      if (filters?.sector) {
        whereConditions.push('s.stage = @sector');
        params.sector = filters.sector;
      }

      if (filters?.lote) {
        whereConditions.push('l.name = @lote');
        params.lote = filters.lote;
      }

      const whereClause = whereConditions.length > 0 
        ? 'WHERE ' + whereConditions.join(' AND ')
        : '';

      const consolidatedQuery = `
        WITH LotesPaginados AS (
          SELECT 
            l.lotID,
            f.Description AS fundo,
            s.stage AS sector,
            l.name AS lote
          FROM GROWER.LOT l WITH (NOLOCK)
          INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
          INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
          ${whereClause}
          ORDER BY f.Description, s.stage, l.name
          OFFSET @offset ROWS
          FETCH NEXT @pageSize ROWS ONLY
        )
        SELECT 
          lp.fundo,
          lp.sector,
          lp.lote,
          v.name AS variedad,
          cf.estadoFenologico,
          cf.diasCianamida,
          CASE 
            WHEN le.fechaUltimaEvaluacion IS NOT NULL 
            THEN CONVERT(VARCHAR(23), le.fechaUltimaEvaluacion, 126)
            ELSE NULL 
          END AS fechaUltimaEvaluacion,
          le.porcentajeLuzMin,
          le.porcentajeLuzMax,
          CAST(le.porcentajeLuzPromedio AS DECIMAL(5,2)) AS porcentajeLuzProm,
          le.porcentajeSombraMin,
          le.porcentajeSombraMax,
          CAST(le.porcentajeSombraPromedio AS DECIMAL(5,2)) AS porcentajeSombraProm
        FROM LotesPaginados lp
        LEFT JOIN GROWER.PLANTATION p WITH (NOLOCK) 
          ON lp.lotID = p.lotID 
          AND p.statusID = 1
        LEFT JOIN GROWER.VARIETY v WITH (NOLOCK) 
          ON p.varietyID = v.varietyID 
          AND v.statusID = 1
        LEFT JOIN dbo.vwc_CianamidaFenologia cf WITH (NOLOCK) 
          ON lp.lotID = cf.lotID
        LEFT JOIN image.LoteEvaluacion le WITH (NOLOCK) 
          ON lp.lotID = le.lotID 
          AND le.statusID = 1
        ORDER BY lp.fundo, lp.sector, lp.lote
      `;

      const countQuery = `
        SELECT COUNT(DISTINCT l.lotID) AS total
        FROM GROWER.LOT l WITH (NOLOCK)
        INNER JOIN GROWER.STAGE s WITH (NOLOCK) ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f WITH (NOLOCK) ON s.farmID = f.farmID
        ${whereClause}
      `;

      params.offset = offset;
      params.pageSize = pageSize;

      const countResult = await query<{ total: number }>(countQuery, params);
      const rows = await query<{
        fundo: string;
        sector: string;
        lote: string;
        variedad: string | null;
        estadoFenologico: string | null;
        diasCianamida: number | null;
        fechaUltimaEvaluacion: string | null;
        porcentajeLuzMin: number | null;
        porcentajeLuzMax: number | null;
        porcentajeLuzProm: number | null;
        porcentajeSombraMin: number | null;
        porcentajeSombraMax: number | null;
        porcentajeSombraProm: number | null;
      }>(consolidatedQuery, params);

      const total = countResult[0]?.total || 0;
      const totalPages = Math.ceil(total / pageSize);

      const fetchTime = Date.now() - startTime;
      console.log(`📊 Consolidated table fetch completed in ${fetchTime}ms (${rows.length} records, total: ${total})`);

      return {
        success: true,
        data: rows,
        total,
        page,
        pageSize,
        totalPages
      };
    } catch (error) {
      console.error('❌ [getConsolidatedTable] Error obteniendo tabla consolidada:', error);
      throw error;
    }
  }

  async getLoteDetalleHistorial(lotID: number): Promise<{
    success: boolean;
    data: Array<{
      fecha: string;
      luzMin: number | null;
      luzMax: number | null;
      luzProm: number | null;
      sombraMin: number | null;
      sombraMax: number | null;
      sombraProm: number | null;
    }>;
  }> {
    try {
      console.log(`📊 [getLoteDetalleHistorial] Obteniendo detalle histórico para lotID: ${lotID}`);
      
      const rows = await query<{
        fecha: Date;
        luzMin: number;
        luzMax: number;
        luzProm: number;
        sombraMin: number;
        sombraMax: number;
        sombraProm: number;
      }>(`
        SELECT 
          CAST(COALESCE(ai.fechaCaptura, ai.fechaCreacion) AS DATE) AS fecha,
          MIN(ai.porcentajeLuz) AS luzMin,
          MAX(ai.porcentajeLuz) AS luzMax,
          AVG(CAST(ai.porcentajeLuz AS FLOAT)) AS luzProm,
          MIN(ai.porcentajeSombra) AS sombraMin,
          MAX(ai.porcentajeSombra) AS sombraMax,
          AVG(CAST(ai.porcentajeSombra AS FLOAT)) AS sombraProm
        FROM image.Analisis_Imagen ai WITH (NOLOCK)
        WHERE ai.lotID = @lotID 
          AND ai.statusID = 1
        GROUP BY CAST(COALESCE(ai.fechaCaptura, ai.fechaCreacion) AS DATE)
        ORDER BY fecha DESC
      `, { lotID });

      const data = rows.map(row => ({
        fecha: row.fecha.toISOString().split('T')[0],
        luzMin: row.luzMin,
        luzMax: row.luzMax,
        luzProm: row.luzProm,
        sombraMin: row.sombraMin,
        sombraMax: row.sombraMax,
        sombraProm: row.sombraProm,
      }));

      console.log(`✅ [getLoteDetalleHistorial] Obtenidos ${data.length} registros para lotID ${lotID}`);

      return {
        success: true,
        data
      };
    } catch (error) {
      console.error('❌ [getLoteDetalleHistorial] Error:', error);
      throw error;
    }
  }

  /**
   * Get statistics
   */
  async getStatistics(): Promise<any> {
    try {
      const pool = await connectDb();
      
      // Get total number of analyses
      const totalAnalisisResult = await pool.request().query(`
        SELECT COUNT(*) as total
        FROM image.Analisis_Imagen
      `);
      const totalAnalisis = totalAnalisisResult.recordset[0]?.total || 0;
      
      // Get total number of lots
      const totalLotesResult = await pool.request().query(`
        SELECT COUNT(DISTINCT CONCAT(f.farmID, '-', s.stageID, '-', l.lotID)) as total
        FROM image.Analisis_Imagen ai
        INNER JOIN [AgroMigiva].[dbo].[Lot] l ON ai.loteID = l.lotID
        INNER JOIN [AgroMigiva].[dbo].[Stage] s ON l.stageID = s.stageID
        INNER JOIN [AgroMigiva].[dbo].[Farm] f ON s.farmID = f.farmID
      `);
      const totalLotes = totalLotesResult.recordset[0]?.total || 0;
      
      // Get average light percentage
      const avgLuzResult = await pool.request().query(`
        SELECT AVG(porcentaje_luz) as promedio
        FROM image.Analisis_Imagen
        WHERE porcentaje_luz IS NOT NULL
      `);
      const promedioLuz = avgLuzResult.recordset[0]?.promedio || 0;
      
      // Get average shadow percentage
      const avgSombraResult = await pool.request().query(`
        SELECT AVG(porcentaje_sombra) as promedio
        FROM image.Analisis_Imagen
        WHERE porcentaje_sombra IS NOT NULL
      `);
      const promedioSombra = avgSombraResult.recordset[0]?.promedio || 0;
      
      return {
        totalAnalisis,
        totalLotes,
        promedioLuz: Math.round(promedioLuz * 100) / 100,
        promedioSombra: Math.round(promedioSombra * 100) / 100
      };
    } catch (error) {
      console.error('❌ Error getting statistics:', error);
      throw error;
    }
  }

  clearCache(): void {
    this.fieldDataCache = null;
    this.historialCache = null;
    console.log('🗑️ SQL Server service cache cleared');
  }

  async testConnection(): Promise<boolean> {
    try {
      const result = await query<{ total: number }>('SELECT COUNT(*) as total FROM GROWER.LOT WHERE statusID = 1');
      console.log(`✅ SQL Server connection OK (${result[0].total} lotes activos)`);
      return true;
    } catch (error) {
      console.error('❌ SQL Server connection test failed:', error);
      return false;
    }
  }
}

export const sqlServerService = new SqlServerService();

