# 🚀 Resumen: Conectar Next.js a SQL Server Express

## ✅ ¿Qué hemos preparado?

### 1. **Archivos creados:**
- ✅ `lib/db.ts` - Utilidad de conexión a SQL Server
- ✅ `app/api/test-db/route.ts` - API para probar la conexión
- ✅ `CONEXION_SQL_SERVER.md` - Guía completa de conexión
- ✅ Actualizado `package.json` con `mssql` y `@types/mssql`
- ✅ Actualizado `env.example` con variables SQL Server

---

## 📦 Próximos pasos (en orden):

### **PASO 1: Instalar dependencias** 
```bash
npm install
```

Esto instalará:
- `mssql@^11.0.1` - Driver oficial de Microsoft para SQL Server
- `@types/mssql@^9.1.5` - TypeScript types

### **PASO 2: Actualizar tu `.env.local`**

Agrega estas líneas a tu archivo `.env.local` (el que ya tiene tus credenciales de Google Sheets):

```env
# SQL Server Configuration
SQL_SERVER=localhost\\SQLEXPRESS
SQL_DATABASE=AgricolaDB
SQL_PORT=1433
SQL_TRUSTED_CONNECTION=true
```

### **PASO 3: Iniciar la app**
```bash
npm run dev
```

### **PASO 4: Probar la conexión**

Abre en tu navegador:
```
http://localhost:3000/api/test-db
```

Deberías ver algo como:
```json
{
  "success": true,
  "message": "Conexión exitosa a SQL Server",
  "counts": {
    "paises": 1,
    "empresas": 5,
    "fundos": 12,
    "sectores": 270,
    "lotes": 509,
    "usuarios": 3,
    "estados_fenologicos": 9,
    "tipos_alerta": 7
  },
  "sample_empresas": [...]
}
```

---

## 🔍 ¿Cómo funciona SQL Server Express?

### **Arquitectura:**

```
┌─────────────────────────────────────────┐
│  Next.js App (puerto 3000)              │
│  ├─ Frontend (React/TypeScript)         │
│  └─ Backend (API Routes)                │
│       └─ lib/db.ts (mssql driver)       │
└─────────────────┬───────────────────────┘
                  │
                  │ Conexión TCP/IP
                  │ (puerto 1433)
                  │
┌─────────────────▼───────────────────────┐
│  SQL Server Express                     │
│  Instancia: localhost\SQLEXPRESS        │
│  ├─ AgricolaDB (tu base de datos)      │
│  │   └─ Schema: image                  │
│  │       ├─ pais (1)                   │
│  │       ├─ empresa (5)                │
│  │       ├─ fundo (12)                 │
│  │       ├─ sector (270)               │
│  │       ├─ lote (509)                 │
│  │       ├─ usuario (3)                │
│  │       ├─ estado_fenologico (9)     │
│  │       └─ tipo_alerta (7)           │
│  └─ Connection Pool (máx 10 conexiones)│
└─────────────────────────────────────────┘
```

### **¿Cómo funciona el Pool de Conexiones?**

1. **Primera petición:** Se crea una conexión al SQL Server
2. **Siguientes peticiones:** Se reutiliza la conexión existente (más rápido)
3. **Múltiples peticiones simultáneas:** Se crean hasta 10 conexiones en paralelo
4. **Idle:** Conexiones inactivas se cierran después de 30 segundos

### **Autenticación Windows vs SQL:**

**Windows Authentication (lo que estás usando ahora):**
- ✅ Más segura (usa tu usuario de Windows)
- ✅ No necesitas password en el código
- ✅ Ideal para desarrollo local
- ❌ Solo funciona en Windows
- ❌ Complicado para producción/deployment

**SQL Server Authentication:**
- ✅ Funciona en cualquier plataforma
- ✅ Fácil de configurar para producción
- ❌ Necesitas guardar password (usar variables de entorno)
- ❌ Debes crear usuarios SQL manualmente

---

## 📊 Datos disponibles para usar:

### **Jerarquía Organizacional** (ya cargada):
```typescript
// Ejemplo de uso en tu app:
import { query } from '@/lib/db';

// Obtener todas las empresas
const empresas = await query('SELECT * FROM image.empresa WHERE statusid = 1');

// Obtener lotes de una empresa específica
const lotes = await query(
  `SELECT l.*, s.sector, f.fundo, e.empresa
   FROM image.lote l
   INNER JOIN image.sector s ON l.sectorid = s.sectorid
   INNER JOIN image.fundo f ON s.fundoid = f.fundoid
   INNER JOIN image.empresa e ON f.empresaid = e.empresaid
   WHERE e.empresaid = @empresaid`,
  { empresaid: 1 }
);
```

### **Vista pre-creada para filtros cascada:**
```typescript
// Usar la vista que ya está en la DB
const jerarquia = await query(`
  SELECT * FROM image.v_jerarquia_completa
  ORDER BY empresa, fundo, sector, lote
`);
```

---

## 🎯 ¿Qué puedes hacer ahora?

### **Inmediatamente:**
1. ✅ Crear dropdowns/selectores con la jerarquía organizacional
2. ✅ Implementar filtros en cascada (País → Empresa → Fundo → Sector → Lote)
3. ✅ Mostrar listados de lotes, sectores, etc.

### **Cuando implementes análisis de imágenes:**
```typescript
// Guardar resultado de análisis
await query(
  `INSERT INTO image.analisis_imagen 
   (loteid, hilera, planta, filename, porcentaje_luz, porcentaje_sombra,
    fecha_captura, usercreatedid)
   VALUES (@loteid, @hilera, @planta, @filename, @luz, @sombra, GETDATE(), @userid)`,
  {
    loteid: 123,
    hilera: 'H01',
    planta: 'P05',
    filename: 'imagen.jpg',
    luz: 65.5,
    sombra: 34.5,
    userid: 2
  }
);
```

### **Dashboard de fenología:**
```typescript
// Ya tienes los estados fenológicos listos
const estados = await query('SELECT * FROM image.estado_fenologico ORDER BY orden');
```

---

## 🔒 Seguridad

### **Para desarrollo:**
- ✅ Autenticación Windows (ya configurada)
- ✅ Conexión local sin SSL
- ✅ Variables de entorno en `.env.local` (git ignoreado)

### **Para producción (futuro):**
- 🔐 Usar autenticación SQL con password seguro
- 🔐 Habilitar SSL/TLS
- 🔐 Configurar firewall para puerto 1433
- 🔐 Usar Azure SQL o SQL Server remoto
- 🔐 Implementar rate limiting en API

---

## 🐛 Troubleshooting

### Error: "Cannot find module 'mssql'"
```bash
npm install
```

### Error: "Login failed"
- Verifica que SQL Server Express esté corriendo
- Verifica que `SQL_TRUSTED_CONNECTION=true` en `.env.local`

### Error: "Unable to connect"
```powershell
# Verificar que SQL Server esté corriendo:
Get-Service MSSQL$SQLEXPRESS

# Si está detenido, iniciarlo:
Start-Service MSSQL$SQLEXPRESS
```

---

## ✅ Checklist Final

- [ ] `npm install` ejecutado
- [ ] Variables SQL agregadas a `.env.local`
- [ ] App iniciada con `npm run dev`
- [ ] Test de conexión exitoso en `/api/test-db`
- [ ] SQL Server Express corriendo

---

## 📚 Recursos

- [Documentación mssql (node)](https://github.com/tediousjs/node-mssql)
- [SQL Server Express Download](https://www.microsoft.com/sql-server/sql-server-downloads)
- [Azure Data Studio](https://azure.microsoft.com/products/data-studio/) - Cliente SQL Server moderno

---

¡Ya está todo listo para que tu app Next.js se conecte a SQL Server! 🎉

