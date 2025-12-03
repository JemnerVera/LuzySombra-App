import { executeProcedure, sql } from '../lib/db';

/**
 * Servicio para gestionar rate limiting de intentos de login
 */
class RateLimitService {
  private readonly maxIntentos = 5;
  private readonly minutosVentana = 15;

  /**
   * Verifica si un dispositivo/IP está bloqueado por rate limiting
   */
  async checkRateLimit(
    deviceId?: string,
    username?: string,
    ipAddress: string = 'unknown'
  ): Promise<{ estaBloqueado: boolean; intentosRestantes: number }> {
    try {
      const result = await executeProcedure(
        'evalImagen.sp_CheckRateLimit',
        {
          deviceId: deviceId || null,
          username: username || null,
          ipAddress,
          maxIntentos: this.maxIntentos,
          minutosVentana: this.minutosVentana
        },
        ['estaBloqueado', 'intentosRestantes'],
        {
          estaBloqueado: sql.Bit,
          intentosRestantes: sql.Int
        }
      );

      const output = result.output;
      return {
        estaBloqueado: output?.estaBloqueado === 1 || output?.estaBloqueado === true,
        intentosRestantes: output?.intentosRestantes || 0
      };
    } catch (error) {
      console.error('❌ Error verificando rate limit:', error);
      // En caso de error, permitir el intento (fail open)
      return { estaBloqueado: false, intentosRestantes: this.maxIntentos };
    }
  }

  /**
   * Registra un intento de login
   */
  async registrarIntento(
    exitoso: boolean,
    ipAddress: string,
    deviceId?: string,
    username?: string,
    motivoFallo?: string
  ): Promise<void> {
    try {
      await executeProcedure(
        'evalImagen.sp_RegistrarIntentoLogin',
        {
          deviceId: deviceId || null,
          username: username || null,
          ipAddress,
          exitoso: exitoso ? 1 : 0,
          motivoFallo: motivoFallo || null
        },
        [],
        {}
      );
    } catch (error) {
      // No lanzar error, solo loguear (no crítico)
      console.error('❌ Error registrando intento de login:', error);
    }
  }

  /**
   * Obtiene la IP del cliente desde el request
   */
  getClientIp(req: any): string {
    const forwarded = req.headers['x-forwarded-for'];
    if (forwarded) {
      return Array.isArray(forwarded) ? forwarded[0] : forwarded.split(',')[0].trim();
    }
    return req.ip || req.connection?.remoteAddress || 'unknown';
  }
}

export const rateLimitService = new RateLimitService();

