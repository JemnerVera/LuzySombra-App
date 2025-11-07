# 🔧 Instrucciones para Configurar .env

## ✅ Paso 1: Crear archivo .env

El archivo `.env.example` ya está creado. Ahora necesitas crear el `.env` real.

### Opción A: Copiar desde .env.example
```bash
cd backend
copy .env.example .env
```

### Opción B: Crear manualmente
Crea un archivo `.env` en la carpeta `backend/` con este contenido:

```bash
PORT=3001
NODE_ENV=development

# SQL Server - CONFIGURAR CON TUS VALORES REALES
SQL_SERVER=tu_servidor_sql
SQL_DATABASE=tu_base_de_datos
SQL_PORT=1433
SQL_USER=tu_usuario_sql
SQL_PASSWORD=tu_contraseña_sql
SQL_ENCRYPT=true

FRONTEND_URL=http://localhost:3000
DATA_SOURCE=sql
```

## ✅ Paso 2: Configurar Credenciales

**IMPORTANTE**: Debes configurar las credenciales reales de SQL Server:

1. **Abre el archivo `.env`** en `backend/`
2. **Reemplaza los valores** de ejemplo con tus credenciales reales:
   - `SQL_SERVER` = IP o hostname del servidor SQL Server
   - `SQL_DATABASE` = Nombre de la base de datos
   - `SQL_USER` = Usuario de SQL Server
   - `SQL_PASSWORD` = Contraseña de SQL Server

### 💡 Tip: Copiar del proyecto Next.js

Si ya tienes el proyecto Next.js configurado, puedes copiar las credenciales del `.env.local`:

1. Abre `.env.local` del proyecto principal
2. Copia las variables `SQL_*`
3. Pégalas en `backend/.env`

## ✅ Paso 3: Verificar

Después de configurar, verifica que el archivo existe:

```bash
Test-Path backend/.env
```

## ✅ Paso 4: Probar

Ejecuta el script de prueba:

```bash
cd backend
npm test
```

Este script verificará:
- ✅ Variables de entorno configuradas
- ✅ Conexión a SQL Server
- ✅ Servicios funcionando

## ⚠️ Importante

- **NO commitear** el archivo `.env` (ya está en `.gitignore`)
- **NO compartir** credenciales
- El archivo `.env` contiene información sensible

## 🚨 Si hay errores

### Error: Variables de entorno faltantes
- Verifica que el archivo `.env` existe en `backend/`
- Verifica que todas las variables `SQL_*` estén configuradas

### Error: No se puede conectar a SQL Server
- Verifica las credenciales en `.env`
- Verifica que SQL Server esté accesible
- Verifica firewall/red

