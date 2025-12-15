import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { RefreshCw, CheckCircle, XCircle, AlertTriangle, Filter, Calendar, MapPin, Package } from 'lucide-react';
import { AlertasNavigation } from '../types';

interface Alerta {
  alertaID: number;
  lotID: number;
  loteEvaluacionID: number | null;
  umbralID: number;
  variedadID: number | null;
  porcentajeLuzEvaluado: number;
  tipoUmbral: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal';
  severidad: 'Critica' | 'Advertencia' | 'Info';
  estado: 'Pendiente' | 'Enviada' | 'Resuelta' | 'Ignorada';
  fechaCreacion: string;
  fechaEnvio: string | null;
  fechaResolucion: string | null;
  notas?: string | null;
  loteNombre?: string;
  fundoNombre?: string;
  sectorNombre?: string;
  variedadNombre?: string;
  umbralDescripcion?: string;
  umbralColor?: string;
}

interface Estadisticas {
  total: number;
  porEstado: Record<string, number>;
  porTipo: Record<string, number>;
  porSeveridad: Record<string, number>;
  ultimas24Horas: number;
}

interface AlertasDashboardProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
  onNavigateToConsolidados?: () => void;
}

const AlertasDashboard: React.FC<AlertasDashboardProps> = ({ onNotification, onNavigateToConsolidados }) => {
  const [alertas, setAlertas] = useState<Alerta[]>([]);
  const [estadisticas, setEstadisticas] = useState<Estadisticas | null>(null);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    estado: '',
    tipoUmbral: '',
    page: 1,
    pageSize: 50
  });
  const [totalPages, setTotalPages] = useState(1);
  const [consolidando, setConsolidando] = useState(false);

  const loadAlertas = async () => {
    try {
      setLoading(true);
      const response = await apiService.getAlertas(filters);
      if (response.success) {
        setAlertas(response.alertas || []);
        setTotalPages(response.totalPages || 1);
      }
    } catch (error) {
      console.error('Error cargando alertas:', error);
      onNotification('Error cargando alertas', 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadEstadisticas = async () => {
    try {
      const response = await apiService.getEstadisticasAlertas();
      if (response.success && response.data) {
        setEstadisticas(response.data);
      }
    } catch (error) {
      console.error('Error cargando estadísticas:', error);
    }
  };

  useEffect(() => {
    loadAlertas();
    loadEstadisticas();
  }, [filters]);

  const handleResolver = async (alertaID: number) => {
    if (!window.confirm('¿Estás seguro de que deseas marcar esta alerta como resuelta?')) {
      return;
    }

    try {
      const response = await apiService.resolverAlerta(alertaID, 1); // TODO: Obtener del contexto de usuario
      if (response.success) {
        onNotification('Alerta resuelta exitosamente', 'success');
        loadAlertas();
        loadEstadisticas();
      }
    } catch (error) {
      console.error('Error resolviendo alerta:', error);
      onNotification('Error resolviendo alerta', 'error');
    }
  };

  const handleIgnorar = async (alertaID: number) => {
    if (!window.confirm('¿Estás seguro de que deseas ignorar esta alerta?')) {
      return;
    }

    try {
      const response = await apiService.ignorarAlerta(alertaID, 1); // TODO: Obtener del contexto de usuario
      if (response.success) {
        onNotification('Alerta ignorada exitosamente', 'success');
        loadAlertas();
        loadEstadisticas();
      }
    } catch (error) {
      console.error('Error ignorando alerta:', error);
      onNotification('Error ignorando alerta', 'error');
    }
  };

  const handleConsolidar = async () => {
    if (!window.confirm('¿Deseas consolidar las alertas pendientes en mensajes por fundo? Esto agrupará las alertas para enviarlas por correo.')) {
      return;
    }

    try {
      setConsolidando(true);
      const response = await apiService.consolidarAlertas(24);
      if (response.success) {
        onNotification(
          `Se consolidaron ${response.mensajesCreados || 0} mensaje(s) exitosamente`,
          'success'
        );
        loadAlertas();
        loadEstadisticas();
      }
    } catch (error) {
      console.error('Error consolidando alertas:', error);
      onNotification('Error consolidando alertas', 'error');
    } finally {
      setConsolidando(false);
    }
  };


  const getEstadoColor = (estado: string) => {
    const colors: Record<string, string> = {
      'Pendiente': 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300',
      'Enviada': 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300',
      'Resuelta': 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300',
      'Ignorada': 'bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300'
    };
    return colors[estado] || colors['Pendiente'];
  };

  const getSeveridadIcon = (severidad: string) => {
    switch (severidad) {
      case 'Critica':
        return <AlertTriangle className="h-5 w-5 text-red-600" />;
      case 'Advertencia':
        return <AlertTriangle className="h-5 w-5 text-yellow-600" />;
      default:
        return <AlertTriangle className="h-5 w-5 text-blue-600" />;
    }
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString('es-CL');
  };

  if (loading && !estadisticas) {
    return (
      <div className="flex items-center justify-center h-64">
        <RefreshCw className="h-8 w-8 animate-spin text-primary-600" />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
            <AlertTriangle className="h-6 w-6" />
            Dashboard de Alertas
          </h2>
          <p className="text-gray-600 dark:text-dark-400 mt-1">
            Visualiza y gestiona las alertas del sistema
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleConsolidar}
            disabled={consolidando}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            title="Consolidar alertas pendientes en mensajes por fundo"
          >
            <Package className={`h-4 w-4 ${consolidando ? 'animate-spin' : ''}`} />
            {consolidando ? 'Consolidando...' : 'Consolidar Alertas'}
          </button>
          {onNavigateToConsolidados && (
            <button
              onClick={onNavigateToConsolidados}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              title="Ver mensajes consolidados por fundo"
            >
              <Package className="h-4 w-4" />
              Ver Consolidados
            </button>
          )}
          <button
            onClick={() => {
              loadAlertas();
              loadEstadisticas();
            }}
            className="flex items-center gap-2 px-4 py-2 bg-gray-200 dark:bg-dark-800 text-gray-700 dark:text-dark-300 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-700 transition-colors"
          >
            <RefreshCw className="h-4 w-4" />
            Actualizar
          </button>
        </div>
      </div>

      {/* Estadísticas */}
      {estadisticas && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
            <div className="text-sm text-gray-600 dark:text-dark-400">Total Alertas</div>
            <div className="text-2xl font-bold text-gray-900 dark:text-white mt-1">
              {estadisticas.total}
            </div>
          </div>
          <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
            <div className="text-sm text-gray-600 dark:text-dark-400">Últimas 24h</div>
            <div className="text-2xl font-bold text-yellow-600 dark:text-yellow-400 mt-1">
              {estadisticas.ultimas24Horas}
            </div>
          </div>
          <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
            <div className="text-sm text-gray-600 dark:text-dark-400">Pendientes</div>
            <div className="text-2xl font-bold text-yellow-600 dark:text-yellow-400 mt-1">
              {estadisticas.porEstado['Pendiente'] || 0}
            </div>
          </div>
          <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
            <div className="text-sm text-gray-600 dark:text-dark-400">Resueltas</div>
            <div className="text-2xl font-bold text-green-600 dark:text-green-400 mt-1">
              {estadisticas.porEstado['Resuelta'] || 0}
            </div>
          </div>
        </div>
      )}

      {/* Filtros */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
        <div className="flex items-center gap-2 mb-4">
          <Filter className="h-5 w-5 text-gray-500" />
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">Filtros</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
              Estado
            </label>
            <select
              value={filters.estado}
              onChange={(e) => setFilters({ ...filters, estado: e.target.value, page: 1 })}
              className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
            >
              <option value="">Todos</option>
              <option value="Pendiente">Pendiente</option>
              <option value="Enviada">Enviada</option>
              <option value="Resuelta">Resuelta</option>
              <option value="Ignorada">Ignorada</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
              Tipo de Umbral
            </label>
            <select
              value={filters.tipoUmbral}
              onChange={(e) => setFilters({ ...filters, tipoUmbral: e.target.value, page: 1 })}
              className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
            >
              <option value="">Todos</option>
              <option value="CriticoRojo">Crítico Rojo</option>
              <option value="CriticoAmarillo">Crítico Amarillo</option>
              <option value="Normal">Normal</option>
            </select>
          </div>
        </div>
      </div>

      {/* Tabla de Alertas */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-dark-800">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Lote / Ubicación
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Tipo / Severidad
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  % Luz
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Fecha
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-4 py-8 text-center">
                    <RefreshCw className="h-6 w-6 animate-spin text-primary-600 mx-auto" />
                  </td>
                </tr>
              ) : alertas.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-4 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay alertas que coincidan con los filtros seleccionados.
                  </td>
                </tr>
              ) : (
                alertas.map((alerta) => (
                  <tr key={alerta.alertaID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getEstadoColor(alerta.estado)}`}>
                        {alerta.estado}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="space-y-1">
                        <div className="flex items-center gap-2">
                          <MapPin className="h-4 w-4 text-gray-400" />
                          <span className="text-sm font-medium text-gray-900 dark:text-white">
                            {alerta.loteNombre || `Lote ${alerta.lotID}`}
                          </span>
                        </div>
                        <div className="text-xs text-gray-500 dark:text-dark-400">
                          {alerta.fundoNombre && `${alerta.fundoNombre}`}
                          {alerta.sectorNombre && ` / ${alerta.sectorNombre}`}
                        </div>
                        {alerta.variedadNombre && (
                          <div className="text-xs text-gray-500 dark:text-dark-400">
                            Variedad: {alerta.variedadNombre}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {getSeveridadIcon(alerta.severidad)}
                        <div>
                          <div className="text-sm font-medium text-gray-900 dark:text-white">
                            {alerta.tipoUmbral === 'CriticoRojo' ? '🚨 Crítico Rojo' :
                             alerta.tipoUmbral === 'CriticoAmarillo' ? '⚠️ Crítico Amarillo' :
                             '✅ Normal'}
                          </div>
                          <div className="text-xs text-gray-500 dark:text-dark-400">
                            {alerta.severidad}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="text-sm font-medium text-gray-900 dark:text-white">
                        {alerta.porcentajeLuzEvaluado.toFixed(1)}%
                      </div>
                      {alerta.umbralDescripcion && (
                        <div className="text-xs text-gray-500 dark:text-dark-400">
                          {alerta.umbralDescripcion}
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1 text-sm text-gray-900 dark:text-white">
                        <Calendar className="h-4 w-4 text-gray-400" />
                        {formatDate(alerta.fechaCreacion)}
                      </div>
                      {alerta.fechaEnvio && (
                        <div className="text-xs text-gray-500 dark:text-dark-400 mt-1">
                          Enviada: {formatDate(alerta.fechaEnvio)}
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="flex items-center justify-end gap-2">
                        {alerta.estado === 'Pendiente' || alerta.estado === 'Enviada' ? (
                          <>
                            <button
                              onClick={() => handleResolver(alerta.alertaID)}
                              className="p-2 text-green-600 hover:bg-green-50 dark:hover:bg-green-900/30 rounded transition-colors"
                              title="Resolver"
                            >
                              <CheckCircle className="h-4 w-4" />
                            </button>
                            <button
                              onClick={() => handleIgnorar(alerta.alertaID)}
                              className="p-2 text-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 rounded transition-colors"
                              title="Ignorar"
                            >
                              <XCircle className="h-4 w-4" />
                            </button>
                          </>
                        ) : null}
                      </div>
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

export default AlertasDashboard;

