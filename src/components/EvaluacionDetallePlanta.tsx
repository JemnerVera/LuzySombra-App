'use client';

import React, { useState, useEffect } from 'react';
import { RefreshCw, ArrowLeft, Image as ImageIcon, X } from 'lucide-react';
import { DetalleNavigation } from '../types';

interface EvaluacionDetallePlantaProps {
  navigation: DetalleNavigation;
  onBack: () => void;
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

interface PlantaRow {
  analisisID: number;
  hilera: string;
  planta: string;
  porcentajeLuz: number;
  porcentajeSombra: number;
  filename: string;
  fechaCaptura: string | null;
  processedImageUrl: string | null;
}

const EvaluacionDetallePlanta: React.FC<EvaluacionDetallePlantaProps> = ({ 
  navigation, 
  onBack,
  onNotification 
}) => {
  const [data, setData] = useState<PlantaRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedImage, setSelectedImage] = useState<{ url: string; filename: string } | null>(null);

  useEffect(() => {
    if (navigation.fecha) {
      loadData();
    }
  }, [navigation]);

  const loadData = async () => {
    if (!navigation.fecha) return;

    try {
      setLoading(true);
      setError(null);
      
      const params = new URLSearchParams({
        fundo: navigation.fundo,
        sector: navigation.sector,
        lote: navigation.lote,
        fecha: navigation.fecha
      });
      
      const response = await fetch(`/api/tabla-consolidada/detalle-planta?${params.toString()}`);
      const result = await response.json();
      
      if (result.success && result.data) {
        setData(result.data);
      } else {
        setError(result.error || 'No se pudieron cargar los datos de las plantas');
      }
    } catch (err) {
      console.error('Error loading detalle planta:', err);
      setError(err instanceof Error ? err.message : 'Error cargando detalle de plantas');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-PE', { day: '2-digit', month: '2-digit', year: 'numeric' });
  };

  const handleImageClick = (row: PlantaRow) => {
    if (row.processedImageUrl) {
      setSelectedImage({
        url: row.processedImageUrl,
        filename: row.filename
      });
    } else {
      onNotification('No hay imagen disponible para esta evaluación', 'warning');
    }
  };

  return (
    <>
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
                Detalle por Evaluación
              </h2>
              <p className="text-sm text-gray-600 dark:text-dark-300 mt-1">
                {navigation.fundo} - {navigation.sector} - {navigation.lote} - {navigation.fecha ? formatDate(navigation.fecha) : ''}
              </p>
            </div>
          </div>
          <button
            onClick={loadData}
            disabled={loading || !navigation.fecha}
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
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                    Hilera
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                    Planta
                  </th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                    Luz
                  </th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider border-r border-gray-300 dark:border-dark-600">
                    Sombra
                  </th>
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 dark:text-dark-300 uppercase tracking-wider">
                    Foto
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white dark:bg-dark-800 divide-y divide-gray-200 dark:divide-dark-700">
                {loading ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-8 text-center">
                      <RefreshCw className="h-6 w-6 animate-spin mx-auto mb-2 text-blue-500" />
                      <p className="text-gray-600 dark:text-dark-300">Cargando datos...</p>
                    </td>
                  </tr>
                ) : data.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-6 py-8 text-center text-gray-500 dark:text-dark-400">
                      No hay datos disponibles para esta fecha
                    </td>
                  </tr>
                ) : (
                  data.map((row, index) => (
                    <tr key={index} className="hover:bg-gray-50 dark:hover:bg-dark-700 transition-colors">
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                        {row.hilera}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                        {row.planta}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-white text-center">
                        {row.porcentajeLuz.toFixed(2)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-white text-center">
                        {row.porcentajeSombra.toFixed(2)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-center">
                        <button
                          onClick={() => handleImageClick(row)}
                          disabled={!row.processedImageUrl}
                          className="inline-flex items-center justify-center px-3 py-2 text-sm font-medium text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                          title={row.processedImageUrl ? 'Ver imagen' : 'No hay imagen disponible'}
                        >
                          <ImageIcon className="h-5 w-5 mr-1" />
                          Ver
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

      {/* Modal de Imagen */}
      {selectedImage && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75 p-4">
          <div className="bg-white dark:bg-dark-800 rounded-xl shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col">
            {/* Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-dark-700">
              <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                Imagen: {selectedImage.filename}
              </h2>
              <button
                onClick={() => setSelectedImage(null)}
                className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Content */}
            <div className="flex-1 overflow-auto p-6 flex items-center justify-center">
              <img
                src={selectedImage.url}
                alt={selectedImage.filename}
                className="max-w-full max-h-[70vh] object-contain rounded-lg"
              />
            </div>

            {/* Footer */}
            <div className="flex items-center justify-end p-6 border-t border-gray-200 dark:border-dark-700">
              <button
                onClick={() => setSelectedImage(null)}
                className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                Cerrar
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default EvaluacionDetallePlanta;
