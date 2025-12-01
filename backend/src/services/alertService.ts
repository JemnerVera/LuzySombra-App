import { query } from '../lib/db';

export interface Alerta {
  alertaID: number;
  lotID: number;
  loteEvaluacionID: number | null;
  umbralID: number;
  variedadID: number | null;
  porcentajeLuzEvaluado: number;
  tipoUmbral: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal';
  severidad: 'Critica' | 'Advertencia' | 'Info';
  estado: 'Pendiente' | 'Enviada' | 'Resuelta' | 'Ignorada';
  fechaCreacion: Date;
  fechaEnvio: Date | null;
  fechaResolucion: Date | null;
  mensajeID: number | null;
}

export interface Mensaje {
  mensajeID: number;
  alertaID: number | null; // NULL para mensajes consolidados (usar tabla intermedia)
  fundoID: string | null; // Nuevo: identifica el fundo del mensaje consolidado
  tipoMensaje: 'Email' | 'SMS' | 'Push';
  asunto: string;
  cuerpoHTML: string;
  cuerpoTexto: string | null;
  destinatarios: string; // JSON array
  destinatariosCC: string | null;
  destinatariosBCC: string | null;
  estado: 'Pendiente' | 'Enviando' | 'Enviado' | 'Error';
  fechaCreacion: Date;
  fechaEnvio: Date | null;
  intentosEnvio: number;
  resendMessageID: string | null;  // Usado por el Worker Service para tracking (puede ser ID de SMTP, Resend, etc.)
  errorMessage: string | null;     // Mensaje de error si falla el envío
}

export interface LoteInfo {
  lotID: number;
  lote: string;
  sector: string;
  sectorID: number;
  fundo: string;
  fundoID: string;  // CHAR(4) en SQL Server
  variedad: string | null;
}

/**
 * Servicio para manejar alertas y mensajes
 */
class AlertService {
  /**
   * Obtiene alertas pendientes que no tienen mensaje asociado
   * Incluye fundoID y sectorID desde evalImagen.LoteEvaluacion para optimizar match con Contacto
   */
  async getAlertasSinMensaje(): Promise<Alerta[]> {
    try {
      const rows = await query<Alerta & { fundoID: string | null; sectorID: number | null }>(`
        SELECT 
          a.alertaID,
          a.lotID,
          a.loteEvaluacionID,
          a.umbralID,
          a.variedadID,
          a.porcentajeLuzEvaluado,
          a.tipoUmbral,
          a.severidad,
          a.estado,
          a.fechaCreacion,
          a.fechaEnvio,
          a.fechaResolucion,
          a.mensajeID,
          le.fundoID,
          le.sectorID
        FROM evalImagen.Alerta a
        LEFT JOIN evalImagen.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
        WHERE a.estado IN ('Pendiente', 'Enviada')
          AND a.statusID = 1
          AND a.mensajeID IS NULL
        ORDER BY a.fechaCreacion ASC
      `);

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo alertas sin mensaje:', error);
      throw error;
    }
  }

  /**
   * Obtiene información del lote para una alerta
   */
  async getLoteInfo(lotID: number): Promise<LoteInfo | null> {
    try {
      const rows = await query<LoteInfo>(`
        SELECT 
          l.lotID,
          l.name AS lote,
          s.stage AS sector,
          s.stageID,
          f.Description AS fundo,
          CAST(f.farmID AS VARCHAR) AS fundoID,
          v.name AS variedad
        FROM GROWER.LOT l
        INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
        INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
        LEFT JOIN GROWER.PLANTATION p ON l.lotID = p.lotID AND p.statusID = 1
        LEFT JOIN GROWER.VARIETY v ON p.varietyID = v.varietyID AND v.statusID = 1
        WHERE l.lotID = @lotID
          AND l.statusID = 1
      `, { lotID });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo información del lote:', error);
      return null;
    }
  }

  /**
   * Obtiene información del umbral
   */
  async getUmbralInfo(umbralID: number): Promise<{ descripcion: string; colorHex: string | null } | null> {
    try {
      const rows = await query<{ descripcion: string; colorHex: string | null }>(`
        SELECT descripcion, colorHex
        FROM evalImagen.UmbralLuz
        WHERE umbralID = @umbralID
          AND activo = 1
          AND statusID = 1
      `, { umbralID });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error obteniendo información del umbral:', error);
      return null;
    }
  }

  /**
   * Genera el HTML del mensaje de alerta
   */
  private generateAlertHTML(alerta: Alerta, loteInfo: LoteInfo, umbralInfo: { descripcion: string; colorHex: string | null } | null): string {
    const emoji = alerta.tipoUmbral === 'CriticoRojo' ? '🚨' : '⚠️';
    const titulo = alerta.tipoUmbral === 'CriticoRojo' ? 'Alerta Crítica' : 'Advertencia';
    const colorFondo = alerta.tipoUmbral === 'CriticoRojo' ? '#fee2e2' : '#fef3c7';
    const colorBorde = alerta.tipoUmbral === 'CriticoRojo' ? '#dc2626' : '#f59e0b';

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .alert-box { 
      background-color: ${colorFondo}; 
      border-left: 4px solid ${colorBorde}; 
      padding: 15px; 
      margin: 20px 0; 
      border-radius: 4px;
    }
    .info-row { margin: 10px 0; }
    .label { font-weight: bold; display: inline-block; width: 150px; }
    .value { display: inline-block; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <h2>${emoji} ${titulo} - Evaluación de Luz</h2>
    
    <div class="alert-box">
      <p><strong>Descripción:</strong> ${umbralInfo?.descripcion || alerta.tipoUmbral}</p>
    </div>

    <div class="info-row">
      <span class="label">Lote:</span>
      <span class="value">${loteInfo.lote}</span>
    </div>
    <div class="info-row">
      <span class="label">Sector:</span>
      <span class="value">${loteInfo.sector}</span>
    </div>
    <div class="info-row">
      <span class="label">Fundo:</span>
      <span class="value">${loteInfo.fundo}</span>
    </div>
    ${loteInfo.variedad ? `
    <div class="info-row">
      <span class="label">Variedad:</span>
      <span class="value">${loteInfo.variedad}</span>
    </div>
    ` : ''}
    <div class="info-row">
      <span class="label">Porcentaje de Luz:</span>
      <span class="value"><strong>${alerta.porcentajeLuzEvaluado.toFixed(2)}%</strong></span>
    </div>
    <div class="info-row">
      <span class="label">Tipo de Umbral:</span>
      <span class="value">${alerta.tipoUmbral}</span>
    </div>
    <div class="info-row">
      <span class="label">Severidad:</span>
      <span class="value">${alerta.severidad}</span>
    </div>
    <div class="info-row">
      <span class="label">Fecha de Evaluación:</span>
      <span class="value">${new Date(alerta.fechaCreacion).toLocaleString('es-ES')}</span>
    </div>

    <div class="footer">
      <p>Este es un mensaje automático del sistema de alertas de evaluación de luz.</p>
      <p>Por favor, revisa el lote y toma las acciones necesarias.</p>
    </div>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Genera el texto plano del mensaje de alerta
   */
  private generateAlertText(alerta: Alerta, loteInfo: LoteInfo, umbralInfo: { descripcion: string; colorHex: string | null } | null): string {
    const emoji = alerta.tipoUmbral === 'CriticoRojo' ? '🚨' : '⚠️';
    const titulo = alerta.tipoUmbral === 'CriticoRojo' ? 'Alerta Crítica' : 'Advertencia';

    return `
${emoji} ${titulo} - Evaluación de Luz

Descripción: ${umbralInfo?.descripcion || alerta.tipoUmbral}

Lote: ${loteInfo.lote}
Sector: ${loteInfo.sector}
Fundo: ${loteInfo.fundo}
${loteInfo.variedad ? `Variedad: ${loteInfo.variedad}\n` : ''}
Porcentaje de Luz: ${alerta.porcentajeLuzEvaluado.toFixed(2)}%
Tipo de Umbral: ${alerta.tipoUmbral}
Severidad: ${alerta.severidad}
Fecha de Evaluación: ${new Date(alerta.fechaCreacion).toLocaleString('es-ES')}

---
Este es un mensaje automático del sistema de alertas de evaluación de luz.
Por favor, revisa el lote y toma las acciones necesarias.
    `.trim();
  }

  /**
   * Crea un mensaje desde una alerta
   */
  async createMensajeFromAlerta(alertaID: number): Promise<number | null> {
    try {
      // Obtener datos de la alerta
      const alertas = await query<Alerta>(`
        SELECT *
        FROM evalImagen.Alerta
        WHERE alertaID = @alertaID
          AND statusID = 1
      `, { alertaID });

      if (alertas.length === 0) {
        console.warn(`⚠️ Alerta ${alertaID} no encontrada`);
        return null;
      }

      const alerta = alertas[0];

      // Obtener información del lote
      const loteInfo = await this.getLoteInfo(alerta.lotID);
      if (!loteInfo) {
        console.warn(`⚠️ No se pudo obtener información del lote ${alerta.lotID}`);
        return null;
      }

      // Obtener información del umbral
      const umbralInfo = await this.getUmbralInfo(alerta.umbralID);

      // Generar contenido del mensaje
      const cuerpoHTML = this.generateAlertHTML(alerta, loteInfo, umbralInfo);
      const cuerpoTexto = this.generateAlertText(alerta, loteInfo, umbralInfo);

      // Obtener destinatarios desde la tabla evalImagen.Contacto o variables de entorno (fallback)
      // Se hace match por fundoID del lote (y opcionalmente sectorID)
      // Optimización: usar fundoID y sectorID desde evalImagen.LoteEvaluacion si están disponibles
      const alertaWithLocation = alerta as Alerta & { fundoID?: string | null; sectorID?: number | null };
      const destinatarios = await this.getDestinatarios(
        alerta.tipoUmbral,
        alerta.lotID,
        alertaWithLocation.fundoID,
        alertaWithLocation.sectorID
      );
      if (destinatarios.length === 0) {
        console.warn('⚠️ No hay destinatarios configurados para alertas');
        console.warn('⚠️ Verifica que existan contactos activos en evalImagen.Contacto o configura ALERTAS_EMAIL_DESTINATARIOS');
        return null;
      }

      // Generar asunto
      const emoji = alerta.tipoUmbral === 'CriticoRojo' ? '🚨' : '⚠️';
      const asunto = `${emoji} ${alerta.tipoUmbral === 'CriticoRojo' ? 'Alerta Crítica' : 'Advertencia'} - Lote ${loteInfo.lote} (${alerta.porcentajeLuzEvaluado.toFixed(2)}% luz)`;

      // Insertar mensaje
      const result = await query<{ mensajeID: number }>(`
        INSERT INTO evalImagen.Mensaje (
          alertaID,
          tipoMensaje,
          asunto,
          cuerpoHTML,
          cuerpoTexto,
          destinatarios,
          destinatariosCC,
          estado,
          fechaCreacion,
          intentosEnvio,
          statusID
        )
        OUTPUT INSERTED.mensajeID
        VALUES (
          @alertaID,
          'Email',
          @asunto,
          @cuerpoHTML,
          @cuerpoTexto,
          @destinatarios,
          NULL,
          'Pendiente',
          GETDATE(),
          0,
          1
        )
      `, {
        alertaID,
        asunto,
        cuerpoHTML,
        cuerpoTexto,
        destinatarios: JSON.stringify(destinatarios)
      });

      const mensajeID = result[0]?.mensajeID;
      if (!mensajeID) {
        throw new Error('No se pudo crear el mensaje');
      }

      // Actualizar alerta con mensajeID
      await query(`
        UPDATE evalImagen.Alerta
        SET mensajeID = @mensajeID
        WHERE alertaID = @alertaID
      `, { mensajeID, alertaID });

      console.log(`✅ Mensaje ${mensajeID} creado para alerta ${alertaID}`);
      return mensajeID;
    } catch (error) {
      console.error(`❌ Error creando mensaje para alerta ${alertaID}:`, error);
      throw error;
    }
  }

  /**
   * Obtiene destinatarios desde la tabla evalImagen.Contacto o variables de entorno (fallback)
   * @param tipoUmbral Tipo de umbral para filtrar contactos (CriticoRojo, CriticoAmarillo, Normal)
   * @param lotID ID del lote (para obtener fundoID y sectorID del lote)
   */
  async getDestinatarios(
    tipoUmbral: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal',
    lotID?: number | null,
    fundoID?: string | null,
    sectorID?: number | null
  ): Promise<string[]> {
    try {
      // Primero intentar obtener desde la tabla evalImagen.Contacto
      const contactos = await this.getDestinatariosFromDB(tipoUmbral, lotID, fundoID, sectorID);
      
      if (contactos.length > 0) {
        console.log(`📧 Obtenidos ${contactos.length} destinatario(s) desde evalImagen.Contacto`);
        return contactos;
      }

      // Fallback: usar variable de entorno si no hay contactos en BD
      console.warn('⚠️ No se encontraron contactos en evalImagen.Contacto, usando variable de entorno como fallback');
      return this.getDestinatariosFromEnv();
    } catch (error) {
      console.error('❌ Error obteniendo destinatarios desde BD, usando fallback:', error);
      return this.getDestinatariosFromEnv();
    }
  }

  /**
   * Obtiene destinatarios desde la tabla evalImagen.Contacto
   * Hace match por fundoID del lote (y opcionalmente sectorID)
   * Puede recibir fundoID y sectorID directamente (optimización) o obtenerlos desde lotID
   */
  private async getDestinatariosFromDB(
    tipoUmbral: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal',
    lotID?: number | null,
    fundoID?: string | null,
    sectorID?: number | null
  ): Promise<string[]> {
    try {
      // Si no se proporcionan fundoID y sectorID, obtenerlos desde el lote
      if ((fundoID === undefined || fundoID === null) && lotID) {
        const loteInfo = await this.getLoteInfo(lotID);
        if (loteInfo) {
          fundoID = loteInfo.fundoID;
          sectorID = loteInfo.sectorID;
        } else {
          console.warn(`⚠️ No se pudo obtener información del lote ${lotID}, no se aplicarán filtros por fundo/sector`);
        }
      }

      // Construir condiciones de filtro
      const condiciones: string[] = [];
      const params: Record<string, unknown> = {};

      // Filtro básico: activo y statusID = 1
      condiciones.push('c.activo = 1');
      condiciones.push('c.statusID = 1');

      // Filtro por tipo de alerta
      if (tipoUmbral === 'CriticoRojo') {
        condiciones.push('c.recibirAlertasCriticas = 1');
      } else if (tipoUmbral === 'CriticoAmarillo') {
        condiciones.push('c.recibirAlertasAdvertencias = 1');
      } else if (tipoUmbral === 'Normal') {
        condiciones.push('c.recibirAlertasNormales = 1');
      }

      // Filtro por fundoID: contactos sin filtro (fundoID IS NULL) O contactos del mismo fundo
      // Nota: fundoID en Contacto es CHAR(4), puede tener espacios, usar RTRIM para comparar
      if (fundoID !== null && fundoID !== undefined && fundoID.trim() !== '') {
        const fundoIDTrimmed = fundoID.trim();
        condiciones.push('(c.fundoID IS NULL OR RTRIM(c.fundoID) = @fundoID)');
        params.fundoID = fundoIDTrimmed;
        console.log(`🔍 Filtro por fundoID: ${fundoIDTrimmed}`);
      } else {
        console.log(`🔍 Sin filtro por fundoID (fundoID es null/undefined/vacío)`);
      }

      // Filtro por sectorID (opcional, más específico): contactos sin filtro (sectorID IS NULL) O contactos del mismo sector
      // Si un contacto tiene sectorID específico, solo recibe alertas de ese sector
      // Si tiene sectorID NULL pero fundoID específico, recibe de todos los sectores de ese fundo
      if (sectorID !== null && sectorID !== undefined) {
        condiciones.push('(c.sectorID IS NULL OR c.sectorID = @sectorID)');
        params.sectorID = sectorID;
        console.log(`🔍 Filtro por sectorID: ${sectorID}`);
      }

      const whereClause = condiciones.length > 0 ? 'WHERE ' + condiciones.join(' AND ') : '';
      console.log(`🔍 Query contactos: WHERE ${condiciones.join(' AND ')}`);

      const rows = await query<{ email: string; prioridad: number; nombre: string }>(`
        SELECT DISTINCT 
          c.email,
          c.prioridad,
          c.nombre
        FROM evalImagen.Contacto c
        ${whereClause}
        ORDER BY c.prioridad DESC, c.nombre ASC
      `, params);

      console.log(`📧 Contactos encontrados en BD: ${rows.length}`);
      return rows.map(row => row.email);
    } catch (error) {
      console.error('❌ Error obteniendo destinatarios desde evalImagen.Contacto:', error);
      return [];
    }
  }

  /**
   * Obtiene destinatarios desde variables de entorno (fallback)
   */
  private getDestinatariosFromEnv(): string[] {
    const destinatariosEnv = process.env.ALERTAS_EMAIL_DESTINATARIOS;
    if (!destinatariosEnv) {
      return [];
    }

    try {
      const destinatarios = JSON.parse(destinatariosEnv);
      return Array.isArray(destinatarios) ? destinatarios : [];
    } catch (error) {
      console.error('❌ Error parseando ALERTAS_EMAIL_DESTINATARIOS:', error);
      return [];
    }
  }

  /**
   * Procesa alertas sin mensaje y crea mensajes
   * @deprecated Usar consolidarAlertasPorFundo() en su lugar para consolidación por fundo
   */
  async processAlertasSinMensaje(): Promise<number> {
    console.warn('⚠️ processAlertasSinMensaje() está deprecado. Usar consolidarAlertasPorFundo() para consolidación por fundo');
    try {
      const alertas = await this.getAlertasSinMensaje();
      let procesadas = 0;

      for (const alerta of alertas) {
        try {
          await this.createMensajeFromAlerta(alerta.alertaID);
          procesadas++;
        } catch (error) {
          console.error(`❌ Error procesando alerta ${alerta.alertaID}:`, error);
          // Continuar con la siguiente
        }
      }

      console.log(`✅ Procesadas ${procesadas} alertas sin mensaje`);
      return procesadas;
    } catch (error) {
      console.error('❌ Error procesando alertas sin mensaje:', error);
      throw error;
    }
  }

  /**
   * Consolida alertas pendientes por Fundo y crea mensajes consolidados
   * @param horasAtras Número de horas hacia atrás para buscar alertas (default: 24)
   * @returns Número de mensajes consolidados creados
   */
  async consolidarAlertasPorFundo(horasAtras: number = 24): Promise<number> {
    try {
      // 1. Obtener alertas pendientes del último período (sin mensaje)
      const fechaLimite = new Date();
      fechaLimite.setHours(fechaLimite.getHours() - horasAtras);
      
      console.log(`🔍 Buscando alertas desde: ${fechaLimite.toISOString()} (últimas ${horasAtras} horas)`);
      
      const alertas = await query<Alerta & { fundoID: string; fundo: string }>(`
        SELECT 
          a.alertaID,
          a.lotID,
          a.loteEvaluacionID,
          a.umbralID,
          a.variedadID,
          a.porcentajeLuzEvaluado,
          a.tipoUmbral,
          a.severidad,
          a.estado,
          a.fechaCreacion,
          CAST(COALESCE(le.fundoID, f.farmID) AS VARCHAR) AS fundoID,
          f.Description AS fundo
        FROM evalImagen.Alerta a
        INNER JOIN evalImagen.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
        LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
        LEFT JOIN GROWER.FARMS f ON COALESCE(le.fundoID, s.farmID) = f.farmID
        WHERE a.estado IN ('Pendiente', 'Enviada')
          AND a.statusID = 1
          AND a.mensajeID IS NULL
          AND a.fechaCreacion >= @fechaLimite
          AND COALESCE(le.fundoID, f.farmID) IS NOT NULL
        ORDER BY COALESCE(le.fundoID, f.farmID), a.fechaCreacion ASC
      `, { fechaLimite });

      console.log(`🔍 Alertas encontradas por la query de consolidación: ${alertas.length}`);
      if (alertas.length > 0) {
        console.log(`📋 Primeras alertas:`, alertas.slice(0, 3).map(a => ({
          alertaID: a.alertaID,
          fundoID: a.fundoID,
          fundo: a.fundo
        })));
      }

      if (alertas.length === 0) {
        console.log('📭 No hay alertas pendientes para consolidar');
        console.log('   Posibles causas:');
        console.log('   - Las alertas están fuera del rango de horas especificado');
        console.log('   - Las alertas no tienen loteEvaluacionID con fundoID');
        console.log('   - Las alertas ya tienen mensajeID asignado');
        return 0;
      }

      // 2. Agrupar alertas por fundoID (trim para eliminar espacios)
      const alertasPorFundo = new Map<string, typeof alertas>();
      for (const alerta of alertas) {
        const fundoID = alerta.fundoID.trim(); // Eliminar espacios
        if (!alertasPorFundo.has(fundoID)) {
          alertasPorFundo.set(fundoID, []);
        }
        alertasPorFundo.get(fundoID)!.push(alerta);
      }

      console.log(`📊 Consolidando ${alertas.length} alertas en ${alertasPorFundo.size} fundo(s)`);

      // 3. Para cada fundo, crear un mensaje consolidado
      let mensajesCreados = 0;
      for (const [fundoID, alertasFundo] of alertasPorFundo) {
        try {
          const mensajeID = await this.createMensajeConsolidado(fundoID, alertasFundo);
          if (mensajeID) {
            mensajesCreados++;
          }
        } catch (error) {
          console.error(`❌ Error consolidando alertas para fundo ${fundoID}:`, error);
          // Continuar con el siguiente fundo
        }
      }

      console.log(`✅ Consolidación completada: ${mensajesCreados} mensaje(s) creado(s)`);
      return mensajesCreados;
    } catch (error) {
      console.error('❌ Error consolidando alertas por fundo:', error);
      throw error;
    }
  }

  /**
   * Crea un mensaje consolidado para múltiples alertas de un fundo
   */
  private async createMensajeConsolidado(
    fundoID: string,
    alertas: Array<Alerta & { fundoID: string; fundo: string }>
  ): Promise<number | null> {
    try {
      // 1. Obtener información detallada de cada alerta (lote, sector, etc.)
      const alertasDetalladas = await Promise.all(
        alertas.map(async (alerta) => {
          const loteInfo = await this.getLoteInfo(alerta.lotID);
          const umbralInfo = await this.getUmbralInfo(alerta.umbralID);
          return {
            ...alerta,
            loteInfo,
            umbralInfo
          };
        })
      );

      // 2. Obtener destinatarios para el fundo (usar la primera alerta como referencia)
      const primeraAlerta = alertasDetalladas[0];
      if (!primeraAlerta) {
        console.warn(`⚠️ No hay alertas para fundo ${fundoID}`);
        return null;
      }

      // Determinar el tipo de umbral más crítico para destinatarios
      const tieneCriticas = alertasDetalladas.some(a => a.tipoUmbral === 'CriticoRojo');
      const tipoUmbralParaDestinatarios: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal' = 
        tieneCriticas ? 'CriticoRojo' : 'CriticoAmarillo';

      // Pasar fundoID sin espacios para la búsqueda de contactos
      const fundoIDParaContactos = fundoID.trim();
      const destinatarios = await this.getDestinatarios(
        tipoUmbralParaDestinatarios,
        primeraAlerta.lotID,
        fundoIDParaContactos,
        primeraAlerta.loteInfo?.sectorID
      );
      
      console.log(`🔍 Buscando destinatarios para fundo: ${fundoIDParaContactos}, tipo: ${tipoUmbralParaDestinatarios}`);
      console.log(`📧 Destinatarios encontrados: ${destinatarios.length}`);

      if (destinatarios.length === 0) {
        console.warn(`⚠️ No hay destinatarios para fundo ${fundoID}`);
        return null;
      }

      // 3. Generar contenido consolidado
      const cuerpoHTML = this.generateConsolidatedHTML(alertasDetalladas);
      const cuerpoTexto = this.generateConsolidatedText(alertasDetalladas);
      const asunto = this.generateConsolidatedSubject(alertasDetalladas);

      // 4. Insertar mensaje (sin alertaID, con fundoID)
      const result = await query<{ mensajeID: number }>(`
        INSERT INTO evalImagen.Mensaje (
          fundoID,
          tipoMensaje,
          asunto,
          cuerpoHTML,
          cuerpoTexto,
          destinatarios,
          destinatariosCC,
          estado,
          fechaCreacion,
          intentosEnvio,
          statusID
        )
        OUTPUT INSERTED.mensajeID
        VALUES (
          @fundoID,
          'Email',
          @asunto,
          @cuerpoHTML,
          @cuerpoTexto,
          @destinatarios,
          NULL,
          'Pendiente',
          GETDATE(),
          0,
          1
        )
      `, {
        fundoID,
        asunto,
        cuerpoHTML,
        cuerpoTexto,
        destinatarios: JSON.stringify(destinatarios)
      });

      const mensajeID = result[0]?.mensajeID;
      if (!mensajeID) {
        throw new Error('No se pudo crear el mensaje consolidado');
      }

      // 5. Crear relaciones en tabla intermedia
      for (const alerta of alertas) {
        await query(`
          INSERT INTO evalImagen.MensajeAlerta (mensajeID, alertaID, fechaCreacion, statusID)
          VALUES (@mensajeID, @alertaID, GETDATE(), 1)
        `, { mensajeID, alertaID: alerta.alertaID });
      }

      // 6. Actualizar alertas con mensajeID
      const alertasIDs = alertas.map(a => a.alertaID);
      if (alertasIDs.length > 0) {
        // Construir query dinámico para IN clause
        const placeholders = alertasIDs.map((_, i) => `@alertaID${i}`).join(', ');
        const params: Record<string, unknown> = { mensajeID };
        alertasIDs.forEach((id, i) => {
          params[`alertaID${i}`] = id;
        });

        await query(`
          UPDATE evalImagen.Alerta
          SET mensajeID = @mensajeID
          WHERE alertaID IN (${placeholders})
        `, params);
      }

      console.log(`✅ Mensaje consolidado ${mensajeID} creado para fundo ${fundoID} con ${alertas.length} alerta(s)`);
      return mensajeID;
    } catch (error) {
      console.error(`❌ Error creando mensaje consolidado para fundo ${fundoID}:`, error);
      throw error;
    }
  }

  /**
   * Genera HTML consolidado para múltiples alertas de un fundo
   */
  private generateConsolidatedHTML(
    alertasDetalladas: Array<Alerta & { 
      fundoID: string; 
      fundo: string; 
      loteInfo: LoteInfo | null;
      umbralInfo: { descripcion: string; colorHex: string | null } | null;
    }>
  ): string {
    const fundo = alertasDetalladas[0]?.fundo || 'Desconocido';
    const totalAlertas = alertasDetalladas.length;
    const criticas = alertasDetalladas.filter(a => a.tipoUmbral === 'CriticoRojo').length;
    const advertencias = alertasDetalladas.filter(a => a.tipoUmbral === 'CriticoAmarillo').length;

    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 800px; margin: 0 auto; padding: 20px; }
    .header { background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
    .summary { margin: 20px 0; }
    .alert-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    .alert-table th, .alert-table td { 
      padding: 12px; 
      text-align: left; 
      border-bottom: 1px solid #ddd; 
    }
    .alert-table th { background-color: #f9fafb; font-weight: bold; }
    .alert-table tr:hover { background-color: #f9fafb; }
    .critica { color: #dc2626; font-weight: bold; }
    .advertencia { color: #f59e0b; font-weight: bold; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>🚨 Resumen de Alertas - Fundo: ${fundo}</h2>
      <p><strong>Total de alertas:</strong> ${totalAlertas}</p>
      <p><strong>Críticas:</strong> <span class="critica">${criticas}</span> | 
         <strong>Advertencias:</strong> <span class="advertencia">${advertencias}</span></p>
    </div>

    <table class="alert-table">
      <thead>
        <tr>
          <th>Lote</th>
          <th>Sector</th>
          <th>Tipo</th>
          <th>% Luz</th>
          <th>Severidad</th>
          <th>Fecha</th>
        </tr>
      </thead>
      <tbody>
        ${alertasDetalladas.map(alerta => `
          <tr>
            <td>${alerta.loteInfo?.lote || 'N/A'}</td>
            <td>${alerta.loteInfo?.sector || 'N/A'}</td>
            <td class="${alerta.tipoUmbral === 'CriticoRojo' ? 'critica' : 'advertencia'}">
              ${alerta.tipoUmbral === 'CriticoRojo' ? '🚨 Crítica' : '⚠️ Advertencia'}
            </td>
            <td><strong>${alerta.porcentajeLuzEvaluado.toFixed(2)}%</strong></td>
            <td>${alerta.severidad}</td>
            <td>${new Date(alerta.fechaCreacion).toLocaleString('es-ES')}</td>
          </tr>
        `).join('')}
      </tbody>
    </table>

    <div class="footer">
      <p>Este es un mensaje automático consolidado del sistema de alertas de evaluación de luz.</p>
      <p>Por favor, revisa los lotes afectados y toma las acciones necesarias.</p>
    </div>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Genera texto plano consolidado para múltiples alertas de un fundo
   */
  private generateConsolidatedText(
    alertasDetalladas: Array<Alerta & { 
      fundoID: string; 
      fundo: string; 
      loteInfo: LoteInfo | null;
      umbralInfo: { descripcion: string; colorHex: string | null } | null;
    }>
  ): string {
    const fundo = alertasDetalladas[0]?.fundo || 'Desconocido';
    const totalAlertas = alertasDetalladas.length;
    const criticas = alertasDetalladas.filter(a => a.tipoUmbral === 'CriticoRojo').length;
    const advertencias = alertasDetalladas.filter(a => a.tipoUmbral === 'CriticoAmarillo').length;

    let texto = `🚨 Resumen de Alertas - Fundo: ${fundo}\n\n`;
    texto += `Total de alertas: ${totalAlertas}\n`;
    texto += `Críticas: ${criticas} | Advertencias: ${advertencias}\n\n`;
    texto += `Detalle por lote:\n`;
    texto += `${'='.repeat(80)}\n\n`;

    for (const alerta of alertasDetalladas) {
      texto += `Lote: ${alerta.loteInfo?.lote || 'N/A'}\n`;
      texto += `Sector: ${alerta.loteInfo?.sector || 'N/A'}\n`;
      texto += `Tipo: ${alerta.tipoUmbral === 'CriticoRojo' ? '🚨 Crítica' : '⚠️ Advertencia'}\n`;
      texto += `% Luz: ${alerta.porcentajeLuzEvaluado.toFixed(2)}%\n`;
      texto += `Severidad: ${alerta.severidad}\n`;
      texto += `Fecha: ${new Date(alerta.fechaCreacion).toLocaleString('es-ES')}\n`;
      texto += `${'-'.repeat(80)}\n\n`;
    }

    texto += `\nEste es un mensaje automático consolidado del sistema de alertas de evaluación de luz.\n`;
    texto += `Por favor, revisa los lotes afectados y toma las acciones necesarias.`;

    return texto;
  }

  /**
   * Genera asunto consolidado para múltiples alertas de un fundo
   */
  private generateConsolidatedSubject(
    alertasDetalladas: Array<Alerta & { fundoID: string; fundo: string }>
  ): string {
    const fundo = alertasDetalladas[0]?.fundo || 'Desconocido';
    const totalAlertas = alertasDetalladas.length;
    const criticas = alertasDetalladas.filter(a => a.tipoUmbral === 'CriticoRojo').length;
    const advertencias = alertasDetalladas.filter(a => a.tipoUmbral === 'CriticoAmarillo').length;

    if (criticas > 0) {
      return `🚨 ${criticas} Alerta(s) Crítica(s) en Fundo ${fundo} - ${totalAlertas} lote(s) afectado(s)`;
    } else {
      return `⚠️ ${advertencias} Advertencia(s) en Fundo ${fundo} - ${totalAlertas} lote(s) afectado(s)`;
    }
  }

  /**
   * Obtiene mensajes pendientes de envío
   * Usado para estadísticas. El Worker Service lee estos mensajes para enviarlos.
   */
  async getMensajesPendientes(): Promise<Mensaje[]> {
    try {
      const rows = await query<Mensaje>(`
        SELECT 
          mensajeID,
          alertaID,
          fundoID,
          tipoMensaje,
          asunto,
          cuerpoHTML,
          cuerpoTexto,
          destinatarios,
          destinatariosCC,
          destinatariosBCC,
          estado,
          fechaCreacion,
          fechaEnvio,
          intentosEnvio,
          resendMessageID,
          errorMessage
        FROM evalImagen.Mensaje
        WHERE estado = 'Pendiente'
          AND statusID = 1
        ORDER BY fechaCreacion ASC
      `);

      return rows;
    } catch (error) {
      console.error('❌ Error obteniendo mensajes pendientes:', error);
      throw error;
    }
  }
}

export const alertService = new AlertService();

