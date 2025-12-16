// Application constants

export interface TabConfig {
  id: string;
  label: string;
  icon: string;
  hasSubMenu?: boolean;
  parent?: string;
  category?: string;
}

export interface CategoryConfig {
  id: string;
  label: string;
  icon: string;
  tabs: TabConfig[];
}

export const UI_CONFIG = {
  categories: [
    {
      id: 'analisis-imagen',
      label: 'Análisis de Imagen',
      icon: 'image',
      tabs: [
        { id: 'analizar', label: 'Analizar Imágenes', icon: 'upload', category: 'analisis-imagen' },
        { id: 'probar', label: 'Probar Modelo', icon: 'eye', category: 'analisis-imagen' },
        { id: 'historial', label: 'Historial', icon: 'history', category: 'analisis-imagen' },
      ],
    },
    {
      id: 'analisis-detallado',
      label: 'Análisis Detallado',
      icon: 'bar-chart-3',
      tabs: [
        { id: 'consolidada', label: 'Detalle', icon: 'layers', hasSubMenu: true, category: 'analisis-detallado' },
        { id: 'evaluacion-por-lote', label: 'Evaluación por lote', icon: 'list', hasSubMenu: false, parent: 'consolidada', category: 'analisis-detallado' },
        { id: 'evaluacion-por-fecha', label: 'Evaluación por fecha', icon: 'calendar', hasSubMenu: false, parent: 'consolidada', category: 'analisis-detallado' },
        { id: 'detalle-por-evaluacion', label: 'Detalle por evaluación', icon: 'image', hasSubMenu: false, parent: 'consolidada', category: 'analisis-detallado' },
      ],
    },
    {
      id: 'gestion-parametros',
      label: 'Gestión de Parámetros',
      icon: 'settings',
      tabs: [
        { id: 'contactos', label: 'Contactos', icon: 'users', category: 'gestion-parametros' },
        { id: 'usuarios', label: 'Usuarios', icon: 'user', category: 'gestion-parametros' },
        { id: 'dispositivos', label: 'Dispositivos', icon: 'smartphone', category: 'gestion-parametros' },
        { id: 'umbrales', label: 'Umbrales', icon: 'gauge', category: 'gestion-parametros' },
      ],
    },
    {
      id: 'dashboard',
      label: 'Dashboard',
      icon: 'bar-chart-3',
      tabs: [
        { id: 'dashboard', label: 'Dashboard', icon: 'bar-chart-3', category: 'dashboard' },
      ],
    },
    {
      id: 'sistema-alerta',
      label: 'Sistema de Alerta',
      icon: 'bell',
      tabs: [
        { id: 'sistema-alertas', label: 'Sistema de Alertas', icon: '', hasSubMenu: true, category: 'sistema-alerta' },
        { id: 'alertas', label: 'Alertas', icon: 'shield-alert', hasSubMenu: false, parent: 'sistema-alertas', category: 'sistema-alerta' },
        { id: 'alertas-consolidados', label: 'Consolidado por fundo', icon: 'package', hasSubMenu: false, parent: 'sistema-alertas', category: 'sistema-alerta' },
        { id: 'alertas-mensajes', label: 'Mensajes', icon: 'mail', hasSubMenu: false, parent: 'sistema-alertas', category: 'sistema-alerta' },
      ],
    },
  ] as CategoryConfig[],
  
  // Mantener tabs para compatibilidad con código existente
  tabs: [
    { id: 'analizar', label: 'Analizar Imágenes', icon: 'upload', hasSubMenu: false, category: 'analisis-imagen' },
    { id: 'probar', label: 'Probar Modelo', icon: 'eye', hasSubMenu: false, category: 'analisis-imagen' },
    { id: 'historial', label: 'Historial', icon: 'history', hasSubMenu: false, category: 'analisis-imagen' },
    { id: 'consolidada', label: 'Detalle', icon: 'layers', hasSubMenu: true, category: 'analisis-detallado' },
    { id: 'evaluacion-por-lote', label: 'Evaluación por lote', icon: 'table', hasSubMenu: false, parent: 'consolidada', category: 'analisis-detallado' },
    { id: 'evaluacion-por-fecha', label: 'Evaluación por fecha', icon: 'calendar', hasSubMenu: false, parent: 'consolidada', category: 'analisis-detallado' },
    { id: 'detalle-por-evaluacion', label: 'Detalle por evaluación', icon: 'image', hasSubMenu: false, parent: 'consolidada', category: 'analisis-detallado' },
    { id: 'contactos', label: 'Contactos', icon: 'users', hasSubMenu: false, category: 'gestion-parametros' },
    { id: 'usuarios', label: 'Usuarios', icon: 'user', hasSubMenu: false, category: 'gestion-parametros' },
    { id: 'dispositivos', label: 'Dispositivos', icon: 'smartphone', hasSubMenu: false, category: 'gestion-parametros' },
    { id: 'umbrales', label: 'Umbrales', icon: 'gauge', hasSubMenu: false, category: 'gestion-parametros' },
    { id: 'dashboard', label: 'Dashboard', icon: 'bar-chart-3', hasSubMenu: false, category: 'dashboard' },
    { id: 'sistema-alertas', label: 'Sistema de Alertas', icon: '', hasSubMenu: true, category: 'sistema-alerta' },
    { id: 'alertas', label: 'Alertas', icon: 'shield-alert', hasSubMenu: false, parent: 'sistema-alertas', category: 'sistema-alerta' },
    { id: 'alertas-consolidados', label: 'Consolidado por fundo', icon: 'package', hasSubMenu: false, parent: 'sistema-alertas', category: 'sistema-alerta' },
    { id: 'alertas-mensajes', label: 'Mensajes', icon: 'mail', hasSubMenu: false, parent: 'sistema-alertas', category: 'sistema-alerta' },
  ] as TabConfig[],
};

