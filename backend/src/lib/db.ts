import sql from 'mssql';
import dotenv from 'dotenv';

// Cargar variables de entorno
dotenv.config();

// Validar que todas las variables de entorno requeridas estén presentes
const requiredEnvVars = ['SQL_USER', 'SQL_PASSWORD', 'SQL_SERVER', 'SQL_DATABASE'];
const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0) {
  throw new Error(
    `❌ Variables de entorno SQL Server faltantes: ${missingVars.join(', ')}\n` +
    `Por favor, configura las variables en .env. Ver .env.example para referencia.`
  );
}

// Log de configuración solo en modo desarrollo
if (process.env.NODE_ENV === 'development') {
  console.log(`🔧 [DB] Conectando a SQL Server: ${process.env.SQL_SERVER}/${process.env.SQL_DATABASE}`);
}

const config: sql.config = {
  user: process.env.SQL_USER!,
  password: process.env.SQL_PASSWORD!,
  server: process.env.SQL_SERVER!,
  database: process.env.SQL_DATABASE!,
  port: parseInt(process.env.SQL_PORT || '1433'),
  
  options: {
    trustServerCertificate: true,
    enableArithAbort: true,
    // Encriptar para servidor remoto (AgroMigiva), pero permitir desactivar para desarrollo local
    encrypt: process.env.SQL_ENCRYPT !== 'false',
    requestTimeout: 60000, // 60 segundos timeout para requests (para queries complejas)
    connectTimeout: 30000, // 30 segundos timeout para establecer conexión
    // Evitar warning de TLS ServerName con IP: usar hostname si es IP
    // Para IPs privadas, trustServerCertificate ya está en true, así que esto es solo para evitar el warning
  },
  
  // Pool de conexiones
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

// Constantes para evitar problemas de TypeScript con config.options
const CONNECT_TIMEOUT = config.options?.connectTimeout || 30000;
const REQUEST_TIMEOUT = config.options?.requestTimeout || 60000;
const ENCRYPT = config.options?.encrypt ?? (process.env.SQL_ENCRYPT !== 'false');
const TRUST_SERVER_CERT = config.options?.trustServerCertificate ?? true;

let pool: sql.ConnectionPool | null = null;
let connectionAttempts = 0;
const maxConnectionAttempts = 3;

/**
 * Obtiene una conexión del pool de SQL Server
 */
export async function getConnection(): Promise<sql.ConnectionPool> {
  if (pool && pool.connected) {
    return pool;
  }

  connectionAttempts++;
  
  try {
    pool = await sql.connect(config);
    
    if (process.env.NODE_ENV === 'development') {
      console.log(`✅ [DB] Conectado a SQL Server: ${config.server}/${config.database}`);
    }
    
    connectionAttempts = 0; // Reset counter on success
    return pool;
  } catch (error: any) {
    console.error(`❌ [DB] Error conectando a SQL Server:`, error.message || error);
    
    if (error.code === 'ESOCKET') {
      console.error(`   💡 Verificar: VPN conectada, firewall, servidor accesible`);
    }
    
    pool = null;
    throw error;
  }
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
    
    // Verificar que la conexión esté activa
    if (!connection.connected) {
      pool = null; // Forzar reconexión
      await getConnection();
    }
    
    const request = connection.request();
    
    // Agregar parámetros si existen
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        request.input(key, value);
      });
    }
    
    const result = await request.query(queryText);
    return result.recordset as T[];
  } catch (error: any) {
    console.error(`❌ [DB] Error en query:`, error.message || error);
    
    // Si es error de conexión, resetear pool
    if (error.code === 'ESOCKET' || error.code === 'ECONNRESET') {
      pool = null;
    }
    
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

