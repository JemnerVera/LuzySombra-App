import * as cron from 'node-cron';
import { alertService } from '../services/alertService';
import { resendService } from '../services/resendService';

/**
 * Scheduler para automatizar la consolidación y envío de alertas
 * 
 * Configuración:
 * - Consolidación: Diariamente a las 8:00 AM
 * - Envío: Cada hora (para procesar mensajes pendientes)
 * 
 * Para desactivar, establecer ENABLE_ALERT_SCHEDULER=false en .env
 */
class AlertScheduler {
  private consolidacionJob: cron.ScheduledTask | null = null;
  private envioJob: cron.ScheduledTask | null = null;
  private enabled: boolean;

  constructor() {
    // Verificar si el scheduler está habilitado (default: true)
    this.enabled = process.env.ENABLE_ALERT_SCHEDULER !== 'false';
    
    if (this.enabled) {
      console.log('✅ Alert Scheduler habilitado');
      this.start();
    } else {
      console.log('⚠️ Alert Scheduler deshabilitado (ENABLE_ALERT_SCHEDULER=false)');
    }
  }

  /**
   * Inicia los jobs programados
   */
  start(): void {
    if (!this.enabled) {
      console.warn('⚠️ Scheduler deshabilitado, no se iniciarán jobs');
      return;
    }

    // Job 1: Consolidación diaria a las 8:00 AM
    // Formato cron: minuto hora día mes día-semana
    // '0 8 * * *' = todos los días a las 8:00 AM
    this.consolidacionJob = cron.schedule('0 8 * * *', async () => {
      console.log('🔄 [Scheduler] Iniciando consolidación diaria de alertas...');
      try {
        const mensajesCreados = await alertService.consolidarAlertasPorFundo(24);
        console.log(`✅ [Scheduler] Consolidación completada: ${mensajesCreados} mensaje(s) creado(s)`);
        
        // Después de consolidar, intentar enviar inmediatamente
        if (mensajesCreados > 0) {
          console.log('📧 [Scheduler] Enviando mensajes consolidados...');
          const resultado = await resendService.processPendingMensajes();
          console.log(`✅ [Scheduler] Envío completado: ${resultado.exitosos} exitoso(s), ${resultado.errores} error(es)`);
        }
      } catch (error) {
        console.error('❌ [Scheduler] Error en consolidación diaria:', error);
      }
    }, {
      timezone: 'America/Santiago' // Ajustar según tu zona horaria
    });

    // Job 2: Envío cada hora (para procesar mensajes pendientes)
    // '0 * * * *' = cada hora en el minuto 0
    this.envioJob = cron.schedule('0 * * * *', async () => {
      console.log('📧 [Scheduler] Procesando mensajes pendientes...');
      try {
        const resultado = await resendService.processPendingMensajes();
        if (resultado.exitosos > 0 || resultado.errores > 0) {
          console.log(`✅ [Scheduler] Procesados ${resultado.exitosos + resultado.errores} mensaje(s): ${resultado.exitosos} exitoso(s), ${resultado.errores} error(es)`);
        }
      } catch (error) {
        console.error('❌ [Scheduler] Error procesando mensajes pendientes:', error);
      }
    }, {
      timezone: 'America/Santiago'
    });

    console.log('✅ [Scheduler] Jobs programados:');
    console.log('   - Consolidación: Diariamente a las 8:00 AM');
    console.log('   - Envío: Cada hora');
  }

  /**
   * Detiene los jobs programados
   */
  stop(): void {
    if (this.consolidacionJob) {
      this.consolidacionJob.stop();
      this.consolidacionJob = null;
    }
    if (this.envioJob) {
      this.envioJob.stop();
      this.envioJob = null;
    }
    console.log('🛑 [Scheduler] Jobs detenidos');
  }

  /**
   * Ejecuta consolidación manualmente (para testing o ejecución inmediata)
   */
  async ejecutarConsolidacionManual(): Promise<{ mensajesCreados: number; exitosos: number; errores: number }> {
    console.log('🔄 [Scheduler] Ejecutando consolidación manual...');
    try {
      const mensajesCreados = await alertService.consolidarAlertasPorFundo(24);
      console.log(`✅ [Scheduler] Consolidación manual completada: ${mensajesCreados} mensaje(s) creado(s)`);
      
      let exitosos = 0;
      let errores = 0;
      
      if (mensajesCreados > 0) {
        console.log('📧 [Scheduler] Enviando mensajes consolidados...');
        const resultado = await resendService.processPendingMensajes();
        exitosos = resultado.exitosos;
        errores = resultado.errores;
        console.log(`✅ [Scheduler] Envío completado: ${exitosos} exitoso(s), ${errores} error(es)`);
      }
      
      return { mensajesCreados, exitosos, errores };
    } catch (error) {
      console.error('❌ [Scheduler] Error en consolidación manual:', error);
      throw error;
    }
  }
}

// Singleton instance
export const alertScheduler = new AlertScheduler();

