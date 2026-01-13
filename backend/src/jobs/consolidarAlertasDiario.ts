import { alertService } from '../services/alertService';

/**
 * Job para consolidar alertas por fundo cada 24 horas
 * Ejecutar diariamente (ej: a las 8:00 AM)
 * 
 * Uso:
 * - Manual: import { consolidarAlertasDiario } from './jobs/consolidarAlertasDiario'; await consolidarAlertasDiario();
 * - Cron: Configurar cron job que llame a POST /api/alertas/consolidar
 */
export async function consolidarAlertasDiario(): Promise<number> {
  try {
    console.log('🔄 Iniciando consolidación diaria de alertas por fundo...');
    const mensajesCreados = await alertService.consolidarAlertasPorFundo(24);
    return mensajesCreados;
  } catch (error) {
    console.error('❌ Error en consolidación diaria de alertas:', error);
    throw error;
  }
}

