# Análisis de Migración: Next.js → Node.js + React

## 📊 Resumen Ejecutivo

**Dificultad**: ⚠️ **MODERADA** (6-8 semanas de trabajo)

La migración es **viable** pero requiere trabajo significativo. La mayoría del código React se puede reutilizar, pero la arquitectura backend necesita reconstruirse.

## 🔍 Características de Next.js Actualmente en Uso

### ✅ Características Usadas

1. **App Router** (`src/app/`)
   - `page.tsx` - Página principal
   - `layout.tsx` - Layout raíz
   - Estructura de rutas basada en archivos

2. **API Routes** (`src/app/api/`)
   - 9 endpoints API diferentes:
     - `/api/procesar-imagen` - Procesamiento de imágenes con ML
     - `/api/historial` - Historial de procesamientos
     - `/api/field-data` - Datos de campo
     - `/api/tabla-consolidada` - Tabla consolidada
     - `/api/tabla-consolidada/detalle` - Detalle de lote
     - `/api/tabla-consolidada/detalle-planta` - Detalle de planta
     - `/api/imagen/[id]` - Obtener imagen por ID
     - `/api/test-db` - Test de conexión
     - `/api/alertas/procesar-mensajes` - Sistema de alertas

3. **'use client' Directives**
   - Todos los componentes React son client-side
   - No hay Server Components siendo utilizados

4. **Next.js Fonts** (`next/font/google`)
   - Geist Sans y Geist Mono

5. **Next.js Metadata API**
   - Metadata en `layout.tsx`

6. **NextRequest/NextResponse**
   - Tipos de Next.js para API routes

7. **Webpack Configuration**
   - Configuración especial para TensorFlow.js
   - Configuración para canvas (server-side)

## 📦 Stack Tecnológico Actual

### Frontend
- ✅ React 19.1.0
- ✅ TypeScript 5
- ✅ Tailwind CSS 3.4.18
- ✅ TensorFlow.js 4.22.0 (cliente)
- ✅ Lucide React (iconos)
- ✅ React Image Crop

### Backend (Next.js API Routes)
- ✅ SQL Server (mssql)
- ✅ TensorFlow.js (server-side)
- ✅ Canvas (server-side)
- ✅ Google Sheets API
- ✅ Procesamiento de imágenes (EXIF, thumbnails)

## 🎯 Arquitectura Propuesta: Node.js + React

### Opción 1: Monorepo (Recomendada)
```
proyecto/
├── frontend/          # React App (Vite)
│   ├── src/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── ...
│   ├── package.json
│   └── vite.config.ts
│
├── backend/           # Node.js API (Express)
│   ├── src/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── controllers/
│   │   └── ...
│   ├── package.json
│   └── server.ts
│
└── package.json       # Workspace root
```

### Opción 2: Repositorios Separados
- `agricola-frontend` (React)
- `agricola-backend` (Node.js)

## 🔄 Plan de Migración

### Fase 1: Backend (Node.js + Express) - 2-3 semanas

#### 1.1 Crear estructura del backend
```bash
mkdir backend
cd backend
npm init -y
npm install express cors dotenv mssql canvas @tensorflow/tfjs-node
npm install -D @types/express @types/node typescript ts-node nodemon
```

#### 1.2 Migrar API Routes
Cada API route de Next.js se convierte en una ruta de Express:

**Next.js:**
```typescript
// src/app/api/procesar-imagen/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  // ...
  return NextResponse.json(result);
}
```

**Express:**
```typescript
// backend/src/routes/imageProcessing.ts
import express from 'express';
const router = express.Router();

router.post('/procesar-imagen', async (req, res) => {
  // ...
  res.json(result);
});

export default router;
```

#### 1.3 Servicios a Migrar
- ✅ `sqlServerService.ts` → `backend/src/services/dbService.ts`
- ✅ `tensorflowService.ts` → `backend/src/services/mlService.ts`
- ✅ `googleSheetsService.ts` → `backend/src/services/sheetsService.ts`
- ✅ `alertService.ts` → `backend/src/services/alertService.ts`
- ✅ `utils/exif-server.ts` → `backend/src/utils/exif.ts`
- ✅ `utils/imageThumbnail.ts` → `backend/src/utils/imageThumbnail.ts`

#### 1.4 Configurar Express Server
```typescript
// backend/src/server.ts
import express from 'express';
import cors from 'cors';
import imageRoutes from './routes/imageProcessing';
import historyRoutes from './routes/history';
// ... más rutas

const app = express();
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

app.use('/api/procesar-imagen', imageRoutes);
app.use('/api/historial', historyRoutes);
// ... más rutas

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
```

### Fase 2: Frontend (React + Vite) - 2-3 semanas

#### 2.1 Crear estructura del frontend
```bash
npm create vite@latest frontend -- --template react-ts
cd frontend
npm install
npm install react-router-dom axios @tensorflow/tfjs lucide-react react-image-crop
npm install -D tailwindcss postcss autoprefixer
```

#### 2.2 Configurar React Router
```typescript
// frontend/src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import History from './pages/History';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/historial" element={<History />} />
        {/* ... más rutas */}
      </Routes>
    </BrowserRouter>
  );
}
```

#### 2.3 Migrar Componentes
- ✅ Todos los componentes React se pueden usar tal cual
- ✅ Solo cambiar imports de Next.js a React puro
- ✅ Cambiar `'use client'` por nada (ya es cliente)

#### 2.4 Configurar API Client
```typescript
// frontend/src/services/api.ts
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
```

#### 2.5 Migrar Hooks y Servicios
- ✅ `hooks/` → Se mantienen igual
- ✅ `services/api.ts` → Actualizar para usar axios con baseURL
- ✅ `services/tensorflowService.ts` → Mantener (solo cliente ahora)

### Fase 3: Configuración y Build - 1 semana

#### 3.1 Variables de Entorno

**Backend (.env)**
```bash
# Server
PORT=3001
NODE_ENV=production

# SQL Server
SQL_SERVER=...
SQL_DATABASE=...
SQL_USER=...
SQL_PASSWORD=...

# API URL (para frontend)
FRONTEND_URL=http://localhost:3000
```

**Frontend (.env)**
```bash
VITE_API_URL=http://localhost:3001
```

#### 3.2 Build Scripts

**Backend (package.json)**
```json
{
  "scripts": {
    "dev": "nodemon src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  }
}
```

**Frontend (package.json)**
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

### Fase 4: Deploy en Azure - 1 semana

#### 4.1 Backend en Azure
- **Azure App Service** (Node.js)
- O **Azure Container Instances** (Docker)
- O **Azure Functions** (serverless)

#### 4.2 Frontend en Azure
- **Azure Static Web Apps**
- O **Azure Blob Storage + CDN**
- O **Azure App Service** (servir archivos estáticos)

#### 4.3 Configuración
- Variables de entorno en Azure Portal
- CORS configurado correctamente
- Conexión a SQL Server (Azure SQL)

## 📋 Checklist de Migración

### Backend
- [ ] Crear proyecto Express
- [ ] Migrar todas las API routes
- [ ] Migrar servicios (SQL, TensorFlow, etc.)
- [ ] Configurar CORS
- [ ] Configurar manejo de archivos (multer)
- [ ] Configurar variables de entorno
- [ ] Tests de endpoints
- [ ] Documentación API (Swagger/OpenAPI)

### Frontend
- [ ] Crear proyecto Vite + React
- [ ] Configurar React Router
- [ ] Migrar todos los componentes
- [ ] Configurar Tailwind CSS
- [ ] Actualizar servicios API
- [ ] Configurar variables de entorno
- [ ] Tests de componentes
- [ ] Optimización de build

### Infraestructura
- [ ] Configurar Azure App Service (backend)
- [ ] Configurar Azure Static Web Apps (frontend)
- [ ] Configurar conexión a SQL Server
- [ ] Configurar CORS en producción
- [ ] Configurar CI/CD (GitHub Actions)
- [ ] Monitoreo y logging

## ⚠️ Desafíos y Consideraciones

### 1. TensorFlow.js
- ✅ **Cliente**: Funciona igual en React puro
- ⚠️ **Servidor**: Necesita `@tensorflow/tfjs-node` en Node.js
- ✅ **Canvas**: Funciona en Node.js con el paquete `canvas`

### 2. Procesamiento de Imágenes
- ✅ **Cliente**: HTML5 Canvas (igual)
- ✅ **Servidor**: Paquete `canvas` (igual que Next.js)
- ✅ **EXIF**: Funciona igual en Node.js

### 3. SQL Server
- ✅ **Conexión**: Igual con `mssql`
- ✅ **Queries**: No cambian

### 4. Google Sheets
- ✅ **API**: Funciona igual en Node.js

### 5. CORS
- ⚠️ **Nuevo**: Necesita configuración explícita en Express
```typescript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
```

### 6. Manejo de Archivos
- ⚠️ **Nuevo**: Necesita `multer` o `formidable` para multipart/form-data
```typescript
import multer from 'multer';
const upload = multer({ storage: multer.memoryStorage() });
router.post('/procesar-imagen', upload.single('image'), async (req, res) => {
  const file = req.file;
  // ...
});
```

### 7. Variables de Entorno
- ⚠️ **Frontend**: Vite usa `VITE_` prefix
- ✅ **Backend**: Node.js usa `process.env` directamente

### 8. Routing
- ⚠️ **Frontend**: Cambiar de file-based routing a React Router
- ✅ **Backend**: Express routing es más explícito

## 🎯 Ventajas de la Migración

### ✅ Ventajas
1. **Separación de Concerns**: Frontend y backend independientes
2. **Escalabilidad**: Puedes escalar frontend y backend por separado
3. **Flexibilidad**: Puedes usar cualquier framework frontend
4. **Deploy Independiente**: Frontend y backend en diferentes servicios
5. **Team Work**: Equipos pueden trabajar en paralelo
6. **Azure Native**: Mejor integración con servicios de Azure

### ⚠️ Desventajas
1. **Más Complejidad**: Dos aplicaciones para mantener
2. **CORS**: Necesita configuración explícita
3. **Deploy**: Dos deploys en lugar de uno
4. **Tiempo**: Más tiempo de desarrollo inicial

## 📊 Estimación de Esfuerzo

| Tarea | Esfuerzo | Dificultad |
|-------|----------|------------|
| Backend (Express) | 2-3 semanas | Media |
| Frontend (React + Vite) | 2-3 semanas | Media |
| Configuración | 1 semana | Baja |
| Deploy Azure | 1 semana | Media |
| Testing | 1 semana | Media |
| **TOTAL** | **7-9 semanas** | **Media** |

## 🚀 Recomendaciones

1. **Empezar por el Backend**: Migrar API routes primero
2. **Mantener Funcionalidad**: No agregar features nuevas durante la migración
3. **Testing Continuo**: Probar cada endpoint migrado
4. **Documentación**: Documentar cambios en la API
5. **CI/CD**: Configurar pipelines desde el inicio
6. **Monorepo**: Considerar monorepo para facilitar desarrollo

## 📚 Recursos

- [Express.js Documentation](https://expressjs.com/)
- [React Router Documentation](https://reactrouter.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Azure App Service](https://azure.microsoft.com/services/app-service/)
- [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/)

## ✅ Conclusión

La migración es **viable y moderadamente difícil**. La mayoría del código React se puede reutilizar, pero el backend necesita reconstruirse. El esfuerzo principal está en:

1. **Migrar API Routes a Express** (2-3 semanas)
2. **Configurar React Router** (1 semana)
3. **Ajustar servicios y hooks** (1 semana)
4. **Deploy en Azure** (1 semana)

**Total estimado: 5-6 semanas** de trabajo dedicado.

¿Seguimos con la migración?

