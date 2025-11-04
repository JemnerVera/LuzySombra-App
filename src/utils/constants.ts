// Application constants

export const UI_CONFIG = {
  tabs: [
    { id: 'analizar', label: 'Analizar Imágenes', icon: 'upload', hasSubMenu: false },
    { id: 'probar', label: 'Probar Modelo', icon: 'eye', hasSubMenu: false },
    { id: 'historial', label: 'Historial', icon: 'bar-chart-3', hasSubMenu: false },
    { id: 'consolidada', label: 'Detalle', icon: 'table', hasSubMenu: true },
    { id: 'evaluacion-por-lote', label: 'Evaluación por lote', icon: 'table', hasSubMenu: false, parent: 'consolidada' },
    { id: 'evaluacion-por-fecha', label: 'Evaluación por fecha', icon: 'calendar', hasSubMenu: false, parent: 'consolidada' },
    { id: 'detalle-por-evaluacion', label: 'Detalle por evaluación', icon: 'image', hasSubMenu: false, parent: 'consolidada' },
  ] as const,
};
