# Guía: Conectar Next.js a SQL Server Express

## 📋 Prerequisitos

✅ SQL Server Express instalado y corriendo (ya lo tienes)
✅ Base de datos `AgricolaDB` creada con datos (ya está lista)
✅ Node.js y npm instalados (ya los tienes)

---

## 🚀 Paso 1: Instalar el driver SQL Server

```bash
npm install mssql
npm install --save-dev @types/mssql
```

---

## 🔧 Paso 2: Configurar variables de entorno

Actualiza tu archivo `.env.local` con la configuración de SQL Server:

```env
# Configuración de Google Sheets (ya existente)
GOOGLE_SHEETS_SPREADSHEET_ID=...
GOOGLE_SHEETS_CREDENTIALS_BASE64=...
GOOGLE_SHEETS_TOKEN_BASE64=...
NEXT_PUBLIC_API_URL=http://localhost:3000

# === NUEVA CONFIGURACIÓN SQL SERVER ===
# Servidor SQL Server Express local
SQL_SERVER=localhost\\SQLEXPRESS
SQL_DATABASE=AgricolaDB
SQL_PORT=1433

# Autenticación Windows (la que estás usando actualmente)
SQL_TRUSTED_CONNECTION=true

# Alternativa: Autenticación SQL Server (si creas usuarios SQL)
# SQL_USER=tu_usuario
# SQL_PASSWORD=tu_password
```

---

## 📁 Paso 3: Crear utilidad de conexión

Crea el archivo `lib/db.ts`:

```typescript
import sql from 'mssql';

const config: sql.config = {
  server: process.env.SQL_SERVER || 'localhost\\SQLEXPRESS',
  database: process.env.SQL_DATABASE || 'AgricolaDB',
  port: parseInt(process.env.SQL_PORT || '1433'),
  
  // Autenticación Windows
  options: {
    trustedConnection: process.env.SQL_TRUSTED_CONNECTION === 'true',
    trustServerCertificate: true, // Para desarrollo local
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

export async function getConnection(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config);
    console.log('✅ Conectado a SQL Server');
  }
  return pool;
}

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

export { sql };
```

---

## 🧪 Paso 4: Crear API de prueba

Crea el archivo `app/api/test-db/route.ts`:

```typescript
import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Test 1: Contar registros
    const counts = await query(`
      SELECT 
        (SELECT COUNT(*) FROM image.pais) as paises,
        (SELECT COUNT(*) FROM image.empresa) as empresas,
        (SELECT COUNT(*) FROM image.fundo) as fundos,
        (SELECT COUNT(*) FROM image.sector) as sectores,
        (SELECT COUNT(*) FROM image.lote) as lotes,
        (SELECT COUNT(*) FROM image.usuario) as usuarios
    `);
    
    return NextResponse.json({
      success: true,
      message: 'Conexión exitosa a SQL Server',
      data: counts[0],
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        success: false,
        message: 'Error conectando a SQL Server',
        error: error.message,
      },
      { status: 500 }
    );
  }
}
```

---

## 🎯 Paso 5: Probar la conexión

1. **Instala las dependencias:**
   ```bash
   npm install
   ```

2. **Inicia el servidor de desarrollo:**
   ```bash
   npm run dev
   ```

3. **Prueba la conexión:**
   ```
   http://localhost:3000/api/test-db
   ```

   Deberías ver algo como:
   ```json
   {
     "success": true,
     "message": "Conexión exitosa a SQL Server",
     "data": {
       "paises": 1,
       "empresas": 5,
       "fundos": 12,
       "sectores": 270,
       "lotes": 509,
       "usuarios": 3
     }
   }
   ```

---

## 🔐 Configuración de Seguridad para Producción

### Si despliegas a producción, considera:

1. **Usar autenticación SQL Server** (no Windows):
   ```sql
   -- Crear usuario SQL
   CREATE LOGIN agricola_app WITH PASSWORD = 'TuPasswordSeguro123!';
   USE AgricolaDB;
   CREATE USER agricola_app FOR LOGIN agricola_app;
   
   -- Dar permisos
   ALTER ROLE db_datareader ADD MEMBER agricola_app;
   ALTER ROLE db_datawriter ADD MEMBER agricola_app;
   ```

2. **Actualizar `.env.local`:**
   ```env
   SQL_TRUSTED_CONNECTION=false
   SQL_USER=agricola_app
   SQL_PASSWORD=TuPasswordSeguro123!
   ```

3. **Habilitar TCP/IP en SQL Server:**
   - Abrir **SQL Server Configuration Manager**
   - Ir a **SQL Server Network Configuration** > **Protocols for SQLEXPRESS**
   - Habilitar **TCP/IP**
   - Reiniciar servicio SQL Server

---

## 📚 Ejemplos de Uso

### Obtener jerarquía completa:
```typescript
import { query } from '@/lib/db';

export async function getJerarquia() {
  return await query(`
    SELECT * FROM image.v_jerarquia_completa
    ORDER BY empresa, fundo, sector, lote
  `);
}
```

### Obtener lotes por empresa:
```typescript
export async function getLotesByEmpresa(empresaId: number) {
  return await query(
    `SELECT * FROM image.lote l
     INNER JOIN image.sector s ON l.sectorid = s.sectorid
     INNER JOIN image.fundo f ON s.fundoid = f.fundoid
     WHERE f.empresaid = @empresaId`,
    { empresaId }
  );
}
```

### Insertar análisis de imagen:
```typescript
export async function insertAnalisis(data: {
  loteid: number;
  hilera: string;
  planta: string;
  filename: string;
  porcentaje_luz: number;
  porcentaje_sombra: number;
  usercreatedid: number;
}) {
  return await query(
    `INSERT INTO image.analisis_imagen 
     (loteid, hilera, planta, filename, porcentaje_luz, porcentaje_sombra, 
      fecha_captura, usercreatedid)
     VALUES 
     (@loteid, @hilera, @planta, @filename, @porcentaje_luz, @porcentaje_sombra,
      GETDATE(), @usercreatedid)`,
    data
  );
}
```

---

## 🐛 Troubleshooting

### Error: "Login failed for user"
- Verifica que el servicio SQL Server esté corriendo
- Asegúrate de usar autenticación Windows (`SQL_TRUSTED_CONNECTION=true`)
- O configura usuario SQL Server correctamente

### Error: "Unable to connect"
- Verifica que SQL Server Express esté corriendo:
  ```powershell
  Get-Service | Where-Object {$_.Name -like '*SQL*'}
  ```
- Verifica el firewall de Windows
- Asegúrate de que TCP/IP esté habilitado

### Error: "Invalid object name"
- Verifica que estás usando el schema correcto: `image.tabla`
- Verifica que la base de datos sea `AgricolaDB`

---

## ✅ Checklist Final

- [ ] Driver `mssql` instalado
- [ ] Variables de entorno configuradas en `.env.local`
- [ ] Archivo `lib/db.ts` creado
- [ ] API de prueba `app/api/test-db/route.ts` creada
- [ ] Conexión probada exitosamente
- [ ] SQL Server Express corriendo

---

## 🎉 ¡Listo!

Tu app Next.js ya puede conectarse a SQL Server Express y usar toda la jerarquía organizacional y datos maestros que insertamos.

**Siguiente paso:** Empezar a construir los componentes de UI que consuman estos datos.

