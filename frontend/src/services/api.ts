import axios from 'axios';
import { FieldData, HistoryRecord, ApiResponse, ProcessingResult } from '../types';
import { extractErrorMessage, logError } from '../utils/errorHandler';

// API URL desde variable de entorno o usar proxy de Vite
const API_BASE_URL = import.meta.env.VITE_API_URL || '';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 120000, // 2 minutes timeout - aumentado para respuestas grandes de SQL Server
});

// Request interceptor - Agregar token a todas las requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log(`🚀 API Request: ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('❌ API Request Error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor - Manejar errores de autenticación
api.interceptors.response.use(
  (response) => {
    console.log(`✅ API Response: ${response.status} ${response.config.url}`);
    return response;
  },
  (error) => {
    // Log error con contexto
    logError(error, `API ${error.config?.method?.toUpperCase()} ${error.config?.url}`);
    
    // Si es error 401 (no autorizado), redirigir a login
    if (error.response?.status === 401) {
      // Solo si no estamos ya en la página de login
      if (window.location.pathname !== '/login') {
        localStorage.removeItem('authToken');
        window.location.href = '/login';
      }
    }
    
    // Mejorar mensaje de error si no tiene uno
    if (error.response?.data && !error.response.data.error && !error.response.data.message) {
      error.response.data.error = extractErrorMessage(error);
    }
    
    return Promise.reject(error);
  }
);

export const apiService = {
  // Health check
  health: async (): Promise<ApiResponse<{ status: string }>> => {
    const response = await api.get('/api/health');
    return response.data;
  },

  // Get field data for dropdowns (migrated to SQL Server with fallback to Google Sheets)
  getFieldData: async (): Promise<FieldData> => {
    const response = await api.get('/api/field-data');
    // New endpoint returns { success, source, data, ... }
    if (response.data.data) {
      return response.data.data;
    }
    // Fallback to old format for compatibility
    return response.data;
  },

  // Process single image
  processImage: async (formData: FormData): Promise<ProcessingResult> => {
    const response = await api.post('/api/procesar-imagen', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // Test model (for testing tab)
  testModel: async (formData: FormData): Promise<ProcessingResult> => {
    const response = await api.post('/api/test-model', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // Process multiple images
  processMultipleImages: async (images: FormData[]): Promise<ProcessingResult[]> => {
    const promises = images.map(formData => apiService.processImage(formData));
    return Promise.all(promises);
  },

  // Get processing history with pagination
  getHistory: async (params?: { page?: number; pageSize?: number; empresa?: string; fundo?: string; sector?: string; lote?: string }): Promise<ApiResponse<HistoryRecord[]>> => {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.pageSize) queryParams.append('pageSize', params.pageSize.toString());
    if (params?.empresa) queryParams.append('empresa', params.empresa);
    if (params?.fundo) queryParams.append('fundo', params.fundo);
    if (params?.sector) queryParams.append('sector', params.sector);
    if (params?.lote) queryParams.append('lote', params.lote);
    
    const url = `/api/historial${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
    const response = await api.get(url);
    
    // El backend devuelve { success: true, procesamientos: [...], total, page, pageSize, totalPages }
    // Retornamos también la información de paginación
    if (response.data.success && response.data.procesamientos) {
      return {
        success: true,
        data: response.data.procesamientos,
        // Incluir información de paginación
        pagination: {
          total: response.data.total,
          page: response.data.page,
          pageSize: response.data.pageSize,
          totalPages: response.data.totalPages
        }
      } as any;
    }
    return response.data;
  },

  // Get consolidated table
  getConsolidatedTable: async (params?: { page?: number; pageSize?: number; fundo?: string; sector?: string; lote?: string }): Promise<{
    success: boolean;
    data: any[];
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
    error?: string;
  }> => {
    const queryParams = new URLSearchParams();
    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.pageSize) queryParams.append('pageSize', params.pageSize.toString());
    if (params?.fundo) queryParams.append('fundo', params.fundo);
    if (params?.sector) queryParams.append('sector', params.sector);
    if (params?.lote) queryParams.append('lote', params.lote);
    
    const url = `/api/tabla-consolidada${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
    const response = await api.get(url);
    return response.data;
  },

  // Get detalle historial (evaluación por fecha)
  getDetalleHistorial: async (fundo: string, sector: string, lote: string): Promise<ApiResponse<any>> => {
    const queryParams = new URLSearchParams({
      fundo,
      sector,
      lote
    });
    const response = await api.get(`/api/tabla-consolidada/detalle?${queryParams.toString()}`);
    return response.data;
  },

  // Get detalle planta (evaluación detalle planta)
  getDetallePlanta: async (fundo: string, sector: string, lote: string, fecha: string): Promise<ApiResponse<any>> => {
    const queryParams = new URLSearchParams({
      fundo,
      sector,
      lote,
      fecha
    });
    const response = await api.get(`/api/tabla-consolidada/detalle-planta?${queryParams.toString()}`);
    return response.data;
  },

  // Get image by ID
  getImage: async (id: string): Promise<ApiResponse<any>> => {
    const response = await api.get(`/api/imagen?id=${id}`);
    return response.data;
  },

  // Get statistics
  getStatistics: async (): Promise<ApiResponse<unknown>> => {
    const response = await api.get('/api/estadisticas');
    return response.data;
  },

  // Check GPS info from image
  checkGpsInfo: async (file: File): Promise<ApiResponse<{ hasGps: boolean; coordinates?: { lat: number; lng: number } }>> => {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await api.post('/api/check-gps-info', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  // Umbrales
  getUmbrales: async (params?: { includeInactive?: boolean; tipo?: string; variedadID?: number }): Promise<ApiResponse<any>> => {
    const queryParams = new URLSearchParams();
    if (params?.includeInactive) queryParams.append('includeInactive', 'true');
    if (params?.tipo) queryParams.append('tipo', params.tipo);
    if (params?.variedadID !== undefined) queryParams.append('variedadID', params.variedadID.toString());
    
    const url = `/api/umbrales${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
    const response = await api.get(url);
    return response.data;
  },

  getUmbralById: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.get(`/api/umbrales/${id}`);
    return response.data;
  },

  createUmbral: async (data: any): Promise<ApiResponse<any>> => {
    const response = await api.post('/api/umbrales', data);
    return response.data;
  },

  updateUmbral: async (id: number, data: any): Promise<ApiResponse<any>> => {
    const response = await api.put(`/api/umbrales/${id}`, data);
    return response.data;
  },

  deleteUmbral: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.delete(`/api/umbrales/${id}`);
    return response.data;
  },

  getVariedades: async (): Promise<ApiResponse<any>> => {
    const response = await api.get('/api/umbrales/variedades/list');
    return response.data;
  },

  // CONTACTOS
  getContactos: async (includeInactive?: boolean): Promise<ApiResponse<any>> => {
    const params = includeInactive ? { includeInactive: 'true' } : {};
    const response = await api.get('/api/contactos', { params });
    return response.data;
  },

  getContactoById: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.get(`/api/contactos/${id}`);
    return response.data;
  },

  createContacto: async (data: any): Promise<ApiResponse<any>> => {
    const response = await api.post('/api/contactos', data);
    return response.data;
  },

  updateContacto: async (id: number, data: any): Promise<ApiResponse<any>> => {
    const response = await api.put(`/api/contactos/${id}`, data);
    return response.data;
  },

  deleteContacto: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.delete(`/api/contactos/${id}`);
    return response.data;
  },

  // USUARIOS
  getUsuarios: async (): Promise<ApiResponse<Array<{
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
  }>>> => {
    const response = await api.get('/api/usuarios');
    return response.data;
  },

  getUsuarioById: async (id: number): Promise<ApiResponse<{
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
  }>> => {
    const response = await api.get(`/api/usuarios/${id}`);
    return response.data;
  },

  createUsuario: async (data: {
    username: string;
    password: string;
    email: string;
    nombreCompleto?: string | null;
    rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
    activo?: boolean;
  }): Promise<ApiResponse<{ usuarioID: number }>> => {
    const response = await api.post('/api/usuarios', data);
    return response.data;
  },

  updateUsuario: async (id: number, data: {
    username?: string;
    password?: string;
    email?: string;
    nombreCompleto?: string | null;
    rol?: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
    activo?: boolean;
  }): Promise<ApiResponse<any>> => {
    const response = await api.put(`/api/usuarios/${id}`, data);
    return response.data;
  },

  deleteUsuario: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.delete(`/api/usuarios/${id}`);
    return response.data;
  },

  // ALERTAS
  getAlertas: async (filters?: {
    estado?: string;
    tipoUmbral?: string;
    fundoID?: string;
    fechaDesde?: string;
    fechaHasta?: string;
    page?: number;
    pageSize?: number;
  }): Promise<ApiResponse<any>> => {
    const response = await api.get('/api/alertas', { params: filters });
    return response.data;
  },

  getEstadisticasAlertas: async (): Promise<ApiResponse<any>> => {
    const response = await api.get('/api/alertas/estadisticas');
    return response.data;
  },

  resolverAlerta: async (id: number, usuarioResolvioID: number, notas?: string): Promise<ApiResponse<any>> => {
    const response = await api.put(`/api/alertas/${id}/resolver`, { usuarioResolvioID, notas });
    return response.data;
  },

  ignorarAlerta: async (id: number, usuarioResolvioID: number, notas?: string): Promise<ApiResponse<any>> => {
    const response = await api.put(`/api/alertas/${id}/ignorar`, { usuarioResolvioID, notas });
    return response.data;
  },

  consolidarAlertas: async (horasAtras?: number): Promise<ApiResponse<{
    mensajesCreados: number;
    horasAtras: number;
    alertasSinMensaje: number;
  }>> => {
    const params = horasAtras ? { horasAtras } : {};
    const response = await api.post('/api/alertas/consolidar', null, { params });
    return response.data;
  },

  enviarMensajes: async (): Promise<ApiResponse<{
    exitosos: number;
    errores: number;
  }>> => {
    const response = await api.post('/api/alertas/enviar');
    return response.data;
  },

  getMensajes: async (filters?: {
    estado?: string;
    fundoID?: string;
    page?: number;
    pageSize?: number;
  }): Promise<ApiResponse<{
    mensajes: Array<{
      mensajeID: number;
      fundoID: string | null;
      fundoNombre: string | null;
      tipoMensaje: string;
      asunto: string;
      estado: string;
      fechaCreacion: string;
      fechaEnvio: string | null;
      intentosEnvio: number;
      resendMessageID: string | null;
      errorMessage: string | null;
      totalAlertas: number;
    }>;
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
  }>> => {
    const response = await api.get('/api/alertas/mensajes', { params: filters });
    return response.data;
  },

  getMensajeById: async (id: number): Promise<ApiResponse<{
    mensaje: {
      mensajeID: number;
      fundoID: string | null;
      fundoNombre: string | null;
      tipoMensaje: string;
      asunto: string;
      cuerpoHTML: string;
      cuerpoTexto: string | null;
      destinatarios: string;
      estado: string;
      fechaCreacion: string;
      fechaEnvio: string | null;
      intentosEnvio: number;
      resendMessageID: string | null;
      errorMessage: string | null;
    };
    alertas: Array<{
      alertaID: number;
      lotID: number;
      loteNombre: string;
      sectorNombre: string;
      tipoUmbral: string;
      porcentajeLuzEvaluado: number;
      fechaCreacion: string;
    }>;
  }>> => {
    const response = await api.get(`/api/alertas/mensajes/${id}`);
    return response.data;
  },

  // AUTENTICACIÓN WEB
  loginWeb: async (username: string, password: string): Promise<ApiResponse<{
    token: string;
    expiresIn: number;
    user: {
      id: number;
      username: string;
      email: string;
      nombreCompleto: string | null;
      rol: string;
      permisos: string[];
    };
  }>> => {
    const response = await api.post('/api/auth/web/login', { username, password });
    return response.data;
  },

  logoutWeb: async (): Promise<ApiResponse<any>> => {
    const response = await api.post('/api/auth/web/logout');
    return response.data;
  },

  getCurrentUser: async (): Promise<ApiResponse<{
    user: {
      id: number;
      username: string;
      email: string;
      nombreCompleto: string | null;
      rol: string;
      permisos: string[];
    };
  }>> => {
    const response = await api.get('/api/auth/web/me');
    return response.data;
  },

  refreshToken: async (): Promise<ApiResponse<{
    token: string;
    expiresIn: number;
  }>> => {
    const response = await api.post('/api/auth/web/refresh');
    return response.data;
  },

  forgotPassword: async (email: string): Promise<ApiResponse<{
    message: string;
  }>> => {
    const response = await api.post('/api/auth/web/forgot-password', { email });
    return response.data;
  },

  // NOTIFICACIONES
  getNotificacionesContador: async (ultimaConsulta?: number): Promise<ApiResponse<{
    nuevasAlertas: number;
    timestamp: number;
  }>> => {
    const params = ultimaConsulta ? { ultimaConsulta } : {};
    const response = await api.get('/api/notificaciones/contador', { params });
    return response.data;
  },

  getNotificacionesLista: async (limit: number = 10): Promise<ApiResponse<{
    notificaciones: Array<{
      id: number;
      tipo: string;
      severidad: string;
      estado: string;
      fecha: Date;
      porcentajeLuz: number;
      lotID: number;
    }>;
  }>> => {
    const response = await api.get('/api/notificaciones/lista', { params: { limit } });
    return response.data;
  },

  // DISPOSITIVOS
  getDispositivos: async (): Promise<ApiResponse<{
    dispositivos: Array<{
      dispositivoID: number;
      deviceId: string;
      apiKey: string | null;
      nombreDispositivo: string | null;
      modeloDispositivo: string | null;
      versionApp: string | null;
      activo: boolean;
      fechaRegistro: string;
      ultimoAcceso: string | null;
    }>;
  }>> => {
    const response = await api.get('/api/dispositivos');
    return response.data;
  },

  getDispositivoById: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.get(`/api/dispositivos/${id}`);
    return response.data;
  },

  createDispositivo: async (data: {
    nombreDispositivo: string;
    modeloDispositivo?: string;
    versionApp?: string;
  }): Promise<ApiResponse<{
    dispositivoID: number;
    apiKey: string;
    qrCodeUrl?: string;
    qrData?: any;
    expiresAt?: string;
  }>> => {
    const response = await api.post('/api/dispositivos', data);
    return response.data;
  },

  updateDispositivo: async (id: number, data: {
    nombreDispositivo?: string;
    modeloDispositivo?: string;
    versionApp?: string;
    activo?: boolean;
  }): Promise<ApiResponse<any>> => {
    const response = await api.put(`/api/dispositivos/${id}`, data);
    return response.data;
  },

  deleteDispositivo: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.delete(`/api/dispositivos/${id}`);
    return response.data;
  },

  regenerateApiKey: async (id: number): Promise<ApiResponse<{
    apiKey: string;
    qrCodeUrl?: string;
    qrData?: any;
    expiresAt?: string;
  }>> => {
    const response = await api.post(`/api/dispositivos/${id}/regenerate-key`);
    return response.data;
  },

  getDispositivoStats: async (id: number): Promise<ApiResponse<any>> => {
    const response = await api.get(`/api/dispositivos/${id}/stats`);
    return response.data;
  },

  // Verificar token de acceso a lote (para links en emails)
  verifyLoteToken: async (token: string): Promise<ApiResponse<{
    lotID: number;
    lote: string;
    sector: string;
    fundo: string;
    expiresAt: number;
  }>> => {
    const response = await api.get('/api/auth/verify-lote-token', {
      params: { token }
    });
    return response.data;
  },
};

export default apiService;
