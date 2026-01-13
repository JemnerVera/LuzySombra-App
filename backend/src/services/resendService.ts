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
        FROM evalImagen.mensaje
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
            UPDATE evalImagen.mensaje
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
              UPDATE evalImagen.mensaje
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
              FROM evalImagen.alerta a
              INNER JOIN evalImagen.mensajeAlerta ma ON a.alertaID = ma.alertaID
              WHERE ma.mensajeID = @mensajeID
                AND a.statusID = 1
                AND ma.statusID = 1
            `, { mensajeID: mensaje.mensajeID });

            exitosos++;
          } else {
            // Actualizar como error
            await query(`
              UPDATE evalImagen.mensaje
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
            UPDATE evalImagen.mensaje
            SET estado = 'Error',
                errorMessage = @errorMessage
            WHERE mensajeID = @mensajeID
          `, {
            mensajeID: mensaje.mensajeID,
            errorMessage
          });
        }
      }

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
        FROM evalImagen.mensaje
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
          UPDATE evalImagen.mensaje
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
          UPDATE evalImagen.mensaje
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

  /**
   * Verifica si el servicio está inicializado
   */
  isInitialized(): boolean {
    return this.resend !== null;
  }

  /**
   * Envía email de recuperación de contraseña
   */
  async sendPasswordResetEmail(email: string, username: string, newPassword: string): Promise<{
    exito: boolean;
    messageId?: string;
    error?: string;
  }> {
    if (!this.resend) {
      return {
        exito: false,
        error: 'Resend no está configurado'
      };
    }

    try {
      const subject = 'Recuperación de Contraseña - LuzSombra';
      const htmlBody = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #10b981; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
            .password-box { background-color: #ffffff; border: 2px solid #10b981; border-radius: 8px; padding: 20px; margin: 20px 0; text-align: center; }
            .password { font-size: 24px; font-weight: bold; color: #10b981; letter-spacing: 2px; font-family: monospace; }
            .warning { background-color: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; border-radius: 4px; }
            .footer { text-align: center; margin-top: 20px; color: #6b7280; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🔐 Recuperación de Contraseña</h1>
            </div>
            <div class="content">
              <p>Hola <strong>${username}</strong>,</p>
              
              <p>Has solicitado recuperar tu contraseña para acceder a LuzSombra.</p>
              
              <div class="password-box">
                <p style="margin: 0 0 10px 0; color: #6b7280; font-size: 14px;">Tu nueva contraseña es:</p>
                <div class="password">${newPassword}</div>
              </div>
              
              <div class="warning">
                <strong>⚠️ Importante:</strong>
                <ul style="margin: 10px 0; padding-left: 20px;">
                  <li>Esta contraseña es temporal y se generó automáticamente</li>
                  <li>Te recomendamos cambiarla después de iniciar sesión</li>
                  <li>No compartas esta contraseña con nadie</li>
                </ul>
              </div>
              
              <p>Puedes iniciar sesión con tu username: <strong>${username}</strong> y la contraseña mostrada arriba.</p>
              
              <p style="margin-top: 30px;">
                Si no solicitaste este cambio, por favor contacta al administrador del sistema.
              </p>
            </div>
            <div class="footer">
              <p>Este es un email automático, por favor no respondas.</p>
              <p>Sistema de Análisis de Imágenes Agrícolas - LuzSombra</p>
            </div>
          </div>
        </body>
        </html>
      `;

      const textBody = `
Recuperación de Contraseña - LuzSombra

Hola ${username},

Has solicitado recuperar tu contraseña para acceder a LuzSombra.

Tu nueva contraseña es: ${newPassword}

⚠️ IMPORTANTE:
- Esta contraseña es temporal y se generó automáticamente
- Te recomendamos cambiarla después de iniciar sesión
- No compartas esta contraseña con nadie

Puedes iniciar sesión con tu username: ${username} y la contraseña mostrada arriba.

Si no solicitaste este cambio, por favor contacta al administrador del sistema.

---
Este es un email automático, por favor no respondas.
Sistema de Análisis de Imágenes Agrícolas - LuzSombra
      `;

      const result = await this.resend.emails.send({
        from: `${this.fromName} <${this.fromEmail}>`,
        to: [email],
        subject,
        html: htmlBody,
        text: textBody,
      });

      if (result.error) {
        console.error('❌ Error enviando email de recuperación:', result.error);
        return {
          exito: false,
          error: result.error.message || 'Error desconocido'
        };
      }

      return {
        exito: true,
        messageId: result.data?.id
      };
    } catch (error) {
      console.error('❌ Error enviando email de recuperación:', error);
      return {
        exito: false,
        error: error instanceof Error ? error.message : 'Error desconocido'
      };
    }
  }
}

export const resendService = new ResendService();

