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
  imagen_url?: string | null; // URL o Base64 de la imagen procesada
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
  tieneImagen: number; // 1 si tiene imagen, 0 si no
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
      // Nota: growerID está en STAGE, no en FARMS
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
      
      // Debug: Log primeros registros para verificar columnas
      if (rows.length > 0) {
        console.log('📊 Sample row (raw):', JSON.stringify(rows[0], null, 2));
        console.log('📊 Sample row values:', {
          empresa: rows[0].empresa,
          fundo: rows[0].fundo,
          sector: rows[0].sector,
          lote: rows[0].lote
        });
        console.log('📊 First 3 empresas:', [...new Set(rows.slice(0, 10).map(r => r.empresa))]);
        console.log('📊 First 3 fundos:', [...new Set(rows.slice(0, 10).map(r => r.fundo))]);
      }

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
      console.log(`📊 Empresas encontradas:`, processedData.empresa.slice(0, 5));
      console.log(`📊 Fundos encontrados:`, processedData.fundo.slice(0, 5));
      console.log(`📊 Sectores encontrados:`, processedData.sector.slice(0, 5));
      console.log(`📊 Lotes encontrados:`, processedData.lote.slice(0, 5));

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
    page?: number;
    pageSize?: number;
  }): Promise<{ success: boolean; procesamientos: ProcessingRecord[]; total: number; page: number; pageSize: number; totalPages: number }> {
    try {
      // Check cache first (only if no filters and no pagination)
      if (!filters && !filters?.page && this.historialCache && (Date.now() - this.historialCache.timestamp) < this.cacheTimeout) {
        console.log('📊 Using cached history data from SQL Server');
        const cachedData = this.historialCache.data;
        // Si hay paginación solicitada, aplicar paginación en memoria (solo para primera página)
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

      // Configuración de paginación
      const pageSize = filters?.pageSize || filters?.limit || 50; // Default 50 registros por página
      const page = filters?.page || 1;
      const offset = (page - 1) * pageSize;

      // Build dynamic query with filters
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

      // Primero obtener el total de registros (para paginación)
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

      // Query principal con paginación usando OFFSET/FETCH (más eficiente que TOP)
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

      // Agregar parámetros de paginación
      params.offset = offset;
      params.pageSize = pageSize;

      const rows = await query<AnalisisRow>(queryStr, params);

      const fetchTime = Date.now() - startTime;
      console.log(`📊 SQL Server history fetch completed in ${fetchTime}ms (${rows.length} records)`);

      const historial: ProcessingRecord[] = rows.map((row, index) => {
        const fecha = new Date(row.fecha_procesamiento);
        // Construir URL para cargar imagen bajo demanda (lazy loading)
        const tieneImagen = row.tieneImagen ?? 0;
        const imagenUrl = tieneImagen === 1
          ? `/api/imagen/${row.analisisid}` // URL del endpoint para cargar imagen bajo demanda
          : null;
        
        return {
          id: row.analisisid.toString(),
          fecha: fecha.toLocaleDateString('es-ES'),
          hora: fecha.toLocaleTimeString('es-ES'),
          imagen: row.nombre_archivo_original || '',
          nombre_archivo: row.nombre_archivo_original || '',
          imagen_url: imagenUrl, // URL para cargar imagen bajo demanda (no Base64 en el historial)
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

      // Cache the result (only if no filters)
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
    thumbnail?: string; // Thumbnail optimizado para guardar en BD
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
      // FARMS no tiene growerID directamente, hay que buscar a través de STAGE
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
      
      // Guardar thumbnail optimizado en processedImageUrl
      const thumbnailBase64 = result.thumbnail || null;
      request.input('processedImageUrl', sql.NVarChar(sql.MAX), thumbnailBase64);
      
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
      
      request.input('fechaCaptura', sql.DateTime, fechaCaptura);
      request.input('porcentajeLuz', sql.Decimal(5, 2), parseFloat(result.porcentaje_luz.toFixed(2)));
      request.input('porcentajeSombra', sql.Decimal(5, 2), parseFloat(result.porcentaje_sombra.toFixed(2)));
      request.input('latitud', sql.Decimal(10, 8), result.latitud);
      request.input('longitud', sql.Decimal(11, 8), result.longitud);
      request.input('usuarioCreaID', sql.Int, userCreatedID);

      const thumbnailInfo = thumbnailBase64 ? `con thumbnail (~${Math.round((thumbnailBase64.length * 3) / 4 / 1024)} KB)` : 'sin imagen';
      console.log(`💾 Ejecutando INSERT en image.Analisis_Imagen ${thumbnailInfo}...`);
      const insertResult = await request.query(`
        INSERT INTO image.Analisis_Imagen (
          lotID, hilera, planta, filename, fechaCaptura,
          porcentajeLuz, porcentajeSombra, latitud, longitud,
          processedImageUrl, usuarioCreaID, statusID
        )
        OUTPUT INSERTED.analisisID
        VALUES (
          @lotID, @hilera, @planta, @filename, @fechaCaptura,
          @porcentajeLuz, @porcentajeSombra, @latitud, @longitud,
          @processedImageUrl, @usuarioCreaID, 1
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
    // Debug: Verificar estructura de datos recibidos
    if (rawData.length > 0) {
      const firstRow = rawData[0];
      console.log('📊 Processing field data - First row keys:', Object.keys(firstRow));
      console.log('📊 Processing field data - Sample values:', {
        empresa: firstRow.empresa,
        fundo: firstRow.fundo,
        sector: firstRow.sector,
        lote: firstRow.lote
      });
    }
    
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

