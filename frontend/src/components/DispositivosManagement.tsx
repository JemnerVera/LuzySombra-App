import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { Plus, Edit, Trash2, RefreshCw, Save, X, Smartphone, Key, Eye, EyeOff, AlertCircle, Copy, Download, Check } from 'lucide-react';

interface Dispositivo {
  dispositivoID: number;
  deviceId: string;
  apiKey: string | null; // Puede ser null si está oculta
  nombreDispositivo: string | null;
  modeloDispositivo: string | null;
  versionApp: string | null;
  activo: boolean;
  fechaRegistro: string;
  ultimoAcceso: string | null;
  statusID: number;
}

interface DispositivosManagementProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

const DispositivosManagement: React.FC<DispositivosManagementProps> = ({ onNotification }) => {
  const [dispositivos, setDispositivos] = useState<Dispositivo[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [showApiKey, setShowApiKey] = useState<number | null>(null);
  const [newApiKey, setNewApiKey] = useState<string | null>(null);
  const [qrCodeUrl, setQrCodeUrl] = useState<string | null>(null);
  const [apiKeyCopied, setApiKeyCopied] = useState(false);
  const [filterActivo, setFilterActivo] = useState<'all' | 'active' | 'inactive'>('all');
  const [formData, setFormData] = useState<Partial<Dispositivo>>({
    nombreDispositivo: '',
    modeloDispositivo: '',
    versionApp: '',
    activo: true
  });

  const loadDispositivos = async () => {
    try {
      setLoading(true);
      const response = await apiService.getDispositivos();
      if (response.success && response.dispositivos) {
        setDispositivos(response.dispositivos);
      }
    } catch (error) {
      console.error('Error cargando dispositivos:', error);
      onNotification('Error cargando dispositivos', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDispositivos();
  }, []);

  // Debug: Log cuando cambian newApiKey o qrCodeUrl
  useEffect(() => {
    if (newApiKey) {
      console.log('🔍 Modal activado. newApiKey:', newApiKey.substring(0, 20) + '...', 'qrCodeUrl:', qrCodeUrl ? 'Presente' : 'Ausente');
    }
  }, [newApiKey, qrCodeUrl]);

  const resetForm = (clearApiKey = false) => {
    setFormData({
      nombreDispositivo: '',
      modeloDispositivo: '',
      versionApp: '',
      activo: true
    });
    setEditingId(null);
    setShowForm(false);
    if (clearApiKey) {
      setNewApiKey(null);
      setQrCodeUrl(null);
      setApiKeyCopied(false);
    }
  };

  const handleCopyApiKey = async () => {
    if (newApiKey) {
      try {
        await navigator.clipboard.writeText(newApiKey);
        setApiKeyCopied(true);
        setTimeout(() => setApiKeyCopied(false), 2000);
        onNotification('API Key copiada al portapapeles', 'success');
      } catch (error) {
        console.error('Error copiando API key:', error);
        onNotification('Error al copiar API key', 'error');
      }
    }
  };

  const handleDownloadQR = () => {
    if (qrCodeUrl) {
      const link = document.createElement('a');
      link.href = qrCodeUrl;
      link.download = `qr-api-key-${Date.now()}.png`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      onNotification('QR Code descargado', 'success');
    }
  };

  const handleCreate = async () => {
    try {
      if (!formData.nombreDispositivo) {
        onNotification('Por favor completa el nombre del dispositivo', 'warning');
        return;
      }

      const response = await apiService.createDispositivo({
        nombreDispositivo: formData.nombreDispositivo,
        modeloDispositivo: formData.modeloDispositivo || undefined,
        versionApp: formData.versionApp || undefined
      });

      if (response.success) {
        console.log('✅ Dispositivo creado - Respuesta completa:', response);
        console.log('📱 API Key recibida:', response.apiKey ? 'Sí' : 'No');
        console.log('📱 QR Code URL recibida:', response.qrCodeUrl ? 'Sí (' + response.qrCodeUrl.substring(0, 50) + '...)' : 'No');
        onNotification('Dispositivo creado exitosamente', 'success');
        // Establecer API key y QR antes de resetear el formulario
        setNewApiKey(response.apiKey || null);
        setQrCodeUrl(response.qrCodeUrl || null);
        setApiKeyCopied(false);
        // Resetear solo el formulario, NO la API key (para que el modal se muestre)
        resetForm(false);
        loadDispositivos();
      }
    } catch (error: any) {
      console.error('Error creando dispositivo:', error);
      onNotification(error.response?.data?.error || 'Error creando dispositivo', 'error');
    }
  };

  const handleUpdate = async (id: number) => {
    try {
      if (!formData.nombreDispositivo) {
        onNotification('Por favor completa el nombre del dispositivo', 'warning');
        return;
      }

      const response = await apiService.updateDispositivo(id, {
        nombreDispositivo: formData.nombreDispositivo,
        modeloDispositivo: formData.modeloDispositivo || undefined,
        versionApp: formData.versionApp || undefined,
        activo: formData.activo
      });

      if (response.success) {
        onNotification('Dispositivo actualizado exitosamente', 'success');
        resetForm();
        loadDispositivos();
      }
    } catch (error: any) {
      console.error('Error actualizando dispositivo:', error);
      onNotification(error.response?.data?.error || 'Error actualizando dispositivo', 'error');
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('¿Estás seguro de que deseas eliminar este dispositivo?')) {
      return;
    }

    try {
      const response = await apiService.deleteDispositivo(id);
      if (response.success) {
        onNotification('Dispositivo eliminado exitosamente', 'success');
        loadDispositivos();
      }
    } catch (error: any) {
      console.error('Error eliminando dispositivo:', error);
      onNotification(error.response?.data?.error || 'Error eliminando dispositivo', 'error');
    }
  };

  const handleRegenerateKey = async (id: number) => {
    if (!window.confirm('¿Estás seguro? La API key actual dejará de funcionar. El dispositivo deberá usar la nueva key.')) {
      return;
    }

    try {
      const response = await apiService.regenerateApiKey(id);
      if (response.success && response.apiKey) {
        console.log('✅ API Key regenerada:', response);
        console.log('📱 QR Code URL recibido:', response.qrCodeUrl ? 'Sí' : 'No');
        onNotification('API Key regenerada exitosamente', 'success');
        setNewApiKey(response.apiKey);
        setQrCodeUrl(response.qrCodeUrl || null);
        setApiKeyCopied(false);
        loadDispositivos();
      }
    } catch (error: any) {
      console.error('Error regenerando API key:', error);
      onNotification(error.response?.data?.error || 'Error regenerando API key', 'error');
    }
  };

  const handleEdit = (dispositivo: Dispositivo) => {
    setFormData({
      nombreDispositivo: dispositivo.nombreDispositivo || '',
      modeloDispositivo: dispositivo.modeloDispositivo || '',
      versionApp: dispositivo.versionApp || '',
      activo: dispositivo.activo
    });
    setEditingId(dispositivo.dispositivoID);
    setShowForm(true);
  };

  const filteredDispositivos = dispositivos.filter(d => {
    if (filterActivo === 'active') return d.activo;
    if (filterActivo === 'inactive') return !d.activo;
    return true;
  });

  const formatDate = (dateString: string | null) => {
    if (!dateString) return 'Nunca';
    const date = new Date(dateString);
    return date.toLocaleString('es-ES');
  };

  const getDaysSinceLastAccess = (dateString: string | null) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    const days = Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24));
    return days;
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
            <Smartphone className="h-6 w-6" />
            Gestión de Dispositivos
          </h2>
          <p className="text-gray-600 dark:text-dark-400 mt-1">
            Gestiona los dispositivos Android (AgriQR) autorizados
          </p>
        </div>
        <button
          onClick={() => {
            resetForm();
            setShowForm(true);
          }}
          className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
        >
          <Plus className="h-5 w-5" />
          Nuevo Dispositivo
        </button>
      </div>

      {/* Modal de nueva API Key con QR */}
      {newApiKey && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white dark:bg-dark-900 rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-900 dark:text-white">
                  Nueva API Key generada
                </h3>
                <button
                  onClick={() => {
                    setNewApiKey(null);
                    setQrCodeUrl(null);
                    setApiKeyCopied(false);
                    resetForm(true); // Limpiar también el formulario al cerrar
                  }}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              <div className="space-y-6">
                {/* QR Code */}
                {qrCodeUrl ? (
                  <div className="flex flex-col items-center p-6 bg-gray-50 dark:bg-dark-800 rounded-lg border border-gray-200 dark:border-dark-700">
                    <p className="text-sm font-medium text-gray-700 dark:text-dark-300 mb-4">
                      Escanea este código QR con la app AgriQR:
                    </p>
                    <div className="relative">
                      <img 
                        src={qrCodeUrl} 
                        alt="QR Code para activación" 
                        className="w-64 h-64 border-4 border-white dark:border-dark-700 rounded-lg shadow-lg"
                      />
                    </div>
                    <div className="mt-4 flex gap-2">
                      <button
                        onClick={handleDownloadQR}
                        className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                      >
                        <Download className="h-4 w-4" />
                        Descargar QR
                      </button>
                    </div>
                    <p className="text-xs text-gray-500 dark:text-dark-400 mt-3 text-center max-w-md">
                      El QR contiene la API key y código de activación. Válido por 24 horas.
                    </p>
                  </div>
                ) : (
                  <div className="p-4 bg-yellow-50 dark:bg-yellow-900/30 border border-yellow-200 dark:border-yellow-800 rounded-lg">
                    <p className="text-sm text-yellow-700 dark:text-yellow-400">
                      ⚠️ No se pudo generar el QR code. Usa la API key manualmente.
                    </p>
                  </div>
                )}

                {/* API Key en texto */}
                <div className="p-4 bg-yellow-50 dark:bg-yellow-900/30 border border-yellow-200 dark:border-yellow-800 rounded-lg">
                  <div className="flex items-center justify-between mb-2">
                    <p className="text-sm font-medium text-yellow-800 dark:text-yellow-300">
                      API Key
                    </p>
                    <button
                      onClick={handleCopyApiKey}
                      className="flex items-center gap-2 px-3 py-1.5 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors text-sm"
                    >
                      {apiKeyCopied ? (
                        <>
                          <Check className="h-4 w-4" />
                          Copiado
                        </>
                      ) : (
                        <>
                          <Copy className="h-4 w-4" />
                          Copiar
                        </>
                      )}
                    </button>
                  </div>
                  <div className="bg-white dark:bg-dark-900 p-3 rounded border border-yellow-200 dark:border-yellow-800">
                    <p className="text-sm text-gray-900 dark:text-white font-mono break-all select-all">
                      {newApiKey}
                    </p>
                  </div>
                  <p className="text-xs text-yellow-600 dark:text-yellow-500 mt-3">
                    ⚠️ Guarda esta key. No se mostrará nuevamente. El dispositivo deberá usar esta key para autenticarse.
                  </p>
                </div>

                <div className="flex justify-end pt-4 border-t border-gray-200 dark:border-dark-700">
                  <button
                    onClick={() => {
                      setNewApiKey(null);
                      setQrCodeUrl(null);
                      setApiKeyCopied(false);
                      resetForm(true); // Limpiar también el formulario al cerrar
                    }}
                    className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                  >
                    Cerrar
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Filtros */}
      <div className="flex items-center gap-4">
        <label className="text-sm font-medium text-gray-700 dark:text-dark-300">Filtro:</label>
        <select
          value={filterActivo}
          onChange={(e) => setFilterActivo(e.target.value as 'all' | 'active' | 'inactive')}
          className="px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
        >
          <option value="all">Todos</option>
          <option value="active">Activos</option>
          <option value="inactive">Inactivos</option>
        </select>
        <button
          onClick={loadDispositivos}
          className="flex items-center gap-2 px-3 py-2 text-gray-700 dark:text-dark-300 bg-gray-100 dark:bg-dark-800 rounded-lg hover:bg-gray-200 dark:hover:bg-dark-700 transition-colors"
        >
          <RefreshCw className="h-4 w-4" />
          Actualizar
        </button>
      </div>

      {/* Formulario */}
      {showForm && (
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-dark-700">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              {editingId ? 'Editar Dispositivo' : 'Nuevo Dispositivo'}
            </h3>
            <button
              onClick={resetForm}
              className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
                Nombre del Dispositivo *
              </label>
              <input
                type="text"
                value={formData.nombreDispositivo || ''}
                onChange={(e) => setFormData({ ...formData, nombreDispositivo: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="Ej: Tablet Campo 1"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
                Modelo del Dispositivo
              </label>
              <input
                type="text"
                value={formData.modeloDispositivo || ''}
                onChange={(e) => setFormData({ ...formData, modeloDispositivo: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="Ej: Samsung Galaxy Tab"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
                Versión de la App
              </label>
              <input
                type="text"
                value={formData.versionApp || ''}
                onChange={(e) => setFormData({ ...formData, versionApp: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="Ej: 1.0.0"
              />
            </div>

            {editingId && (
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="activo"
                  checked={formData.activo || false}
                  onChange={(e) => setFormData({ ...formData, activo: e.target.checked })}
                  className="w-4 h-4 text-primary-600 rounded"
                />
                <label htmlFor="activo" className="text-sm text-gray-700 dark:text-dark-300">
                  Dispositivo activo
                </label>
              </div>
            )}

            <div className="flex gap-3">
              <button
                onClick={editingId ? () => handleUpdate(editingId) : handleCreate}
                className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              >
                <Save className="h-4 w-4" />
                {editingId ? 'Guardar Cambios' : 'Crear Dispositivo'}
              </button>
              <button
                onClick={resetForm}
                className="px-4 py-2 text-gray-700 dark:text-dark-300 bg-gray-100 dark:bg-dark-800 rounded-lg hover:bg-gray-200 dark:hover:bg-dark-700 transition-colors"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Tabla */}
      {loading ? (
        <div className="text-center py-12">
          <div className="w-8 h-8 border-4 border-primary-600 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-gray-600 dark:text-dark-400">Cargando dispositivos...</p>
        </div>
      ) : filteredDispositivos.length === 0 ? (
        <div className="text-center py-12 bg-white dark:bg-dark-900 rounded-lg border border-gray-200 dark:border-dark-700">
          <Smartphone className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 dark:text-dark-400">No hay dispositivos registrados</p>
        </div>
      ) : (
        <div className="bg-white dark:bg-dark-800 rounded-xl shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200 dark:divide-dark-700 text-xs">
              <thead className="bg-gray-50 dark:bg-dark-700">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Nombre
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Device ID
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Estado
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Último Acceso
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
                {filteredDispositivos.map((dispositivo) => (
                  <tr key={dispositivo.dispositivoID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      {dispositivo.nombreDispositivo || 'Sin nombre'}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 dark:text-dark-400 font-mono text-xs">
                      {dispositivo.deviceId}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        dispositivo.activo
                          ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                          : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
                      }`}>
                        {dispositivo.activo ? 'Activo' : 'Inactivo'}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 dark:text-dark-400">
                      <div>{formatDate(dispositivo.ultimoAcceso)}</div>
                      {dispositivo.ultimoAcceso && (
                        <div className="text-xs text-gray-500 dark:text-dark-500">
                          Hace {getDaysSinceLastAccess(dispositivo.ultimoAcceso)} días
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleEdit(dispositivo)}
                          className="p-2 text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-900/30 rounded-lg transition-colors"
                          title="Editar"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleRegenerateKey(dispositivo.dispositivoID)}
                          className="p-2 text-yellow-600 dark:text-yellow-400 hover:bg-yellow-50 dark:hover:bg-yellow-900/30 rounded-lg transition-colors"
                          title="Regenerar API Key"
                        >
                          <Key className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(dispositivo.dispositivoID)}
                          className="p-2 text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg transition-colors"
                          title="Eliminar"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
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

export default DispositivosManagement;

