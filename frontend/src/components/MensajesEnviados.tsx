import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { RefreshCw, ChevronLeft, Mail, CheckCircle, XCircle } from 'lucide-react';
import { AlertasNavigation } from '../types';

interface MensajesEnviadosProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
  onNavigateBack: () => void;
  navigation?: AlertasNavigation;
}

interface MensajeDetalle {
  mensajeID: number;
  fundoID: string | null;
  fundoNombre: string | null;
  tipoMensaje: string;
  asunto: string;
  cuerpoHTML: string;
  cuerpoTexto: string | null;
  destinatarios: string;
  estado: string;
  fechaCreacion: string;
  fechaEnvio: string | null;
  intentosEnvio: number;
  resendMessageID: string | null;
  errorMessage: string | null;
}

interface AlertaAsociada {
  alertaID: number;
  lotID: number;
  loteNombre: string;
  sectorNombre: string;
  tipoUmbral: string;
  porcentajeLuzEvaluado: number;
  fechaCreacion: string;
}

const MensajesEnviados: React.FC<MensajesEnviadosProps> = ({
  onNotification,
  onNavigateBack,
  navigation
}) => {
  const [mensaje, setMensaje] = useState<MensajeDetalle | null>(null);
  const [alertas, setAlertas] = useState<AlertaAsociada[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (navigation?.mensajeID) {
      loadMensaje();
    }
  }, [navigation?.mensajeID]);

  const loadMensaje = async () => {
    if (!navigation?.mensajeID) return;

    try {
      setLoading(true);
      const response = await apiService.getMensajeById(navigation.mensajeID);
      if (response.success) {
        const data = (response.data as any) || response;
        setMensaje(data.mensaje);
        setAlertas(data.alertas || []);
      }
    } catch (error) {
      console.error('Error cargando mensaje:', error);
      onNotification('Error cargando detalle del mensaje', 'error');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('es-CL');
  };

  const parseDestinatarios = (destinatariosJson: string): string[] => {
    try {
      return JSON.parse(destinatariosJson);
    } catch {
      return [];
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <RefreshCw className="h-8 w-8 animate-spin text-primary-600" />
      </div>
    );
  }

  if (!mensaje) {
    return (
      <div className="p-6">
        <button
          onClick={onNavigateBack}
          className="mb-4 flex items-center gap-2 px-4 py-2 bg-gray-200 dark:bg-dark-800 text-gray-700 dark:text-dark-300 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-700 transition-colors"
        >
          <ChevronLeft className="h-4 w-4" />
          Volver
        </button>
        <div className="text-center text-gray-500 dark:text-dark-400">
          No se encontró el mensaje
        </div>
      </div>
    );
  }

  const destinatarios = parseDestinatarios(mensaje.destinatarios);

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={onNavigateBack}
            className="p-2 hover:bg-gray-100 dark:hover:bg-dark-800 rounded-lg transition-colors"
            title="Volver"
          >
            <ChevronLeft className="h-5 w-5" />
          </button>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
              <Mail className="h-6 w-6" />
              Detalle de Mensaje Enviado
            </h2>
            <p className="text-gray-600 dark:text-dark-400 mt-1">
              Información completa del mensaje y alertas asociadas
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {mensaje.estado === 'Enviado' && mensaje.resendMessageID && (
            <span className="text-sm text-gray-600 dark:text-dark-400">
              ID Resend: {mensaje.resendMessageID}
            </span>
          )}
        </div>
      </div>

      {/* Información del Mensaje */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700 space-y-4">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">Información del Mensaje</h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Estado</label>
            <div className="mt-1">
              <span className={`inline-flex items-center gap-1 px-2 py-1 rounded text-sm font-medium ${
                mensaje.estado === 'Enviado' 
                  ? 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300'
                  : mensaje.estado === 'Error'
                  ? 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300'
                  : 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300'
              }`}>
                {mensaje.estado === 'Enviado' ? <CheckCircle className="h-4 w-4" /> : <XCircle className="h-4 w-4" />}
                {mensaje.estado}
              </span>
            </div>
          </div>
          
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Fundo</label>
            <p className="mt-1 text-sm text-gray-900 dark:text-white">
              {mensaje.fundoNombre || mensaje.fundoID || 'Sin fundo'}
            </p>
          </div>
          
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Asunto</label>
            <p className="mt-1 text-sm text-gray-900 dark:text-white">{mensaje.asunto}</p>
          </div>
          
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Fecha de Creación</label>
            <p className="mt-1 text-sm text-gray-900 dark:text-white">{formatDate(mensaje.fechaCreacion)}</p>
          </div>
          
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Fecha de Envío</label>
            <p className="mt-1 text-sm text-gray-900 dark:text-white">{formatDate(mensaje.fechaEnvio)}</p>
          </div>
          
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Intentos de Envío</label>
            <p className="mt-1 text-sm text-gray-900 dark:text-white">{mensaje.intentosEnvio}</p>
          </div>
        </div>

        <div>
          <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Destinatarios</label>
          <div className="mt-1">
            {destinatarios.map((email, index) => (
              <span key={index} className="inline-block mr-2 mb-2 px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 rounded text-sm">
                {email}
              </span>
            ))}
          </div>
        </div>

        {mensaje.errorMessage && (
          <div>
            <label className="text-sm font-medium text-gray-500 dark:text-dark-400">Error</label>
            <p className="mt-1 text-sm text-red-600 dark:text-red-400">{mensaje.errorMessage}</p>
          </div>
        )}
      </div>

      {/* Alertas Asociadas */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="p-4 border-b border-gray-200 dark:border-dark-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
            Alertas Asociadas ({alertas.length})
          </h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-dark-800">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Lote
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Sector
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  % Luz
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Fecha
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
              {alertas.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay alertas asociadas
                  </td>
                </tr>
              ) : (
                alertas.map((alerta) => (
                  <tr key={alerta.alertaID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {alerta.loteNombre}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {alerta.sectorNombre}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {alerta.tipoUmbral === 'CriticoRojo' ? '🚨 Crítico Rojo' : '⚠️ Crítico Amarillo'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {alerta.porcentajeLuzEvaluado.toFixed(2)}%
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {formatDate(alerta.fechaCreacion)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Vista Previa del HTML */}
      {mensaje.cuerpoHTML && (
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
          <div className="p-4 border-b border-gray-200 dark:border-dark-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">Vista Previa del Email</h3>
          </div>
          <div className="p-4">
            <div 
              className="prose dark:prose-invert max-w-none"
              dangerouslySetInnerHTML={{ __html: mensaje.cuerpoHTML }}
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default MensajesEnviados;

