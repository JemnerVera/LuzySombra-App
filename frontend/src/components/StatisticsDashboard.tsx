import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { RefreshCw, BarChart3, TrendingUp, PieChart, Activity, FileText } from 'lucide-react';
import { exportStatisticsToPDF } from '../utils/pdfExport';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart as RechartsPieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

interface StatisticsDashboardProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

interface Statistics {
  general: {
    totalAnalisis: number;
    totalLotes: number;
    promedioLuz: number;
    promedioSombra: number;
  };
  porFundo: Array<{
    fundo: string;
    total: number;
    promedioLuz: number;
    promedioSombra: number;
  }>;
  porMes: Array<{
    mes: string;
    total: number;
    promedioLuz: number;
  }>;
  distribucionLuz: Array<{
    rango: string;
    total: number;
    porcentaje: number;
  }>;
  actividadReciente: Array<{
    fecha: string;
    total: number;
  }>;
}

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

const StatisticsDashboard: React.FC<StatisticsDashboardProps> = ({ onNotification }) => {
  const [statistics, setStatistics] = useState<Statistics | null>(null);
  const [loading, setLoading] = useState(true);

  const loadStatistics = async () => {
    try {
      setLoading(true);
      const response = await apiService.getStatistics();
      if (response.success && response.data) {
        setStatistics(response.data);
      }
    } catch (error) {
      console.error('Error cargando estadísticas:', error);
      onNotification('Error cargando estadísticas', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadStatistics();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <RefreshCw className="h-8 w-8 animate-spin text-primary-600" />
      </div>
    );
  }

  if (!statistics) {
    return (
      <div className="text-center text-gray-500 dark:text-dark-400 p-6">
        No hay estadísticas disponibles
      </div>
    );
  }

  // Formatear mes para mostrar
  const formatMes = (mes: string) => {
    const [year, month] = mes.split('-');
    const date = new Date(parseInt(year), parseInt(month) - 1);
    return date.toLocaleDateString('es-ES', { month: 'short', year: 'numeric' });
  };

  // Formatear fecha para mostrar
  const formatFecha = (fecha: string) => {
    const date = new Date(fecha);
    return date.toLocaleDateString('es-ES', { day: 'numeric', month: 'short' });
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
            <BarChart3 className="h-6 w-6" />
            Dashboard de Estadísticas
          </h2>
          <p className="text-gray-600 dark:text-dark-400 mt-1">
            Visión general del sistema y análisis de datos
          </p>
        </div>
        <div className="flex gap-2">
        <div className="flex gap-2">
          <button
            onClick={loadStatistics}
            className="flex items-center gap-2 px-4 py-2 bg-gray-200 dark:bg-dark-800 text-gray-700 dark:text-dark-300 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-700 transition-colors"
          >
            <RefreshCw className="h-4 w-4" />
            Actualizar
          </button>
          <button
            onClick={() => {
              if (statistics) {
                try {
                  exportStatisticsToPDF(statistics);
                  onNotification('PDF exportado exitosamente', 'success');
                } catch (error) {
                  onNotification('Error exportando PDF', 'error');
                }
              }
            }}
            className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            <FileText className="h-4 w-4" />
            Exportar PDF
          </button>
        </div>
          <button
            onClick={() => {
              if (statistics) {
                try {
                  exportStatisticsToPDF(statistics);
                  onNotification('PDF exportado exitosamente', 'success');
                } catch (error) {
                  onNotification('Error exportando PDF', 'error');
                }
              }
            }}
            className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            <FileText className="h-4 w-4" />
            Exportar PDF
          </button>
        </div>
      </div>

      {/* Cards de resumen */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-gray-600 dark:text-dark-400">Total Análisis</div>
              <div className="text-2xl font-bold text-gray-900 dark:text-white mt-1">
                {statistics.general.totalAnalisis.toLocaleString()}
              </div>
            </div>
            <BarChart3 className="h-8 w-8 text-blue-500" />
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-gray-600 dark:text-dark-400">Total Lotes</div>
              <div className="text-2xl font-bold text-gray-900 dark:text-white mt-1">
                {statistics.general.totalLotes.toLocaleString()}
              </div>
            </div>
            <Activity className="h-8 w-8 text-green-500" />
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-gray-600 dark:text-dark-400">Promedio % Luz</div>
              <div className="text-2xl font-bold text-yellow-600 dark:text-yellow-400 mt-1">
                {statistics.general.promedioLuz.toFixed(1)}%
              </div>
            </div>
            <TrendingUp className="h-8 w-8 text-yellow-500" />
          </div>
        </div>

        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-4 border border-gray-200 dark:border-dark-700">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-gray-600 dark:text-dark-400">Promedio % Sombra</div>
              <div className="text-2xl font-bold text-gray-600 dark:text-gray-400 mt-1">
                {statistics.general.promedioSombra.toFixed(1)}%
              </div>
            </div>
            <PieChart className="h-8 w-8 text-gray-500" />
          </div>
        </div>
      </div>

      {/* Gráficos */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Gráfico de actividad reciente */}
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Actividad Reciente (Últimos 7 días)
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={statistics.actividadReciente}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-gray-300 dark:stroke-dark-700" />
              <XAxis 
                dataKey="fecha" 
                tickFormatter={formatFecha}
                className="text-xs"
                stroke="#6b7280"
              />
              <YAxis 
                className="text-xs"
                stroke="#6b7280"
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'rgba(255, 255, 255, 0.95)',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px'
                }}
                labelFormatter={formatFecha}
              />
              <Bar dataKey="total" fill="#3b82f6" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Distribución de luz */}
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Distribución por % Luz
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <RechartsPieChart>
              <Pie
                data={statistics.distribucionLuz}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ rango, porcentaje }) => `${rango}: ${porcentaje}%`}
                outerRadius={100}
                fill="#8884d8"
                dataKey="total"
              >
                {statistics.distribucionLuz.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </RechartsPieChart>
          </ResponsiveContainer>
        </div>

        {/* Estadísticas por fundo */}
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Análisis por Fundo
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={statistics.porFundo.slice(0, 10)}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-gray-300 dark:stroke-dark-700" />
              <XAxis 
                dataKey="fundo" 
                angle={-45}
                textAnchor="end"
                height={100}
                className="text-xs"
                stroke="#6b7280"
              />
              <YAxis 
                className="text-xs"
                stroke="#6b7280"
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'rgba(255, 255, 255, 0.95)',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px'
                }}
              />
              <Legend />
              <Bar dataKey="total" fill="#3b82f6" name="Total Análisis" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Tendencia mensual */}
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
            Tendencia Mensual (Últimos 12 meses)
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={statistics.porMes}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-gray-300 dark:stroke-dark-700" />
              <XAxis 
                dataKey="mes" 
                tickFormatter={formatMes}
                className="text-xs"
                stroke="#6b7280"
              />
              <YAxis 
                className="text-xs"
                stroke="#6b7280"
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'rgba(255, 255, 255, 0.95)',
                  border: '1px solid #e5e7eb',
                  borderRadius: '8px'
                }}
                labelFormatter={formatMes}
              />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="total" 
                stroke="#3b82f6" 
                strokeWidth={2}
                name="Total Análisis"
                dot={{ r: 4 }}
              />
              <Line 
                type="monotone" 
                dataKey="promedioLuz" 
                stroke="#f59e0b" 
                strokeWidth={2}
                name="Promedio % Luz"
                dot={{ r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Tabla de estadísticas por fundo */}
      {statistics.porFundo.length > 0 && (
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
          <div className="p-6 border-b border-gray-200 dark:border-dark-700">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              Detalle por Fundo
            </h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 dark:bg-dark-800">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Fundo
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Total Análisis
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Promedio % Luz
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Promedio % Sombra
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
                {statistics.porFundo.map((fundo, index) => (
                  <tr key={index} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3 text-sm font-medium text-gray-900 dark:text-white">
                      {fundo.fundo}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {fundo.total.toLocaleString()}
                    </td>
                    <td className="px-4 py-3 text-sm text-yellow-600 dark:text-yellow-400">
                      {fundo.promedioLuz.toFixed(1)}%
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 dark:text-gray-400">
                      {fundo.promedioSombra.toFixed(1)}%
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default StatisticsDashboard;

