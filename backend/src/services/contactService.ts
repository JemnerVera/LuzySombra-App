import { query } from '../lib/db';

export interface Contacto {
  contactoID: number;
  nombre: string;
  email: string;
  telefono: string | null;
  tipo: 'General' | 'Admin' | 'Agronomo' | 'Manager' | 'Supervisor' | 'Tecnico' | 'Otro';
  rol: string | null;
  recibirAlertasCriticas: boolean;
  recibirAlertasAdvertencias: boolean;
  recibirAlertasNormales: boolean;
  fundoID: string | null;
  sectorID: number | null;
  prioridad: number;
  activo: boolean;
  fechaCreacion: Date;
  fechaModificacion: Date | null;
  usuarioCreaID: number | null;
  usuarioModificaID: number | null;
  statusID: number;
}

export interface ContactoWithLocation extends Contacto {
  fundoNombre?: string | null;
  sectorNombre?: string | null;
}

/**
 * Servicio para gestionar contactos
 */
class ContactService {
  /**
   * Obtiene todos los contactos
   */
  async getAllContactos(includeInactive: boolean = false): Promise<ContactoWithLocation[]> {
    try {
      const whereClause = includeInactive 
        ? 'WHERE c.statusID = 1' 
        : 'WHERE c.statusID = 1 AND c.activo = 1';

      const rows = await query<ContactoWithLocation>(`
        SELECT 
          c.contactoID,
          c.nombre,
          c.email,
          c.telefono,
          c.tipo,
          c.rol,
          c.recibirAlertasCriticas,
          c.recibirAlertasAdvertencias,
          c.recibirAlertasNormales,
          c.fundoID,
          c.sectorID,
          c.prioridad,
          c.activo,
          c.fechaCreacion,
          c.fechaModificacion,
          c.usuarioCreaID,
          c.usuarioModificaID,
          c.statusID,
          f.Description AS fundoNombre,
          s.stage AS sectorNombre
        FROM evalImagen.contacto c
        LEFT JOIN GROWER.FARMS f ON c.fundoID = f.farmID
        LEFT JOIN GROWER.STAGE s ON c.sectorID = s.stageID
        ${whereClause}
        ORDER BY c.prioridad DESC, c.nombre ASC
      `);

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo contactos:', error);
      throw error;
    }
  }

  /**
   * Obtiene un contacto por ID
   */
  async getContactoById(contactoID: number): Promise<ContactoWithLocation | null> {
    try {
      const rows = await query<ContactoWithLocation>(`
        SELECT 
          c.contactoID,
          c.nombre,
          c.email,
          c.telefono,
          c.tipo,
          c.rol,
          c.recibirAlertasCriticas,
          c.recibirAlertasAdvertencias,
          c.recibirAlertasNormales,
          c.fundoID,
          c.sectorID,
          c.prioridad,
          c.activo,
          c.fechaCreacion,
          c.fechaModificacion,
          c.usuarioCreaID,
          c.usuarioModificaID,
          c.statusID,
          f.Description AS fundoNombre,
          s.stage AS sectorNombre
        FROM evalImagen.contacto c
        LEFT JOIN GROWER.FARMS f ON c.fundoID = f.farmID
        LEFT JOIN GROWER.STAGE s ON c.sectorID = s.stageID
        WHERE c.contactoID = @contactoID
          AND c.statusID = 1
      `, { contactoID });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo contacto por ID:', error);
      throw error;
    }
  }

  /**
   * Crea un nuevo contacto
   */
  async createContacto(data: {
    nombre: string;
    email: string;
    telefono?: string | null;
    tipo: 'General' | 'Admin' | 'Agronomo' | 'Manager' | 'Supervisor' | 'Tecnico' | 'Otro';
    rol?: string | null;
    recibirAlertasCriticas: boolean;
    recibirAlertasAdvertencias: boolean;
    recibirAlertasNormales: boolean;
    fundoID?: string | null;
    sectorID?: number | null;
    prioridad: number;
    activo: boolean;
    usuarioCreaID: number;
  }): Promise<number> {
    try {
      // Validar email único
      const existing = await query<{ contactoID: number }>(`
        SELECT contactoID
        FROM evalImagen.contacto
        WHERE email = @email
          AND statusID = 1
      `, { email: data.email });

      if (existing.length > 0) {
        throw new Error(`El email ${data.email} ya está registrado`);
      }

      const result = await query<{ contactoID: number }>(`
        INSERT INTO evalImagen.contacto (
          nombre,
          email,
          telefono,
          tipo,
          rol,
          recibirAlertasCriticas,
          recibirAlertasAdvertencias,
          recibirAlertasNormales,
          fundoID,
          sectorID,
          prioridad,
          activo,
          usuarioCreaID,
          fechaCreacion,
          statusID
        )
        OUTPUT INSERTED.contactoID
        VALUES (
          @nombre,
          @email,
          @telefono,
          @tipo,
          @rol,
          @recibirAlertasCriticas,
          @recibirAlertasAdvertencias,
          @recibirAlertasNormales,
          @fundoID,
          @sectorID,
          @prioridad,
          @activo,
          @usuarioCreaID,
          GETDATE(),
          1
        )
      `, {
        nombre: data.nombre,
        email: data.email,
        telefono: data.telefono || null,
        tipo: data.tipo,
        rol: data.rol || null,
        recibirAlertasCriticas: data.recibirAlertasCriticas ? 1 : 0,
        recibirAlertasAdvertencias: data.recibirAlertasAdvertencias ? 1 : 0,
        recibirAlertasNormales: data.recibirAlertasNormales ? 1 : 0,
        fundoID: data.fundoID || null,
        sectorID: data.sectorID || null,
        prioridad: data.prioridad,
        activo: data.activo ? 1 : 0,
        usuarioCreaID: data.usuarioCreaID
      });

      const contactoID = result[0]?.contactoID;
      if (!contactoID) {
        throw new Error('No se pudo crear el contacto');
      }

      console.log(`✅ Contacto ${contactoID} creado exitosamente`);
      return contactoID;
    } catch (error) {
      console.error('❌ Error creando contacto:', error);
      throw error;
    }
  }

  /**
   * Actualiza un contacto existente
   */
  async updateContacto(contactoID: number, data: {
    nombre?: string;
    email?: string;
    telefono?: string | null;
    tipo?: 'General' | 'Admin' | 'Agronomo' | 'Manager' | 'Supervisor' | 'Tecnico' | 'Otro';
    rol?: string | null;
    recibirAlertasCriticas?: boolean;
    recibirAlertasAdvertencias?: boolean;
    recibirAlertasNormales?: boolean;
    fundoID?: string | null;
    sectorID?: number | null;
    prioridad?: number;
    activo?: boolean;
    usuarioModificaID: number;
  }): Promise<boolean> {
    try {
      // Validar email único si se está cambiando
      if (data.email) {
        const existing = await query<{ contactoID: number }>(`
          SELECT contactoID
          FROM evalImagen.contacto
          WHERE email = @email
            AND contactoID != @contactoID
            AND statusID = 1
        `, { email: data.email, contactoID });

        if (existing.length > 0) {
          throw new Error(`El email ${data.email} ya está registrado en otro contacto`);
        }
      }

      const updates: string[] = [];
      const params: Record<string, unknown> = { contactoID, usuarioModificaID: data.usuarioModificaID };

      if (data.nombre !== undefined) {
        updates.push('nombre = @nombre');
        params.nombre = data.nombre;
      }
      if (data.email !== undefined) {
        updates.push('email = @email');
        params.email = data.email;
      }
      if (data.telefono !== undefined) {
        updates.push('telefono = @telefono');
        params.telefono = data.telefono || null;
      }
      if (data.tipo !== undefined) {
        updates.push('tipo = @tipo');
        params.tipo = data.tipo;
      }
      if (data.rol !== undefined) {
        updates.push('rol = @rol');
        params.rol = data.rol || null;
      }
      if (data.recibirAlertasCriticas !== undefined) {
        updates.push('recibirAlertasCriticas = @recibirAlertasCriticas');
        params.recibirAlertasCriticas = data.recibirAlertasCriticas ? 1 : 0;
      }
      if (data.recibirAlertasAdvertencias !== undefined) {
        updates.push('recibirAlertasAdvertencias = @recibirAlertasAdvertencias');
        params.recibirAlertasAdvertencias = data.recibirAlertasAdvertencias ? 1 : 0;
      }
      if (data.recibirAlertasNormales !== undefined) {
        updates.push('recibirAlertasNormales = @recibirAlertasNormales');
        params.recibirAlertasNormales = data.recibirAlertasNormales ? 1 : 0;
      }
      if (data.fundoID !== undefined) {
        updates.push('fundoID = @fundoID');
        params.fundoID = data.fundoID || null;
      }
      if (data.sectorID !== undefined) {
        updates.push('sectorID = @sectorID');
        params.sectorID = data.sectorID || null;
      }
      if (data.prioridad !== undefined) {
        updates.push('prioridad = @prioridad');
        params.prioridad = data.prioridad;
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
        UPDATE evalImagen.contacto
        SET ${updates.join(', ')}
        WHERE contactoID = @contactoID
          AND statusID = 1
      `, params);

      console.log(`✅ Contacto ${contactoID} actualizado exitosamente`);
      return true;
    } catch (error) {
      console.error('❌ Error actualizando contacto:', error);
      throw error;
    }
  }

  /**
   * Elimina (soft delete) un contacto
   */
  async deleteContacto(contactoID: number): Promise<boolean> {
    try {
      await query(`
        UPDATE evalImagen.contacto
        SET statusID = 0,
            activo = 0,
            fechaModificacion = GETDATE()
        WHERE contactoID = @contactoID
          AND statusID = 1
      `, { contactoID });

      console.log(`✅ Contacto ${contactoID} eliminado exitosamente`);
      return true;
    } catch (error) {
      console.error('❌ Error eliminando contacto:', error);
      throw error;
    }
  }
}

export const contactService = new ContactService();

