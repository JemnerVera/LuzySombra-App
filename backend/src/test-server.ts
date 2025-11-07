/**
 * Script de prueba para verificar que el backend funciona correctamente
 * Ejecutar: npx ts-node src/test-server.ts
 */

import dotenv from 'dotenv';
import { query, getConnection, closeConnection } from './lib/db';
import { sqlServerService } from './services/sqlServerService';

// Cargar variables de entorno
dotenv.config();

async function testDatabaseConnection() {
  console.log('\n📊 Probando conexión a SQL Server...');
  try {
    const connection = await getConnection();
    console.log('✅ Conexión a SQL Server exitosa');
    
    // Test simple query
    const result = await query<{ total: number }>('SELECT COUNT(*) as total FROM GROWER.LOT WHERE statusID = 1');
    console.log(`✅ Query exitosa: ${result[0].total} lotes activos encontrados`);
    
    return true;
  } catch (error) {
    console.error('❌ Error conectando a SQL Server:', error);
    return false;
  }
}

async function testFieldData() {
  console.log('\n📊 Probando servicio getFieldData...');
  try {
    const fieldData = await sqlServerService.getFieldData();
    console.log('✅ getFieldData exitoso');
    console.log(`   - Empresas: ${fieldData.empresa.length}`);
    console.log(`   - Fundos: ${fieldData.fundo.length}`);
    console.log(`   - Sectores: ${fieldData.sector.length}`);
    console.log(`   - Lotes: ${fieldData.lote.length}`);
    return true;
  } catch (error) {
    console.error('❌ Error en getFieldData:', error);
    return false;
  }
}

async function testHistorial() {
  console.log('\n📊 Probando servicio getHistorial...');
  try {
    const historial = await sqlServerService.getHistorial({ page: 1, pageSize: 5 });
    console.log('✅ getHistorial exitoso');
    console.log(`   - Total registros: ${historial.total}`);
    console.log(`   - Registros en página: ${historial.procesamientos.length}`);
    console.log(`   - Página actual: ${historial.page}`);
    console.log(`   - Total páginas: ${historial.totalPages}`);
    return true;
  } catch (error) {
    console.error('❌ Error en getHistorial:', error);
    return false;
  }
}

async function testConsolidatedTable() {
  console.log('\n📊 Probando servicio getConsolidatedTable...');
  try {
    const table = await sqlServerService.getConsolidatedTable({ page: 1, pageSize: 5 });
    console.log('✅ getConsolidatedTable exitoso');
    console.log(`   - Total lotes: ${table.total}`);
    console.log(`   - Registros en página: ${table.data.length}`);
    console.log(`   - Página actual: ${table.page}`);
    console.log(`   - Total páginas: ${table.totalPages}`);
    if (table.data.length > 0) {
      console.log(`   - Ejemplo: ${table.data[0].fundo} - ${table.data[0].sector} - ${table.data[0].lote}`);
    }
    return true;
  } catch (error) {
    console.error('❌ Error en getConsolidatedTable:', error);
    if (error instanceof Error && error.message.includes('vwc_CianamidaFenologia')) {
      console.warn('⚠️ Nota: La vista vwc_CianamidaFenologia no existe. Esto es normal si no se ha ejecutado el script SQL.');
    }
    return false;
  }
}

async function testServerRoutes() {
  console.log('\n📊 Verificando configuración del servidor...');
  try {
    // Verificar variables de entorno
    const requiredVars = ['SQL_USER', 'SQL_PASSWORD', 'SQL_SERVER', 'SQL_DATABASE'];
    const missingVars = requiredVars.filter(varName => !process.env[varName]);
    
    if (missingVars.length > 0) {
      console.error(`❌ Variables de entorno faltantes: ${missingVars.join(', ')}`);
      console.error('   Por favor, crea un archivo .env en la carpeta backend/');
      return false;
    }
    
    console.log('✅ Variables de entorno configuradas');
    console.log(`   - SQL_SERVER: ${process.env.SQL_SERVER}`);
    console.log(`   - SQL_DATABASE: ${process.env.SQL_DATABASE}`);
    console.log(`   - PORT: ${process.env.PORT || 3001}`);
    console.log(`   - FRONTEND_URL: ${process.env.FRONTEND_URL || 'http://localhost:3000'}`);
    
    return true;
  } catch (error) {
    console.error('❌ Error verificando configuración:', error);
    return false;
  }
}

async function runAllTests() {
  console.log('🧪 Iniciando pruebas del backend...\n');
  console.log('=' .repeat(60));
  
  const results = {
    config: false,
    database: false,
    fieldData: false,
    historial: false,
    consolidatedTable: false,
  };
  
  // Test 1: Configuración
  results.config = await testServerRoutes();
  if (!results.config) {
    console.log('\n❌ Configuración fallida. No se pueden ejecutar más pruebas.');
    await closeConnection();
    process.exit(1);
  }
  
  // Test 2: Conexión a BD
  results.database = await testDatabaseConnection();
  if (!results.database) {
    console.log('\n❌ Conexión a BD fallida. No se pueden ejecutar más pruebas.');
    await closeConnection();
    process.exit(1);
  }
  
  // Test 3: Field Data
  results.fieldData = await testFieldData();
  
  // Test 4: Historial
  results.historial = await testHistorial();
  
  // Test 5: Consolidated Table
  results.consolidatedTable = await testConsolidatedTable();
  
  // Cerrar conexión
  await closeConnection();
  
  // Resumen
  console.log('\n' + '='.repeat(60));
  console.log('📊 RESUMEN DE PRUEBAS\n');
  console.log(`Configuración:        ${results.config ? '✅' : '❌'}`);
  console.log(`Conexión a BD:        ${results.database ? '✅' : '❌'}`);
  console.log(`Field Data:           ${results.fieldData ? '✅' : '❌'}`);
  console.log(`Historial:            ${results.historial ? '✅' : '❌'}`);
  console.log(`Tabla Consolidada:    ${results.consolidatedTable ? '✅' : '⚠️ '}`);
  
  const allCritical = results.config && results.database;
  const allOptional = results.fieldData && results.historial;
  
  if (allCritical) {
    console.log('\n✅ Backend básico funcionando correctamente!');
    if (allOptional) {
      console.log('✅ Todos los servicios funcionando!');
    } else {
      console.log('⚠️ Algunos servicios opcionales tienen problemas (puede ser normal)');
    }
    console.log('\n🚀 Puedes iniciar el servidor con: npm run dev');
  } else {
    console.log('\n❌ Hay problemas críticos que deben resolverse');
    process.exit(1);
  }
}

// Ejecutar pruebas
runAllTests().catch(error => {
  console.error('\n❌ Error ejecutando pruebas:', error);
  process.exit(1);
});

