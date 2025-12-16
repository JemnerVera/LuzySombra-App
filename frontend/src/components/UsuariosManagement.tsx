import React, { useState, useEffect, useMemo } from 'react';
import { apiService } from '../services/api';
import { Plus, Edit, Trash2, RefreshCw, Save, X, User, Mail, Shield, Search, ChevronLeft, ChevronRight, Lock, Unlock } from 'lucide-react';

interface Usuario {
  usuarioID: number;
  username: string;
  email: string;
  nombreCompleto: string | null;
  rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
  activo: boolean;
  ultimoAcceso: Date | null;
  intentosLogin: number;
  bloqueadoHasta: Date | null;
  fechaCreacion: Date;
  fechaModificacion: Date | null;
}

interface UsuariosManagementProps {
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void;
}

const UsuariosManagement: React.FC<UsuariosManagementProps> = ({ onNotification }) => {
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  
  // Filtros y búsqueda
  const [searchTerm, setSearchTerm] = useState('');
  const [filterRol, setFilterRol] = useState<string>('');
  const [filterActivo, setFilterActivo] = useState<string>('');
  
  // Paginación
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 20;
  
  const [formData, setFormData] = useState<Partial<Usuario & { password: string; confirmPassword: string }>>({
    username: '',
    email: '',
    nombreCompleto: '',
    rol: 'Lector',
    activo: true,
    password: '',
    confirmPassword: ''
  });

  const loadUsuarios = async () => {
    try {
      setLoading(true);
      const response = await apiService.getUsuarios();
      if (response.success && response.data) {
        setUsuarios(response.data);
      }
    } catch (error) {
      console.error('Error cargando usuarios:', error);
      onNotification('Error cargando usuarios', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsuarios();
  }, []);

  const handleCreate = async () => {
    try {
      if (!formData.username || !formData.email || !formData.password) {
        onNotification('Por favor completa username, email y password', 'warning');
        return;
      }

      if (formData.password !== formData.confirmPassword) {
        onNotification('Las contraseñas no coinciden', 'warning');
        return;
      }

      if (formData.password && formData.password.length < 6) {
        onNotification('La contraseña debe tener al menos 6 caracteres', 'warning');
        return;
      }

      const response = await apiService.createUsuario({
        username: formData.username!,
        password: formData.password!,
        email: formData.email!,
        nombreCompleto: formData.nombreCompleto || null,
        rol: formData.rol || 'Lector',
        activo: formData.activo !== undefined ? formData.activo : true
      });

      if (response.success) {
        onNotification('Usuario creado exitosamente', 'success');
        setShowForm(false);
        resetForm();
        loadUsuarios();
      }
    } catch (error: any) {
      console.error('Error creando usuario:', error);
      onNotification(error.response?.data?.error || 'Error creando usuario', 'error');
    }
  };

  const handleUpdate = async (id: number) => {
    try {
      if (!formData.username || !formData.email) {
        onNotification('Por favor completa username y email', 'warning');
        return;
      }

      if (formData.password) {
        if (formData.password !== formData.confirmPassword) {
          onNotification('Las contraseñas no coinciden', 'warning');
          return;
        }
        if (formData.password.length < 6) {
          onNotification('La contraseña debe tener al menos 6 caracteres', 'warning');
          return;
        }
      }

      const updateData: any = {
        username: formData.username,
        email: formData.email,
        nombreCompleto: formData.nombreCompleto || null,
        rol: formData.rol,
        activo: formData.activo
      };

      if (formData.password) {
        updateData.password = formData.password;
      }

      const response = await apiService.updateUsuario(id, updateData);

      if (response.success) {
        onNotification('Usuario actualizado exitosamente', 'success');
        setEditingId(null);
        resetForm();
        loadUsuarios();
      }
    } catch (error: any) {
      console.error('Error actualizando usuario:', error);
      onNotification(error.response?.data?.error || 'Error actualizando usuario', 'error');
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('¿Estás seguro de que deseas eliminar este usuario?')) {
      return;
    }

    try {
      const response = await apiService.deleteUsuario(id);
      if (response.success) {
        onNotification('Usuario eliminado exitosamente', 'success');
        loadUsuarios();
      }
    } catch (error: any) {
      console.error('Error eliminando usuario:', error);
      onNotification(error.response?.data?.error || 'Error eliminando usuario', 'error');
    }
  };

  const handleEdit = (usuario: Usuario) => {
    setEditingId(usuario.usuarioID);
    setFormData({
      username: usuario.username,
      email: usuario.email,
      nombreCompleto: usuario.nombreCompleto || '',
      rol: usuario.rol,
      activo: usuario.activo,
      password: '',
      confirmPassword: ''
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setFormData({
      username: '',
      email: '',
      nombreCompleto: '',
      rol: 'Lector',
      activo: true,
      password: '',
      confirmPassword: ''
    });
    setEditingId(null);
  };

  const getRolColor = (rol: string) => {
    const colors: Record<string, string> = {
      'Admin': 'bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300',
      'Agronomo': 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300',
      'Supervisor': 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300',
      'Lector': 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300'
    };
    return colors[rol] || colors['Lector'];
  };

  // Filtrar y paginar usuarios
  const filteredUsuarios = useMemo(() => {
    return usuarios.filter(usuario => {
      const matchesSearch = !searchTerm || 
        usuario.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
        usuario.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
        usuario.nombreCompleto?.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesRol = !filterRol || usuario.rol === filterRol;
      
      const matchesActivo = !filterActivo || 
        (filterActivo === 'activo' && usuario.activo) ||
        (filterActivo === 'inactivo' && !usuario.activo);
      
      return matchesSearch && matchesRol && matchesActivo;
    });
  }, [usuarios, searchTerm, filterRol, filterActivo]);

  const totalPages = Math.ceil(filteredUsuarios.length / itemsPerPage);
  const paginatedUsuarios = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return filteredUsuarios.slice(startIndex, endIndex);
  }, [filteredUsuarios, currentPage, itemsPerPage]);

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, filterRol, filterActivo]);

  const formatDate = (date: Date | string | null) => {
    if (!date) return '-';
    const d = new Date(date);
    return d.toLocaleDateString('es-PE', { 
      year: 'numeric', 
      month: '2-digit', 
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    });
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
            <User className="h-6 w-6" />
            Gestión de Usuarios
          </h2>
          <p className="text-gray-600 dark:text-dark-400 mt-1">
            Administra los usuarios que pueden acceder a la webapp
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
            Nuevo Usuario
          </button>
          <button
            onClick={loadUsuarios}
            className="flex items-center gap-2 px-4 py-2 bg-gray-200 dark:bg-dark-700 text-gray-700 dark:text-dark-300 rounded-lg hover:bg-gray-300 dark:hover:bg-dark-600 transition-colors"
          >
            <RefreshCw className="h-4 w-4" />
            Actualizar
          </button>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow p-4 space-y-4">
        <div className="flex items-center gap-4 flex-wrap">
          <div className="flex-1 min-w-[200px]">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por username, email o nombre..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>
          </div>
          <select
            value={filterRol}
            onChange={(e) => setFilterRol(e.target.value)}
            className="px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
          >
            <option value="">Todos los roles</option>
            <option value="Admin">Admin</option>
            <option value="Agronomo">Agrónomo</option>
            <option value="Supervisor">Supervisor</option>
            <option value="Lector">Lector</option>
          </select>
          <select
            value={filterActivo}
            onChange={(e) => setFilterActivo(e.target.value)}
            className="px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
          >
            <option value="">Todos</option>
            <option value="activo">Activos</option>
            <option value="inactivo">Inactivos</option>
          </select>
        </div>
      </div>

      {/* Formulario */}
      {showForm && (
        <div className="bg-white dark:bg-dark-900 rounded-lg shadow p-6 space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              {editingId ? 'Editar Usuario' : 'Nuevo Usuario'}
            </h3>
            <button
              onClick={() => {
                setShowForm(false);
                resetForm();
              }}
              className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Username *
              </label>
              <input
                type="text"
                value={formData.username || ''}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                required
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
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Nombre Completo
              </label>
              <input
                type="text"
                value={formData.nombreCompleto || ''}
                onChange={(e) => setFormData({ ...formData, nombreCompleto: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                Rol *
              </label>
              <select
                value={formData.rol || 'Lector'}
                onChange={(e) => setFormData({ ...formData, rol: e.target.value as any })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
              >
                <option value="Admin">Admin</option>
                <option value="Agronomo">Agrónomo</option>
                <option value="Supervisor">Supervisor</option>
                <option value="Lector">Lector</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                {editingId ? 'Nueva Contraseña (dejar vacío para mantener la actual)' : 'Contraseña *'}
              </label>
              <input
                type="password"
                value={formData.password || ''}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                required={!editingId}
                placeholder={editingId ? 'Dejar vacío para mantener contraseña actual' : ''}
              />
            </div>
            {formData.password && (
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-1">
                  Confirmar Contraseña {!editingId && '*'}
                </label>
                <input
                  type="password"
                  value={formData.confirmPassword || ''}
                  onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white"
                  required={!editingId || !!formData.password}
                />
              </div>
            )}
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="activo"
                checked={formData.activo || false}
                onChange={(e) => setFormData({ ...formData, activo: e.target.checked })}
                className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
              />
              <label htmlFor="activo" className="text-sm font-medium text-gray-700 dark:text-dark-300">
                Usuario activo
              </label>
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <button
              onClick={() => {
                setShowForm(false);
                resetForm();
              }}
              className="px-4 py-2 text-gray-700 dark:text-dark-300 bg-gray-100 dark:bg-dark-800 rounded-lg hover:bg-gray-200 dark:hover:bg-dark-700 transition-colors"
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

      {/* Tabla */}
      <div className="bg-white dark:bg-dark-900 rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-dark-800">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Username</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Email</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Nombre</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Rol</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Estado</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Último Acceso</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-dark-700">
              {paginatedUsuarios.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center text-gray-500 dark:text-dark-400">
                    No hay usuarios que mostrar
                  </td>
                </tr>
              ) : (
                paginatedUsuarios.map((usuario) => (
                  <tr key={usuario.usuarioID} className="hover:bg-gray-50 dark:hover:bg-dark-800">
                    <td className="px-4 py-3 text-sm text-gray-900 dark:text-white font-medium">{usuario.username}</td>
                    <td className="px-4 py-3 text-sm text-gray-600 dark:text-dark-300 flex items-center gap-2">
                      <Mail className="h-4 w-4" />
                      {usuario.email}
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 dark:text-dark-300">{usuario.nombreCompleto || '-'}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getRolColor(usuario.rol)}`}>
                        <Shield className="h-3 w-3 mr-1" />
                        {usuario.rol}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        usuario.activo 
                          ? 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300' 
                          : 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300'
                      }`}>
                        {usuario.activo ? (
                          <>
                            <Unlock className="h-3 w-3 mr-1" />
                            Activo
                          </>
                        ) : (
                          <>
                            <Lock className="h-3 w-3 mr-1" />
                            Inactivo
                          </>
                        )}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-gray-600 dark:text-dark-300">{formatDate(usuario.ultimoAcceso)}</td>
                    <td className="px-4 py-3 text-sm">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleEdit(usuario)}
                          className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 transition-colors"
                          title="Editar"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(usuario.usuarioID)}
                          className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 transition-colors"
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
        {totalPages > 1 && (
          <div className="bg-gray-50 dark:bg-dark-800 px-4 py-3 flex items-center justify-between border-t border-gray-200 dark:border-dark-700">
            <div className="text-sm text-gray-700 dark:text-dark-300">
              Mostrando {((currentPage - 1) * itemsPerPage) + 1} a {Math.min(currentPage * itemsPerPage, filteredUsuarios.length)} de {filteredUsuarios.length} usuarios
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                disabled={currentPage === 1}
                className="p-2 text-gray-600 dark:text-dark-400 hover:text-gray-900 dark:hover:text-white disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronLeft className="h-5 w-5" />
              </button>
              <span className="text-sm text-gray-700 dark:text-dark-300">
                Página {currentPage} de {totalPages}
              </span>
              <button
                onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                disabled={currentPage === totalPages}
                className="p-2 text-gray-600 dark:text-dark-400 hover:text-gray-900 dark:hover:text-white disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ChevronRight className="h-5 w-5" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default UsuariosManagement;

