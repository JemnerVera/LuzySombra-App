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
  growerID?: string;  // Para compatibilidad con GROWER.GROWERS
  farmID?: string;    // Para compatibilidad con GROWER.FARMS
  stageID?: number;   // Para compatibilidad con GROWER.STAGE
  lotID?: number;     // Para compatibilidad con GROWER.LOT
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

      // Usar tablas GROWER de AgroMigiva (BD_PACKING_AGROMIGIVA_DESA)
      const rows = await query<JerarquiaRow>(`
        SELECT 
          g.businessName as empresa,
          f.Description as fundo,
          s.stage as sector,
          l.name as lote,
          g.growerID,
          f.farmID,
          s.stageID,
          l.lotID
        FROM GROWER.LOT l
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        INNER JOIN GROWER.GROWERS g ON f.growerID = g.growerID
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

      // Build dynamic query with filters (usando abreviaturas para sector y lote)
      let whereClause = 'WHERE 1=1';
      const params: Record<string, string> = {};

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

      const queryStr = `
        SELECT TOP ${limit}
          a.analisisID,
          a.dateCreated as fecha_procesamiento,
          a.filename as nombre_archivo_original,
          g.businessName as empresa,
          f.Description as fundo,
          s.stage as sector,
          l.name as lote,
          a.hilera,
          a.planta as numero_planta,
          a.latitud,
          a.longitud,
          a.porcentaje_luz,
          a.porcentaje_sombra,
          '' as dispositivo,
          '' as software,
          '' as direccion
        FROM IMAGE.ANALISIS_IMAGEN a
        INNER JOIN GROWER.LOT l ON a.lotID = l.lotID
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        INNER JOIN GROWER.GROWERS g ON f.growerID = g.growerID
        WHERE a.statusID = 1
        ${whereClause}
        ORDER BY a.dateCreated DESC
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
      console.log('📋 Data received:', {
        empresa: result.empresa,
        fundo: result.fundo,
        sector: result.sector,
        lote: result.lote,
        fileName: result.fileName
      });
      const startTime = Date.now();

      // 1. Obtener IDs de la jerarquía usando tablas GROWER de AgroMigiva
      console.log('🔍 Buscando empresa:', result.empresa);
      const empresaResult = await query<{ growerID: string }>(`
        SELECT growerID FROM GROWER.GROWERS 
        WHERE businessName = @empresa AND statusID = 1
      `, { empresa: result.empresa });

      if (empresaResult.length === 0) {
        throw new Error(`Empresa no encontrada: ${result.empresa}`);
      }
      const growerID = empresaResult[0].growerID;
      console.log('✅ Empresa encontrada, ID:', growerID);

      console.log('🔍 Buscando fundo:', result.fundo);
      const fundoResult = await query<{ farmID: string }>(`
        SELECT farmID FROM GROWER.FARMS 
        WHERE Description = @fundo AND growerID = @growerID AND statusID = 1
      `, { fundo: result.fundo, growerID });

      if (fundoResult.length === 0) {
        throw new Error(`Fundo no encontrado: ${result.fundo} en empresa ${result.empresa}`);
      }
      const farmID = fundoResult[0].farmID;
      console.log('✅ Fundo encontrado, ID:', farmID);

      console.log('🔍 Buscando sector:', result.sector);
      const sectorResult = await query<{ stageID: number }>(`
        SELECT stageID FROM GROWER.STAGE 
        WHERE stage = @sector AND farmID = @farmID AND statusID = 1
      `, { sector: result.sector, farmID });

      if (sectorResult.length === 0) {
        throw new Error(`Sector no encontrado: ${result.sector} en fundo ${result.fundo}`);
      }
      const stageID = sectorResult[0].stageID;
      console.log('✅ Sector encontrado, ID:', stageID);

      console.log('🔍 Buscando lote:', result.lote);
      const loteResult = await query<{ lotID: number }>(`
        SELECT lotID FROM GROWER.LOT 
        WHERE name = @lote AND stageID = @stageID AND statusID = 1
      `, { lote: result.lote, stageID });

      if (loteResult.length === 0) {
        throw new Error(`Lote no encontrado: ${result.lote} en sector ${result.sector}`);
      }
      const lotID = loteResult[0].lotID;
      console.log('✅ Lote encontrado, ID:', lotID);

      // 2. Obtener usuario de MAST.USERS
      // Estructura verificada: userID (int, PK), statusID (int, NO NULL)
      // No existe columna 'active', solo 'statusID'
      let userCreatedID = 1; // Valor por defecto
      try {
        const usuarioResult = await query<{ userID: number }>(`
          SELECT TOP 1 userID 
          FROM MAST.USERS 
          WHERE statusID = 1 
          ORDER BY userID
        `);
        
        if (usuarioResult.length > 0 && usuarioResult[0].userID) {
          userCreatedID = Number(usuarioResult[0].userID);
          console.log('✅ Usuario ID obtenido de MAST.USERS:', userCreatedID);
        } else {
          console.log('ℹ️ No se encontraron usuarios activos, usando valor por defecto:', userCreatedID);
        }
      } catch (userError) {
        console.warn('⚠️ Error al obtener usuario de MAST.USERS, usando valor por defecto:', userError);
        // Usar valor por defecto (1) si falla
      }

      // 3. Insertar análisis (usando el schema real)
      console.log('💾 Preparando INSERT...');
      const pool = await connectDb();
      const request = pool.request();

      request.input('lotID', sql.Int, lotID);
      request.input('hilera', sql.NVarChar(50), result.hilera || '');
      request.input('planta', sql.NVarChar(50), result.numero_planta || '');
      request.input('filename', sql.NVarChar(500), result.fileName);
      request.input('filepath', sql.NVarChar(sql.MAX), result.processed_image); // Base64 puede ser muy largo
      
      // Fecha de captura desde EXIF si está disponible
      let fechaCaptura = null;
      if (result.exifDateTime) {
        try {
          // Convertir fecha EXIF a DATETIME (formato: DD/MM/YYYY HH:MM:SS)
          const [day, month, year] = result.exifDateTime.date.split('/');
          const [hour, minute, second] = result.exifDateTime.time.split(':');
          fechaCaptura = new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}`);
        } catch (e) {
          console.warn('⚠️ Error parsing EXIF date:', e);
        }
      }
      
      request.input('fecha_captura', sql.DateTime, fechaCaptura);
      request.input('porcentaje_luz', sql.Decimal(5, 2), parseFloat(result.porcentaje_luz.toFixed(2)));
      request.input('porcentaje_sombra', sql.Decimal(5, 2), parseFloat(result.porcentaje_sombra.toFixed(2)));
      request.input('latitud', sql.Decimal(10, 8), result.latitud);
      request.input('longitud', sql.Decimal(11, 8), result.longitud);
      request.input('processed_image_url', sql.NVarChar(sql.MAX), result.processed_image); // Base64 puede ser muy largo
      request.input('userCreatedID', sql.Int, userCreatedID);

      console.log('💾 Ejecutando INSERT en IMAGE.ANALISIS_IMAGEN...');
      const insertResult = await request.query(`
        INSERT INTO IMAGE.ANALISIS_IMAGEN (
          lotID, hilera, planta, filename, filepath, fecha_captura,
          porcentaje_luz, porcentaje_sombra, latitud, longitud,
          processed_image_url, userCreatedID, statusID
        )
        OUTPUT INSERTED.analisisID
        VALUES (
          @lotID, @hilera, @planta, @filename, @filepath, @fecha_captura,
          @porcentaje_luz, @porcentaje_sombra, @latitud, @longitud,
          @processed_image_url, @userCreatedID, 1
        )
      `);

      const analisisID = insertResult.recordset[0].analisisID;
      const saveTime = Date.now() - startTime;

      console.log(`✅ Processing result saved to SQL Server in ${saveTime}ms (ID: ${analisisID})`);

      // Clear cache to force refresh on next load
      this.historialCache = null;

      return analisisID;
    } catch (error: any) {
      console.error('❌ Error saving processing result to SQL Server:', error);
      
      // Detectar error de duplicado (UNIQUE constraint violation)
      if (error.number === 2627 || error.number === 2601) {
        throw new Error(`Esta imagen ya fue procesada anteriormente para el lote "${result.lote}". Archivo: ${result.fileName}`);
      }
      
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

