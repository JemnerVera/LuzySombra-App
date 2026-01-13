import { query, connectDb, executeProcedure } from '../lib/db';
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
        return this.fieldDataCache.data;
      }

      // Usar Stored Procedure
      const result = await executeProcedure<JerarquiaRow>('evalImagen.usp_evalImagen_getFieldData');
      const rows = result.recordset;

      if (rows.length === 0) {
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
    fechaDesde?: string;
    fechaHasta?: string;
    porcentajeLuzMin?: number;
    porcentajeLuzMax?: number;
    limit?: number;
    page?: number;
    pageSize?: number;
  }): Promise<{ success: boolean; procesamientos: ProcessingRecord[]; total: number; page: number; pageSize: number; totalPages: number }> {
    try {
      const pageSize = filters?.pageSize || filters?.limit || 50;
      const page = filters?.page || 1;

      if (!filters?.empresa && !filters?.fundo && !filters?.sector && !filters?.lote && !filters?.page && this.historialCache && (Date.now() - this.historialCache.timestamp) < this.cacheTimeout) {
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
      if (filters?.fechaDesde) {
        whereClause += ' AND a.fechaCreacion >= @fechaDesde';
        params.fechaDesde = filters.fechaDesde;
      }
      if (filters?.fechaHasta) {
        whereClause += ' AND a.fechaCreacion <= @fechaHasta';
        params.fechaHasta = filters.fechaHasta;
      }
      if (filters?.porcentajeLuzMin !== undefined) {
        whereClause += ' AND a.porcentajeLuz >= @porcentajeLuzMin';
        params.porcentajeLuzMin = filters.porcentajeLuzMin;
      }
      if (filters?.porcentajeLuzMax !== undefined) {
        whereClause += ' AND a.porcentajeLuz <= @porcentajeLuzMax';
        params.porcentajeLuzMax = filters.porcentajeLuzMax;
      }

      const countQuery = `
        SELECT COUNT(*) as total
        FROM evalImagen.analisisImagen a
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
          CASE WHEN mi.processedImageUrl IS NOT NULL THEN 1 ELSE 0 END as tieneImagen,
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
        FROM evalImagen.analisisImagen a
        INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
        LEFT JOIN evalImagen.metadataImagen mi ON a.analisisID = mi.analisisID
        ${whereClause}
        ORDER BY a.fechaCreacion DESC
        OFFSET @offset ROWS
        FETCH NEXT @pageSize ROWS ONLY
      `;

      params.offset = offset;
      params.pageSize = pageSize;

      const rows = await query<AnalisisRow>(queryStr, params);

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
      // Preparar fecha de captura
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

      // Usar Stored Procedure sp_InsertAnalisisImagen
      const spResult = await executeProcedure(
        'evalImagen.usp_evalImagen_insertAnalisisImagen',
        {
          empresa: result.empresa,
          fundo: result.fundo,
          sector: result.sector,
          lote: result.lote,
          hilera: result.hilera || '',
          planta: result.numero_planta || '',
          filename: result.fileName,
          processedImageUrl: result.thumbnail || result.processed_image || null,
          originalImageUrl: result.originalThumbnail || null,
          fechaCaptura: fechaCaptura,
          porcentajeLuz: parseFloat(result.porcentaje_luz.toFixed(2)),
          porcentajeSombra: parseFloat(result.porcentaje_sombra.toFixed(2)),
          latitud: result.latitud,
          longitud: result.longitud,
          usuarioCreaID: null // El SP obtendrá el usuario por defecto
        },
        ['analisisID'], // Parámetro OUTPUT
        { analisisID: sql.Int() } // Tipo SQL para OUTPUT
      );

      const analisisID = spResult.output?.analisisID;
      
      console.log(`📝 Stored procedure ejecutado. analisisID recibido: ${analisisID}`);
      
      if (!analisisID) {
        // Verificar si el registro existe de todas formas (por si acaso)
        console.warn('⚠️ No se recibió analisisID del OUTPUT, verificando si el registro existe...');
        
        // Obtener lotID primero (sin filtrar por statusID - puede estar inactivo)
        const lotResult = await query<{ lotID: number }>(`
          SELECT TOP 1 lotID 
          FROM GROWER.LOT l
          INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
          INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
          INNER JOIN GROWER.GROWERS g ON s.growerID = g.growerID
          WHERE l.name = @lote
            AND s.stage = @sector
            AND f.Description = @fundo
            AND g.businessName = @empresa
          ORDER BY l.lotID
        `, { 
          lote: result.lote,
          sector: result.sector,
          fundo: result.fundo,
          empresa: result.empresa
        });
        
        if (lotResult.length > 0) {
          const lotID = lotResult[0].lotID;
          const existingRecord = await query<{ analisisID: number }>(`
            SELECT TOP 1 analisisID 
            FROM evalImagen.analisisImagen 
            WHERE filename = @filename 
              AND lotID = @lotID
              AND statusID = 1
            ORDER BY analisisID DESC
          `, { 
            filename: result.fileName,
            lotID: lotID
          });
          
          if (existingRecord.length > 0) {
            this.historialCache = null;
            return existingRecord[0].analisisID;
          }
        }
        
        throw new Error('No se pudo obtener el ID del análisis insertado');
      }

      this.historialCache = null;

      return analisisID;
    } catch (error: unknown) {
      console.error('❌ Error saving processing result to SQL Server:', error);
      
      const sqlError = error as { number?: number; message?: string; originalError?: any };
      
      // Log detallado del error
      if (sqlError.message) {
        console.error(`   Mensaje SQL: ${sqlError.message}`);
      }
      if (sqlError.number) {
        console.error(`   Error SQL #${sqlError.number}`);
      }
      if (sqlError.originalError) {
        console.error(`   Error original:`, sqlError.originalError);
      }
      
      // Errores conocidos - Duplicados
      // 2627 = Violation of UNIQUE KEY constraint (error estándar SQL Server)
      // 2601 = Cannot insert duplicate key (error estándar SQL Server)
      // 50000 = Error personalizado del stored procedure (RAISERROR)
      const errorMessage = sqlError.message || sqlError.originalError?.message || '';
      const isDuplicateError = 
        sqlError.number === 2627 || 
        sqlError.number === 2601 || 
        sqlError.number === 50000 ||
        errorMessage.includes('UNIQUE KEY constraint') ||
        errorMessage.includes('duplicate key') ||
        errorMessage.includes('ya fue procesada');
      
      if (isDuplicateError) {
        // Extraer información del error si es posible
        const duplicateMatch = errorMessage.match(/duplicate key value is \(([^,]+), (\d+)\)/);
        if (duplicateMatch) {
          const [, filename, lotID] = duplicateMatch;
          throw new Error(`Esta imagen ya fue procesada anteriormente. Archivo: "${filename}" para el lote ID ${lotID}. Si necesitas reprocesarla, elimina el registro anterior o usa un nombre de archivo diferente.`);
        } else {
          throw new Error(`Esta imagen ya fue procesada anteriormente para el lote "${result.lote}". Archivo: ${result.fileName}. Si necesitas reprocesarla, elimina el registro anterior o usa un nombre de archivo diferente.`);
        }
      }
      
      // Si el error menciona que no se encontró empresa/fundo/sector/lote
      if (sqlError.message && (
        sqlError.message.includes('no encontrada') || 
        sqlError.message.includes('not found') ||
        sqlError.message.includes('Empresa no encontrada') ||
        sqlError.message.includes('Fundo no encontrado') ||
        sqlError.message.includes('Sector no encontrado') ||
        sqlError.message.includes('Lote no encontrado')
      )) {
        throw new Error(`Error de validación: ${sqlError.message}. Verifica que empresa, fundo, sector y lote existan en la base de datos.`);
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
          (SELECT TOP 1 v.name 
           FROM GROWER.PLANTATION p WITH (NOLOCK)
           INNER JOIN GROWER.VARIETY v WITH (NOLOCK) ON p.varietyID = v.varietyID
           WHERE p.lotID = lp.lotID 
             AND p.statusID = 1 
             AND v.statusID = 1
           ORDER BY p.plantationID) AS variedad,
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
        LEFT JOIN dbo.vwc_Cianamida_fenologia cf WITH (NOLOCK) 
          ON lp.lotID = cf.lotID
        LEFT JOIN evalImagen.loteEvaluacion le WITH (NOLOCK) 
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

      // Ejecutar count y rows en paralelo para mejor rendimiento
      const [countResult, rows] = await Promise.all([
        query<{ total: number }>(countQuery, params),
        query<{
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
      }>(consolidatedQuery, params)
      ]);

      const total = countResult[0]?.total || 0;
      const totalPages = Math.ceil(total / pageSize);

      return {
        success: true,
        data: rows,
        total,
        page,
        pageSize,
        totalPages
      };
    } catch (error: any) {
      console.error('❌ [getConsolidatedTable] Error obteniendo tabla consolidada:', error);
      
      // Manejar errores de timeout específicamente
      if (error.code === 'ETIMEOUT' || error.message?.includes('Timeout')) {
        const timeoutError = new Error('La consulta está tardando demasiado. Por favor, intenta con filtros más específicos (fundo, sector o lote) para reducir el tiempo de respuesta.');
        (timeoutError as any).code = 'ETIMEOUT';
        (timeoutError as any).isTimeout = true;
        throw timeoutError;
      }
      
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
        FROM evalImagen.analisisImagen ai WITH (NOLOCK)
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
      // Get total number of analyses
      const totalAnalisisResult = await query<{ total: number }>(`
        SELECT COUNT(*) as total
        FROM evalImagen.analisisImagen
        WHERE statusID = 1
      `);
      const totalAnalisis = totalAnalisisResult[0]?.total || 0;
      
      // Get total number of lots
      const totalLotesResult = await query<{ total: number }>(`
        SELECT COUNT(DISTINCT a.lotID) as total
        FROM evalImagen.analisisImagen a
        WHERE a.statusID = 1
      `);
      const totalLotes = totalLotesResult[0]?.total || 0;
      
      // Get average light percentage
      const avgLuzResult = await query<{ promedio: number }>(`
        SELECT AVG(CAST(porcentajeLuz AS FLOAT)) as promedio
        FROM evalImagen.analisisImagen
        WHERE porcentajeLuz IS NOT NULL AND statusID = 1
      `);
      const promedioLuz = avgLuzResult[0]?.promedio || 0;
      
      // Get average shadow percentage
      const avgSombraResult = await query<{ promedio: number }>(`
        SELECT AVG(CAST(porcentajeSombra AS FLOAT)) as promedio
        FROM evalImagen.analisisImagen
        WHERE porcentajeSombra IS NOT NULL AND statusID = 1
      `);
      const promedioSombra = avgSombraResult[0]?.promedio || 0;

      // Get statistics by fundo
      const statsPorFundo = await query<{
        fundo: string;
        total: number;
        promedioLuz: number;
        promedioSombra: number;
      }>(`
        SELECT 
          f.Description AS fundo,
          COUNT(*) as total,
          AVG(CAST(a.porcentajeLuz AS FLOAT)) as promedioLuz,
          AVG(CAST(a.porcentajeSombra AS FLOAT)) as promedioSombra
        FROM evalImagen.analisisImagen a
        INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        WHERE a.statusID = 1
        GROUP BY f.Description
        ORDER BY total DESC
      `);

      // Get statistics by month (last 12 months)
      const statsPorMes = await query<{
        mes: string;
        total: number;
        promedioLuz: number;
      }>(`
        SELECT 
          FORMAT(a.fechaCreacion, 'yyyy-MM') AS mes,
          COUNT(*) as total,
          AVG(CAST(a.porcentajeLuz AS FLOAT)) as promedioLuz
        FROM evalImagen.analisisImagen a
        WHERE a.statusID = 1
          AND a.fechaCreacion >= DATEADD(MONTH, -12, GETDATE())
        GROUP BY FORMAT(a.fechaCreacion, 'yyyy-MM')
        ORDER BY mes ASC
      `);

      // Get distribution by light percentage ranges
      const distribucionLuz = await query<{
        rango: string;
        total: number;
        porcentaje: number;
      }>(`
        SELECT 
          CASE 
            WHEN porcentajeLuz < 20 THEN '0-20%'
            WHEN porcentajeLuz < 40 THEN '20-40%'
            WHEN porcentajeLuz < 60 THEN '40-60%'
            WHEN porcentajeLuz < 80 THEN '60-80%'
            ELSE '80-100%'
          END AS rango,
          COUNT(*) as total,
          CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM evalImagen.analisisImagen WHERE statusID = 1) AS DECIMAL(5,2)) as porcentaje
        FROM evalImagen.analisisImagen
        WHERE porcentajeLuz IS NOT NULL AND statusID = 1
        GROUP BY 
          CASE 
            WHEN porcentajeLuz < 20 THEN '0-20%'
            WHEN porcentajeLuz < 40 THEN '20-40%'
            WHEN porcentajeLuz < 60 THEN '40-60%'
            WHEN porcentajeLuz < 80 THEN '60-80%'
            ELSE '80-100%'
          END
        ORDER BY rango
      `);

      // Get recent activity (last 7 days)
      const actividadReciente = await query<{
        fecha: Date;
        total: number;
      }>(`
        SELECT 
          CAST(a.fechaCreacion AS DATE) AS fecha,
          COUNT(*) as total
        FROM evalImagen.analisisImagen a
        WHERE a.statusID = 1
          AND a.fechaCreacion >= DATEADD(DAY, -7, GETDATE())
        GROUP BY CAST(a.fechaCreacion AS DATE)
        ORDER BY fecha ASC
      `);

      return {
        general: {
          totalAnalisis,
          totalLotes,
          promedioLuz: parseFloat((promedioLuz || 0).toFixed(2)),
          promedioSombra: parseFloat((promedioSombra || 0).toFixed(2))
        },
        porFundo: statsPorFundo.map(s => ({
          fundo: s.fundo,
          total: s.total,
          promedioLuz: parseFloat((s.promedioLuz || 0).toFixed(2)),
          promedioSombra: parseFloat((s.promedioSombra || 0).toFixed(2))
        })),
        porMes: statsPorMes.map(s => ({
          mes: s.mes,
          total: s.total,
          promedioLuz: parseFloat((s.promedioLuz || 0).toFixed(2))
        })),
        distribucionLuz: distribucionLuz.map(d => ({
          rango: d.rango,
          total: d.total,
          porcentaje: parseFloat((d.porcentaje || 0).toFixed(2))
        })),
        actividadReciente: actividadReciente.map(a => ({
          fecha: a.fecha.toISOString().split('T')[0],
          total: a.total
        }))
      };
    } catch (error) {
      console.error('❌ Error getting statistics:', error);
      throw error;
    }
  }

  clearCache(): void {
    this.fieldDataCache = null;
    this.historialCache = null;
  }

  async testConnection(): Promise<boolean> {
    try {
      await query<{ total: number }>('SELECT COUNT(*) as total FROM GROWER.LOT WHERE statusID = 1');
      return true;
    } catch (error) {
      console.error('❌ SQL Server connection test failed:', error);
      return false;
    }
  }
}

export const sqlServerService = new SqlServerService();

