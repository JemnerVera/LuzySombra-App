import React, { useState, useEffect, useRef } from 'react';
import { apiService } from '../services/api';
import { HistoryRecord } from '../types';
import { formatDate, exportToCSV } from '../utils/helpers';
import { exportHistoryToPDF } from '../utils/pdfExport';
import { Download, RefreshCw, Search, ChevronLeft, ChevronRight, FileText } from 'lucide-react';

interface HistoryTableProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

const HistoryTable: React.FC<HistoryTableProps> = ({ onNotification }) => {
  const [history, setHistory] = useState<HistoryRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterEmpresa, setFilterEmpresa] = useState('');
  const [filterFundo, setFilterFundo] = useState('');
  const [filterFechaDesde, setFilterFechaDesde] = useState('');
  const [filterFechaHasta, setFilterFechaHasta] = useState('');
  const [filterPorcentajeLuzMin, setFilterPorcentajeLuzMin] = useState('');
  const [filterPorcentajeLuzMax, setFilterPorcentajeLuzMax] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 50; // Aumentado a 50 para mejor rendimiento
  const [totalRecords, setTotalRecords] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const isInitialMount = useRef(true);
  const prevFilters = useRef({ filterEmpresa, filterFundo, filterFechaDesde, filterFechaHasta, filterPorcentajeLuzMin, filterPorcentajeLuzMax });
  const pageChangeFromFilter = useRef(false);

  const loadHistory = async (page: number = currentPage) => {
    try {
      setLoading(true);
      setError(null);
      console.log(`📊 Loading history page ${page}...`);
      
      // Construir filtros para enviar al servidor
      const params: { 
        page: number; 
        pageSize: number; 
        empresa?: string; 
        fundo?: string;
        fechaDesde?: string;
        fechaHasta?: string;
        porcentajeLuzMin?: number;
        porcentajeLuzMax?: number;
      } = {
        page,
        pageSize: itemsPerPage
      };
      
      if (filterEmpresa) params.empresa = filterEmpresa;
      if (filterFundo) params.fundo = filterFundo;
      if (filterFechaDesde) params.fechaDesde = filterFechaDesde;
      if (filterFechaHasta) params.fechaHasta = filterFechaHasta;
      if (filterPorcentajeLuzMin) {
        const min = parseFloat(filterPorcentajeLuzMin);
        if (!isNaN(min)) params.porcentajeLuzMin = min;
      }
      if (filterPorcentajeLuzMax) {
        const max = parseFloat(filterPorcentajeLuzMax);
        if (!isNaN(max)) params.porcentajeLuzMax = max;
      }
      
      const response = await apiService.getHistory(params);
      
      if (response.success && response.data) {
        setHistory(response.data);
        setTotalRecords(response.pagination?.total || 0);
        setTotalPages(response.pagination?.totalPages || 0);
        console.log(`📊 History loaded: page ${page}/${response.pagination?.totalPages || 0} (${response.data.length} records, total: ${response.pagination?.total || 0})`);
      } else {
        setError('No se pudieron cargar los datos del historial');
      }
    } catch (err) {
      console.error('❌ Error loading history:', err);
      setError(err instanceof Error ? err.message : 'Error cargando historial');
    } finally {
      setLoading(false);
    }
  };

  // Efecto para manejar cambios en filtros
  useEffect(() => {
    const filtersChanged = 
      prevFilters.current.filterEmpresa !== filterEmpresa ||
      prevFilters.current.filterFundo !== filterFundo ||
      prevFilters.current.filterFechaDesde !== filterFechaDesde ||
      prevFilters.current.filterFechaHasta !== filterFechaHasta ||
      prevFilters.current.filterPorcentajeLuzMin !== filterPorcentajeLuzMin ||
      prevFilters.current.filterPorcentajeLuzMax !== filterPorcentajeLuzMax;

    if (filtersChanged && !isInitialMount.current) {
      // Si cambian los filtros (y no es el mount inicial), resetear a página 1
      prevFilters.current = { 
        filterEmpresa, 
        filterFundo, 
        filterFechaDesde, 
        filterFechaHasta, 
        filterPorcentajeLuzMin, 
        filterPorcentajeLuzMax 
      };
      pageChangeFromFilter.current = true;
      setCurrentPage(1);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filterEmpresa, filterFundo, filterFechaDesde, filterFechaHasta, filterPorcentajeLuzMin, filterPorcentajeLuzMax]);

  // Efecto principal para cargar datos
  useEffect(() => {
    if (isInitialMount.current) {
      // Carga inicial
      isInitialMount.current = false;
      prevFilters.current = { 
        filterEmpresa, 
        filterFundo,
        filterFechaDesde: '',
        filterFechaHasta: '',
        filterPorcentajeLuzMin: '',
        filterPorcentajeLuzMax: ''
      };
      loadHistory(1);
    } else if (pageChangeFromFilter.current) {
      // Si el cambio de página fue causado por un cambio de filtro, cargar página 1
      pageChangeFromFilter.current = false;
      loadHistory(1);
    } else {
      // Cargar la página actual (cambio de página normal)
      loadHistory(currentPage);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPage, filterEmpresa, filterFundo]);

  const handleExportCSV = () => {
    if (history.length === 0) {
      onNotification('No hay datos para exportar', 'warning');
      return;
    }

    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      exportToCSV(history as Record<string, unknown>[], 'historial_luz_sombra.csv');
      onNotification('✅ Historial exportado exitosamente', 'success');
    } catch (error) {
      console.error('Error exporting CSV:', error);
      onNotification('Error al exportar el historial', 'error');
    }
  };

  // Filtrar localmente solo por búsqueda de texto (filtros de empresa y fundo ya vienen del servidor)
  const filteredHistory = history
    .filter(record => {
      if (!searchTerm) return true;
      
      return (
        record.empresa.toLowerCase().includes(searchTerm.toLowerCase()) ||
        record.fundo.toLowerCase().includes(searchTerm.toLowerCase()) ||
        record.sector.toLowerCase().includes(searchTerm.toLowerCase()) ||
        record.lote.toLowerCase().includes(searchTerm.toLowerCase()) ||
        record.hilera.toLowerCase().includes(searchTerm.toLowerCase()) ||
        record.numero_planta.toLowerCase().includes(searchTerm.toLowerCase())
      );
    })
    .sort((a, b) => parseInt(b.id) - parseInt(a.id)); // Ordenar por ID descendente (más recientes primero)

  // Usar totalPages del servidor (ya viene en el estado)
  // Si hay búsqueda local, recalcular paginación local
  const localTotalPages = searchTerm 
    ? Math.ceil(filteredHistory.length / itemsPerPage)
    : totalPages;
  
  const startIndex = searchTerm ? (currentPage - 1) * itemsPerPage : 0;
  const endIndex = searchTerm ? startIndex + itemsPerPage : filteredHistory.length;
  const paginatedHistory = searchTerm 
    ? filteredHistory.slice(startIndex, endIndex)
    : filteredHistory;

  // Resetear página cuando cambien los filtros
  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm]); // Solo resetear cuando cambie searchTerm (filtro local)
  // filterEmpresa y filterFundo ya disparan loadHistory que resetea la página en el servidor

  const uniqueEmpresas = [...new Set(history.map(record => record.empresa))];
  const uniqueFundos = [...new Set(history.map(record => record.fundo))];

  if (loading) {
    return (
      <div className="space-y-6">
        {/* Loading Header */}
        <div className="bg-white dark:bg-dark-800 p-6 rounded-lg shadow">
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center space-x-3">
              <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
                📊 Cargando Historial...
              </h2>
            </div>
            <div className="text-sm text-gray-500 dark:text-dark-400">
              Esto puede tomar unos segundos
            </div>
          </div>
          <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
            <div className="flex items-center space-x-2">
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
              <span className="text-sm text-blue-700 dark:text-blue-300">
                Cargando historial desde SQL Server...
              </span>
            </div>
          </div>
        </div>
        
        {/* Table Skeleton */}
        <div className="bg-white dark:bg-dark-800 rounded-lg shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200 dark:divide-dark-600">
              <thead className="bg-gray-50 dark:bg-dark-700">
                <tr>
                  {Array.from({ length: 10 }).map((_, i) => (
                    <th key={i} className="px-6 py-3">
                      <div className="h-4 bg-gray-200 dark:bg-dark-600 rounded w-20"></div>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="bg-white dark:bg-dark-800 divide-y divide-gray-200 dark:divide-dark-600">
                {Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    {Array.from({ length: 10 }).map((_, j) => (
                      <td key={j} className="px-6 py-4">
                        <div className="h-4 bg-gray-200 dark:bg-dark-600 rounded w-16"></div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white dark:bg-dark-800 p-6 rounded-lg shadow">
        <div className="text-center">
          <div className="text-red-500 text-lg font-medium mb-2">Error al cargar el historial</div>
          <p className="text-gray-600 dark:text-dark-300 mb-4">{error}</p>
          <button
            onClick={() => loadHistory()}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            <RefreshCw className="h-4 w-4 mr-2" />
            Reintentar
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="bg-white dark:bg-dark-800 p-6 rounded-xl shadow-2xl border border-gray-200 dark:border-dark-700">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white font-display">
            Historial de Procesamiento
          </h2>
          <div className="flex space-x-3">
            <button
              onClick={() => loadHistory()}
              className="inline-flex items-center px-3 py-2 border border-gray-300 dark:border-dark-600 text-sm font-medium rounded-lg text-gray-700 dark:text-dark-200 bg-white dark:bg-dark-700 hover:bg-gray-50 dark:hover:bg-dark-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 transition-all duration-200"
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              Actualizar
            </button>
            <button
              onClick={handleExportCSV}
              className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-gradient-to-r from-accent-600 to-accent-700 hover:from-accent-700 hover:to-accent-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-accent-500 transition-all duration-200 shadow-md hover:shadow-lg"
            >
              <Download className="h-4 w-4 mr-2" />
              Exportar CSV
            </button>
            <button
              onClick={() => {
                try {
                  exportHistoryToPDF(history);
                  onNotification('PDF exportado exitosamente', 'success');
                } catch (error) {
                  onNotification('Error exportando PDF', 'error');
                }
              }}
              className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-all duration-200 shadow-md hover:shadow-lg"
            >
              <FileText className="h-4 w-4 mr-2" />
              Exportar PDF
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="space-y-4">
          {/* Primera fila de filtros */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                Buscar
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400 dark:text-dark-400" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Buscar en todos los campos..."
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-dark-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                Empresa
              </label>
              <select
                value={filterEmpresa}
                onChange={(e) => setFilterEmpresa(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
              >
                <option value="">Todas las empresas</option>
                {uniqueEmpresas.map((empresa) => (
                  <option key={empresa} value={empresa}>
                    {empresa}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                Fundo
              </label>
              <select
                value={filterFundo}
                onChange={(e) => setFilterFundo(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
              >
                <option value="">Todos los fundos</option>
                {uniqueFundos.map((fundo) => (
                  <option key={fundo} value={fundo}>
                    {fundo}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Segunda fila de filtros avanzados */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                Fecha Desde
              </label>
              <input
                type="date"
                value={filterFechaDesde}
                onChange={(e) => setFilterFechaDesde(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                Fecha Hasta
              </label>
              <input
                type="date"
                value={filterFechaHasta}
                onChange={(e) => setFilterFechaHasta(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                % Luz Mínimo
              </label>
              <input
                type="number"
                min="0"
                max="100"
                step="0.1"
                value={filterPorcentajeLuzMin}
                onChange={(e) => setFilterPorcentajeLuzMin(e.target.value)}
                placeholder="0"
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-200 mb-1">
                % Luz Máximo
              </label>
              <input
                type="number"
                min="0"
                max="100"
                step="0.1"
                value={filterPorcentajeLuzMax}
                onChange={(e) => setFilterPorcentajeLuzMax(e.target.value)}
                placeholder="100"
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all duration-200"
              />
            </div>
          </div>
        </div>

        <div className="mt-4 text-sm text-gray-600 dark:text-dark-300">
          {searchTerm 
            ? `Mostrando ${startIndex + 1}-${Math.min(endIndex, filteredHistory.length)} de ${filteredHistory.length} registros encontrados`
            : `Mostrando ${history.length} registros de ${totalRecords} total (Página ${currentPage} de ${totalPages})`
          }
        </div>
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-dark-800 rounded-xl shadow-2xl border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-dark-700">
            <thead className="bg-gray-50 dark:bg-dark-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Empresa
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Fundo
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Sector
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Lote
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Hilera
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  N° Planta
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Luz %
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Sombra %
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  Fecha
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                  GPS
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-dark-800 divide-y divide-gray-200 dark:divide-dark-700">
              {paginatedHistory.length === 0 ? (
                <tr>
                  <td colSpan={10} className="px-6 py-4 text-center text-gray-500 dark:text-dark-400">
                    No se encontraron registros
                  </td>
                </tr>
              ) : (
                paginatedHistory.map((record) => (
                  <tr key={record.id} className="hover:bg-gray-50 dark:hover:bg-dark-700 transition-colors duration-200">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                      {record.empresa}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {record.fundo}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {record.sector || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {record.lote || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {record.hilera || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {record.numero_planta || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-500/20 text-yellow-600 dark:text-yellow-400 border border-yellow-500/30">
                        {record.porcentaje_luz}%
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-200 dark:bg-dark-600 text-gray-700 dark:text-dark-300 border border-gray-300 dark:border-dark-500">
                        {record.porcentaje_sombra}%
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {formatDate(record.fecha_tomada)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-dark-200">
                      {record.latitud && record.longitud ? (
                        <span className="text-accent-600 dark:text-accent-400 text-xs">
                          {record.latitud.toFixed(4)}, {record.longitud.toFixed(4)}
                        </span>
                      ) : (
                        <span className="text-red-600 dark:text-red-400 text-xs">Sin GPS</span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Paginación - Mostrar siempre que haya más de 1 página (servidor o búsqueda local) */}
      {(searchTerm ? localTotalPages > 1 : totalPages > 1) && (
        <div className="bg-white dark:bg-dark-800 px-4 py-3 flex items-center justify-between border-t border-gray-200 dark:border-dark-700 sm:px-6 rounded-xl shadow-2xl border border-gray-200 dark:border-dark-700">
          <div className="flex-1 flex justify-between sm:hidden">
            <button
              onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
              disabled={currentPage === 1}
              className="relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-dark-600 text-sm font-medium rounded-lg text-gray-700 dark:text-dark-200 bg-white dark:bg-dark-700 hover:bg-gray-50 dark:hover:bg-dark-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              Anterior
            </button>
            <button
              onClick={() => {
                const maxPages = searchTerm ? localTotalPages : totalPages;
                setCurrentPage(prev => Math.min(prev + 1, maxPages));
              }}
              disabled={currentPage >= (searchTerm ? localTotalPages : totalPages)}
              className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-dark-600 text-sm font-medium rounded-lg text-gray-700 dark:text-dark-200 bg-white dark:bg-dark-700 hover:bg-gray-50 dark:hover:bg-dark-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              Siguiente
            </button>
          </div>
          <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
            <div>
              <p className="text-sm text-gray-600 dark:text-dark-300">
                Página <span className="font-medium text-gray-900 dark:text-white">{currentPage}</span> de{' '}
                <span className="font-medium text-gray-900 dark:text-white">
                  {searchTerm ? localTotalPages : totalPages}
                </span>
                {!searchTerm && totalRecords > 0 && (
                  <span className="text-gray-500 dark:text-dark-400 ml-2">
                    ({totalRecords} registros totales)
                  </span>
                )}
              </p>
            </div>
            <div>
              <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                <button
                  onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                  disabled={currentPage === 1}
                  className="relative inline-flex items-center px-2 py-2 rounded-l-lg border border-gray-300 dark:border-dark-600 bg-white dark:bg-dark-700 text-sm font-medium text-gray-700 dark:text-dark-300 hover:bg-gray-50 dark:hover:bg-dark-600 hover:text-gray-900 dark:hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
                >
                  <ChevronLeft className="h-5 w-5" />
                </button>
                
                                  {/* Números de página */}
                {Array.from({ length: Math.min(5, searchTerm ? localTotalPages : totalPages) }, (_, i) => {
                  const maxPages = searchTerm ? localTotalPages : totalPages;
                  let pageNum: number;
                  if (maxPages <= 5) {
                    pageNum = i + 1;
                  } else if (currentPage <= 3) {
                    pageNum = i + 1;
                  } else if (currentPage >= maxPages - 2) {
                    pageNum = maxPages - 4 + i;
                  } else {
                    pageNum = currentPage - 2 + i;
                  }
                  
                  return (
                    <button
                      key={pageNum}
                      onClick={() => setCurrentPage(pageNum)}
                      className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium transition-all duration-200 ${
                        currentPage === pageNum
                          ? 'z-10 bg-primary-600 border-primary-500 text-white shadow-lg'
                          : 'bg-white dark:bg-dark-700 border-gray-300 dark:border-dark-600 text-gray-700 dark:text-dark-300 hover:bg-gray-50 dark:hover:bg-dark-600 hover:text-gray-900 dark:hover:text-white'
                      }`}
                    >
                      {pageNum}
                    </button>
                  );
                })}
                
                <button
                  onClick={() => {
                    const maxPages = searchTerm ? localTotalPages : totalPages;
                    setCurrentPage(prev => Math.min(prev + 1, maxPages));
                  }}
                  disabled={currentPage >= (searchTerm ? localTotalPages : totalPages)}
                  className="relative inline-flex items-center px-2 py-2 rounded-r-lg border border-gray-300 dark:border-dark-600 bg-white dark:bg-dark-700 text-sm font-medium text-gray-700 dark:text-dark-300 hover:bg-gray-50 dark:hover:bg-dark-600 hover:text-gray-900 dark:hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
                >
                  <ChevronRight className="h-5 w-5" />
                </button>
              </nav>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default HistoryTable;
