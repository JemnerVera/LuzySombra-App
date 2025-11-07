import { NextRequest, NextResponse } from 'next/server';
import { alertService } from '@/services/alertService';

/**
 * API Route para procesar alertas y crear mensajes
 * POST /api/alertas/procesar-mensajes
 * 
 * IMPORTANTE: Este endpoint SOLO crea mensajes en image.Mensaje.
 * El envío de emails se realiza mediante un Worker Service en .NET
 * que lee image.Mensaje y envía los emails desde el servidor.
 * 
 * Procesa:
 * 1. Alertas sin mensaje → Crea mensajes en image.Mensaje (estado: Pendiente)
 * 
 * El Worker Service se encarga de:
 * - Leer image.Mensaje con estado = 'Pendiente'
 * - Enviar emails (SMTP, Resend, etc.)
 * - Actualizar estado a 'Enviado' o 'Error'
 */
export async function POST(request: NextRequest) {
  try {
    // Procesar alertas sin mensaje → Crea mensajes en image.Mensaje
    console.log('📊 Procesando alertas sin mensaje...');
    const alertasProcesadas = await alertService.processAlertasSinMensaje();
    console.log(`✅ ${alertasProcesadas} alertas procesadas, mensajes creados en image.Mensaje`);

    // Obtener estadísticas de mensajes pendientes (para información)
    const mensajesPendientes = await alertService.getMensajesPendientes();

    return NextResponse.json({
      success: true,
      mensaje: 'Mensajes creados exitosamente. El Worker Service se encargará del envío.',
      alertas: {
        procesadas: alertasProcesadas
      },
      mensajes: {
        pendientes: mensajesPendientes.length,
        nota: 'Los mensajes serán enviados por el Worker Service en .NET'
      }
    });
  } catch (error) {
    console.error('❌ Error procesando alertas y mensajes:', error);
    return NextResponse.json(
      { 
        error: 'Error procesando alertas y mensajes',
        message: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
}

/**
 * GET /api/alertas/procesar-mensajes
 * Devuelve estadísticas de alertas y mensajes
 */
export async function GET() {
  try {
    const alertasSinMensaje = await alertService.getAlertasSinMensaje();
    const mensajesPendientes = await alertService.getMensajesPendientes();

    return NextResponse.json({
      success: true,
      estadisticas: {
        alertasSinMensaje: alertasSinMensaje.length,
        mensajesPendientes: mensajesPendientes.length,
        nota: 'Los mensajes pendientes serán enviados por el Worker Service en .NET'
      }
    });
  } catch (error) {
    console.error('❌ Error obteniendo estadísticas:', error);
    return NextResponse.json(
      { 
        error: 'Error obteniendo estadísticas',
        message: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
}

