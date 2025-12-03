import { query, executeProcedure, sql } from '../lib/db';
import crypto from 'crypto';
import bcrypt from 'bcrypt';

export interface Dispositivo {
  dispositivoID: number;
  deviceId: string;
  apiKey?: string; // Solo para respuesta (no se almacena)
  apiKeyHash: string; // Hash almacenado en BD
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
   * Hashea una API key usando bcrypt
   */
  async hashApiKey(apiKey: string): Promise<string> {
    const saltRounds = 10;
    return await bcrypt.hash(apiKey, saltRounds);
  }

  /**
   * Compara una API key con su hash
   */
  async compareApiKey(apiKey: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(apiKey, hash);
  }

  /**
   * Lista todos los dispositivos
   * NOTA: No retorna apiKeyHash por seguridad
   */
  async getAllDevices(): Promise<Omit<Dispositivo, 'apiKeyHash'>[]> {
    try {
      const devices = await query<Dispositivo>(`
        SELECT 
          dispositivoID,
          deviceId,
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
        FROM evalImagen.dispositivo
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
   * NOTA: No retorna apiKeyHash por seguridad
   */
  async getDeviceById(dispositivoID: number): Promise<Omit<Dispositivo, 'apiKeyHash'> | null> {
    try {
      const devices = await query<Dispositivo>(`
        SELECT 
          dispositivoID,
          deviceId,
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
        FROM evalImagen.dispositivo
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
   * Obtiene dispositivo con hash para autenticación (solo para uso interno)
   */
  async getDeviceForAuth(deviceId: string): Promise<{
    dispositivoID: number;
    deviceId: string;
    apiKeyHash: string;
    nombreDispositivo: string | null;
    activo: boolean;
  } | null> {
    try {
      const result = await executeProcedure(
        'evalImagen.usp_evalImagen_getDeviceForAuth',
        { deviceId },
        [],
        {}
      );

      if (result.recordset && result.recordset.length > 0) {
        return result.recordset[0];
      }

      return null;
    } catch (error) {
      console.error('❌ Error obteniendo dispositivo para auth:', error);
      return null;
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
      const apiKeyHash = await this.hashApiKey(apiKey);
      const deviceId = `device_${Date.now()}_${Math.random().toString(36).substring(7)}`;

      const result = await query<{ dispositivoID: number }>(`
        INSERT INTO evalImagen.dispositivo (
          deviceId,
          apiKeyHash,
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
          @apiKeyHash,
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
        apiKeyHash,
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
        apiKey // Retornar la key en texto plano solo una vez
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
        UPDATE evalImagen.dispositivo
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
      const newApiKeyHash = await this.hashApiKey(newApiKey);

      await query(`
        UPDATE evalImagen.dispositivo
        SET apiKeyHash = @apiKeyHash,
            usuarioModificaID = @usuarioModificaID,
            fechaModificacion = GETDATE()
        WHERE dispositivoID = @dispositivoID
          AND statusID = 1
      `, { dispositivoID, apiKeyHash: newApiKeyHash, usuarioModificaID });

      return newApiKey; // Retornar la key en texto plano solo una vez
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
        UPDATE evalImagen.dispositivo
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

  /**
   * Obtiene dispositivo por código de activación
   */
  async getDeviceByActivationCode(activationCode: string): Promise<{
    dispositivoID: number;
    deviceId: string;
    activo: boolean;
    activationCodeExpires: Date | null;
  } | null> {
    try {
      const result = await query<{
        dispositivoID: number;
        deviceId: string;
        activo: boolean;
        activationCodeExpires: Date | null;
      }>(`
        SELECT 
          dispositivoID,
          deviceId,
          activo,
          activationCodeExpires
        FROM evalImagen.dispositivo
        WHERE activationCode = @activationCode
          AND statusID = 1
      `, { activationCode });

      return result.length > 0 ? result[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo dispositivo por código:', error);
      return null;
    }
  }

  /**
   * Limpia código de activación (después de usarse)
   */
  async clearActivationCode(dispositivoID: number): Promise<boolean> {
    try {
      await query(`
        UPDATE evalImagen.dispositivo
        SET activationCode = NULL,
            activationCodeExpires = NULL,
            ultimoAcceso = GETDATE()
        WHERE dispositivoID = @dispositivoID
      `, { dispositivoID });

      return true;
    } catch (error) {
      console.error('❌ Error limpiando código de activación:', error);
      return false;
    }
  }

  /**
   * Genera código de activación para un dispositivo
   */
  async generateActivationCode(
    dispositivoID: number,
    operarioNombre?: string,
    usuarioModificaID: number = 1
  ): Promise<{ activationCode: string; expiresAt: Date }> {
    try {
      const activationCode = `luzsombra_${crypto.randomBytes(32).toString('hex')}`;
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 horas

      const updates: string[] = [];
      const params: Record<string, unknown> = {
        dispositivoID,
        activationCode,
        expiresAt,
        usuarioModificaID
      };

      updates.push('activationCode = @activationCode');
      updates.push('activationCodeExpires = @expiresAt');

      if (operarioNombre) {
        updates.push('operarioNombre = @operarioNombre');
        updates.push('fechaAsignacion = GETDATE()');
        params.operarioNombre = operarioNombre.trim();
      }

      updates.push('usuarioModificaID = @usuarioModificaID');
      updates.push('fechaModificacion = GETDATE()');

      await query(`
        UPDATE evalImagen.dispositivo
        SET ${updates.join(', ')}
        WHERE dispositivoID = @dispositivoID
          AND statusID = 1
      `, params);

      return { activationCode, expiresAt };
    } catch (error) {
      console.error('❌ Error generando código de activación:', error);
      throw error;
    }
  }
}

export const deviceService = new DeviceService();

