/**
 * Script simple para generar hash de contraseña usando bcrypt
 * 
 * Uso:
 *   node scripts/generar_hash_password.js [password]
 * 
 * Ejemplo:
 *   node scripts/generar_hash_password.js admin123
 */

const bcrypt = require('bcrypt');

// Obtener contraseña de argumentos o usar valor por defecto
const password = process.argv[2] || 'admin123';

async function generarHash() {
  try {
    console.log('🔐 Generando hash de contraseña...');
    console.log(`   Password: ${password}`);
    console.log('');
    
    // Generar hash con 10 rounds (recomendado)
    const saltRounds = 10;
    const hash = await bcrypt.hash(password, saltRounds);
    
    console.log('✅ Hash generado exitosamente');
    console.log('');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('  HASH GENERADO');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('');
    console.log(hash);
    console.log('');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('  SCRIPT SQL PARA INSERTAR USUARIO');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('');
    console.log(`USE [TU_BASE_DE_DATOS];`);
    console.log(`GO`);
    console.log(``);
    console.log(`IF NOT EXISTS (SELECT 1 FROM evalImagen.UsuarioWeb WHERE username = 'admin')`);
    console.log(`BEGIN`);
    console.log(`    INSERT INTO evalImagen.UsuarioWeb (`);
    console.log(`        username,`);
    console.log(`        passwordHash,`);
    console.log(`        email,`);
    console.log(`        nombreCompleto,`);
    console.log(`        rol,`);
    console.log(`        activo,`);
    console.log(`        statusID,`);
    console.log(`        usuarioCreaID`);
    console.log(`    ) VALUES (`);
    console.log(`        'admin',`);
    console.log(`        '${hash}',`);
    console.log(`        'admin@luzsombra.com',`);
    console.log(`        'Administrador',`);
    console.log(`        'Admin',`);
    console.log(`        1, -- activo`);
    console.log(`        1, -- statusID`);
    console.log(`        NULL -- usuarioCreaID`);
    console.log(`    );`);
    console.log(`    PRINT '✅ Usuario admin creado exitosamente';`);
    console.log(`END`);
    console.log(`ELSE`);
    console.log(`BEGIN`);
    console.log(`    PRINT '⚠️  Usuario admin ya existe';`);
    console.log(`END`);
    console.log(`GO`);
    console.log(``);
    console.log(`-- Verificar usuario creado`);
    console.log(`SELECT `);
    console.log(`    usuarioID,`);
    console.log(`    username,`);
    console.log(`    email,`);
    console.log(`    nombreCompleto,`);
    console.log(`    rol,`);
    console.log(`    activo,`);
    console.log(`    fechaCreacion`);
    console.log(`FROM evalImagen.UsuarioWeb`);
    console.log(`WHERE username = 'admin';`);
    console.log(`GO`);
    console.log('');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('  ✅ LISTO');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('\n📋 Copia y pega el script SQL de arriba en SSMS para crear el usuario.\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error generando hash:', error);
    process.exit(1);
  }
}

generarHash();

