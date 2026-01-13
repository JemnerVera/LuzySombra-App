// Types for the Agricola Luz-Sombra application

export interface FieldData {
  empresa: string[];
  fundo: string[];
  sector: string[];
  lote: string[];
  hierarchical: HierarchicalData;
}

export interface HierarchicalData {
  [empresa: string]: {
    [fundo: string]: {
      [sector: string]: string[];
    };
  };
}

export interface ImageFile {
  file: File;
  preview: string;
  gpsStatus: 'extracting' | 'found' | 'not-found';
  coordinates?: {
    lat: number;
    lng: number;
  };
  dateStatus: 'extracting' | 'found' | 'not-found';
  dateTime?: {
    date: string;
    time: string;
  };
  lotStatus: 'extracting' | 'found' | 'not-found';
  lotID?: number;
  hilera?: string;
  numero_planta?: string;
}

export interface ProcessingResult {
  success: boolean;
  fileName?: string;
  image_name?: string;
  empresa?: string;
  hilera?: string;
  numero_planta?: string;
  porcentaje_luz?: number;
  porcentaje_sombra?: number;
  fundo?: string;
  sector?: string;
  latitud?: number;
  longitud?: number;
  error?: string;
  message?: string;
  processed_image?: string;
}

export interface HistoryRecord {
  id: string;
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  hilera: string;
  numero_planta: string;
  porcentaje_luz: number;
  porcentaje_sombra: number;
  fecha_tomada: string;
  latitud?: number;
  longitud?: number;
  timestamp: string;
  imagen: string;
  dispositivo: string;
  direccion: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  detail?: string;
  error?: string;
  pagination?: {
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
  };
  // Propiedades que pueden estar en el objeto raíz (para compatibilidad con backend)
  [key: string]: any;
}

export interface ProcessingFormData {
  empresa: string;
  fundo: string;
  sector: string;
  lote: string;
  images: ImageFile[];
}

export interface TestFormData {
  empresa: string;
  fundo: string;
  imagen: File;
}

export type TabType = 'analizar' | 'probar' | 'dashboard' | 'historial' | 'sistema-alertas' | 'alertas' | 'alertas-consolidados' | 'alertas-mensajes' | 'contactos' | 'usuarios' | 'dispositivos' | 'umbrales' | 'consolidada' | 'evaluacion-por-lote' | 'evaluacion-por-fecha' | 'evaluacion-detalle-planta' | 'detalle-por-evaluacion';

export interface NotificationState {
  show: boolean;
  message: string;
  type: 'success' | 'error' | 'warning' | 'info';
}

// Navegación de detalle
export interface DetalleNavigation {
  fundo: string;
  sector: string;
  lote: string;
  fecha?: string; // Para navegación a detalle de plantas
}

// Navegación de alertas
export interface AlertasNavigation {
  fundoID?: string; // Para navegación a mensajes consolidados por fundo
  mensajeID?: number; // Para navegación a detalle de mensaje
}

