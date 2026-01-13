import { query } from '../lib/db';

export interface Umbral {
  umbralID: number;
  variedadID: number | null;
  usuarioCreaID: number | null;
  usuarioModificaID: number | null;
  tipo: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal';
  minPorcentajeLuz: number;
  maxPorcentajeLuz: number;
  descripcion: string | null;
  colorHex: string | null;
  orden: number;
  activo: boolean;
  fechaCreacion: Date;
  fechaModificacion: Date | null;
  statusID: number;
}

export interface UmbralWithVariety extends Umbral {
  variedadNombre?: string | null;
}

/**
 * Servicio para gestionar umbrales de luz
 */
class UmbralService {
  /**
   * Obtiene todos los umbrales activos
   */
  async getAllUmbrales(includeInactive: boolean = false): Promise<UmbralWithVariety[]> {
    try {
      const whereClause = includeInactive 
        ? 'WHERE u.statusID = 1' 
        : 'WHERE u.statusID = 1 AND u.activo = 1';

      const rows = await query<UmbralWithVariety>(`
        SELECT 
          u.umbralID,
          u.variedadID,
          u.usuarioCreaID,
          u.usuarioModificaID,
          u.tipo,
          u.minPorcentajeLuz,
          u.maxPorcentajeLuz,
          u.descripcion,
          u.colorHex,
          u.orden,
          u.activo,
          u.fechaCreacion,
          u.fechaModificacion,
          u.statusID,
          v.name AS variedadNombre
        FROM evalImagen.umbralLuz u
        LEFT JOIN GROWER.VARIETY v ON u.variedadID = v.varietyID
        ${whereClause}
        ORDER BY u.orden ASC, u.tipo ASC, u.minPorcentajeLuz ASC
      `);

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo umbrales:', error);
      throw error;
    }
  }

  /**
   * Obtiene un umbral por ID
   */
  async getUmbralById(umbralID: number): Promise<UmbralWithVariety | null> {
    try {
      const rows = await query<UmbralWithVariety>(`
        SELECT 
          u.umbralID,
          u.variedadID,
          u.usuarioCreaID,
          u.usuarioModificaID,
          u.tipo,
          u.minPorcentajeLuz,
          u.maxPorcentajeLuz,
          u.descripcion,
          u.colorHex,
          u.orden,
          u.activo,
          u.fechaCreacion,
          u.fechaModificacion,
          u.statusID,
          v.name AS variedadNombre
        FROM evalImagen.umbralLuz u
        LEFT JOIN GROWER.VARIETY v ON u.variedadID = v.varietyID
        WHERE u.umbralID = @umbralID
          AND u.statusID = 1
      `, { umbralID });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo umbral por ID:', error);
      throw error;
    }
  }

  /**
   * Obtiene umbrales por tipo
   */
  async getUmbralesByTipo(tipo: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal'): Promise<UmbralWithVariety[]> {
    try {
      const rows = await query<UmbralWithVariety>(`
        SELECT 
          u.umbralID,
          u.variedadID,
          u.usuarioCreaID,
          u.usuarioModificaID,
          u.tipo,
          u.minPorcentajeLuz,
          u.maxPorcentajeLuz,
          u.descripcion,
          u.colorHex,
          u.orden,
          u.activo,
          u.fechaCreacion,
          u.fechaModificacion,
          u.statusID,
          v.name AS variedadNombre
        FROM evalImagen.umbralLuz u
        LEFT JOIN GROWER.VARIETY v ON u.variedadID = v.varietyID
        WHERE u.tipo = @tipo
          AND u.statusID = 1
          AND u.activo = 1
        ORDER BY u.orden ASC, u.minPorcentajeLuz ASC
      `, { tipo });

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo umbrales por tipo:', error);
      throw error;
    }
  }

  /**
   * Obtiene umbrales por variedad (o globales si variedadID es null)
   */
  async getUmbralesByVariedad(variedadID: number | null): Promise<UmbralWithVariety[]> {
    try {
      const rows = await query<UmbralWithVariety>(`
        SELECT 
          u.umbralID,
          u.variedadID,
          u.usuarioCreaID,
          u.usuarioModificaID,
          u.tipo,
          u.minPorcentajeLuz,
          u.maxPorcentajeLuz,
          u.descripcion,
          u.colorHex,
          u.orden,
          u.activo,
          u.fechaCreacion,
          u.fechaModificacion,
          u.statusID,
          v.name AS variedadNombre
        FROM evalImagen.umbralLuz u
        LEFT JOIN GROWER.VARIETY v ON u.variedadID = v.varietyID
        WHERE (u.variedadID = @variedadID OR (u.variedadID IS NULL AND @variedadID IS NOT NULL))
          AND u.statusID = 1
          AND u.activo = 1
        ORDER BY 
          CASE WHEN u.variedadID IS NULL THEN 1 ELSE 0 END ASC,
          u.orden ASC,
          u.minPorcentajeLuz ASC
      `, { variedadID });

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo umbrales por variedad:', error);
      throw error;
    }
  }

  /**
   * Crea un nuevo umbral
   */
  async createUmbral(data: {
    variedadID: number | null;
    tipo: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal';
    minPorcentajeLuz: number;
    maxPorcentajeLuz: number;
    descripcion: string | null;
    colorHex: string | null;
    orden: number;
    activo: boolean;
    usuarioCreaID: number;
  }): Promise<number> {
    try {
      // Validar rangos
      if (data.minPorcentajeLuz < 0 || data.minPorcentajeLuz > 100) {
        throw new Error('minPorcentajeLuz debe estar entre 0 y 100');
      }
      if (data.maxPorcentajeLuz < 0 || data.maxPorcentajeLuz > 100) {
        throw new Error('maxPorcentajeLuz debe estar entre 0 y 100');
      }
      if (data.minPorcentajeLuz > data.maxPorcentajeLuz) {
        throw new Error('minPorcentajeLuz no puede ser mayor que maxPorcentajeLuz');
      }

      const result = await query<{ umbralID: number }>(`
        INSERT INTO evalImagen.umbralLuz (
          variedadID,
          tipo,
          minPorcentajeLuz,
          maxPorcentajeLuz,
          descripcion,
          colorHex,
          orden,
          activo,
          usuarioCreaID,
          fechaCreacion,
          statusID
        )
        OUTPUT INSERTED.umbralID
        VALUES (
          @variedadID,
          @tipo,
          @minPorcentajeLuz,
          @maxPorcentajeLuz,
          @descripcion,
          @colorHex,
          @orden,
          @activo,
          @usuarioCreaID,
          GETDATE(),
          1
        )
      `, {
        variedadID: data.variedadID,
        tipo: data.tipo,
        minPorcentajeLuz: data.minPorcentajeLuz,
        maxPorcentajeLuz: data.maxPorcentajeLuz,
        descripcion: data.descripcion || null,
        colorHex: data.colorHex || null,
        orden: data.orden,
        activo: data.activo ? 1 : 0,
        usuarioCreaID: data.usuarioCreaID
      });

      const umbralID = result[0]?.umbralID;
      if (!umbralID) {
        throw new Error('No se pudo crear el umbral');
      }

      return umbralID;
    } catch (error) {
      console.error('❌ Error creando umbral:', error);
      throw error;
    }
  }

  /**
   * Actualiza un umbral existente
   */
  async updateUmbral(umbralID: number, data: {
    variedadID?: number | null;
    tipo?: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal';
    minPorcentajeLuz?: number;
    maxPorcentajeLuz?: number;
    descripcion?: string | null;
    colorHex?: string | null;
    orden?: number;
    activo?: boolean;
    usuarioModificaID: number;
  }): Promise<boolean> {
    try {
      // Validar rangos si se proporcionan
      if (data.minPorcentajeLuz !== undefined) {
        if (data.minPorcentajeLuz < 0 || data.minPorcentajeLuz > 100) {
          throw new Error('minPorcentajeLuz debe estar entre 0 y 100');
        }
      }
      if (data.maxPorcentajeLuz !== undefined) {
        if (data.maxPorcentajeLuz < 0 || data.maxPorcentajeLuz > 100) {
          throw new Error('maxPorcentajeLuz debe estar entre 0 y 100');
        }
      }
      if (data.minPorcentajeLuz !== undefined && data.maxPorcentajeLuz !== undefined) {
        if (data.minPorcentajeLuz > data.maxPorcentajeLuz) {
          throw new Error('minPorcentajeLuz no puede ser mayor que maxPorcentajeLuz');
        }
      }

      const updates: string[] = [];
      const params: Record<string, unknown> = { umbralID, usuarioModificaID: data.usuarioModificaID };

      if (data.variedadID !== undefined) {
        updates.push('variedadID = @variedadID');
        params.variedadID = data.variedadID;
      }
      if (data.tipo !== undefined) {
        updates.push('tipo = @tipo');
        params.tipo = data.tipo;
      }
      if (data.minPorcentajeLuz !== undefined) {
        updates.push('minPorcentajeLuz = @minPorcentajeLuz');
        params.minPorcentajeLuz = data.minPorcentajeLuz;
      }
      if (data.maxPorcentajeLuz !== undefined) {
        updates.push('maxPorcentajeLuz = @maxPorcentajeLuz');
        params.maxPorcentajeLuz = data.maxPorcentajeLuz;
      }
      if (data.descripcion !== undefined) {
        updates.push('descripcion = @descripcion');
        params.descripcion = data.descripcion || null;
      }
      if (data.colorHex !== undefined) {
        updates.push('colorHex = @colorHex');
        params.colorHex = data.colorHex || null;
      }
      if (data.orden !== undefined) {
        updates.push('orden = @orden');
        params.orden = data.orden;
      }
      if (data.activo !== undefined) {
        updates.push('activo = @activo');
        params.activo = data.activo ? 1 : 0;
      }

      if (updates.length === 0) {
        throw new Error('No hay campos para actualizar');
      }

      updates.push('usuarioModificaID = @usuarioModificaID');
      updates.push('fechaModificacion = GETDATE()');

      await query(`
        UPDATE evalImagen.umbralLuz
        SET ${updates.join(', ')}
        WHERE umbralID = @umbralID
          AND statusID = 1
      `, params);

      return true;
    } catch (error) {
      console.error('❌ Error actualizando umbral:', error);
      throw error;
    }
  }

  /**
   * Elimina (soft delete) un umbral
   */
  async deleteUmbral(umbralID: number): Promise<boolean> {
    try {
      await query(`
        UPDATE evalImagen.umbralLuz
        SET statusID = 0,
            activo = 0,
            fechaModificacion = GETDATE()
        WHERE umbralID = @umbralID
          AND statusID = 1
      `, { umbralID });

      return true;
    } catch (error) {
      console.error('❌ Error eliminando umbral:', error);
      throw error;
    }
  }

  /**
   * Obtiene todas las variedades disponibles
   */
  async getVariedades(): Promise<Array<{ varietyID: number; name: string }>> {
    try {
      const rows = await query<{ varietyID: number; name: string }>(`
        SELECT varietyID, name
        FROM GROWER.VARIETY
        WHERE statusID = 1
        ORDER BY name ASC
      `);

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo variedades:', error);
      throw error;
    }
  }
}

export const umbralService = new UmbralService();

