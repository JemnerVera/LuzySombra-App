import { query, connectDb } from '@/lib/db';
import sql from 'mssql';

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
}

interface AnalisisRow {
  analisisid: number;
  fecha_procesamiento: Date;
  nombre_archivo_original: string;
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  hilera: string | null;
  numero_planta: string | null;
  latitud: number | null;
  longitud: number | null;
  porcentaje_luz: number;
  porcentaje_sombra: number;
  dispositivo: string | null;
  software: string | null;
  direccion: string | null;
}

class SqlServerService {
  private fieldDataCache: { data: FieldData; timestamp: number } | null = null;
  private historialCache: { data: ProcessingRecord[]; timestamp: number } | null = null;
  private cacheTimeout = 300000; // 5 minutes cache

  /**
   * Obtiene la jerarquía de campos (empresa, fundo, sector, lote) desde SQL Server
   */
  async getFieldData(): Promise<FieldData> {
    try {
      // Check cache first
      if (this.fieldDataCache && (Date.now() - this.fieldDataCache.timestamp) < this.cacheTimeout) {
        console.log('📊 Using cached field data from SQL Server');
        return this.fieldDataCache.data;
      }

      console.log('📊 Fetching field data from SQL Server...');
      const startTime = Date.now();

      // Usar la vista que ya creamos en el schema
      const rows = await query<JerarquiaRow>(`
        SELECT 
          e.empresa,
          f.fundo,
          s.sector,
          l.lote
        FROM image.lote l
        INNER JOIN image.sector s ON l.sectorid = s.sectorid
        INNER JOIN image.fundo f ON s.fundoid = f.fundoid
        INNER JOIN image.empresa e ON f.empresaid = e.empresaid
        WHERE l.statusid = 1 
          AND s.statusid = 1 
          AND f.statusid = 1 
          AND e.statusid = 1
        ORDER BY e.empresa, f.fundo, s.sector, l.lote
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

      // Cache the result
      this.fieldDataCache = {
        data: processedData,
        timestamp: Date.now()
      };

      console.log(`✅ Field data processed: ${processedData.empresa.length} empresas, ${processedData.fundo.length} fundos, ${processedData.sector.length} sectores, ${processedData.lote.length} lotes`);

      return processedData;
    } catch (error) {
      console.error('❌ Error obteniendo datos de campo desde SQL Server:', error);
      throw error;
    }
  }

  /**
   * Obtiene el historial de procesamientos desde SQL Server
   */
  async getHistorial(filters?: {
    empresa?: string;
    fundo?: string;
    sector?: string;
    lote?: string;
    limit?: number;
  }): Promise<{ success: boolean; procesamientos: ProcessingRecord[] }> {
    try {
      // Check cache first (only if no filters)
      if (!filters && this.historialCache && (Date.now() - this.historialCache.timestamp) < this.cacheTimeout) {
        console.log('📊 Using cached history data from SQL Server');
        return { success: true, procesamientos: this.historialCache.data };
      }

      console.log('📊 Fetching history data from SQL Server...');
      const startTime = Date.now();

      const limit = filters?.limit || 500;

      // Build dynamic query with filters
      let whereClause = 'WHERE 1=1';
      const params: Record<string, string> = {};

      if (filters?.empresa) {
        whereClause += ' AND e.empresa = @empresa';
        params.empresa = filters.empresa;
      }
      if (filters?.fundo) {
        whereClause += ' AND f.fundo = @fundo';
        params.fundo = filters.fundo;
      }
      if (filters?.sector) {
        whereClause += ' AND s.sector = @sector';
        params.sector = filters.sector;
      }
      if (filters?.lote) {
        whereClause += ' AND l.lote = @lote';
        params.lote = filters.lote;
      }

      const queryStr = `
        SELECT TOP ${limit}
          a.analisisid,
          a.fecha_procesamiento,
          a.nombre_archivo_original,
          e.empresa,
          f.fundo,
          s.sector,
          l.lote,
          a.hilera,
          a.numero_planta,
          a.latitud,
          a.longitud,
          a.porcentaje_luz,
          a.porcentaje_sombra,
          a.dispositivo,
          a.software,
          a.direccion
        FROM image.analisis_imagen a
        INNER JOIN image.lote l ON a.loteid = l.loteid
        INNER JOIN image.sector s ON l.sectorid = s.sectorid
        INNER JOIN image.fundo f ON s.fundoid = f.fundoid
        INNER JOIN image.empresa e ON f.empresaid = e.empresaid
        ${whereClause}
        ORDER BY a.fecha_procesamiento DESC
      `;

      const rows = await query<AnalisisRow>(queryStr, params);

      const fetchTime = Date.now() - startTime;
      console.log(`📊 SQL Server history fetch completed in ${fetchTime}ms (${rows.length} records)`);

      const historial: ProcessingRecord[] = rows.map((row, index) => {
        const fecha = new Date(row.fecha_procesamiento);
        return {
          id: row.analisisid.toString(),
          fecha: fecha.toLocaleDateString('es-ES'),
          hora: fecha.toLocaleTimeString('es-ES'),
          imagen: row.nombre_archivo_original,
          nombre_archivo: row.nombre_archivo_original,
          empresa: row.empresa,
          fundo: row.fundo,
          sector: row.sector,
          lote: row.lote,
          hilera: row.hilera || '',
          numero_planta: row.numero_planta || '',
          latitud: row.latitud,
          longitud: row.longitud,
          porcentaje_luz: row.porcentaje_luz,
          porcentaje_sombra: row.porcentaje_sombra,
          dispositivo: row.dispositivo || '',
          software: row.software || '',
          direccion: row.direccion || '',
          timestamp: row.fecha_procesamiento.toISOString()
        };
      });

      // Cache the result (only if no filters)
      if (!filters) {
        this.historialCache = {
          data: historial,
          timestamp: Date.now()
        };
      }

      return {
        success: true,
        procesamientos: historial
      };
    } catch (error) {
      console.error('❌ Error obteniendo historial desde SQL Server:', error);
      throw error;
    }
  }

  /**
   * Guarda el resultado de un procesamiento de imagen en SQL Server
   */
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
  }): Promise<number> {
    try {
      console.log('💾 Saving processing result to SQL Server...');
      const startTime = Date.now();

      // 1. Obtener IDs de la jerarquía
      const empresaResult = await query<{ empresaid: number }>(`
        SELECT empresaid FROM image.empresa WHERE empresa = @empresa
      `, { empresa: result.empresa });

      if (empresaResult.length === 0) {
        throw new Error(`Empresa no encontrada: ${result.empresa}`);
      }
      const empresaid = empresaResult[0].empresaid;

      const fundoResult = await query<{ fundoid: number }>(`
        SELECT fundoid FROM image.fundo WHERE fundo = @fundo AND empresaid = @empresaid
      `, { fundo: result.fundo, empresaid });

      if (fundoResult.length === 0) {
        throw new Error(`Fundo no encontrado: ${result.fundo} en empresa ${result.empresa}`);
      }
      const fundoid = fundoResult[0].fundoid;

      const sectorResult = await query<{ sectorid: number }>(`
        SELECT sectorid FROM image.sector WHERE sector = @sector AND fundoid = @fundoid
      `, { sector: result.sector, fundoid });

      if (sectorResult.length === 0) {
        throw new Error(`Sector no encontrado: ${result.sector} en fundo ${result.fundo}`);
      }
      const sectorid = sectorResult[0].sectorid;

      const loteResult = await query<{ loteid: number }>(`
        SELECT loteid FROM image.lote WHERE lote = @lote AND sectorid = @sectorid
      `, { lote: result.lote, sectorid });

      if (loteResult.length === 0) {
        throw new Error(`Lote no encontrado: ${result.lote} en sector ${result.sector}`);
      }
      const loteid = loteResult[0].loteid;

      // 2. Obtener usuario (por ahora usamos el primero disponible)
      const usuarioResult = await query<{ usuarioid: number }>(`
        SELECT TOP 1 usuarioid FROM image.usuario WHERE activo = 1 ORDER BY usuarioid
      `);

      const usuarioid = usuarioResult.length > 0 ? usuarioResult[0].usuarioid : 1;

      // 3. Insertar análisis
      const pool = await connectDb();
      const request = pool.request();

      request.input('loteid', sql.Int, loteid);
      request.input('usuarioid', sql.Int, usuarioid);
      request.input('nombre_archivo_original', sql.NVarChar(500), result.fileName);
      request.input('ruta_imagen_procesada', sql.NVarChar(1000), result.processed_image);
      request.input('porcentaje_luz', sql.Decimal(5, 2), parseFloat(result.porcentaje_luz.toFixed(2)));
      request.input('porcentaje_sombra', sql.Decimal(5, 2), parseFloat(result.porcentaje_sombra.toFixed(2)));
      request.input('hilera', sql.NVarChar(50), result.hilera || null);
      request.input('numero_planta', sql.NVarChar(50), result.numero_planta || null);
      request.input('latitud', sql.Decimal(10, 8), result.latitud);
      request.input('longitud', sql.Decimal(11, 8), result.longitud);
      request.input('dispositivo', sql.NVarChar(200), 'Web App');
      request.input('software', sql.NVarChar(200), 'Next.js + TensorFlow.js');
      request.input('direccion', sql.NVarChar(500), result.timestamp);

      const insertResult = await request.query(`
        INSERT INTO image.analisis_imagen (
          loteid, usuarioid, nombre_archivo_original, ruta_imagen_procesada,
          porcentaje_luz, porcentaje_sombra, hilera, numero_planta,
          latitud, longitud, dispositivo, software, direccion
        )
        OUTPUT INSERTED.analisisid
        VALUES (
          @loteid, @usuarioid, @nombre_archivo_original, @ruta_imagen_procesada,
          @porcentaje_luz, @porcentaje_sombra, @hilera, @numero_planta,
          @latitud, @longitud, @dispositivo, @software, @direccion
        )
      `);

      const analisisid = insertResult.recordset[0].analisisid;
      const saveTime = Date.now() - startTime;

      console.log(`✅ Processing result saved to SQL Server in ${saveTime}ms (ID: ${analisisid})`);

      // Clear cache to force refresh on next load
      this.historialCache = null;

      return analisisid;
    } catch (error) {
      console.error('❌ Error saving processing result to SQL Server:', error);
      throw error;
    }
  }

  /**
   * Procesa los datos crudos para crear la estructura jerárquica y listas únicas
   */
  private processFieldData(rawData: JerarquiaRow[]): FieldData {
    // Extraer listas únicas
    const empresas = [...new Set(rawData.map(item => item.empresa).filter(Boolean))].sort();
    const fundos = [...new Set(rawData.map(item => item.fundo).filter(Boolean))].sort();
    const sectores = [...new Set(rawData.map(item => item.sector).filter(Boolean))].sort();
    const lotes = [...new Set(rawData.map(item => item.lote).filter(Boolean))].sort();

    // Crear estructura jerárquica
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

    // Ordenar lotes dentro de cada sector
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

  /**
   * Limpia el cache (útil para testing o forzar refresh)
   */
  clearCache(): void {
    this.fieldDataCache = null;
    this.historialCache = null;
    console.log('🗑️ SQL Server service cache cleared');
  }

  /**
   * Verifica que la conexión a SQL Server esté funcionando
   */
  async testConnection(): Promise<boolean> {
    try {
      const result = await query<{ total: number }>('SELECT COUNT(*) as total FROM image.lote');
      console.log(`✅ SQL Server connection OK (${result[0].total} lotes)`);
      return true;
    } catch (error) {
      console.error('❌ SQL Server connection test failed:', error);
      return false;
    }
  }
}

export const sqlServerService = new SqlServerService();

