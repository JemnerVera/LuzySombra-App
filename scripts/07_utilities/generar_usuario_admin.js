/**
 * Script para generar hash de contraseña e insertar usuario admin
 * 
 * Uso:
 *   node scripts/07_utilities/generar_usuario_admin.js
 * 
 * O con parámetros:
 *   node scripts/07_utilities/generar_usuario_admin.js admin password123 admin@example.com
 */

const bcrypt = require('bcrypt');

// Parámetros (pueden pasarse como argumentos o usar valores por defecto)
const username = process.argv[2] || 'admin';
const password = process.argv[3] || 'admin123';
const email = process.argv[4] || 'admin@luzsombra.com';
const nombreCompleto = process.argv[5] || 'Administrador';
const rol = process.argv[6] || 'Admin';

const bcryptRounds = 10;

async function generarUsuario() {
  try {
    console.log('🔐 Generando hash de contraseña...');
    const passwordHash = await bcrypt.hash(password, bcryptRounds);
    
    console.log('\n✅ Hash generado exitosamente\n');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('  DATOS DEL USUARIO');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log(`Username:     ${username}`);
    console.log(`Password:     ${password}`);
    console.log(`Email:        ${email}`);
    console.log(`Nombre:       ${nombreCompleto}`);
    console.log(`Rol:          ${rol}`);
    console.log('\n═══════════════════════════════════════════════════════════════════');
    console.log('  SCRIPT SQL PARA EJECUTAR EN SSMS');
    console.log('═══════════════════════════════════════════════════════════════════\n');
    
    // Escapar comillas simples en los valores
    const usernameEscaped = username.replace(/'/g, "''");
    const emailEscaped = email.replace(/'/g, "''");
    const nombreEscaped = nombreCompleto.replace(/'/g, "''");
    const hashEscaped = passwordHash.replace(/'/g, "''");
    
    console.log(`USE BD_PACKING_AGROMIGIVA_DESA;`);
    console.log(`GO`);
    console.log(``);
    console.log(`-- Insertar usuario admin`);
    console.log(`IF NOT EXISTS (SELECT 1 FROM evalImagen.UsuarioWeb WHERE username = '${usernameEscaped}')`);
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
    console.log(`        '${usernameEscaped}',`);
    console.log(`        '${hashEscaped}',`);
    console.log(`        '${emailEscaped}',`);
    console.log(`        '${nombreEscaped}',`);
    console.log(`        '${rol}',`);
    console.log(`        1, -- activo`);
    console.log(`        1, -- statusID`);
    console.log(`        NULL -- usuarioCreaID`);
    console.log(`    );`);
    console.log(`    `);
    console.log(`    PRINT '✅ Usuario ${usernameEscaped} creado exitosamente';`);
    console.log(`END`);
    console.log(`ELSE`);
    console.log(`BEGIN`);
    console.log(`    PRINT '⚠️  Usuario ${usernameEscaped} ya existe';`);
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
    console.log(`WHERE username = '${usernameEscaped}';`);
    console.log(`GO`);
    
    console.log('\n═══════════════════════════════════════════════════════════════════');
    console.log('  ✅ LISTO');
    console.log('═══════════════════════════════════════════════════════════════════');
    console.log('\n📋 Copia y pega el script SQL de arriba en SSMS para crear el usuario.\n');
    
  } catch (error) {
    console.error('❌ Error generando hash:', error);
    process.exit(1);
  }
}

generarUsuario();

