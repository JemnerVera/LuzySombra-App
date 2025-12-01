/**
 * Utilidades para manejo de errores
 */

export interface ApiError {
  message: string;
  code?: string;
  status?: number;
  details?: unknown;
}

/**
 * Extrae un mensaje de error descriptivo de una respuesta de error
 */
export const extractErrorMessage = (error: unknown): string => {
  // Error de red (sin conexión, timeout, etc.)
  if (error instanceof TypeError && error.message.includes('fetch')) {
    return 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
  }

  // Error de timeout
  if (error instanceof Error && error.message.includes('timeout')) {
    return 'La solicitud tardó demasiado. Por favor, intenta nuevamente.';
  }

  // Error de axios (API)
  if (typeof error === 'object' && error !== null && 'response' in error) {
    const axiosError = error as { response?: { data?: { error?: string; message?: string }; status?: number }; message?: string };
    
    if (axiosError.response) {
      const status = axiosError.response.status;
      const data = axiosError.response.data;

      // Mensajes específicos por código de estado
      switch (status) {
        case 400:
          return data?.error || data?.message || 'Solicitud inválida. Verifica los datos ingresados.';
        case 401:
          return 'No autorizado. Por favor, inicia sesión nuevamente.';
        case 403:
          return 'No tienes permisos para realizar esta acción.';
        case 404:
          return 'Recurso no encontrado.';
        case 409:
          return data?.error || data?.message || 'Conflicto: El recurso ya existe o está en uso.';
        case 413:
          return 'El archivo es demasiado grande.';
        case 422:
          return data?.error || data?.message || 'Error de validación. Verifica los datos ingresados.';
        case 429:
          return 'Demasiadas solicitudes. Por favor, espera un momento e intenta nuevamente.';
        case 500:
          return 'Error interno del servidor. Por favor, contacta al administrador.';
        case 502:
        case 503:
        case 504:
          return 'El servidor no está disponible temporalmente. Por favor, intenta más tarde.';
        default:
          return data?.error || data?.message || `Error del servidor (${status}).`;
      }
    }

    // Error de red sin respuesta
    if (axiosError.message) {
      if (axiosError.message.includes('Network Error')) {
        return 'Error de red. Verifica tu conexión a internet.';
      }
      if (axiosError.message.includes('timeout')) {
        return 'La solicitud tardó demasiado. Por favor, intenta nuevamente.';
      }
    }
  }

  // Error estándar de JavaScript
  if (error instanceof Error) {
    return error.message;
  }

  // Error desconocido
  if (typeof error === 'string') {
    return error;
  }

  return 'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
};

/**
 * Determina el tipo de error para mostrar el icono/color apropiado
 */
export const getErrorType = (error: unknown): 'error' | 'warning' | 'info' => {
  if (typeof error === 'object' && error !== null && 'response' in error) {
    const axiosError = error as { response?: { status?: number } };
    const status = axiosError.response?.status;

    if (status === 400 || status === 422) {
      return 'warning'; // Errores de validación son warnings
    }
  }

  return 'error';
};

/**
 * Log de error para debugging (solo en desarrollo)
 */
export const logError = (error: unknown, context?: string): void => {
  if (process.env.NODE_ENV === 'development') {
    console.error(`❌ [Error${context ? ` - ${context}` : ''}]`, error);
    
    if (typeof error === 'object' && error !== null && 'response' in error) {
      const axiosError = error as { response?: { data?: unknown; status?: number } };
      console.error('Response:', axiosError.response?.data);
      console.error('Status:', axiosError.response?.status);
    }
  }
};

/**
 * Maneja errores de forma consistente y muestra notificación
 */
export const handleError = (
  error: unknown,
  onNotification: (message: string, type: 'success' | 'error' | 'warning' | 'info') => void,
  context?: string
): void => {
  logError(error, context);
  const message = extractErrorMessage(error);
  const type = getErrorType(error);
  onNotification(message, type);
};

/**
 * Retry helper para operaciones que pueden fallar temporalmente
 */
export const retryOperation = async <T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> => {
  let lastError: unknown;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;
      
      // No reintentar para errores 4xx (excepto 429)
      if (typeof error === 'object' && error !== null && 'response' in error) {
        const axiosError = error as { response?: { status?: number } };
        const status = axiosError.response?.status;
        if (status && status >= 400 && status < 500 && status !== 429) {
          throw error;
        }
      }

      if (attempt < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, delay * attempt));
      }
    }
  }

  throw lastError;
};

