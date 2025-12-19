import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { RefreshCw, Mail, ChevronLeft, Package, CheckCircle, XCircle, Clock } from 'lucide-react';
import { AlertasNavigation } from '../types';

interface MensajesConsolidadosProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
  onNavigateBack: () => void;
  onNavigateToMensajes: (navigation: AlertasNavigation) => void;
}

interface Mensaje {
  mensajeID: number;
  fundoID: string | null;
  fundoNombre: string | null;
  tipoMensaje: string;
  asunto: string;
  estado: string;
  fechaCreacion: string;
  fechaEnvio: string | null;
  intentosEnvio: number;
  resendMessageID: string | null;
  errorMessage: string | null;
  totalAlertas: number;
}

const MensajesConsolidados: React.FC<MensajesConsolidadosProps> = ({
  onNotification,
  onNavigateBack,
  onNavigateToMensajes
}) => {
  const [mensajes, setMensajes] = useState<Mensaje[]>([]);
  const [loading, setLoading] = useState(true);
  const [enviando, setEnviando] = useState(false);
  const [filters, setFilters] = useState({
    estado: 'Pendiente',
    page: 1,
    pageSize: 50
  });
  const [totalPages, setTotalPages] = useState(1);

  const loadMensajes = async () => {
    try {
      setLoading(true);
      const response = await apiService.getMensajes(filters);
      if (response.success) {
        const data = (response.data as any) || response;
        setMensajes(data.mensajes || []);
        setTotalPages(data.totalPages || response.pagination?.totalPages || 1);
      }
    } catch (error) {
      console.error('Error cargando mensajes:', error);
      onNotification('Error cargando mensajes consolidados', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMensajes();
  }, [filters]);

  const handleEnviar = async () => {
    if (!window.confirm('¿Deseas enviar todos los mensajes pendientes vía correo electrónico?')) {
      return;
    }

    try {
      setEnviando(true);
      const response = await apiService.enviarMensajes();
      if (response.success) {
        const data = (response.data as any) || response;
        const exitosos = data.exitosos || 0;
        const errores = data.errores || 0;
        onNotification(
          `Se enviaron ${exitosos} mensaje(s) exitosamente${errores ? `, ${errores} error(es)` : ''}`,
          errores ? 'warning' : 'success'
        );
        loadMensajes();
      }
    } catch (error) {
      console.error('Error enviando mensajes:', error);
      onNotification('Error enviando mensajes', 'error');
    } finally {
      setEnviando(false);
    }
  };

  const getEstadoColor = (estado: string) => {
    const colors: Record<string, string> = {
      'Pendiente': 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300',
      'Enviando': 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300',
      'Enviado': 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300',
      'Error': 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300'
    };
    return colors[estado] || colors['Pendiente'];
  };

  const getEstadoIcon = (estado: string) => {
    switch (estado) {
      case 'Enviado':
        return <CheckCircle className="h-4 w-4" />;
      case 'Error':
        return <XCircle className="h-4 w-4" />;
      case 'Enviando':
        return <Clock className="h-4 w-4 animate-spin" />;
      default:
        return <Package className="h-4 w-4" />;
    }
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('es-CL');
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={onNavigateBack}
            className="p-2 hover:bg-gray-100 dark:hover:bg-dark-800 rounded-lg transition-colors"
            title="Volver a Alertas"
          >
            <ChevronLeft className="h-5 w-5" />
          </button>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
              <Package className="h-6 w-6" />
              Mensajes Consolidados por Fundo
            </h2>
            <p className="text-gray-600 dark:text-dark-400 mt-1">
              Mensajes agrupados por fundo listos para enviar
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleEnviar}
            disabled={enviando || mensajes.filter(m => m.estado === 'Pendiente').length === 0}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            title="Enviar todos los mensajes pendientes"
          >
            <Mail className={`h-4 w-4 ${enviando ? 'animate-spin' : ''}`} />
            {enviando ? 'Enviando...' : 'Enviar Mensajes'}
          </button>
          <button
            onClick={loadMensajes}
            className="flex items-center gap-2 px-4 py-2 bg-gray-200 dark:bg-dark-800 text-gray-700 dark:text-dark-300 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-700 transition-colors"
          >
            <RefreshCw className="h-4 w-4" />
            Actualizar
          </button>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
        <div className="flex items-center gap-4">
          <label className="text-sm font-medium text-gray-700 dark:text-dark-300">
            Estado:
          </label>
          <select
            value={filters.estado}
            onChange={(e) => setFilters({ ...filters, estado: e.target.value, page: 1 })}
            className="px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
          >
            <option value="Pendiente">Pendiente</option>
            <option value="Enviando">Enviando</option>
            <option value="Enviado">Enviado</option>
            <option value="Error">Error</option>
            <option value="">Todos</option>
          </select>
        </div>
      </div>

      {/* Tabla de Mensajes */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-dark-800">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Fundo
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Asunto
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Alertas
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Fecha Creación
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Fecha Envío
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center">
                    <RefreshCw className="h-6 w-6 animate-spin text-primary-600 mx-auto" />
                  </td>
                </tr>
              ) : mensajes.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay mensajes que coincidan con los filtros seleccionados.
                  </td>
                </tr>
              ) : (
                mensajes.map((mensaje) => (
                  <tr key={mensaje.mensajeID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-medium ${getEstadoColor(mensaje.estado)}`}>
                        {getEstadoIcon(mensaje.estado)}
                        {mensaje.estado}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {mensaje.fundoNombre || mensaje.fundoID || 'Sin fundo'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {mensaje.asunto}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {mensaje.totalAlertas} alerta(s)
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {formatDate(mensaje.fechaCreacion)}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {formatDate(mensaje.fechaEnvio)}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <button
                        onClick={() => onNavigateToMensajes({ mensajeID: mensaje.mensajeID })}
                        className="px-3 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                      >
                        Ver Detalle
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Paginación */}
        {totalPages > 1 && (
          <div className="px-4 py-3 bg-gray-50 dark:bg-dark-800 border-t border-gray-200 dark:border-dark-700 flex items-center justify-between">
            <div className="text-sm text-gray-700 dark:text-dark-300">
              Página {filters.page} de {totalPages}
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => setFilters({ ...filters, page: Math.max(1, filters.page - 1) })}
                disabled={filters.page === 1}
                className="px-3 py-1 text-sm bg-white dark:bg-dark-900 border border-gray-300 dark:border-dark-700 rounded hover:bg-gray-50 dark:hover:bg-dark-800 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Anterior
              </button>
              <button
                onClick={() => setFilters({ ...filters, page: Math.min(totalPages, filters.page + 1) })}
                disabled={filters.page === totalPages}
                className="px-3 py-1 text-sm bg-white dark:bg-dark-900 border border-gray-300 dark:border-dark-700 rounded hover:bg-gray-50 dark:hover:bg-dark-800 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Siguiente
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default MensajesConsolidados;

