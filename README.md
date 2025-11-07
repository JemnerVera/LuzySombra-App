# 🌱 Agricola Luz-Sombra

Aplicación web para análisis de imágenes agrícolas que clasifica píxeles en suelo/malla y luz/sombra usando algoritmos heurísticos y Machine Learning con TensorFlow.js (cliente).

## 🚀 Características

- **Análisis de Imágenes**: Clasificación de píxeles en luz/sombra con algoritmo heurístico
- **SQL Server Integration**: Base de datos empresarial AgroMigiva para almacenamiento
- **Procesamiento de Imágenes**: Extracción de GPS y metadatos EXIF
- **Interfaz Moderna**: Dark mode, responsive design con Tailwind CSS
- **Deploy Ready**: Optimizado para Azure App Service

## 🛠️ Tecnologías

- **Backend**: Node.js + Express + TypeScript
- **Frontend**: React 18 + Vite + TypeScript
- **Styling**: Tailwind CSS
- **ML**: TensorFlow.js (solo en cliente, opcional)
- **Database**: SQL Server (AgroMigiva Enterprise DB)
- **Deploy**: Azure App Service / Static Web Apps

## 📦 Instalación

```bash
# Clonar el repositorio
git clone <repository-url>
cd Agricola-nextjs

# Instalar dependencias del backend
cd backend
npm install
cd ..

# Instalar dependencias del frontend
cd frontend
npm install
cd ..

# O instalar todo con el script del root
npm run install:all
```

## 🔧 Configuración

### Paso 1: Conectar VPN (Obligatorio para desarrollo)

**⚠️ IMPORTANTE:** Debes estar conectado a la VPN antes de ejecutar el backend.

1. Conectar a FortiClient VPN:
   - Nombre: VPN-AGRO
   - Usuario: jverac
   - Contraseña: bz7371Xa
2. Verificar que la VPN esté conectada
3. Ver `backend/CONFIGURACION_VPN.md` para más detalles

### Paso 2: Configurar Backend

1. Crear archivo `.env` en `backend/`:

```bash
# SQL Server Configuration
SQL_SERVER=***REMOVED***
SQL_DATABASE=***REMOVED***
SQL_PORT=1433
SQL_USER=***REMOVED***
SQL_PASSWORD=***REMOVED***
SQL_ENCRYPT=true

# Server Configuration
PORT=3001
FRONTEND_URL=http://localhost:3000

# Data Source (sql | google_sheets)
DATA_SOURCE=sql
```

**⚠️ NOTA:** Las credenciales de VPN NO van en `.env`. La VPN se conecta con FortiClient antes de ejecutar el backend.

### Frontend

1. Crear archivo `.env` en `frontend/` (opcional):

```bash
# API URL (opcional, por defecto usa proxy de Vite)
VITE_API_URL=http://localhost:3001
```

**⚠️ IMPORTANTE**: Los archivos `.env` contienen credenciales sensibles y NO deben commitrearse.

## 🚀 Desarrollo

### Opción 1: Script automatizado (recomendado)

```bash
# Ejecutar backend y frontend con script
.\start-dev.bat
```

### Opción 2: Manual

```bash
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend
cd frontend
npm run dev
```

- **Backend**: http://localhost:3001
- **Frontend**: http://localhost:3000

## 🔧 Scripts Disponibles

### Root
```bash
npm run dev:backend      # Iniciar backend
npm run dev:frontend     # Iniciar frontend
npm run build:backend    # Build del backend
npm run build:frontend   # Build del frontend
npm run build            # Build de ambos
npm run install:all      # Instalar dependencias de ambos
```

### Backend
```bash
npm run dev              # Servidor de desarrollo
npm run build            # Build para producción
npm run start            # Servidor de producción
npm run test             # Probar conexión a BD
```

### Frontend
```bash
npm run dev              # Servidor de desarrollo
npm run build            # Build para producción
npm run preview          # Preview del build
```

## 📱 Funcionalidades

### 🔍 Analizar Imágenes
- Subida de imágenes con drag & drop
- Extracción automática de GPS y fecha EXIF
- Clasificación de píxeles en luz/sombra
- Integración con datos de campo (empresa, fundo, sector, lote)
- Guardado automático en SQL Server

### 🧪 Probar Modelo
- Prueba del algoritmo heurístico (backend)
- Prueba del modelo TensorFlow.js (cliente, opcional)
- Comparación de imágenes original vs procesada
- Slider de comparación con overlay

### 📊 Historial
- Visualización de todos los procesamientos
- Filtros por empresa, fundo, fecha
- Exportación a CSV
- Paginación y búsqueda

### 📈 Tabla Consolidada
- Visualización de evaluaciones por lote
- Detalles históricos por fecha
- Detalles por planta

## 🏗️ Estructura del Proyecto

```
.
├── backend/              # Backend Node.js + Express
│   ├── src/
│   │   ├── routes/      # API Routes
│   │   ├── services/    # Business logic
│   │   ├── lib/         # Libraries (DB connection)
│   │   └── utils/       # Utilities
│   └── package.json
├── frontend/            # Frontend React + Vite
│   ├── src/
│   │   ├── components/  # React components
│   │   ├── hooks/       # Custom hooks
│   │   ├── services/    # API services
│   │   ├── types/       # TypeScript types
│   │   └── utils/       # Utilities
│   └── package.json
├── scripts/             # SQL scripts
└── docs/                # Documentación
```

## 🌐 API Endpoints

### Backend (http://localhost:3001)

- `GET /api/health` - Health check
- `GET /api/test-db` - Test database connection
- `GET /api/field-data` - Get hierarchical field data
- `POST /api/procesar-imagen` - Process image and save to DB
- `POST /api/test-model` - Test model (doesn't save to DB)
- `POST /api/check-gps-info` - Check GPS info from image
- `GET /api/historial` - Get processing history
- `GET /api/tabla-consolidada` - Get consolidated table
- `GET /api/tabla-consolidada/detalle` - Get lot detail history
- `GET /api/tabla-consolidada/detalle-planta` - Get plant detail
- `GET /api/imagen` - Get image by ID
- `GET /api/estadisticas` - Get statistics

## 🚀 Deploy en Azure

### ⚠️ Importante: VPN en Azure

En Azure **NO necesitas** configurar VPN manualmente como en desarrollo local. La conexión se maneja a nivel de infraestructura mediante:
- Azure Virtual Network (VNet) Integration
- VPN Site-to-Site
- ExpressRoute

**Contactar al equipo de infraestructura** para configurar el acceso a la red interna.

### Backend (Azure App Service)

1. **Crear Azure App Service:**
   - Runtime: Node.js 18 LTS
   - OS: Linux (recomendado)

2. **Configurar Variables de Entorno (Application Settings):**
   ```
   SQL_SERVER=***REMOVED***
   SQL_DATABASE=***REMOVED***
   SQL_PORT=1433
   SQL_USER=***REMOVED***
   SQL_PASSWORD=***REMOVED***
   SQL_ENCRYPT=true
   PORT=3001
   FRONTEND_URL=https://tu-frontend.azurestaticapps.net
   DATA_SOURCE=sql
   NODE_ENV=production
   ```

3. **Configurar VNet Integration:**
   - App Service → Networking → VNet integration
   - Conectar a VNet con acceso a la red interna

4. **Configurar Startup Command:**
   ```
   node backend/dist/server.js
   ```

5. **Deploy:** Git, Azure DevOps, o Azure CLI

### Frontend (Azure Static Web Apps)

1. **Crear Azure Static Web App**
2. **Conectar repositorio**
3. **Configurar build settings:**
   - App location: `frontend`
   - Build command: `npm run build`
   - Output location: `dist`
4. **Deploy automático** en cada push

### Documentación Completa

Ver `docs/DEPLOY_AZURE.md` para guía detallada de deploy.

## 🔒 Seguridad

- Variables de entorno para credenciales sensibles
- Validación de archivos de imagen
- Sanitización de inputs
- HTTPS en producción
- CORS configurado

## 📝 Licencia

Este proyecto es privado y confidencial.

## 🤝 Contribución

Para contribuir al proyecto, contacta al equipo de desarrollo.

---

**Desarrollado con ❤️ para análisis agrícola**
