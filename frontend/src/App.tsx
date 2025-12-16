import { useState, useEffect } from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import { TabType } from './types';
import Layout from './components/Layout';
import ImageUploadForm from './components/ImageUploadForm';
import ModelTestForm from './components/ModelTestForm';
import HistoryTable from './components/HistoryTable';
import ConsolidatedTable from './components/ConsolidatedTable';
import EvaluacionPorFecha from './components/EvaluacionPorFecha';
import EvaluacionDetallePlanta from './components/EvaluacionDetallePlanta';
import UmbralesManagement from './components/UmbralesManagement';
import ContactosManagement from './components/ContactosManagement';
import UsuariosManagement from './components/UsuariosManagement';
import AlertasDashboard from './components/AlertasDashboard';
import MensajesConsolidados from './components/MensajesConsolidados';
import MensajesEnviados from './components/MensajesEnviados';
import StatisticsDashboard from './components/StatisticsDashboard';
import DispositivosManagement from './components/DispositivosManagement';
import Notification from './components/Notification';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import { DetalleNavigation, AlertasNavigation } from './types';
import { apiService } from './services/api';

// Componente interno que maneja las tabs (requiere autenticación)
function AppContent() {
  const location = useLocation();
  const { isAuthenticated } = useAuth();
  const [currentTab, setCurrentTab] = useState<TabType>('analizar');
  const [hasUnsavedData, setHasUnsavedData] = useState(false);
  const [pendingTab, setPendingTab] = useState<TabType | null>(null);
  const [detalleNavigation, setDetalleNavigation] = useState<DetalleNavigation | null>(null);
  const [alertasNavigation, setAlertasNavigation] = useState<AlertasNavigation | null>(null);
  const [notification, setNotification] = useState<{
    show: boolean;
    message: string;
    type: 'success' | 'error' | 'warning' | 'info';
  }>({
    show: false,
    message: '',
    type: 'info'
  });

  // Load EXIF library on app start
  useEffect(() => {
    // Load EXIF.js dynamically
    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/npm/exif-js@2.3.0/exif.js';
    script.onload = () => console.log('✅ EXIF.js loaded');
    script.onerror = () => console.error('❌ Failed to load EXIF.js');
    document.head.appendChild(script);
  }, []);

  const showNotification = (message: string, type: 'success' | 'error' | 'warning' | 'info' = 'info') => {
    setNotification({
      show: true,
      message,
      type
    });
    
    setTimeout(() => {
      setNotification(prev => ({ ...prev, show: false }));
    }, 5000);
  };

  // Manejar links con token desde emails de alertas
  useEffect(() => {
    const handleLoteTokenLink = async () => {
      // Primero verificar si hay navegación guardada en sessionStorage (desde Login)
      const savedNavigation = sessionStorage.getItem('loteTokenNavigation');
      if (savedNavigation) {
        try {
          const nav = JSON.parse(savedNavigation);
          console.log('✅ Restaurando navegación desde token guardado:', nav);
          setDetalleNavigation({ fundo: nav.fundo, sector: nav.sector, lote: nav.lote });
          setCurrentTab('evaluacion-por-fecha');
          sessionStorage.removeItem('loteTokenNavigation');
          showNotification('Acceso autorizado. Mostrando evaluación del lote.', 'success');
          return;
        } catch (error) {
          console.error('❌ Error restaurando navegación:', error);
          sessionStorage.removeItem('loteTokenNavigation');
        }
      }

      // Si no hay navegación guardada, verificar URL directamente
      const searchParams = new URLSearchParams(location.search);
      const lotID = searchParams.get('lotID');
      const token = searchParams.get('token');

      if (lotID && token) {
        try {
          console.log('🔍 Verificando token de acceso a lote desde URL...', { lotID, tokenLength: token.length });
          const result = await apiService.verifyLoteToken(token);
          
          console.log('📋 Resultado de verificación:', result);
          
          if (result.success && result.data) {
            const { lote, sector, fundo } = result.data;
            console.log('✅ Token válido. Navegando a evaluación del lote:', { fundo, sector, lote });
            setDetalleNavigation({ fundo, sector, lote });
            setCurrentTab('evaluacion-por-fecha');
            window.history.replaceState({}, '', window.location.pathname);
            showNotification('Acceso autorizado. Mostrando evaluación del lote.', 'success');
          } else {
            console.error('❌ Token inválido:', result);
            const errorMsg = 'error' in result ? (result as { error?: string }).error : 'Token inválido o expirado';
            showNotification(`${errorMsg}. Por favor, inicia sesión.`, 'error');
          }
        } catch (error: unknown) {
          console.error('❌ Error verificando token:', error);
          let errorMsg = 'Error al verificar el enlace';
          if (error && typeof error === 'object' && 'response' in error) {
            const axiosError = error as { response?: { data?: { error?: string } } };
            errorMsg = axiosError.response?.data?.error || errorMsg;
          } else if (error instanceof Error) {
            errorMsg = error.message;
          }
          showNotification(`${errorMsg}. Por favor, inicia sesión.`, 'error');
        }
      }
    };

    // Solo ejecutar si está autenticado
    if (isAuthenticated) {
      handleLoteTokenLink();
    }
  }, [location.search, isAuthenticated]);

  const [showModal, setShowModal] = useState(false);

  const handleTabChange = (tab: TabType) => {
    if (hasUnsavedData && currentTab === 'analizar') {
      setPendingTab(tab);
      setShowModal(true);
    } else {
      setCurrentTab(tab);
      setHasUnsavedData(false);
    }
  };

  const confirmTabChange = () => {
    if (pendingTab) {
      setCurrentTab(pendingTab);
      setHasUnsavedData(false);
      setPendingTab(null);
    }
    setShowModal(false);
  };

  const cancelTabChange = () => {
    setPendingTab(null);
    setShowModal(false);
  };

  const renderTabContent = () => {
    switch (currentTab) {
      case 'analizar':
        return (
          <ImageUploadForm 
            onUnsavedDataChange={setHasUnsavedData}
            onNotification={showNotification}
          />
        );
      case 'probar':
        return (
          <ModelTestForm 
            onNotification={showNotification}
          />
        );
      case 'dashboard':
        return (
          <StatisticsDashboard 
            onNotification={showNotification}
          />
        );
      case 'historial':
        return (
          <HistoryTable 
            onNotification={showNotification}
          />
        );
      case 'umbrales':
        return (
          <UmbralesManagement 
            onNotification={showNotification}
          />
        );
      case 'contactos':
        return (
          <ContactosManagement 
            onNotification={showNotification}
          />
        );
      case 'usuarios':
        return (
          <UsuariosManagement 
            onNotification={showNotification}
          />
        );
      case 'dispositivos':
        return (
          <DispositivosManagement 
            onNotification={showNotification}
          />
        );
      case 'sistema-alertas':
        // Por defecto, mostrar Alertas cuando se selecciona el padre
        return (
          <AlertasDashboard 
            onNotification={showNotification}
            onNavigateToConsolidados={() => {
              setCurrentTab('alertas-consolidados');
            }}
          />
        );
      case 'alertas':
        return (
          <AlertasDashboard 
            onNotification={showNotification}
            onNavigateToConsolidados={() => {
              setCurrentTab('alertas-consolidados');
            }}
          />
        );
      case 'alertas-consolidados':
        return (
          <MensajesConsolidados
            onNotification={showNotification}
            onNavigateBack={() => {
              setCurrentTab('alertas');
              setAlertasNavigation(null);
            }}
            onNavigateToMensajes={(nav: AlertasNavigation) => {
              setAlertasNavigation(nav);
              setCurrentTab('alertas-mensajes');
            }}
          />
        );
      case 'alertas-mensajes':
        return (
          <MensajesEnviados
            onNotification={showNotification}
            onNavigateBack={() => {
              setCurrentTab('alertas-consolidados');
              setAlertasNavigation(null);
            }}
            navigation={alertasNavigation || undefined}
          />
        );
      case 'consolidada':
      case 'evaluacion-por-lote':
        return (
          <ConsolidatedTable 
            onNotification={showNotification}
            onNavigateToDetalle={(nav: DetalleNavigation) => {
              setDetalleNavigation(nav);
              setCurrentTab('evaluacion-por-fecha');
            }}
          />
        );
      case 'evaluacion-por-fecha':
        if (!detalleNavigation) {
          return (
            <div className="text-center text-gray-500 dark:text-dark-400">
              No hay navegación disponible. Por favor, selecciona un lote desde la tabla consolidada.
            </div>
          );
        }
        return (
          <EvaluacionPorFecha 
            navigation={detalleNavigation}
            onNotification={showNotification}
            onNavigateToDetallePlanta={(nav: DetalleNavigation) => {
              setDetalleNavigation(nav);
              setCurrentTab('evaluacion-detalle-planta');
            }}
            onBack={() => setCurrentTab('evaluacion-por-lote')}
          />
        );
      case 'evaluacion-detalle-planta':
        if (!detalleNavigation) {
          return (
            <div className="text-center text-gray-500 dark:text-dark-400">
              No hay navegación disponible. Por favor, selecciona un lote desde la tabla consolidada.
            </div>
          );
        }
        return (
          <EvaluacionDetallePlanta 
            navigation={detalleNavigation}
            onNotification={showNotification}
            onBack={() => setCurrentTab('evaluacion-por-fecha')}
          />
        );
      default:
        return (
          <div className="text-center text-gray-500 dark:text-dark-400">
            Tab no encontrado
          </div>
        );
    }
  };

  return (
    <>
      <Layout currentTab={currentTab} onTabChange={handleTabChange}>
        {renderTabContent()}
      </Layout>

      {/* Confirmation Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white dark:bg-dark-900 rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              ¿Descartar cambios?
            </h3>
            <p className="text-gray-600 dark:text-dark-400 mb-6">
              Tienes cambios sin guardar. ¿Estás seguro de que deseas cambiar de pestaña?
            </p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={cancelTabChange}
                className="px-4 py-2 text-gray-700 dark:text-dark-300 bg-gray-100 dark:bg-dark-800 rounded-lg hover:bg-gray-200 dark:hover:bg-dark-700 transition-colors"
              >
                Cancelar
              </button>
              <button
                onClick={confirmTabChange}
                className="px-4 py-2 text-white bg-red-600 rounded-lg hover:bg-red-700 transition-colors"
              >
                Descartar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Notification */}
      <Notification 
        show={notification.show}
        message={notification.message}
        type={notification.type}
        onClose={() => setNotification(prev => ({ ...prev, show: false }))}
      />
    </>
  );
}

// Componente principal con routing
function App() {
  const { isAuthenticated, isLoading } = useAuth();

  // Mostrar loading mientras verifica autenticación
  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="w-8 h-8 border-4 border-primary-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <Routes>
      {/* Ruta pública: Login */}
      <Route 
        path="/login" 
        element={
          isAuthenticated ? <Navigate to="/" replace /> : <Login />
        } 
      />
      
      {/* Rutas protegidas: App principal con tabs */}
      <Route 
        path="/*" 
        element={
          <ProtectedRoute>
            <AppContent />
          </ProtectedRoute>
        } 
      />
    </Routes>
  );
}

export default App;

