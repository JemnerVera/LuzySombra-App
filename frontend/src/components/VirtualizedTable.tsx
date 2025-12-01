import React, { useMemo } from 'react';
import { FixedSizeList as List } from 'react-window';

interface VirtualizedTableProps<T> {
  data: T[];
  columns: Array<{
    header: string;
    accessor: (row: T) => React.ReactNode;
    width?: number;
  }>;
  rowHeight?: number;
  height?: number;
  className?: string;
}

/**
 * Tabla virtualizada para renderizar grandes cantidades de datos eficientemente
 */
function VirtualizedTable<T extends { id: string | number }>({
  data,
  columns,
  rowHeight = 50,
  height = 600,
  className = ''
}: VirtualizedTableProps<T>) {
  const totalWidth = useMemo(() => {
    return columns.reduce((sum, col) => sum + (col.width || 150), 0);
  }, [columns]);

  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => {
    const row = data[index];
    if (!row) return null;

    return (
      <div
        style={style}
        className={`flex items-center border-b border-gray-200 dark:border-dark-700 hover:bg-gray-50 dark:hover:bg-dark-800 transition-colors ${
          index % 2 === 0 ? 'bg-white dark:bg-dark-900' : 'bg-gray-50 dark:bg-dark-800'
        }`}
      >
        {columns.map((column, colIndex) => (
          <div
            key={colIndex}
            className="px-4 py-2 text-sm text-gray-900 dark:text-white"
            style={{ width: column.width || 150, minWidth: column.width || 150 }}
          >
            {column.accessor(row)}
          </div>
        ))}
      </div>
    );
  };

  return (
    <div className={`border border-gray-200 dark:border-dark-700 rounded-lg overflow-hidden ${className}`}>
      {/* Header */}
      <div className="flex items-center bg-gray-50 dark:bg-dark-800 border-b border-gray-200 dark:border-dark-700 sticky top-0 z-10">
        {columns.map((column, index) => (
          <div
            key={index}
            className="px-4 py-3 text-xs font-medium text-gray-500 dark:text-dark-400 uppercase tracking-wider"
            style={{ width: column.width || 150, minWidth: column.width || 150 }}
          >
            {column.header}
          </div>
        ))}
      </div>

      {/* Virtualized list */}
      <List
        height={height}
        itemCount={data.length}
        itemSize={rowHeight}
        width={totalWidth}
        overscanCount={5} // Renderizar 5 items extra fuera de la vista
      >
        {Row}
      </List>
    </div>
  );
}

export default VirtualizedTable;

