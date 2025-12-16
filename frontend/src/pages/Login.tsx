import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { LogIn, Lock, User, AlertCircle } from 'lucide-react';
import { apiService } from '../services/api';

const Login: React.FC = () => {
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // Si ya está autenticado, redirigir
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  // Detectar y guardar token de lote desde URL (antes del login)
  useEffect(() => {
    const lotID = searchParams.get('lotID');
    const token = searchParams.get('token');

    if (lotID && token) {
      // Verificar token y guardar información de navegación
      apiService.verifyLoteToken(token)
        .then(result => {
          if (result.success && result.data) {
            const { lote, sector, fundo } = result.data;
            // Guardar en sessionStorage para usar después del login
            sessionStorage.setItem('loteTokenNavigation', JSON.stringify({
              fundo,
              sector,
              lote,
              lotID: parseInt(lotID, 10)
            }));
            console.log('✅ Token válido guardado. Se navegará después del login.');
          }
        })
        .catch(error => {
          console.error('❌ Error verificando token:', error);
          // No mostrar error aquí, solo limpiar si hay problema
          sessionStorage.removeItem('loteTokenNavigation');
        });
    }
  }, [searchParams]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      await login(formData.username, formData.password);
      
      // Verificar si hay navegación guardada desde token de lote
      const savedNavigation = sessionStorage.getItem('loteTokenNavigation');
      if (savedNavigation) {
        // Limpiar sessionStorage
        sessionStorage.removeItem('loteTokenNavigation');
        // Navegar a la app (el App.tsx detectará la navegación guardada)
        navigate('/');
      } else {
        navigate('/');
      }
    } catch (err: any) {
      const errorMessage = err.response?.data?.error || 
                          err.message || 
                          'Error al iniciar sesión';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 dark:from-dark-950 dark:to-dark-900 flex items-center justify-center p-4">
      <div className="bg-white dark:bg-dark-900 rounded-2xl shadow-2xl w-full max-w-md p-8">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-600 rounded-full mb-4">
            <LogIn className="h-8 w-8 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Iniciar Sesión
          </h1>
          <p className="text-gray-600 dark:text-dark-400">
            Ingresa tus credenciales para acceder
          </p>
        </div>

        {/* Error Message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg flex items-start gap-3">
            <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-sm font-medium text-red-800 dark:text-red-300">
                {error}
              </p>
            </div>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Username */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Usuario
            </label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ingresa tu usuario"
                required
                autoComplete="username"
                disabled={loading}
              />
            </div>
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Contraseña
            </label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="w-full pl-10 pr-12 py-3 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ingresa tu contraseña"
                required
                autoComplete="current-password"
                disabled={loading}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              >
                {showPassword ? '👁️' : '👁️‍🗨️'}
              </button>
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading || !formData.username || !formData.password}
            className="w-full bg-primary-600 text-white py-3 rounded-lg font-medium hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Iniciando sesión...
              </>
            ) : (
              <>
                <LogIn className="h-5 w-5" />
                Iniciar Sesión
              </>
            )}
          </button>
        </form>

        {/* Footer */}
        <div className="mt-6 text-center text-sm text-gray-600 dark:text-dark-400">
          <p>¿Problemas para acceder? Contacta al administrador</p>
        </div>
      </div>
    </div>
  );
};

export default Login;

