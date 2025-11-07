# 📋 Guía de Migración: Next.js → Node.js + React

## 🎯 Objetivo

Migrar la aplicación de Next.js a una arquitectura separada:
- **Backend**: Node.js + Express
- **Frontend**: React + Vite

## ✅ Estado Actual

### Backend (En Progreso - ~40%)

✅ **Completado:**
- Estructura del proyecto
- Configuración TypeScript
- Servidor Express básico
- Conexión a SQL Server
- Rutas básicas:
  - `/api/health`
  - `/api/test-db`
  - `/api/field-data`
  - `/api/historial`
- Servicio SQL Server migrado

⏳ **Pendiente:**
- Ruta `/api/procesar-imagen` (requiere TensorFlow.js-node)
- Rutas adicionales (tabla-consolidada, imagen, alertas)
- Servicios pendientes (TensorFlow, Google Sheets, Alertas)
- Utils (exif, thumbnails, filenameParser)

### Frontend (No Iniciado - 0%)

⏳ **Pendiente:**
- Crear proyecto React + Vite
- Configurar React Router
- Migrar componentes
- Migrar hooks
- Actualizar servicios API
- Configurar Tailwind CSS

## 🚀 Próximos Pasos

### Paso 1: Completar Backend

1. **Instalar TensorFlow.js-node** (requiere Visual Studio Build Tools o usar Azure)
2. **Migrar servicios:**
   - `tensorflowService.ts`
   - `googleSheetsService.ts`
   - `alertService.ts`
3. **Migrar utils:**
   - `exif-server.ts`
   - `imageThumbnail.ts`
   - `filenameParser.ts`
4. **Completar rutas:**
   - `/api/procesar-imagen`
   - `/api/tabla-consolidada`
   - `/api/tabla-consolidada/detalle`
   - `/api/tabla-consolidada/detalle-planta`
   - `/api/imagen/:id`
   - `/api/alertas/procesar-mensajes`

### Paso 2: Crear Frontend

1. **Crear proyecto:**
   ```bash
   cd frontend
   npm create vite@latest . -- --template react-ts
   npm install
   ```

2. **Instalar dependencias:**
   ```bash
   npm install react-router-dom axios @tensorflow/tfjs lucide-react react-image-crop
   npm install -D tailwindcss postcss autoprefixer
   ```

3. **Configurar React Router:**
   - Crear estructura de rutas
   - Migrar componentes
   - Configurar navegación

4. **Migrar componentes:**
   - Todos los componentes de `src/components/`
   - Ajustar imports
   - Actualizar servicios API

### Paso 3: Testing

1. **Backend:**
   - Probar todas las rutas
   - Verificar conexión a SQL Server
   - Probar procesamiento de imágenes

2. **Frontend:**
   - Probar navegación
   - Probar carga de datos
   - Probar procesamiento de imágenes

### Paso 4: Deploy

1. **Backend en Azure:**
   - Azure App Service
   - Configurar variables de entorno
   - Instalar dependencias (incluyendo TensorFlow.js-node)

2. **Frontend en Azure:**
   - Azure Static Web Apps
   - O Azure Blob Storage + CDN
   - Configurar CORS

## 📝 Notas Importantes

### TensorFlow.js-node

**Problema**: Requiere compilación nativa y Visual Studio Build Tools.

**Soluciones**:
1. Instalar Visual Studio Build Tools localmente
2. Instalar dependencias en Azure (recomendado)
3. Usar Docker container

### CORS

El backend debe configurar CORS para permitir requests del frontend:
```typescript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
```

### Variables de Entorno

**Backend (.env):**
```bash
PORT=3001
SQL_SERVER=...
SQL_DATABASE=...
SQL_USER=...
SQL_PASSWORD=...
FRONTEND_URL=http://localhost:3000
```

**Frontend (.env):**
```bash
VITE_API_URL=http://localhost:3001
```

## 🔧 Comandos Útiles

### Backend
```bash
cd backend
npm install --legacy-peer-deps
npm run dev
npm run build
npm start
```

### Frontend
```bash
cd frontend
npm install
npm run dev
npm run build
```

## 📚 Recursos

- [Express.js Documentation](https://expressjs.com/)
- [React Router Documentation](https://reactrouter.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Azure App Service](https://azure.microsoft.com/services/app-service/)
- [TensorFlow.js-node](https://github.com/tensorflow/tfjs-node)

## ⚠️ Advertencias

1. **TensorFlow.js-node** requiere compilación nativa
2. **CORS** debe configurarse correctamente
3. **Variables de entorno** deben estar sincronizadas
4. **SQL Server** debe estar accesible desde Azure
5. **Frontend y backend** deben estar en la misma red o CORS configurado

## ✅ Checklist Final

- [ ] Backend completamente funcional
- [ ] Frontend completamente funcional
- [ ] Todas las rutas probadas
- [ ] CORS configurado
- [ ] Variables de entorno configuradas
- [ ] Deploy en Azure exitoso
- [ ] Testing completo
- [ ] Documentación actualizada

