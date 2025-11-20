import React, { useState, useEffect } from 'react';
import { RefreshCw, Eye, ArrowLeft } from 'lucide-react';
import { apiService } from '../services/api';
import { DetalleNavigation } from '../types';

interface EvaluacionPorFechaProps {
  navigation: DetalleNavigation;
  onBack: () => void;
  onNavigateToDetallePlanta: (navigation: DetalleNavigation) => void;
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

interface DetalleRow {
  fecha: string;
  luzMin: number | null;
  luzMax: number | null;
  luzProm: number | null;
  sombraMin: number | null;
  sombraMax: number | null;
  sombraProm: number | null;
}

const EvaluacionPorFecha: React.FC<EvaluacionPorFechaProps> = ({ 
  navigation, 
  onBack, 
  onNavigateToDetallePlanta,
  onNotification: _onNotification
}) => {
  const [data, setData] = useState<DetalleRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadData();
  }, [navigation]);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const result = await apiService.getDetalleHistorial(
        navigation.fundo,
        navigation.sector,
        navigation.lote
      );
      
      if (result.success && result.data) {
        setData(result.data);
      } else {
        setError((result as any).error || 'No se pudieron cargar los datos del detalle');
      }
    } catch (err) {
      console.error('Error loading detalle:', err);
      setError(err instanceof Error ? err.message : 'Error cargando detalle histórico');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-PE', { day: '2-digit', month: '2-digit' });
  };

  return (
    <div className="space-y-6">
      {/* Header con botón de regreso */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={onBack}
            className="flex items-center space-x-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
            <span>Volver</span>
          </button>
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
              Evaluación por Fecha
            </h2>
            <p className="text-sm text-gray-600 dark:text-dark-300 mt-1">
              {navigation.fundo} - {navigation.sector} - {navigation.lote}
            </p>
          </div>
        </div>
        <button
          onClick={loadData}
          disabled={loading}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
          Actualizar
        </button>
      </div>

      {/* Error */}
      {error && (
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-800 dark:text-red-200 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      {/* Tabla */}
      <div className="bg-white dark:bg-dark-800 rounded-xl shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-dark-700 text-xs">
            <thead className="bg-gray-50 dark:bg-dark-700">
              <tr>
                <th rowSpan={2} className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                  Fecha
                </th>
                <th colSpan={3} className="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                  Luz
                </th>
                <th colSpan={3} className="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                  Sombra
                </th>
                <th rowSpan={2} className="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Ver Detalle
                </th>
              </tr>
              <tr>
                <th className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">
                  Min
                </th>
                <th className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">
                  Prom
                </th>
                <th className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">
                  Max
                </th>
                <th className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">
                  Min
                </th>
                <th className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">
                  Prom
                </th>
                <th className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">
                  Max
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-dark-800 divide-y divide-gray-200 dark:divide-dark-700">
              {loading ? (
                <tr>
                  <td colSpan={8} className="px-6 py-8 text-center">
                    <RefreshCw className="h-6 w-6 animate-spin mx-auto mb-2 text-blue-500" />
                    <p className="text-gray-600 dark:text-dark-300">Cargando datos...</p>
                  </td>
                </tr>
              ) : data.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-6 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay datos históricos disponibles para este lote
                  </td>
                </tr>
              ) : (
                data.map((row, index) => (
                  <tr key={index} className="hover:bg-gray-50 dark:hover:bg-dark-700 transition-colors">
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                      {formatDate(row.fecha)}
                    </td>
                    <td className="px-2 py-3 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.luzMin !== null ? row.luzMin.toFixed(2) : '-'}
                    </td>
                    <td className="px-2 py-3 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.luzProm !== null ? row.luzProm.toFixed(2) : '-'}
                    </td>
                    <td className="px-2 py-3 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.luzMax !== null ? row.luzMax.toFixed(2) : '-'}
                    </td>
                    <td className="px-2 py-3 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.sombraMin !== null ? row.sombraMin.toFixed(2) : '-'}
                    </td>
                    <td className="px-2 py-3 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.sombraProm !== null ? row.sombraProm.toFixed(2) : '-'}
                    </td>
                    <td className="px-2 py-3 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.sombraMax !== null ? row.sombraMax.toFixed(2) : '-'}
                    </td>
                                         <td className="px-4 py-3 whitespace-nowrap text-center">
                       <button
                         onClick={() => onNavigateToDetallePlanta({ ...navigation, fecha: row.fecha })}
                         className="inline-flex items-center justify-center p-2 text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors"
                         title="Ver detalle por evaluación"
                       >
                         <Eye className="h-5 w-5" />
                       </button>
                     </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default EvaluacionPorFecha;
