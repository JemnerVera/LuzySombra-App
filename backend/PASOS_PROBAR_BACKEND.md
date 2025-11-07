# 🧪 Pasos para Probar el Backend

## ✅ Paso 1: Configurar .env

El archivo `.env` ya está creado en `backend/`. 

**Edita el archivo `backend/.env`** y configura las credenciales de SQL Server:

```bash
SQL_SERVER=tu_servidor_sql
SQL_DATABASE=tu_base_de_datos
SQL_USER=tu_usuario
SQL_PASSWORD=tu_contraseña
```

💡 **Tip**: Puedes copiar estas variables del `.env.local` del proyecto Next.js principal.

## ✅ Paso 2: Instalar Dependencias (sin TensorFlow)

TensorFlow.js-node requiere compilación nativa. Para probar el backend básico, puedes instalar las dependencias esenciales:

```bash
cd backend

# Instalar dependencias críticas (sin TensorFlow)
npm install express cors dotenv mssql multer piexifjs axios --save
npm install @types/express @types/cors @types/node @types/multer @types/mssql typescript ts-node nodemon --save-dev
```

**Nota**: TensorFlow se instalará después en Azure o cuando tengas Visual Studio Build Tools.

## ✅ Paso 3: Probar Conexión

Ejecuta el script de prueba:

```bash
npm test
```

Esto verificará:
- ✅ Variables de entorno configuradas
- ✅ Conexión a SQL Server
- ✅ Servicios básicos funcionando

## ✅ Paso 4: Iniciar Servidor

Si las pruebas pasan, inicia el servidor:

```bash
npm run dev
```

El servidor estará disponible en `http://localhost:3001`

## ✅ Paso 5: Probar Rutas

### Health Check
```bash
curl http://localhost:3001/api/health
```

### Test de Base de Datos
```bash
curl http://localhost:3001/api/test-db
```

### Field Data
```bash
curl http://localhost:3001/api/field-data
```

### Historial
```bash
curl http://localhost:3001/api/historial?page=1&pageSize=10
```

### Tabla Consolidada
```bash
curl http://localhost:3001/api/tabla-consolidada?page=1&pageSize=10
```

## ⚠️ Problemas Conocidos

### TensorFlow.js-node no se instala
**Esto es normal** en Windows sin Visual Studio Build Tools. No es necesario para probar las rutas básicas del backend.

### Error de conexión a SQL Server
- Verifica las credenciales en `.env`
- Verifica que SQL Server esté accesible
- Verifica firewall/red

### Vista vwc_CianamidaFenologia no existe
Esto es normal si no se ha ejecutado el script SQL. No es crítico para probar el backend básico.

## ✅ Estado Esperado

Si todo funciona correctamente, deberías ver:

```
✅ Backend básico funcionando correctamente!
✅ Todos los servicios funcionando!
🚀 Puedes iniciar el servidor con: npm run dev
```

## 📝 Notas

- El backend puede funcionar sin TensorFlow para las rutas básicas
- TensorFlow se instalará en Azure o cuando tengas Visual Studio Build Tools
- Las rutas de procesamiento de imágenes requerirán TensorFlow

