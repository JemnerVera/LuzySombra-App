import sql from 'mssql';

const config: sql.config = {
  user: process.env.SQL_USER || 'agricola_app',
  password: process.env.SQL_PASSWORD || 'Agricola2024!',
  server: process.env.SQL_SERVER || 'localhost\\SQLEXPRESS',
  database: process.env.SQL_DATABASE || 'AgricolaDB',
  port: parseInt(process.env.SQL_PORT || '1433'),
  
  options: {
    trustServerCertificate: true,
    enableArithAbort: true,
    encrypt: false, // Para conexión local sin SSL
  },
  
  // Pool de conexiones
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

let pool: sql.ConnectionPool | null = null;

/**
 * Obtiene una conexión del pool de SQL Server
 */
export async function getConnection(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config);
    console.log('✅ Conectado a SQL Server:', config.database);
  }
  return pool;
}

/**
 * Ejecuta una query SQL con parámetros opcionales
 * @param queryText - Query SQL a ejecutar
 * @param params - Objeto con parámetros para la query
 * @returns Array de resultados
 */
export async function query<T = any>(
  queryText: string,
  params?: Record<string, any>
): Promise<T[]> {
  try {
    const connection = await getConnection();
    const request = connection.request();
    
    // Agregar parámetros si existen
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        request.input(key, value);
      });
    }
    
    const result = await request.query(queryText);
    return result.recordset as T[];
  } catch (error) {
    console.error('❌ Error en query SQL:', error);
    throw error;
  }
}

/**
 * Ejecuta un stored procedure con parámetros
 * @param procedureName - Nombre del stored procedure
 * @param params - Objeto con parámetros para el SP
 * @returns Resultado del stored procedure
 */
export async function executeProcedure<T = any>(
  procedureName: string,
  params?: Record<string, any>
): Promise<T> {
  try {
    const connection = await getConnection();
    const request = connection.request();
    
    // Agregar parámetros si existen
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        request.input(key, value);
      });
    }
    
    const result = await request.execute(procedureName);
    return result.recordset as T;
  } catch (error) {
    console.error('❌ Error ejecutando stored procedure:', error);
    throw error;
  }
}

/**
 * Cierra la conexión al pool (usar solo cuando la app se cierra)
 */
export async function closeConnection(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
    console.log('🔌 Conexión a SQL Server cerrada');
  }
}

// Exportar el objeto sql para tipos y utilidades
export { sql };

// Alias para compatibilidad
export const connectDb = getConnection;

