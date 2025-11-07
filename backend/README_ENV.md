# 📝 Configuración de Variables de Entorno

## ✅ Estado Actual

- ✅ Archivo `.env.example` creado
- ✅ Archivo `.env` creado (necesita configuración)

## 🔧 Configurar .env

El archivo `.env` ya existe en `backend/`. Ahora necesitas:

1. **Abrir el archivo** `backend/.env`
2. **Configurar las credenciales de SQL Server**:
   ```
   SQL_SERVER=tu_servidor_sql
   SQL_DATABASE=tu_base_de_datos
   SQL_USER=tu_usuario
   SQL_PASSWORD=tu_contraseña
   ```

### 💡 Opción Rápida: Copiar del proyecto Next.js

Si ya tienes el proyecto Next.js funcionando:

1. Abre `.env.local` del proyecto principal (raíz del proyecto)
2. Copia las variables `SQL_*`
3. Pégalas en `backend/.env`

## 🧪 Probar Configuración

Una vez configurado, ejecuta:

```bash
cd backend
npm test
```

Esto verificará:
- ✅ Variables configuradas
- ✅ Conexión a SQL Server
- ✅ Servicios funcionando

## 🚀 Iniciar Servidor

Después de configurar, inicia el servidor:

```bash
cd backend
npm run dev
```

El servidor estará disponible en `http://localhost:3001`

## ⚠️ Importante

- El archivo `.env` **NO** se commitea (está en `.gitignore`)
- **NO** compartas credenciales
- Usa las **mismas credenciales** que el proyecto Next.js

