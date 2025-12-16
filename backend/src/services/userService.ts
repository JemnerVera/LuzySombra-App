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

  /**
   * Obtiene todos los usuarios (sin passwordHash)
   */
  async getAllUsers(): Promise<Usuario[]> {
    try {
      const rows = await query<Usuario>(`
        SELECT 
          usuarioID,
          username,
          email,
          nombreCompleto,
          rol,
          activo,
          ultimoAcceso,
          intentosLogin,
          bloqueadoHasta,
          fechaCreacion,
          fechaModificacion
        FROM evalImagen.usuarioWeb
        WHERE statusID = 1
        ORDER BY fechaCreacion DESC
      `);

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo usuarios:', error);
      throw error;
    }
  }

  /**
   * Obtiene un usuario por ID (sin passwordHash)
   */
  async getUserById(usuarioID: number): Promise<Usuario | null> {
    try {
      const rows = await query<Usuario>(`
        SELECT 
          usuarioID,
          username,
          email,
          nombreCompleto,
          rol,
          activo,
          ultimoAcceso,
          intentosLogin,
          bloqueadoHasta,
          fechaCreacion,
          fechaModificacion
        FROM evalImagen.usuarioWeb
        WHERE usuarioID = @usuarioID
          AND statusID = 1
      `, { usuarioID });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo usuario:', error);
      throw error;
    }
  }

  /**
   * Crea un nuevo usuario
   */
  async createUser(data: {
    username: string;
    password: string;
    email: string;
    nombreCompleto?: string | null;
    rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
    activo?: boolean;
    usuarioCreaID: number;
  }): Promise<number> {
    try {
      // Verificar que el username no exista
      const existing = await this.findByUsername(data.username);
      if (existing) {
        throw new Error('El username ya existe');
      }

      // Hash de la contraseña
      const passwordHash = await this.hashPassword(data.password);

      const result = await query<{ usuarioID: number }>(`
        INSERT INTO evalImagen.usuarioWeb (
          username,
          passwordHash,
          email,
          nombreCompleto,
          rol,
          activo,
          intentosLogin,
          bloqueadoHasta,
          ultimoAcceso,
          statusID,
          usuarioCreaID,
          fechaCreacion,
          usuarioModificaID,
          fechaModificacion
        )
        OUTPUT INSERTED.usuarioID
        VALUES (
          @username,
          @passwordHash,
          @email,
          @nombreCompleto,
          @rol,
          @activo,
          0,
          NULL,
          NULL,
          1,
          @usuarioCreaID,
          GETDATE(),
          NULL,
          NULL
        )
      `, {
        username: data.username,
        passwordHash,
        email: data.email,
        nombreCompleto: data.nombreCompleto || null,
        rol: data.rol,
        activo: data.activo !== undefined ? data.activo : true,
        usuarioCreaID: data.usuarioCreaID
      });

      if (result.length === 0) {
        throw new Error('No se pudo crear el usuario');
      }

      return result[0].usuarioID;
    } catch (error) {
      console.error('❌ Error creando usuario:', error);
      throw error;
    }
  }

  /**
   * Actualiza un usuario
   */
  async updateUser(
    usuarioID: number,
    data: {
      username?: string;
      password?: string;
      email?: string;
      nombreCompleto?: string | null;
      rol?: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
      activo?: boolean;
      usuarioModificaID: number;
    }
  ): Promise<boolean> {
    try {
      const updates: string[] = [];
      const params: Record<string, unknown> = {
        usuarioID,
        usuarioModificaID: data.usuarioModificaID
      };

      if (data.username !== undefined) {
        // Verificar que el nuevo username no exista en otro usuario
        const existing = await this.findByUsername(data.username);
        if (existing && existing.usuarioID !== usuarioID) {
          throw new Error('El username ya existe');
        }
        updates.push('username = @username');
        params.username = data.username;
      }

      if (data.password !== undefined) {
        const passwordHash = await this.hashPassword(data.password);
        updates.push('passwordHash = @passwordHash');
        params.passwordHash = passwordHash;
      }

      if (data.email !== undefined) {
        updates.push('email = @email');
        params.email = data.email;
      }

      if (data.nombreCompleto !== undefined) {
        updates.push('nombreCompleto = @nombreCompleto');
        params.nombreCompleto = data.nombreCompleto;
      }

      if (data.rol !== undefined) {
        updates.push('rol = @rol');
        params.rol = data.rol;
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
        UPDATE evalImagen.usuarioWeb
        SET ${updates.join(', ')}
        WHERE usuarioID = @usuarioID
          AND statusID = 1
      `, params);

      return true;
    } catch (error) {
      console.error('❌ Error actualizando usuario:', error);
      throw error;
    }
  }

  /**
   * Elimina un usuario (soft delete)
   */
  async deleteUser(usuarioID: number, usuarioModificaID: number): Promise<boolean> {
    try {
      await query(`
        UPDATE evalImagen.usuarioWeb
        SET statusID = 0,
            usuarioModificaID = @usuarioModificaID,
            fechaModificacion = GETDATE()
        WHERE usuarioID = @usuarioID
          AND statusID = 1
      `, { usuarioID, usuarioModificaID });

      return true;
    } catch (error) {
      console.error('❌ Error eliminando usuario:', error);
      throw error;
    }
  }
}

export const userService = new UserService();

