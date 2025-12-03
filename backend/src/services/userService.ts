import bcrypt from 'bcrypt';
import { query } from '../lib/db';

export interface Usuario {
  usuarioID: number;
  username: string;
  email: string;
  nombreCompleto: string | null;
  rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
  activo: boolean;
  ultimoAcceso: Date | null;
}

export interface UsuarioConPassword extends Usuario {
  passwordHash: string;
}

/**
 * Servicio para gestionar usuarios web
 */
class UserService {
  private readonly bcryptRounds = parseInt(process.env.BCRYPT_ROUNDS || '10');

  /**
   * Busca un usuario por username
   */
  async findByUsername(username: string): Promise<UsuarioConPassword | null> {
    try {
      const rows = await query<UsuarioConPassword>(`
        SELECT 
          usuarioID,
          username,
          passwordHash,
          email,
          nombreCompleto,
          rol,
          activo,
          ultimoAcceso
        FROM evalImagen.usuarioWeb
        WHERE username = @username
          AND statusID = 1
      `, { username });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error buscando usuario:', error);
      throw error;
    }
  }

  /**
   * Verifica si la contraseña es correcta
   */
  async verifyPassword(
    password: string,
    passwordHash: string
  ): Promise<boolean> {
    try {
      return await bcrypt.compare(password, passwordHash);
    } catch (error) {
      console.error('❌ Error verificando contraseña:', error);
      return false;
    }
  }

  /**
   * Hashea una contraseña
   */
  async hashPassword(password: string): Promise<string> {
    return await bcrypt.hash(password, this.bcryptRounds);
  }

  /**
   * Actualiza último acceso del usuario
   */
  async updateLastAccess(usuarioID: number): Promise<void> {
    try {
      await query(`
        UPDATE evalImagen.usuarioWeb
        SET ultimoAcceso = GETDATE()
        WHERE usuarioID = @usuarioID
      `, { usuarioID });
    } catch (error) {
      console.warn('⚠️ No se pudo actualizar último acceso:', error);
    }
  }

  /**
   * Incrementa intentos de login fallidos
   */
  async incrementFailedAttempts(usuarioID: number): Promise<void> {
    try {
      await query(`
        UPDATE evalImagen.usuarioWeb
        SET intentosLogin = intentosLogin + 1,
            bloqueadoHasta = CASE 
              WHEN intentosLogin >= 4 THEN DATEADD(MINUTE, 15, GETDATE())
              ELSE bloqueadoHasta
            END
        WHERE usuarioID = @usuarioID
      `, { usuarioID });
    } catch (error) {
      console.warn('⚠️ No se pudo actualizar intentos:', error);
    }
  }

  /**
   * Resetea intentos de login fallidos
   */
  async resetFailedAttempts(usuarioID: number): Promise<void> {
    try {
      await query(`
        UPDATE evalImagen.usuarioWeb
        SET intentosLogin = 0,
            bloqueadoHasta = NULL
        WHERE usuarioID = @usuarioID
      `, { usuarioID });
    } catch (error) {
      console.warn('⚠️ No se pudo resetear intentos:', error);
    }
  }

  /**
   * Verifica si el usuario está bloqueado
   */
  async isUserBlocked(usuarioID: number): Promise<boolean> {
    try {
      const rows = await query<{ bloqueadoHasta: Date | null }>(`
        SELECT bloqueadoHasta
        FROM evalImagen.usuarioWeb
        WHERE usuarioID = @usuarioID
      `, { usuarioID });

      if (rows.length === 0) return true;

      const bloqueadoHasta = rows[0].bloqueadoHasta;
      if (!bloqueadoHasta) return false;

      // Si ya pasó el tiempo de bloqueo, desbloquear
      if (new Date(bloqueadoHasta) < new Date()) {
        await this.resetFailedAttempts(usuarioID);
        return false;
      }

      return true;
    } catch (error) {
      console.error('❌ Error verificando bloqueo:', error);
      return false;
    }
  }

  /**
   * Obtiene permisos del usuario según su rol
   */
  getPermissions(rol: string): string[] {
    const PERMISOS: Record<string, string[]> = {
      Admin: ['*'], // Todo
      Agronomo: [
        'umbrales:read',
        'umbrales:write',
        'alertas:read',
        'alertas:write',
        'alertas:resolve',
        'contactos:read',
        'contactos:write',
        'dashboard:read',
        'historial:read',
        'dispositivos:read'
      ],
      Supervisor: [
        'alertas:read',
        'alertas:resolve',
        'contactos:read',
        'dashboard:read',
        'historial:read'
      ],
      Lector: [
        'dashboard:read',
        'historial:read',
        'alertas:read'
      ]
    };

    return PERMISOS[rol] || PERMISOS['Lector'];
  }
}

export const userService = new UserService();

