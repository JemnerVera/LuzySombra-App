/**
 * Utilidades de validación reutilizables
 */

export interface ValidationResult {
  valid: boolean;
  error?: string;
}

/**
 * Valida un email
 */
export const validateEmail = (email: string): ValidationResult => {
  if (!email || email.trim() === '') {
    return { valid: false, error: 'El email es requerido' };
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { valid: false, error: 'El formato del email no es válido' };
  }

  if (email.length > 255) {
    return { valid: false, error: 'El email no puede tener más de 255 caracteres' };
  }

  return { valid: true };
};

/**
 * Valida un teléfono (formato flexible)
 */
export const validatePhone = (phone: string | null | undefined): ValidationResult => {
  if (!phone || phone.trim() === '') {
    return { valid: true }; // Teléfono es opcional
  }

  // Permite números, espacios, guiones, paréntesis y +
  const phoneRegex = /^[\d\s\-\+\(\)]+$/;
  if (!phoneRegex.test(phone)) {
    return { valid: false, error: 'El formato del teléfono no es válido' };
  }

  // Debe tener al menos 8 dígitos
  const digitsOnly = phone.replace(/\D/g, '');
  if (digitsOnly.length < 8) {
    return { valid: false, error: 'El teléfono debe tener al menos 8 dígitos' };
  }

  if (phone.length > 20) {
    return { valid: false, error: 'El teléfono no puede tener más de 20 caracteres' };
  }

  return { valid: true };
};

/**
 * Valida un nombre (no vacío, longitud razonable)
 */
export const validateName = (name: string, fieldName: string = 'Nombre'): ValidationResult => {
  if (!name || name.trim() === '') {
    return { valid: false, error: `${fieldName} es requerido` };
  }

  if (name.trim().length < 2) {
    return { valid: false, error: `${fieldName} debe tener al menos 2 caracteres` };
  }

  if (name.length > 100) {
    return { valid: false, error: `${fieldName} no puede tener más de 100 caracteres` };
  }

  return { valid: true };
};

/**
 * Valida un porcentaje (0-100)
 */
export const validatePercentage = (value: number | string, fieldName: string = 'Porcentaje'): ValidationResult => {
  const numValue = typeof value === 'string' ? parseFloat(value) : value;

  if (isNaN(numValue)) {
    return { valid: false, error: `${fieldName} debe ser un número válido` };
  }

  if (numValue < 0 || numValue > 100) {
    return { valid: false, error: `${fieldName} debe estar entre 0 y 100` };
  }

  return { valid: true };
};

/**
 * Valida un número entero positivo
 */
export const validatePositiveInteger = (value: number | string, fieldName: string = 'Valor'): ValidationResult => {
  const numValue = typeof value === 'string' ? parseInt(value, 10) : value;

  if (isNaN(numValue) || !Number.isInteger(numValue)) {
    return { valid: false, error: `${fieldName} debe ser un número entero válido` };
  }

  if (numValue < 0) {
    return { valid: false, error: `${fieldName} debe ser un número positivo` };
  }

  return { valid: true };
};

/**
 * Valida un archivo de imagen
 */
export const validateImageFile = (
  file: File,
  options?: {
    maxSizeMB?: number;
    allowedTypes?: string[];
    maxWidth?: number;
    maxHeight?: number;
  }
): ValidationResult => {
  const maxSizeMB = options?.maxSizeMB || 10;
  const allowedTypes = options?.allowedTypes || ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  const maxSizeBytes = maxSizeMB * 1024 * 1024;

  // Validar tipo
  if (!allowedTypes.includes(file.type)) {
    const allowedExtensions = allowedTypes
      .map(t => t.split('/')[1].toUpperCase())
      .join(', ');
    return {
      valid: false,
      error: `Tipo de archivo no válido. Solo se permiten: ${allowedExtensions}`
    };
  }

  // Validar tamaño
  if (file.size > maxSizeBytes) {
    return {
      valid: false,
      error: `El archivo es demasiado grande. Máximo ${maxSizeMB}MB (actual: ${(file.size / 1024 / 1024).toFixed(2)}MB)`
    };
  }

  // Validar que el archivo no esté vacío
  if (file.size === 0) {
    return { valid: false, error: 'El archivo está vacío' };
  }

  return { valid: true };
};

/**
 * Valida múltiples archivos
 */
export const validateImageFiles = (
  files: FileList | File[],
  options?: {
    maxSizeMB?: number;
    allowedTypes?: string[];
    maxFiles?: number;
  }
): ValidationResult => {
  const fileArray = Array.from(files);
  const maxFiles = options?.maxFiles || 50;

  if (fileArray.length === 0) {
    return { valid: false, error: 'No se seleccionaron archivos' };
  }

  if (fileArray.length > maxFiles) {
    return {
      valid: false,
      error: `Demasiados archivos. Máximo ${maxFiles} archivos por lote`
    };
  }

  // Validar cada archivo
  for (const file of fileArray) {
    const validation = validateImageFile(file, options);
    if (!validation.valid) {
      return {
        valid: false,
        error: `${file.name}: ${validation.error}`
      };
    }
  }

  return { valid: true };
};

/**
 * Valida un rango de fechas
 */
export const validateDateRange = (
  fechaDesde: string | Date | null,
  fechaHasta: string | Date | null
): ValidationResult => {
  if (!fechaDesde || !fechaHasta) {
    return { valid: true }; // Rango opcional
  }

  const desde = fechaDesde instanceof Date ? fechaDesde : new Date(fechaDesde);
  const hasta = fechaHasta instanceof Date ? fechaHasta : new Date(fechaHasta);

  if (isNaN(desde.getTime())) {
    return { valid: false, error: 'Fecha desde no es válida' };
  }

  if (isNaN(hasta.getTime())) {
    return { valid: false, error: 'Fecha hasta no es válida' };
  }

  if (desde > hasta) {
    return { valid: false, error: 'La fecha desde debe ser anterior a la fecha hasta' };
  }

  // Validar que el rango no sea mayor a 1 año
  const diffDays = Math.abs((hasta.getTime() - desde.getTime()) / (1000 * 60 * 60 * 24));
  if (diffDays > 365) {
    return { valid: false, error: 'El rango de fechas no puede ser mayor a 1 año' };
  }

  return { valid: true };
};

/**
 * Valida un rango de porcentajes
 */
export const validatePercentageRange = (
  min: number | string,
  max: number | string
): ValidationResult => {
  const minValidation = validatePercentage(min, 'Porcentaje mínimo');
  if (!minValidation.valid) {
    return minValidation;
  }

  const maxValidation = validatePercentage(max, 'Porcentaje máximo');
  if (!maxValidation.valid) {
    return maxValidation;
  }

  const minValue = typeof min === 'string' ? parseFloat(min) : min;
  const maxValue = typeof max === 'string' ? parseFloat(max) : max;

  if (minValue > maxValue) {
    return { valid: false, error: 'El porcentaje mínimo debe ser menor o igual al máximo' };
  }

  return { valid: true };
};

/**
 * Sanitiza un string para prevenir inyección SQL (básico)
 */
export const sanitizeString = (input: string): string => {
  if (!input) return '';
  
  // Remover caracteres peligrosos
  return input
    .replace(/[<>]/g, '') // Remover < y >
    .trim();
};

/**
 * Valida y sanitiza un ID numérico
 */
export const validateId = (id: number | string | null | undefined, fieldName: string = 'ID'): ValidationResult => {
  if (id === null || id === undefined || id === '') {
    return { valid: false, error: `${fieldName} es requerido` };
  }

  const numId = typeof id === 'string' ? parseInt(id, 10) : id;

  if (isNaN(numId) || !Number.isInteger(numId)) {
    return { valid: false, error: `${fieldName} debe ser un número entero válido` };
  }

  if (numId <= 0) {
    return { valid: false, error: `${fieldName} debe ser un número positivo` };
  }

  return { valid: true };
};

