/**
 * Utilidades para exportar datos a PDF
 */
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

export interface PDFOptions {
  title?: string;
  subtitle?: string;
  filename?: string;
  orientation?: 'portrait' | 'landscape';
  author?: string;
  subject?: string;
}

/**
 * Exporta una tabla a PDF
 */
export const exportTableToPDF = (
  data: Record<string, unknown>[],
  columns: Array<{ header: string; dataKey: string }>,
  options: PDFOptions = {}
): void => {
  if (data.length === 0) {
    throw new Error('No hay datos para exportar');
  }

  const {
    title = 'Reporte',
    subtitle,
    filename = `reporte_${new Date().toISOString().split('T')[0]}.pdf`,
    orientation = 'portrait',
    author = 'Sistema LuzSombra',
    subject = 'Reporte de datos'
  } = options;

  const doc = new jsPDF({
    orientation,
    unit: 'mm',
    format: 'a4'
  });

  // Configurar metadatos
  doc.setProperties({
    title,
    author,
    subject
  });

  // Título
  doc.setFontSize(18);
  doc.text(title, 14, 20);

  // Subtítulo
  if (subtitle) {
    doc.setFontSize(12);
    doc.setTextColor(100, 100, 100);
    doc.text(subtitle, 14, 28);
    doc.setTextColor(0, 0, 0);
  }

  // Fecha de generación
  const fecha = new Date().toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
  doc.setFontSize(10);
  doc.setTextColor(100, 100, 100);
  doc.text(`Generado el: ${fecha}`, 14, orientation === 'portrait' ? 35 : 25);
  doc.setTextColor(0, 0, 0);

  // Preparar datos para la tabla
  const tableData = data.map(row => 
    columns.map(col => {
      const value = row[col.dataKey];
      if (value === null || value === undefined) return '';
      if (typeof value === 'number') return value.toLocaleString('es-ES');
      if (value instanceof Date) return value.toLocaleDateString('es-ES');
      return String(value);
    })
  );

  const tableHeaders = columns.map(col => col.header);

  // Agregar tabla
  autoTable(doc, {
    head: [tableHeaders],
    body: tableData,
    startY: orientation === 'portrait' ? 40 : 30,
    styles: {
      fontSize: 9,
      cellPadding: 3
    },
    headStyles: {
      fillColor: [59, 130, 246], // Blue
      textColor: 255,
      fontStyle: 'bold'
    },
    alternateRowStyles: {
      fillColor: [249, 250, 251] // Light gray
    },
    margin: { top: 10, right: 14, bottom: 10, left: 14 }
  });

  // Guardar PDF
  doc.save(filename);
};

/**
 * Exporta estadísticas a PDF
 */
export const exportStatisticsToPDF = (
  statistics: {
    general: {
      totalAnalisis: number;
      totalLotes: number;
      promedioLuz: number;
      promedioSombra: number;
    };
    porFundo: Array<{
      fundo: string;
      total: number;
      promedioLuz: number;
      promedioSombra: number;
    }>;
  },
  options: PDFOptions = {}
): void => {
  const {
    title = 'Reporte de Estadísticas',
    filename = `estadisticas_${new Date().toISOString().split('T')[0]}.pdf`,
    orientation = 'portrait'
  } = options;

  const doc = new jsPDF({
    orientation,
    unit: 'mm',
    format: 'a4'
  });

  // Título
  doc.setFontSize(18);
  doc.text(title, 14, 20);

  // Fecha
  const fecha = new Date().toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
  doc.setFontSize(10);
  doc.setTextColor(100, 100, 100);
  doc.text(`Generado el: ${fecha}`, 14, 28);
  doc.setTextColor(0, 0, 0);

  let startY = 35;

  // Estadísticas generales
  doc.setFontSize(14);
  doc.text('Estadísticas Generales', 14, startY);
  startY += 10;

  const generalData = [
    ['Total Análisis', statistics.general.totalAnalisis.toLocaleString()],
    ['Total Lotes', statistics.general.totalLotes.toLocaleString()],
    ['Promedio % Luz', `${statistics.general.promedioLuz.toFixed(2)}%`],
    ['Promedio % Sombra', `${statistics.general.promedioSombra.toFixed(2)}%`]
  ];

  autoTable(doc, {
    head: [['Métrica', 'Valor']],
    body: generalData,
    startY,
    styles: {
      fontSize: 10,
      cellPadding: 4
    },
    headStyles: {
      fillColor: [59, 130, 246],
      textColor: 255,
      fontStyle: 'bold'
    },
    margin: { top: 10, right: 14, bottom: 10, left: 14 }
  });

  startY = (doc as any).lastAutoTable.finalY + 15;

  // Estadísticas por fundo
  if (statistics.porFundo.length > 0) {
    doc.setFontSize(14);
    doc.text('Estadísticas por Fundo', 14, startY);
    startY += 10;

    const fundoData = statistics.porFundo.map(f => [
      f.fundo,
      f.total.toLocaleString(),
      `${f.promedioLuz.toFixed(2)}%`,
      `${f.promedioSombra.toFixed(2)}%`
    ]);

    autoTable(doc, {
      head: [['Fundo', 'Total Análisis', 'Promedio % Luz', 'Promedio % Sombra']],
      body: fundoData,
      startY,
      styles: {
        fontSize: 9,
        cellPadding: 3
      },
      headStyles: {
        fillColor: [59, 130, 246],
        textColor: 255,
        fontStyle: 'bold'
      },
      alternateRowStyles: {
        fillColor: [249, 250, 251]
      },
      margin: { top: 10, right: 14, bottom: 10, left: 14 }
    });
  }

  // Guardar PDF
  doc.save(filename);
};

/**
 * Exporta historial a PDF
 */
export const exportHistoryToPDF = (
  history: Array<Record<string, unknown>>,
  options: PDFOptions = {}
): void => {
  if (history.length === 0) {
    throw new Error('No hay datos para exportar');
  }

  const columns = [
    { header: 'Fecha', dataKey: 'fecha' },
    { header: 'Hora', dataKey: 'hora' },
    { header: 'Empresa', dataKey: 'empresa' },
    { header: 'Fundo', dataKey: 'fundo' },
    { header: 'Sector', dataKey: 'sector' },
    { header: 'Lote', dataKey: 'lote' },
    { header: '% Luz', dataKey: 'porcentaje_luz' },
    { header: '% Sombra', dataKey: 'porcentaje_sombra' }
  ];

  exportTableToPDF(history, columns, {
    title: 'Historial de Procesamiento',
    subtitle: `${history.length} registros`,
    filename: `historial_${new Date().toISOString().split('T')[0]}.pdf`,
    orientation: 'landscape',
    ...options
  });
};

