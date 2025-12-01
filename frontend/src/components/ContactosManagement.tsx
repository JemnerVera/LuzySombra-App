import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { useFieldData } from '../hooks/useFieldData';
import { Plus, Edit, Trash2, RefreshCw, Save, X, Users, Mail, Phone } from 'lucide-react';

interface Contacto {
  contactoID: number;
  nombre: string;
  email: string;
  telefono: string | null;
  tipo: 'General' | 'Admin' | 'Agronomo' | 'Manager' | 'Supervisor' | 'Tecnico' | 'Otro';
  rol: string | null;
  recibirAlertasCriticas: boolean;
  recibirAlertasAdvertencias: boolean;
  recibirAlertasNormales: boolean;
  fundoID: string | null;
  sectorID: number | null;
  fundoNombre?: string | null;
  sectorNombre?: string | null;
  prioridad: number;
  activo: boolean;
  fechaCreacion: string;
  fechaActualizacion: string | null;
}

interface ContactosManagementProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

const ContactosManagement: React.FC<ContactosManagementProps> = ({ onNotification }) => {
  const { fieldData } = useFieldData();
  const [contactos, setContactos] = useState<Contacto[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState<Partial<Contacto>>({
    nombre: '',
    email: '',
    telefono: '',
    tipo: 'General',
    rol: '',
    recibirAlertasCriticas: true,
    recibirAlertasAdvertencias: true,
    recibirAlertasNormales: false,
    fundoID: null,
    sectorID: null,
    prioridad: 0,
    activo: true
  });

  const loadContactos = async () => {
    try {
      setLoading(true);
      const response = await apiService.getContactos();
      if (response.success && response.data) {
        setContactos(response.data);
      }
    } catch (error) {
      console.error('Error cargando contactos:', error);
      onNotification('Error cargando contactos', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadContactos();
  }, []);

  const handleCreate = async () => {
    try {
      if (!formData.nombre || !formData.email) {
        onNotification('Por favor completa nombre y email', 'warning');
        return;
      }

      const response = await apiService.createContacto({
        ...formData,
        usuarioCreaID: 1 // TODO: Obtener del contexto de usuario
      });

      if (response.success) {
        onNotification('Contacto creado exitosamente', 'success');
        setShowForm(false);
        resetForm();
        loadContactos();
      }
    } catch (error) {
      console.error('Error creando contacto:', error);
      onNotification('Error creando contacto', 'error');
    }
  };

  const handleUpdate = async (id: number) => {
    try {
      if (!formData.nombre || !formData.email) {
        onNotification('Por favor completa nombre y email', 'warning');
        return;
      }

      const response = await apiService.updateContacto(id, {
        ...formData,
        usuarioActualizaID: 1 // TODO: Obtener del contexto de usuario
      });

      if (response.success) {
        onNotification('Contacto actualizado exitosamente', 'success');
        setEditingId(null);
        resetForm();
        loadContactos();
      }
    } catch (error) {
      console.error('Error actualizando contacto:', error);
      onNotification('Error actualizando contacto', 'error');
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('¿Estás seguro de que deseas eliminar este contacto?')) {
      return;
    }

    try {
      const response = await apiService.deleteContacto(id);
      if (response.success) {
        onNotification('Contacto eliminado exitosamente', 'success');
        loadContactos();
      }
    } catch (error) {
      console.error('Error eliminando contacto:', error);
      onNotification('Error eliminando contacto', 'error');
    }
  };

  const handleEdit = (contacto: Contacto) => {
    setEditingId(contacto.contactoID);
    setFormData({
      nombre: contacto.nombre,
      email: contacto.email,
      telefono: contacto.telefono || '',
      tipo: contacto.tipo,
      rol: contacto.rol || '',
      recibirAlertasCriticas: contacto.recibirAlertasCriticas,
      recibirAlertasAdvertencias: contacto.recibirAlertasAdvertencias,
      recibirAlertasNormales: contacto.recibirAlertasNormales,
      fundoID: contacto.fundoID,
      sectorID: contacto.sectorID,
      prioridad: contacto.prioridad,
      activo: contacto.activo
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setFormData({
      nombre: '',
      email: '',
      telefono: '',
      tipo: 'General',
      rol: '',
      recibirAlertasCriticas: true,
      recibirAlertasAdvertencias: true,
      recibirAlertasNormales: false,
      fundoID: null,
      sectorID: null,
      prioridad: 0,
      activo: true
    });
    setEditingId(null);
  };

  const getTipoColor = (tipo: string) => {
    const colors: Record<string, string> = {
      'Admin': 'bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300',
      'Agronomo': 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300',
      'Manager': 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300',
      'Supervisor': 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300',
      'Tecnico': 'bg-orange-100 dark:bg-orange-900/30 text-orange-800 dark:text-orange-300',
      'General': 'bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300',
      'Otro': 'bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300'
    };
    return colors[tipo] || colors['General'];
  };

  // Obtener fundos y sectores disponibles
  const fundos = fieldData?.fundo || [];
  const sectores = formData.fundoID 
    ? fieldData?.hierarchical?.[Object.keys(fieldData.hierarchical)[0]]?.[formData.fundoID] 
      ? Object.keys(fieldData.hierarchical[Object.keys(fieldData.hierarchical)[0]][formData.fundoID])
      : []
    : [];

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
            <Users className="h-6 w-6" />
            Gestión de Contactos
          </h2>
          <p className="text-gray-600 dark:text-dark-400 mt-1">
            Administra los destinatarios de alertas por email
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
            Nuevo Contacto
          </button>
          <button
            onClick={loadContactos}
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
              {editingId ? 'Editar Contacto' : 'Nuevo Contacto'}
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
                Nombre *
              </label>
              <input
                type="text"
                value={formData.nombre || ''}
                onChange={(e) => setFormData({ ...formData, nombre: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="Juan Pérez"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Email *
              </label>
              <input
                type="email"
                value={formData.email || ''}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="juan@example.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Teléfono
              </label>
              <input
                type="tel"
                value={formData.telefono || ''}
                onChange={(e) => setFormData({ ...formData, telefono: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="+56 9 1234 5678"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Tipo *
              </label>
              <select
                value={formData.tipo || 'General'}
                onChange={(e) => setFormData({ ...formData, tipo: e.target.value as any })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              >
                <option value="General">General</option>
                <option value="Admin">Admin</option>
                <option value="Agronomo">Agrónomo</option>
                <option value="Manager">Manager</option>
                <option value="Supervisor">Supervisor</option>
                <option value="Tecnico">Técnico</option>
                <option value="Otro">Otro</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Rol
              </label>
              <input
                type="text"
                value={formData.rol || ''}
                onChange={(e) => setFormData({ ...formData, rol: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="Jefe de Campo"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Fundo
              </label>
              <select
                value={formData.fundoID || ''}
                onChange={(e) => {
                  setFormData({ ...formData, fundoID: e.target.value || null, sectorID: null });
                }}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              >
                <option value="">Todos los fundos</option>
                {fundos.map((fundo) => (
                  <option key={fundo} value={fundo}>
                    {fundo}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Sector
              </label>
              <select
                value={formData.sectorID || ''}
                onChange={(e) => setFormData({ ...formData, sectorID: e.target.value ? parseInt(e.target.value) : null })}
                disabled={!formData.fundoID}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white disabled:opacity-50"
              >
                <option value="">Todos los sectores</option>
                {sectores.map((sector) => (
                  <option key={sector} value={sector}>
                    {sector}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Prioridad
              </label>
              <input
                type="number"
                value={formData.prioridad || 0}
                onChange={(e) => setFormData({ ...formData, prioridad: parseInt(e.target.value) || 0 })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                placeholder="0"
              />
              <p className="text-xs text-gray-500 dark:text-dark-400 mt-1">
                Mayor número = mayor prioridad en envío
              </p>
            </div>

            <div className="md:col-span-2 space-y-2">
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
                Preferencias de Alertas
              </label>
              <div className="space-y-2">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.recibirAlertasCriticas !== false}
                    onChange={(e) => setFormData({ ...formData, recibirAlertasCriticas: e.target.checked })}
                    className="w-4 h-4 text-primary-600 rounded"
                  />
                  <span className="text-sm text-gray-700 dark:text-dark-300">
                    Recibir alertas críticas (🚨 Crítico Rojo)
                  </span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.recibirAlertasAdvertencias !== false}
                    onChange={(e) => setFormData({ ...formData, recibirAlertasAdvertencias: e.target.checked })}
                    className="w-4 h-4 text-primary-600 rounded"
                  />
                  <span className="text-sm text-gray-700 dark:text-dark-300">
                    Recibir alertas de advertencia (⚠️ Crítico Amarillo)
                  </span>
                </label>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={formData.recibirAlertasNormales === true}
                    onChange={(e) => setFormData({ ...formData, recibirAlertasNormales: e.target.checked })}
                    className="w-4 h-4 text-primary-600 rounded"
                  />
                  <span className="text-sm text-gray-700 dark:text-dark-300">
                    Recibir notificaciones cuando vuelve a Normal
                  </span>
                </label>
              </div>
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

      {/* Tabla de Contactos */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-dark-800">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Nombre
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Email
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Tipo
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Filtros
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">
                  Alertas
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
              {contactos.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay contactos configurados. Crea uno nuevo para comenzar.
                  </td>
                </tr>
              ) : (
                contactos.map((contacto) => (
                  <tr key={contacto.contactoID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <Users className="h-4 w-4 text-gray-400" />
                        <span className="text-sm font-medium text-gray-900 dark:text-white">
                          {contacto.nombre}
                        </span>
                      </div>
                      {contacto.rol && (
                        <p className="text-xs text-gray-500 dark:text-dark-400 mt-1">
                          {contacto.rol}
                        </p>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <Mail className="h-4 w-4 text-gray-400" />
                        <span className="text-sm text-gray-900 dark:text-white">
                          {contacto.email}
                        </span>
                      </div>
                      {contacto.telefono && (
                        <div className="flex items-center gap-1 mt-1">
                          <Phone className="h-3 w-3 text-gray-400" />
                          <span className="text-xs text-gray-500 dark:text-dark-400">
                            {contacto.telefono}
                          </span>
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getTipoColor(contacto.tipo)}`}>
                        {contacto.tipo}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white">
                      <div className="space-y-1">
                        <div>
                          <span className="text-xs text-gray-500 dark:text-dark-400">Fundo: </span>
                          <span>{contacto.fundoNombre || 'Todos'}</span>
                        </div>
                        <div>
                          <span className="text-xs text-gray-500 dark:text-dark-400">Sector: </span>
                          <span>{contacto.sectorNombre || 'Todos'}</span>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex flex-col gap-1">
                        {contacto.recibirAlertasCriticas && (
                          <span className="text-xs px-2 py-0.5 bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300 rounded">
                            🚨 Críticas
                          </span>
                        )}
                        {contacto.recibirAlertasAdvertencias && (
                          <span className="text-xs px-2 py-0.5 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300 rounded">
                            ⚠️ Advertencias
                          </span>
                        )}
                        {contacto.recibirAlertasNormales && (
                          <span className="text-xs px-2 py-0.5 bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300 rounded">
                            ✅ Normales
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${
                        contacto.activo
                          ? 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300'
                          : 'bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-300'
                      }`}>
                        {contacto.activo ? 'Activo' : 'Inactivo'}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleEdit(contacto)}
                          className="p-2 text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-900/30 rounded transition-colors"
                          title="Editar"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(contacto.contactoID)}
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

export default ContactosManagement;

