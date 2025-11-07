import { useState, useEffect } from 'react';
import { TabType } from './types';
import Layout from './components/Layout';
import ImageUploadForm from './components/ImageUploadForm';
import ModelTestForm from './components/ModelTestForm';
import HistoryTable from './components/HistoryTable';
import ConsolidatedTable from './components/ConsolidatedTable';
import EvaluacionPorFecha from './components/EvaluacionPorFecha';
import EvaluacionDetallePlanta from './components/EvaluacionDetallePlanta';
import Notification from './components/Notification';
import { DetalleNavigation } from './types';

function App() {
  const [currentTab, setCurrentTab] = useState<TabType>('analizar');
  const [hasUnsavedData, setHasUnsavedData] = useState(false);
  const [pendingTab, setPendingTab] = useState<TabType | null>(null);
  const [detalleNavigation, setDetalleNavigation] = useState<DetalleNavigation | null>(null);
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
      case 'historial':
        return (
          <HistoryTable 
            onNotification={showNotification}
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

export default App;

