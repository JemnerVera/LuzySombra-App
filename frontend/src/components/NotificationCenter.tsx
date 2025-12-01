import React, { useState, useRef, useEffect } from 'react';
import { Bell, AlertTriangle, AlertCircle, Info, X } from 'lucide-react';
import { useNotifications } from '../hooks/useNotifications';
import { useAuth } from '../contexts/AuthContext';

const NotificationCenter: React.FC = () => {
  const { contador, notificaciones, isLoading } = useNotifications(true);
  const { isAuthenticated } = useAuth();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Cerrar dropdown al hacer click fuera
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  // No mostrar si no está autenticado
  if (!isAuthenticated) {
    return null;
  }

  const getSeverityIcon = (severidad: string) => {
    switch (severidad) {
      case 'Critico':
        return <AlertTriangle className="h-4 w-4 text-red-500" />;
      case 'Advertencia':
        return <AlertCircle className="h-4 w-4 text-yellow-500" />;
      default:
        return <Info className="h-4 w-4 text-blue-500" />;
    }
  };

  const getSeverityColor = (severidad: string) => {
    switch (severidad) {
      case 'Critico':
        return 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800';
      case 'Advertencia':
        return 'bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800';
      default:
        return 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800';
    }
  };

  return (
    <div className="relative" ref={dropdownRef}>
      {/* Botón de notificaciones */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 text-gray-600 dark:text-dark-300 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-dark-800 rounded-lg transition-colors"
        aria-label="Notificaciones"
      >
        <Bell className="h-6 w-6" />
        {contador > 0 && (
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">
            {contador > 9 ? '9+' : contador}
          </span>
        )}
      </button>

      {/* Dropdown de notificaciones */}
      {isOpen && (
        <div className="absolute right-0 mt-2 w-80 bg-white dark:bg-dark-900 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 z-50 max-h-96 overflow-hidden flex flex-col">
          {/* Header */}
          <div className="p-4 border-b border-gray-200 dark:border-dark-700 flex items-center justify-between">
            <h3 className="font-semibold text-gray-900 dark:text-white">
              Notificaciones
              {contador > 0 && (
                <span className="ml-2 text-sm text-gray-500 dark:text-dark-400">
                  ({contador} nuevas)
                </span>
              )}
            </h3>
            <button
              onClick={() => setIsOpen(false)}
              className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Lista de notificaciones */}
          <div className="overflow-y-auto flex-1">
            {isLoading ? (
              <div className="p-4 text-center text-gray-500 dark:text-dark-400">
                <div className="w-6 h-6 border-2 border-primary-600 border-t-transparent rounded-full animate-spin mx-auto mb-2" />
                Cargando...
              </div>
            ) : notificaciones.length === 0 ? (
              <div className="p-4 text-center text-gray-500 dark:text-dark-400">
                No hay notificaciones
              </div>
            ) : (
              <div className="divide-y divide-gray-200 dark:divide-dark-700">
                {notificaciones.map((notif) => (
                  <div
                    key={notif.id}
                    className={`p-4 hover:bg-gray-50 dark:hover:bg-dark-800 transition-colors ${getSeverityColor(notif.severidad)}`}
                  >
                    <div className="flex items-start gap-3">
                      {getSeverityIcon(notif.severidad)}
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-gray-900 dark:text-white">
                          Alerta {notif.tipo}
                        </p>
                        <p className="text-xs text-gray-600 dark:text-dark-400 mt-1">
                          Luz: {notif.porcentajeLuz.toFixed(1)}%
                        </p>
                        <p className="text-xs text-gray-500 dark:text-dark-500 mt-1">
                          {new Date(notif.fecha).toLocaleString('es-ES')}
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Footer */}
          {notificaciones.length > 0 && (
            <div className="p-2 border-t border-gray-200 dark:border-dark-700">
              <button
                onClick={() => {
                  // Redirigir a alertas
                  window.location.href = '#alertas';
                  setIsOpen(false);
                }}
                className="w-full text-sm text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 text-center py-2"
              >
                Ver todas las alertas
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default NotificationCenter;

