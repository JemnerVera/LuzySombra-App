import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { apiService } from '../services/api';

interface User {
  id: number;
  username: string;
  email: string;
  nombreCompleto: string | null;
  rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
  permisos: string[];
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
  refreshToken: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Cargar usuario desde token almacenado al iniciar
  useEffect(() => {
    const initAuth = async () => {
      const token = localStorage.getItem('authToken');
      if (token) {
        try {
          const response = await apiService.getCurrentUser();
          if (response.success && response.user) {
            setUser(response.user);
          } else {
            // Token inválido, limpiar
            localStorage.removeItem('authToken');
          }
        } catch (error) {
          console.error('Error cargando usuario:', error);
          localStorage.removeItem('authToken');
        }
      }
      setIsLoading(false);
    };

    initAuth();
  }, []);

  // Login
  const login = useCallback(async (username: string, password: string) => {
    try {
      const response = await apiService.loginWeb(username, password);
      
      if (response.success && response.token && response.user) {
        // Guardar token
        localStorage.setItem('authToken', response.token);
        
        // Guardar usuario
        setUser(response.user);
        
        // Programar refresh automático
        scheduleTokenRefresh(response.expiresIn);
      } else {
        throw new Error(response.error || 'Error en login');
      }
    } catch (error) {
      console.error('Error en login:', error);
      throw error;
    }
  }, []);

  // Logout
  const logout = useCallback(() => {
    localStorage.removeItem('authToken');
    setUser(null);
    
    // Limpiar refresh programado
    if (window.tokenRefreshTimeout) {
      clearTimeout(window.tokenRefreshTimeout);
    }
  }, []);

  // Verificar permiso
  const hasPermission = useCallback((permission: string): boolean => {
    if (!user) return false;
    
    // Admin tiene todos los permisos
    if (user.permisos.includes('*')) return true;
    
    return user.permisos.includes(permission);
  }, [user]);

  // Verificar rol
  const hasRole = useCallback((role: string): boolean => {
    return user?.rol === role;
  }, [user]);

  // Refrescar token
  const refreshToken = useCallback(async () => {
    try {
      const response = await apiService.refreshToken();
      if (response.success && response.token) {
        localStorage.setItem('authToken', response.token);
        scheduleTokenRefresh(response.expiresIn);
      }
    } catch (error) {
      console.error('Error refrescando token:', error);
      logout(); // Si falla, cerrar sesión
    }
  }, [logout]);

  // Programar refresh automático del token
  const scheduleTokenRefresh = (expiresIn: number) => {
    // Refrescar 5 minutos antes de que expire
    const refreshTime = (expiresIn - 300) * 1000;
    
    if (window.tokenRefreshTimeout) {
      clearTimeout(window.tokenRefreshTimeout);
    }
    
    window.tokenRefreshTimeout = setTimeout(() => {
      refreshToken();
    }, refreshTime);
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    hasPermission,
    hasRole,
    refreshToken
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth debe usarse dentro de AuthProvider');
  }
  return context;
};

// Extender Window para TypeScript
declare global {
  interface Window {
    tokenRefreshTimeout?: NodeJS.Timeout;
  }
}

