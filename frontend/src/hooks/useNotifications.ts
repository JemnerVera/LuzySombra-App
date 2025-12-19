import { useState, useEffect, useCallback } from 'react';
import { apiService } from '../services/api';

interface Notification {
  id: number;
  tipo: string;
  severidad: string;
  estado: string;
  fecha: Date;
  porcentajeLuz: number;
  lotID: number;
}

interface UseNotificationsReturn {
  contador: number;
  notificaciones: Notification[];
  isLoading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}

/**
 * Hook para manejar notificaciones en tiempo real
 * Usa polling cada 30 segundos para verificar nuevas alertas
 */
export const useNotifications = (enabled: boolean = true): UseNotificationsReturn => {
  const [contador, setContador] = useState(0);
  const [notificaciones, setNotificaciones] = useState<Notification[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [ultimaConsulta, setUltimaConsulta] = useState<number>(Date.now());

  const fetchNotifications = useCallback(async () => {
    if (!enabled) return;

    try {
      setIsLoading(true);
      setError(null);

      // Obtener contador de nuevas alertas
      const contadorResponse = await apiService.getNotificacionesContador(ultimaConsulta);
      
      if (contadorResponse.success) {
        const contadorData = (contadorResponse.data as any) || contadorResponse;
        const nuevas = contadorData.nuevasAlertas || 0;
        setContador(nuevas);
        
        // Si hay nuevas, actualizar timestamp
        if (nuevas > 0 && contadorData.timestamp) {
          setUltimaConsulta(contadorData.timestamp);
        }

        // Obtener lista de notificaciones recientes
        const listaResponse = await apiService.getNotificacionesLista(10);
        if (listaResponse.success) {
          const listaData = (listaResponse.data as any) || listaResponse;
          if (listaData.notificaciones) {
            setNotificaciones(listaData.notificaciones);
          }
        }
      }
    } catch (err: any) {
      console.error('Error obteniendo notificaciones:', err);
      setError(err.response?.data?.error || 'Error obteniendo notificaciones');
    } finally {
      setIsLoading(false);
    }
  }, [enabled, ultimaConsulta]);

  // Polling cada 30 segundos
  useEffect(() => {
    if (!enabled) return;

    // Cargar inmediatamente
    fetchNotifications();

    // Configurar intervalo
    const interval = setInterval(() => {
      fetchNotifications();
    }, 30000); // 30 segundos

    return () => clearInterval(interval);
  }, [enabled, fetchNotifications]);

  const refresh = useCallback(async () => {
    await fetchNotifications();
  }, [fetchNotifications]);

  return {
    contador,
    notificaciones,
    isLoading,
    error,
    refresh
  };
};

