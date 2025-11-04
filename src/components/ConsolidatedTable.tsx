'use client';

import React, { useState, useEffect, useRef } from 'react';
import { apiService } from '../services/api';
import { formatDate, exportToCSV } from '../utils/helpers';
import { Download, RefreshCw, ChevronLeft, ChevronRight, Eye } from 'lucide-react';
import { useFieldData } from '../hooks/useFieldData';
import { DetalleNavigation } from '../types';

interface ConsolidatedTableProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
  onNavigateToDetalle?: (navigation: DetalleNavigation) => void;
}

interface ConsolidatedRow {
  fundo: string;
  sector: string;
  lote: string;
  variedad: string | null;
  estadoFenologico: string | null;
  diasCianamida: number | null;
  fechaUltimaEvaluacion: string | null;
  porcentajeLuzMin: number | null;
  porcentajeLuzMax: number | null;
  porcentajeLuzProm: number | null;
  porcentajeSombraMin: number | null;
  porcentajeSombraMax: number | null;
  porcentajeSombraProm: number | null;
}

const ConsolidatedTable: React.FC<ConsolidatedTableProps> = ({ onNotification, onNavigateToDetalle }) => {
  const [data, setData] = useState<ConsolidatedRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filterFundo, setFilterFundo] = useState('');
  const [filterSector, setFilterSector] = useState('');
  const [filterLote, setFilterLote] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 20;
  const [totalRecords, setTotalRecords] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const isInitialMount = useRef(true);
  const prevFilters = useRef({ filterFundo, filterSector, filterLote });
  const pageChangeFromFilter = useRef(false);

  const { fieldData, loading: fieldLoading } = useFieldData();

  const loadData = async (page: number = currentPage) => {
    try {
      setLoading(true);
      setError(null);
      console.log(`📊 Loading consolidated table page ${page}...`);
      
      const params: { page: number; pageSize: number; fundo?: string; sector?: string; lote?: string } = {
        page,
        pageSize: itemsPerPage
      };
      
      if (filterFundo) params.fundo = filterFundo;
      if (filterSector) params.sector = filterSector;
      if (filterLote) params.lote = filterLote;
      
      const response = await fetch(`/api/tabla-consolidada?${new URLSearchParams(Object.fromEntries(Object.entries(params).map(([k, v]) => [k, String(v)]))).toString()}`);
      const result = await response.json();
      
      if (result.success && result.data) {
        setData(result.data);
        setTotalRecords(result.total || 0);
        setTotalPages(result.totalPages || 0);
        console.log(`📊 Consolidated table loaded: page ${page}/${result.totalPages || 0} (${result.data.length} records, total: ${result.total || 0})`);
      } else {
        setError('No se pudieron cargar los datos de la tabla consolidada');
      }
    } catch (err) {
      console.error('❌ Error loading consolidated table:', err);
      setError(err instanceof Error ? err.message : 'Error cargando tabla consolidada');
    } finally {
      setLoading(false);
    }
  };

  // Efecto para manejar cambios en filtros
  useEffect(() => {
    const filtersChanged = 
      prevFilters.current.filterFundo !== filterFundo ||
      prevFilters.current.filterSector !== filterSector ||
      prevFilters.current.filterLote !== filterLote;

    if (filtersChanged && !isInitialMount.current) {
      prevFilters.current = { filterFundo, filterSector, filterLote };
      pageChangeFromFilter.current = true;
      setCurrentPage(1);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filterFundo, filterSector, filterLote]);

  // Efecto principal para cargar datos
  useEffect(() => {
    if (isInitialMount.current) {
      isInitialMount.current = false;
      prevFilters.current = { filterFundo, filterSector, filterLote };
      loadData(1);
    } else if (pageChangeFromFilter.current) {
      pageChangeFromFilter.current = false;
      loadData(1);
    } else {
      loadData(currentPage);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPage, filterFundo, filterSector, filterLote]);

  const handleExportCSV = () => {
    if (data.length === 0) {
      onNotification('No hay datos para exportar', 'warning');
      return;
    }

    try {
      const csvData = data.map(row => ({
        Fundo: row.fundo,
        Sector: row.sector,
        Lote: row.lote,
        Variedad: row.variedad || '',
        'Estado Fenológico': row.estadoFenologico || '',
        'Días Cianamida': row.diasCianamida || '',
        'Fecha Última Evaluación': row.fechaUltimaEvaluacion || '',
        '% Luz Mín': row.porcentajeLuzMin?.toFixed(2) || '',
        '% Luz Máx': row.porcentajeLuzMax?.toFixed(2) || '',
        '% Luz Prom': row.porcentajeLuzProm?.toFixed(2) || '',
        '% Sombra Mín': row.porcentajeSombraMin?.toFixed(2) || '',
        '% Sombra Máx': row.porcentajeSombraMax?.toFixed(2) || '',
        '% Sombra Prom': row.porcentajeSombraProm?.toFixed(2) || '',
      }));
      
      exportToCSV(csvData, 'tabla_consolidada.csv');
      onNotification('Datos exportados exitosamente', 'success');
    } catch (err) {
      console.error('Error exporting CSV:', err);
      onNotification('Error al exportar datos', 'error');
    }
  };

  // Obtener listas únicas para filtros desde fieldData
  // hierarchical es un objeto Record<empresa, Record<fundo, Record<sector, string[]>>>
  const uniqueFundos = fieldData?.fundo ? [...new Set(fieldData.fundo)].sort() : [];
  
  // Para sectores y lotes, necesitamos navegar por el objeto hierarchical
  const uniqueSectores = fieldData && filterFundo && fieldData.hierarchical
    ? [...new Set(
        Object.values(fieldData.hierarchical)
          .flatMap(emp => Object.entries(emp)
            .filter(([fundoName]) => fundoName === filterFundo)
            .flatMap(([, fundo]) => Object.keys(fundo))
          )
      )].sort()
    : [];
    
  const uniqueLotes = fieldData && filterFundo && filterSector && fieldData.hierarchical
    ? [...new Set(
        Object.values(fieldData.hierarchical)
          .flatMap(emp => Object.entries(emp)
            .filter(([fundoName]) => fundoName === filterFundo)
            .flatMap(([, fundo]) => Object.entries(fundo)
              .filter(([sectorName]) => sectorName === filterSector)
              .flatMap(([, lotes]) => lotes)
            )
          )
      )].sort()
    : [];

  if (loading && isInitialMount.current) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <RefreshCw className="h-8 w-8 animate-spin mx-auto mb-4 text-blue-500" />
          <p className="text-gray-600 dark:text-dark-300">Cargando tabla consolidada...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Filtros */}
      <div className="bg-white dark:bg-dark-800 p-6 rounded-xl shadow-lg border border-gray-200 dark:border-dark-700">
        <h2 className="text-xl font-semibold mb-4 text-gray-900 dark:text-white">Filtros</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Fundo
            </label>
            <select
              value={filterFundo}
              onChange={(e) => {
                setFilterFundo(e.target.value);
                setFilterSector(''); // Reset sector cuando cambia fundo
                setFilterLote(''); // Reset lote cuando cambia fundo
              }}
              className="w-full px-4 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Todos los fundos</option>
              {uniqueFundos.map(fundo => (
                <option key={fundo} value={fundo}>{fundo}</option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Sector
            </label>
            <select
              value={filterSector}
              onChange={(e) => {
                setFilterSector(e.target.value);
                setFilterLote(''); // Reset lote cuando cambia sector
              }}
              disabled={!filterFundo}
              className="w-full px-4 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <option value="">Todos los sectores</option>
              {uniqueSectores.map(sector => (
                <option key={sector} value={sector}>{sector}</option>
              ))}
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Lote
            </label>
            <select
              value={filterLote}
              onChange={(e) => setFilterLote(e.target.value)}
              disabled={!filterSector}
              className="w-full px-4 py-2 border border-gray-300 dark:border-dark-600 rounded-lg bg-white dark:bg-dark-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <option value="">Todos los lotes</option>
              {uniqueLotes.map(lote => (
                <option key={lote} value={lote}>{lote}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Acciones */}
      <div className="flex justify-between items-center">
        <div className="text-sm text-gray-600 dark:text-dark-300">
          {loading ? 'Cargando...' : `Mostrando ${data.length} de ${totalRecords} registros`}
        </div>
        <div className="flex gap-2">
          <button
            onClick={handleExportCSV}
            disabled={data.length === 0 || loading}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <Download className="h-4 w-4" />
            Exportar CSV
          </button>
          <button
            onClick={() => loadData(currentPage)}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            Actualizar
          </button>
        </div>
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
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Fundo</th>
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Sector</th>
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Lote</th>
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Variedad</th>
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Estado Fenológico</th>
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Días Cianamida</th>
                <th rowSpan={2} className="px-2 py-2 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">Fecha Última Evaluación</th>
                <th colSpan={3} className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">% Luz</th>
                <th colSpan={3} className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">% Sombra</th>
                <th rowSpan={2} className="px-2 py-2 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">Ver Detalle</th>
              </tr>
              <tr>
                <th className="px-1 py-1 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">Min</th>
                <th className="px-1 py-1 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">Prom</th>
                <th className="px-1 py-1 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">Max</th>
                <th className="px-1 py-1 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">Min</th>
                <th className="px-1 py-1 text-center text-xs font-medium text-gray-500 dark:text-dark-300 border-r border-gray-300 dark:border-dark-600">Prom</th>
                <th className="px-1 py-1 text-center text-xs font-medium text-gray-500 dark:text-dark-300">Max</th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-dark-800 divide-y divide-gray-200 dark:divide-dark-700">
              {loading ? (
                <tr>
                  <td colSpan={14} className="px-6 py-8 text-center">
                    <RefreshCw className="h-6 w-6 animate-spin mx-auto mb-2 text-blue-500" />
                    <p className="text-gray-600 dark:text-dark-300">Cargando datos...</p>
                  </td>
                </tr>
              ) : data.length === 0 ? (
                <tr>
                  <td colSpan={14} className="px-6 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay datos disponibles
                  </td>
                </tr>
              ) : (
                                data.map((row, index) => (
                  <tr key={index} className="hover:bg-gray-50 dark:hover:bg-dark-700 transition-colors">
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white">{row.fundo}</td>
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white">{row.sector}</td>
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white">{row.lote}</td>
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white">{row.variedad || '-'}</td>
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white">{row.estadoFenologico || '-'}</td>
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">{row.diasCianamida !== null ? row.diasCianamida : '-'}</td>
                    <td className="px-2 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white">
                      {row.fechaUltimaEvaluacion ? formatDate(row.fechaUltimaEvaluacion) : '-'}
                    </td>
                    <td className="px-1 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.porcentajeLuzMin !== null ? row.porcentajeLuzMin.toFixed(2) : '-'}
                    </td>
                    <td className="px-1 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.porcentajeLuzProm !== null ? row.porcentajeLuzProm.toFixed(2) : '-'}
                    </td>
                    <td className="px-1 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.porcentajeLuzMax !== null ? row.porcentajeLuzMax.toFixed(2) : '-'}
                    </td>
                    <td className="px-1 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.porcentajeSombraMin !== null ? row.porcentajeSombraMin.toFixed(2) : '-'}
                    </td>
                    <td className="px-1 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.porcentajeSombraProm !== null ? row.porcentajeSombraProm.toFixed(2) : '-'}
                    </td>
                    <td className="px-1 py-2 whitespace-nowrap text-xs text-gray-900 dark:text-white text-center">
                      {row.porcentajeSombraMax !== null ? row.porcentajeSombraMax.toFixed(2) : '-'}
                    </td>
                    <td className="px-2 py-2 whitespace-nowrap text-center">
                      <button
                        onClick={() => {
                          if (onNavigateToDetalle) {
                            onNavigateToDetalle({ fundo: row.fundo, sector: row.sector, lote: row.lote });
                          }
                        }}
                        className="inline-flex items-center justify-center p-2 text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors"
                        title="Ver detalle histórico"
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

      {/* Paginación */}
      {totalPages > 1 && (
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
              onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
              disabled={currentPage >= totalPages}
              className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 dark:border-dark-600 text-sm font-medium rounded-lg text-gray-700 dark:text-dark-200 bg-white dark:bg-dark-700 hover:bg-gray-50 dark:hover:bg-dark-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              Siguiente
            </button>
          </div>
          <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
            <div>
              <p className="text-sm text-gray-600 dark:text-dark-300">
                Página <span className="font-medium text-gray-900 dark:text-white">{currentPage}</span> de{' '}
                <span className="font-medium text-gray-900 dark:text-white">{totalPages}</span>
                {totalRecords > 0 && (
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
                {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                  let pageNum: number;
                  if (totalPages <= 5) {
                    pageNum = i + 1;
                  } else if (currentPage <= 3) {
                    pageNum = i + 1;
                  } else if (currentPage >= totalPages - 2) {
                    pageNum = totalPages - 4 + i;
                  } else {
                    pageNum = currentPage - 2 + i;
                  }
                  
                  return (
                    <button
                      key={pageNum}
                      onClick={() => setCurrentPage(pageNum)}
                      className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium transition-all duration-200 ${
                        currentPage === pageNum
                          ? 'z-10 bg-blue-50 dark:bg-blue-900/30 border-blue-500 text-blue-600 dark:text-blue-400'
                          : 'bg-white dark:bg-dark-700 border-gray-300 dark:border-dark-600 text-gray-700 dark:text-dark-300 hover:bg-gray-50 dark:hover:bg-dark-600'
                      }`}
                    >
                      {pageNum}
                    </button>
                  );
                })}
                
                <button
                  onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                  disabled={currentPage >= totalPages}
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

export default ConsolidatedTable;

