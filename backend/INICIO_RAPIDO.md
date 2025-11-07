# 🚀 Inicio Rápido - Backend

## ✅ Archivos Creados

- ✅ `.env.example` - Plantilla de variables de entorno
- ✅ `.env` - Archivo de configuración (necesita credenciales)
- ✅ `src/test-server.ts` - Script de prueba
- ✅ Documentación completa

## 📋 Pasos para Probar

### 1. Configurar .env

**Abre el archivo `backend/.env`** y configura las credenciales de SQL Server:

```bash
SQL_SERVER=tu_servidor_sql
SQL_DATABASE=tu_base_de_datos  
SQL_USER=tu_usuario
SQL_PASSWORD=tu_contraseña
```

💡 **Tip**: Copia estas variables del `.env.local` del proyecto Next.js principal.

### 2. Instalar Dependencias Básicas

```bash
cd backend
npm install express cors dotenv mssql multer piexifjs axios --save
npm install @types/express @types/cors @types/node @types/multer @types/mssql typescript ts-node nodemon --save-dev
```

⚠️ **Nota**: TensorFlow.js-node se omitirá (requiere compilación nativa). No es necesario para probar las rutas básicas.

### 3. Probar

```bash
npm test
```

Esto verificará:
- ✅ Variables de entorno
- ✅ Conexión a SQL Server
- ✅ Servicios básicos

### 4. Iniciar Servidor

```bash
npm run dev
```

Servidor disponible en: `http://localhost:3001`

## 🧪 Probar Rutas

Una vez iniciado el servidor:

```bash
# Health check
curl http://localhost:3001/api/health

# Test BD
curl http://localhost:3001/api/test-db

# Field data
curl http://localhost:3001/api/field-data

# Historial
curl http://localhost:3001/api/historial?page=1&pageSize=10
```

## ⚠️ Si hay Problemas

### Error: Variables de entorno faltantes
- Verifica que `backend/.env` existe
- Verifica que todas las variables `SQL_*` estén configuradas

### Error: No se puede conectar a SQL Server
- Verifica credenciales en `.env`
- Verifica que SQL Server esté accesible
- Verifica firewall/red

### Error: TensorFlow no se instala
- **Esto es normal** - No es necesario para rutas básicas
- TensorFlow se instalará en Azure o con Visual Studio Build Tools

## 📝 Estado Actual

- ✅ Estructura del backend completa
- ✅ Rutas API creadas (8/9)
- ✅ Servicios migrados
- ✅ Configuración lista
- ⏳ TensorFlow pendiente (no crítico para pruebas básicas)

## 🎯 Próximo Paso

1. **Configurar `.env`** con credenciales reales
2. **Instalar dependencias** básicas
3. **Ejecutar `npm test`** para verificar
4. **Iniciar servidor** con `npm run dev`

