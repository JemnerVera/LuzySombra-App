# 🔧 Cómo Configurar .env para Backend

## Opción 1: Crear desde .env.example (Recomendado)

1. **En el directorio `backend/`**, ejecuta:
   ```bash
   copy .env.example .env
   ```

2. **Edita el archivo `.env`** y configura las credenciales de SQL Server:
   ```bash
   SQL_SERVER=tu_servidor
   SQL_DATABASE=tu_base_de_datos
   SQL_USER=tu_usuario
   SQL_PASSWORD=tu_contraseña
   ```

## Opción 2: Copiar desde proyecto Next.js

Si ya tienes configurado el proyecto Next.js original:

1. **Copia las variables SQL Server** del `.env.local` del proyecto principal
2. **Crea el archivo `.env` en `backend/`** con estas variables:
   ```bash
   PORT=3001
   NODE_ENV=development
   
   # SQL Server (copiar del .env.local del proyecto principal)
   SQL_SERVER=...
   SQL_DATABASE=...
   SQL_PORT=1433
   SQL_USER=...
   SQL_PASSWORD=...
   SQL_ENCRYPT=true
   
   FRONTEND_URL=http://localhost:3000
   DATA_SOURCE=sql
   ```

## Verificar Configuración

Después de crear el `.env`, verifica que esté correcto:

```bash
# Verificar que el archivo existe
Test-Path .env

# Verificar variables (sin mostrar valores sensibles)
Get-Content .env | Select-String "SQL_"
```

## Probar Conexión

Una vez configurado, prueba la conexión:

```bash
npm test
```

Este script verificará:
- ✅ Variables de entorno configuradas
- ✅ Conexión a SQL Server
- ✅ Servicios funcionando

## ⚠️ Importante

- **NO commitear** el archivo `.env` (contiene credenciales)
- **NO compartir** credenciales
- Usar las **mismas credenciales** que el proyecto Next.js original

