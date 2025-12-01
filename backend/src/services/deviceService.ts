import { query } from '../lib/db';
import crypto from 'crypto';

export interface Dispositivo {
  dispositivoID: number;
  deviceId: string;
  apiKey: string;
  nombreDispositivo: string | null;
  modeloDispositivo: string | null;
  versionApp: string | null;
  activo: boolean;
  fechaRegistro: Date;
  ultimoAcceso: Date | null;
  statusID: number;
  usuarioCreaID: number;
  fechaCreacion: Date;
  usuarioModificaID: number | null;
  fechaModificacion: Date | null;
}

/**
 * Servicio para gestionar dispositivos (AgriQR)
 */
class DeviceService {
  /**
   * Genera una API key segura
   */
  generateApiKey(): string {
    return `luzsombra_${crypto.randomBytes(32).toString('hex')}`;
  }

  /**
   * Lista todos los dispositivos
   */
  async getAllDevices(): Promise<Dispositivo[]> {
    try {
      const devices = await query<Dispositivo>(`
        SELECT 
          dispositivoID,
          deviceId,
          apiKey,
          nombreDispositivo,
          modeloDispositivo,
          versionApp,
          activo,
          fechaRegistro,
          ultimoAcceso,
          statusID,
          usuarioCreaID,
          fechaCreacion,
          usuarioModificaID,
          fechaModificacion
        FROM evalImagen.Dispositivo
        WHERE statusID = 1
        ORDER BY fechaCreacion DESC
      `);

      return devices;
    } catch (error) {
      console.error('❌ Error obteniendo dispositivos:', error);
      throw error;
    }
  }

  /**
   * Obtiene un dispositivo por ID
   */
  async getDeviceById(dispositivoID: number): Promise<Dispositivo | null> {
    try {
      const devices = await query<Dispositivo>(`
        SELECT 
          dispositivoID,
          deviceId,
          apiKey,
          nombreDispositivo,
          modeloDispositivo,
          versionApp,
          activo,
          fechaRegistro,
          ultimoAcceso,
          statusID,
          usuarioCreaID,
          fechaCreacion,
          usuarioModificaID,
          fechaModificacion
        FROM evalImagen.Dispositivo
        WHERE dispositivoID = @dispositivoID
          AND statusID = 1
      `, { dispositivoID });

      return devices.length > 0 ? devices[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo dispositivo:', error);
      throw error;
    }
  }

  /**
   * Crea un nuevo dispositivo
   */
  async createDevice(data: {
    nombreDispositivo: string;
    modeloDispositivo?: string;
    versionApp?: string;
    usuarioCreaID: number;
  }): Promise<{ dispositivoID: number; apiKey: string }> {
    try {
      const apiKey = this.generateApiKey();
      const deviceId = `device_${Date.now()}_${Math.random().toString(36).substring(7)}`;

      const result = await query<{ dispositivoID: number }>(`
        INSERT INTO evalImagen.Dispositivo (
          deviceId,
          apiKey,
          nombreDispositivo,
          modeloDispositivo,
          versionApp,
          activo,
          fechaRegistro,
          usuarioCreaID,
          fechaCreacion,
          statusID
        )
        OUTPUT INSERTED.dispositivoID
        VALUES (
          @deviceId,
          @apiKey,
          @nombreDispositivo,
          @modeloDispositivo,
          @versionApp,
          1,
          GETDATE(),
          @usuarioCreaID,
          GETDATE(),
          1
        )
      `, {
        deviceId,
        apiKey,
        nombreDispositivo: data.nombreDispositivo,
        modeloDispositivo: data.modeloDispositivo || null,
        versionApp: data.versionApp || null,
        usuarioCreaID: data.usuarioCreaID
      });

      if (result.length === 0) {
        throw new Error('No se pudo crear el dispositivo');
      }

      return {
        dispositivoID: result[0].dispositivoID,
        apiKey
      };
    } catch (error) {
      console.error('❌ Error creando dispositivo:', error);
      throw error;
    }
  }

  /**
   * Actualiza un dispositivo
   */
  async updateDevice(
    dispositivoID: number,
    data: {
      nombreDispositivo?: string;
      modeloDispositivo?: string;
      versionApp?: string;
      activo?: boolean;
      usuarioModificaID: number;
    }
  ): Promise<boolean> {
    try {
      const updates: string[] = [];
      const params: Record<string, unknown> = { dispositivoID, usuarioModificaID: data.usuarioModificaID };

      if (data.nombreDispositivo !== undefined) {
        updates.push('nombreDispositivo = @nombreDispositivo');
        params.nombreDispositivo = data.nombreDispositivo;
      }

      if (data.modeloDispositivo !== undefined) {
        updates.push('modeloDispositivo = @modeloDispositivo');
        params.modeloDispositivo = data.modeloDispositivo;
      }

      if (data.versionApp !== undefined) {
        updates.push('versionApp = @versionApp');
        params.versionApp = data.versionApp;
      }

      if (data.activo !== undefined) {
        updates.push('activo = @activo');
        params.activo = data.activo;
      }

      if (updates.length === 0) {
        return true; // No hay cambios
      }

      updates.push('usuarioModificaID = @usuarioModificaID');
      updates.push('fechaModificacion = GETDATE()');

      await query(`
        UPDATE evalImagen.Dispositivo
        SET ${updates.join(', ')}
        WHERE dispositivoID = @dispositivoID
          AND statusID = 1
      `, params);

      return true;
    } catch (error) {
      console.error('❌ Error actualizando dispositivo:', error);
      throw error;
    }
  }

  /**
   * Regenera la API key de un dispositivo
   */
  async regenerateApiKey(dispositivoID: number, usuarioModificaID: number): Promise<string> {
    try {
      const newApiKey = this.generateApiKey();

      await query(`
        UPDATE evalImagen.Dispositivo
        SET apiKey = @apiKey,
            usuarioModificaID = @usuarioModificaID,
            fechaModificacion = GETDATE()
        WHERE dispositivoID = @dispositivoID
          AND statusID = 1
      `, { dispositivoID, apiKey: newApiKey, usuarioModificaID });

      return newApiKey;
    } catch (error) {
      console.error('❌ Error regenerando API key:', error);
      throw error;
    }
  }

  /**
   * Elimina un dispositivo (soft delete)
   */
  async deleteDevice(dispositivoID: number, usuarioModificaID: number): Promise<boolean> {
    try {
      await query(`
        UPDATE evalImagen.Dispositivo
        SET statusID = 0,
            usuarioModificaID = @usuarioModificaID,
            fechaModificacion = GETDATE()
        WHERE dispositivoID = @dispositivoID
      `, { dispositivoID, usuarioModificaID });

      return true;
    } catch (error) {
      console.error('❌ Error eliminando dispositivo:', error);
      throw error;
    }
  }

  /**
   * Obtiene estadísticas de uso de un dispositivo
   */
  async getDeviceStats(dispositivoID: number): Promise<{
    totalAccesos: number;
    ultimoAcceso: Date | null;
    diasInactivo: number;
  }> {
    try {
      const device = await this.getDeviceById(dispositivoID);
      
      if (!device) {
        throw new Error('Dispositivo no encontrado');
      }

      // Contar accesos (basado en AnalisisImagen creados por este dispositivo)
      // Nota: Esto es una aproximación, ya que no tenemos un campo directo que relacione
      const diasInactivo = device.ultimoAcceso
        ? Math.floor((Date.now() - new Date(device.ultimoAcceso).getTime()) / (1000 * 60 * 60 * 24))
        : 999;

      return {
        totalAccesos: 0, // Se puede calcular con una query más compleja si es necesario
        ultimoAcceso: device.ultimoAcceso,
        diasInactivo
      };
    } catch (error) {
      console.error('❌ Error obteniendo estadísticas:', error);
      throw error;
    }
  }
}

export const deviceService = new DeviceService();

