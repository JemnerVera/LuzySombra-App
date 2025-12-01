// Application constants

export const UI_CONFIG = {
  tabs: [
    { id: 'analizar', label: 'Analizar Imágenes', icon: 'upload', hasSubMenu: false },
    { id: 'probar', label: 'Probar Modelo', icon: 'eye', hasSubMenu: false },
    { id: 'dashboard', label: 'Dashboard', icon: 'bar-chart-3', hasSubMenu: false },
    { id: 'historial', label: 'Historial', icon: 'history', hasSubMenu: false },
    { id: 'alertas', label: 'Alertas', icon: 'bell', hasSubMenu: false },
    { id: 'contactos', label: 'Contactos', icon: 'users', hasSubMenu: false },
    { id: 'dispositivos', label: 'Dispositivos', icon: 'smartphone', hasSubMenu: false },
    { id: 'umbrales', label: 'Umbrales', icon: 'gauge', hasSubMenu: false },
    { id: 'consolidada', label: 'Detalle', icon: 'table', hasSubMenu: true },
    { id: 'evaluacion-por-lote', label: 'Evaluación por lote', icon: 'table', hasSubMenu: false, parent: 'consolidada' },
    { id: 'evaluacion-por-fecha', label: 'Evaluación por fecha', icon: 'calendar', hasSubMenu: false, parent: 'consolidada' },
    { id: 'detalle-por-evaluacion', label: 'Detalle por evaluación', icon: 'image', hasSubMenu: false, parent: 'consolidada' },
  ] as const,
};

