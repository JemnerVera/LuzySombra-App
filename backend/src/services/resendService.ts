import { Resend } from 'resend';
import { query } from '../lib/db';
import { Mensaje } from './alertService';

/**
 * Servicio para enviar emails vía Resend API
 */
class ResendService {
  private resend: Resend | null = null;
  private fromEmail: string;
  private fromName: string;

  constructor() {
    const apiKey = process.env.RESEND_API_KEY;
    this.fromEmail = process.env.RESEND_FROM_EMAIL || 'noreply@example.com';
    this.fromName = process.env.RESEND_FROM_NAME || 'Sistema de Alertas';

    if (apiKey) {
      this.resend = new Resend(apiKey);
      console.log('✅ Resend Service inicializado');
    } else {
      console.warn('⚠️ RESEND_API_KEY no configurada. El servicio de envío de emails no funcionará.');
    }
  }

  /**
   * Procesa mensajes pendientes y los envía vía Resend API
   * @returns Objeto con conteo de mensajes exitosos y errores
   */
  async processPendingMensajes(): Promise<{ exitosos: number; errores: number }> {
    if (!this.resend) {
      console.error('❌ Resend no está configurado. Verifica RESEND_API_KEY en .env');
      return { exitosos: 0, errores: 0 };
    }

    try {
      // Obtener mensajes pendientes
      const mensajes = await query<Mensaje>(`
        SELECT 
          mensajeID,
          fundoID,
          tipoMensaje,
          asunto,
          cuerpoHTML,
          cuerpoTexto,
          destinatarios,
          destinatariosCC,
          destinatariosBCC,
          estado,
          intentosEnvio,
          resendMessageID,
          errorMessage
        FROM evalImagen.Mensaje
        WHERE estado = 'Pendiente'
          AND statusID = 1
          AND intentosEnvio < 3
        ORDER BY fechaCreacion ASC
      `);

      if (mensajes.length === 0) {
        console.log('📭 No hay mensajes pendientes para enviar');
        return { exitosos: 0, errores: 0 };
      }

      console.log(`📧 Procesando ${mensajes.length} mensaje(s) pendiente(s)...`);

      let exitosos = 0;
      let errores = 0;

      for (const mensaje of mensajes) {
        try {
          // Actualizar estado a 'Enviando'
          await query(`
            UPDATE evalImagen.Mensaje
            SET estado = 'Enviando',
                intentosEnvio = intentosEnvio + 1,
                ultimoIntentoEnvio = GETDATE()
            WHERE mensajeID = @mensajeID
          `, { mensajeID: mensaje.mensajeID });

          // Enviar email
          const resultado = await this.enviarEmail(mensaje);

          if (resultado.exito) {
            // Actualizar como enviado
            await query(`
              UPDATE evalImagen.Mensaje
              SET estado = 'Enviado',
                  fechaEnvio = GETDATE(),
                  resendMessageID = @resendMessageID,
                  resendResponse = @resendResponse
              WHERE mensajeID = @mensajeID
            `, {
              mensajeID: mensaje.mensajeID,
              resendMessageID: resultado.messageId || null,
              resendResponse: JSON.stringify(resultado.response || {})
            });

            // Actualizar fechaEnvio en las alertas relacionadas
            await query(`
              UPDATE a
              SET a.fechaEnvio = GETDATE(),
                  a.estado = 'Enviada'
              FROM evalImagen.Alerta a
              INNER JOIN evalImagen.MensajeAlerta ma ON a.alertaID = ma.alertaID
              WHERE ma.mensajeID = @mensajeID
                AND a.statusID = 1
                AND ma.statusID = 1
            `, { mensajeID: mensaje.mensajeID });

            exitosos++;
            console.log(`✅ Mensaje ${mensaje.mensajeID} enviado exitosamente`);
          } else {
            // Actualizar como error
            await query(`
              UPDATE evalImagen.Mensaje
              SET estado = 'Error',
                  errorMessage = @errorMessage,
                  resendResponse = @resendResponse
              WHERE mensajeID = @mensajeID
            `, {
              mensajeID: mensaje.mensajeID,
              errorMessage: resultado.error || 'Error desconocido',
              resendResponse: JSON.stringify(resultado.response || {})
            });

            errores++;
            console.error(`❌ Error enviando mensaje ${mensaje.mensajeID}: ${resultado.error}`);
          }
        } catch (error) {
          errores++;
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          console.error(`❌ Error procesando mensaje ${mensaje.mensajeID}:`, error);

          // Actualizar como error
          await query(`
            UPDATE evalImagen.Mensaje
            SET estado = 'Error',
                errorMessage = @errorMessage
            WHERE mensajeID = @mensajeID
          `, {
            mensajeID: mensaje.mensajeID,
            errorMessage
          });
        }
      }

      console.log(`✅ Procesamiento completado: ${exitosos} exitoso(s), ${errores} error(es)`);
      return { exitosos, errores };
    } catch (error) {
      console.error('❌ Error procesando mensajes pendientes:', error);
      throw error;
    }
  }

  /**
   * Envía un email vía Resend API
   */
  private async enviarEmail(mensaje: Mensaje): Promise<{
    exito: boolean;
    messageId?: string;
    response?: unknown;
    error?: string;
  }> {
    if (!this.resend) {
      return {
        exito: false,
        error: 'Resend no está configurado'
      };
    }

    try {
      // Parsear destinatarios desde JSON
      let destinatarios: string[] = [];
      let destinatariosCC: string[] = [];
      let destinatariosBCC: string[] = [];

      try {
        destinatarios = JSON.parse(mensaje.destinatarios);
        if (mensaje.destinatariosCC) {
          destinatariosCC = JSON.parse(mensaje.destinatariosCC);
        }
        if (mensaje.destinatariosBCC) {
          destinatariosBCC = JSON.parse(mensaje.destinatariosBCC);
        }
      } catch (parseError) {
        console.error('❌ Error parseando destinatarios:', parseError);
        return {
          exito: false,
          error: 'Error parseando destinatarios'
        };
      }

      if (destinatarios.length === 0) {
        return {
          exito: false,
          error: 'No hay destinatarios'
        };
      }

      // Enviar email vía Resend
      const data = await this.resend.emails.send({
        from: `${this.fromName} <${this.fromEmail}>`,
        to: destinatarios,
        cc: destinatariosCC.length > 0 ? destinatariosCC : undefined,
        bcc: destinatariosBCC.length > 0 ? destinatariosBCC : undefined,
        subject: mensaje.asunto,
        html: mensaje.cuerpoHTML,
        text: mensaje.cuerpoTexto || undefined
      });

      // La respuesta de Resend tiene estructura: { data: { id: "..." }, error: null }
      const messageId = data.data?.id || undefined;

      return {
        exito: true,
        messageId,
        response: data
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error('❌ Error enviando email vía Resend:', error);

      return {
        exito: false,
        error: errorMessage,
        response: error
      };
    }
  }

  /**
   * Envía un mensaje específico por ID
   */
  async enviarMensajePorID(mensajeID: number): Promise<boolean> {
    try {
      const mensajes = await query<Mensaje>(`
        SELECT 
          mensajeID,
          fundoID,
          tipoMensaje,
          asunto,
          cuerpoHTML,
          cuerpoTexto,
          destinatarios,
          destinatariosCC,
          destinatariosBCC,
          estado,
          intentosEnvio
        FROM evalImagen.Mensaje
        WHERE mensajeID = @mensajeID
          AND statusID = 1
      `, { mensajeID });

      if (mensajes.length === 0) {
        console.warn(`⚠️ Mensaje ${mensajeID} no encontrado`);
        return false;
      }

      const mensaje = mensajes[0];
      const resultado = await this.enviarEmail(mensaje);

      if (resultado.exito) {
        await query(`
          UPDATE evalImagen.Mensaje
          SET estado = 'Enviado',
              fechaEnvio = GETDATE(),
              resendMessageID = @resendMessageID,
              resendResponse = @resendResponse
          WHERE mensajeID = @mensajeID
        `, {
          mensajeID,
          resendMessageID: resultado.messageId || null,
          resendResponse: JSON.stringify(resultado.response || {})
        });
        return true;
      } else {
        await query(`
          UPDATE evalImagen.Mensaje
          SET estado = 'Error',
              errorMessage = @errorMessage
          WHERE mensajeID = @mensajeID
        `, {
          mensajeID,
          errorMessage: resultado.error || 'Error desconocido'
        });
        return false;
      }
    } catch (error) {
      console.error(`❌ Error enviando mensaje ${mensajeID}:`, error);
      return false;
    }
  }
}

export const resendService = new ResendService();

