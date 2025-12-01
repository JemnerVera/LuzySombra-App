import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { Plus, Edit, Trash2, RefreshCw, Save, X, Gauge } from 'lucide-react';

interface Umbral {
  umbralID: number;
  variedadID: number | null;
  variedadNombre?: string | null;
  tipo: 'CriticoRojo' | 'CriticoAmarillo' | 'Normal';
  minPorcentajeLuz: number;
  maxPorcentajeLuz: number;
  descripcion: string | null;
  colorHex: string | null;
  orden: number;
  activo: boolean;
  fechaCreacion: string;
  fechaModificacion: string | null;
}

interface Variedad {
  varietyID: number;
  name: string;
}

interface UmbralesManagementProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

const UmbralesManagement: React.FC<UmbralesManagementProps> = ({ onNotification }) => {
  const [umbrales, setUmbrales] = useState<Umbral[]>([]);
  const [variedades, setVariedades] = useState<Variedad[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState<Partial<Umbral>>({
    tipo: 'CriticoRojo',
    minPorcentajeLuz: 0,
    maxPorcentajeLuz: 10,
    descripcion: '',
    colorHex: '#FF0000',
    orden: 0,
    activo: true,
    variedadID: null
  });

  const loadUmbrales = async () => {
    try {
      setLoading(true);
      const response = await apiService.getUmbrales();
      if (response.success && response.data) {
        setUmbrales(response.data);
      }
    } catch (error) {
      console.error('Error cargando umbrales:', error);
      onNotification('Error cargando umbrales', 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadVariedades = async () => {
    try {
      const response = await apiService.getVariedades();
      if (response.success && response.data) {
        setVariedades(response.data);
      }
    } catch (error) {
      console.error('Error cargando variedades:', error);
    }
  };

  useEffect(() => {
    loadUmbrales();
    loadVariedades();
  }, []);

  const handleCreate = async () => {
    try {
      if (!formData.tipo || formData.minPorcentajeLuz === undefined || formData.maxPorcentajeLuz === undefined) {
        onNotification('Por favor completa todos los campos requeridos', 'warning');
        return;
      }

      const response = await apiService.createUmbral({
        ...formData,
        usuarioCreaID: 1 // TODO: Obtener del contexto de usuario
      });

      if (response.success) {
        onNotification('Umbral creado exitosamente', 'success');
        setShowForm(false);
        resetForm();
        loadUmbrales();
      }
    } catch (error) {
      console.error('Error creando umbral:', error);
      onNotification('Error creando umbral', 'error');
    }
  };

  const handleUpdate = async (id: number) => {
    try {
      if (!formData.tipo || formData.minPorcentajeLuz === undefined || formData.maxPorcentajeLuz === undefined) {
        onNotification('Por favor completa todos los campos requeridos', 'warning');
        return;
      }

      const response = await apiService.updateUmbral(id, {
        ...formData,
        usuarioModificaID: 1 // TODO: Obtener del contexto de usuario
      });

      if (response.success) {
        onNotification('Umbral actualizado exitosamente', 'success');
        setEditingId(null);
        resetForm();
        loadUmbrales();
      }
    } catch (error) {
      console.error('Error actualizando umbral:', error);
      onNotification('Error actualizando umbral', 'error');
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('¿Estás seguro de que deseas eliminar este umbral?')) {
      return;
    }

    try {
      const response = await apiService.deleteUmbral(id);
      if (response.success) {
        onNotification('Umbral eliminado exitosamente', 'success');
        loadUmbrales();
      }
    } catch (error) {
      console.error('Error eliminando umbral:', error);
      onNotification('Error eliminando umbral', 'error');
    }
  };

  const handleEdit = (umbral: Umbral) => {
    setEditingId(umbral.umbralID);
    setFormData({
      tipo: umbral.tipo,
      minPorcentajeLuz: umbral.minPorcentajeLuz,
      maxPorcentajeLuz: umbral.maxPorcentajeLuz,
      descripcion: umbral.descripcion || '',
      colorHex: umbral.colorHex || '#FF0000',
      orden: umbral.orden,
      activo: umbral.activo,
      variedadID: umbral.variedadID
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setFormData({
      tipo: 'CriticoRojo',
      minPorcentajeLuz: 0,
      maxPorcentajeLuz: 10,
      descripcion: '',
      colorHex: '#FF0000',
      orden: 0,
      activo: true,
      variedadID: null
    });
    setEditingId(null);
  };

  const getTipoColor = (tipo: string) => {
    switch (tipo) {
      case 'CriticoRojo':
        return 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300';
      case 'CriticoAmarillo':
        return 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300';
      case 'Normal':
        return 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300';
      default:
        return 'bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300';
    }
  };

  const getTipoLabel = (tipo: string) => {
    switch (tipo) {
      case 'CriticoRojo':
        return '🚨 Crítico Rojo';
      case 'CriticoAmarillo':
        return '⚠️ Crítico Amarillo';
      case 'Normal':
        return '✅ Normal';
      default:
        return tipo;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <RefreshCw className="h-8 w-8 animate-spin text-primary-600" />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
            <Gauge className="h-6 w-6" />
            Gestión de Umbrales
          </h2>
          <p className="text-gray-600 dark:text-dark-400 mt-1">
            Configura los umbrales de porcentaje de luz para generar alertas automáticas
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => {
              resetForm();
              setShowForm(true);
            }}
            className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <Plus className="h-4 w-4" />
            Nuevo Umbral
          </button>
          <button
            onClick={loadUmbrales}
            className="flex items-center gap-2 px-4 py-2 bg-gray-200 dark:bg-dark-800 text-gray-700 dark:text-dark-300 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-700 transition-colors"
          >
            <RefreshCw className="h-4 w-4" />
            Actualizar
          </button>
        </div>
      </div>

      {/* Formulario */}
      {showForm && (
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              {editingId ? 'Editar Umbral' : 'Nuevo Umbral'}
            </h3>
            <button
              onClick={() => {
                setShowForm(false);
                resetForm();
              }}
              className="text-gray-500 hover:text-gray-700 dark:text-dark-400 dark:hover:text-dark-300"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Tipo de Umbral *
              </label>
              <select
                value={formData.tipo || 'CriticoRojo'}
                onChange={(e) => setFormData({ ...formData, tipo: e.target.value as any })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              >
                <option value="CriticoRojo">🚨 Crítico Rojo</option>
                <option value="CriticoAmarillo">⚠️ Crítico Amarillo</option>
                <option value="Normal">✅ Normal</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Variedad
              </label>
              <select
                value={formData.variedadID || ''}
                onChange={(e) => setFormData({ ...formData, variedadID: e.target.value ? parseInt(e.target.value) : null })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              >
                <option value="">Todas las variedades (Global)</option>
                {variedades.map((v) => (
                  <option key={v.varietyID} value={v.varietyID}>
                    {v.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Porcentaje Mínimo de Luz * (0-100)
              </label>
              <input
                type="number"
                min="0"
                max="100"
                step="0.01"
                value={formData.minPorcentajeLuz || 0}
                onChange={(e) => setFormData({ ...formData, minPorcentajeLuz: parseFloat(e.target.value) || 0 })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Porcentaje Máximo de Luz * (0-100)
              </label>
              <input
                type="number"
                min="0"
                max="100"
                step="0.01"
                value={formData.maxPorcentajeLuz || 0}
                onChange={(e) => setFormData({ ...formData, maxPorcentajeLuz: parseFloat(e.target.value) || 0 })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Descripción
              </label>
              <input
                type="text"
                value={formData.descripcion || ''}
                onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="Ej: Muy bajo - Crítico"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Color (Hex)
              </label>
              <div className="flex gap-2">
                <input
                  type="color"
                  value={formData.colorHex || '#FF0000'}
                  onChange={(e) => setFormData({ ...formData, colorHex: e.target.value })}
                  className="h-10 w-20 border border-gray-300 dark:border-dark-700 rounded-lg cursor-pointer"
                />
                <input
                  type="text"
                  value={formData.colorHex || '#FF0000'}
                  onChange={(e) => setFormData({ ...formData, colorHex: e.target.value })}
                  className="flex-1 px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                  placeholder="#FF0000"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Orden
              </label>
              <input
                type="number"
                value={formData.orden || 0}
                onChange={(e) => setFormData({ ...formData, orden: parseInt(e.target.value) || 0 })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              />
            </div>

            <div className="flex items-center">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.activo !== false}
                  onChange={(e) => setFormData({ ...formData, activo: e.target.checked })}
                  className="w-4 h-4 text-primary-600 rounded"
                />
                <span className="text-sm font-medium text-gray-700 dark:text-dark-300">
                  Activo
                </span>
              </label>
            </div>
          </div>

          <div className="flex justify-end gap-2 mt-6">
            <button
              onClick={() => {
                setShowForm(false);
                resetForm();
              }}
              className="px-4 py-2 text-gray-700 dark:text-dark-300 bg-gray-200 dark:bg-dark-800 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-700 transition-colors"
            >
              Cancelar
            </button>
            <button
              onClick={() => editingId ? handleUpdate(editingId) : handleCreate()}
              className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
            >
              <Save className="h-4 w-4" />
              {editingId ? 'Actualizar' : 'Crear'}
            </button>
          </div>
        </div>
      )}

      {/* Tabla de Umbrales */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-dark-800">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Variedad
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Rango (% Luz)
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Descripción
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Color
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Orden
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
              {umbrales.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay umbrales configurados. Crea uno nuevo para comenzar.
                  </td>
                </tr>
              ) : (
                umbrales.map((umbral) => (
                  <tr key={umbral.umbralID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getTipoColor(umbral.tipo)}`}>
                        {getTipoLabel(umbral.tipo)}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {umbral.variedadNombre || 'Todas (Global)'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {umbral.minPorcentajeLuz.toFixed(2)}% - {umbral.maxPorcentajeLuz.toFixed(2)}%
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {umbral.descripcion || '-'}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div
                          className="w-6 h-6 rounded border border-gray-300 dark:border-dark-700"
                          style={{ backgroundColor: umbral.colorHex || '#FF0000' }}
                        />
                        <span className="text-xs text-gray-600 dark:text-dark-400">
                          {umbral.colorHex || '#FF0000'}
                        </span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {umbral.orden}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${
                        umbral.activo
                          ? 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300'
                          : 'bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300'
                      }`}>
                        {umbral.activo ? 'Activo' : 'Inactivo'}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleEdit(umbral)}
                          className="p-2 text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/30 rounded transition-colors"
                          title="Editar"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(umbral.umbralID)}
                          className="p-2 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/30 rounded transition-colors"
                          title="Eliminar"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
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

export default UmbralesManagement;

