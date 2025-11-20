# 🌱 Agricola Frontend - React + Vite

Frontend de la aplicación Agricola Luz-Sombra migrado de Next.js a React + Vite.

## 🚀 Instalación

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm run dev

# Build para producción
npm run build

# Preview de producción
npm run preview
```

## 🏗️ Estructura

```
frontend/
├── src/
│   ├── components/     # Componentes React
│   ├── hooks/          # Custom hooks
│   ├── services/       # Servicios API
│   ├── types/          # TypeScript types
│   ├── utils/          # Utilidades
│   ├── App.tsx         # Componente principal
│   └── main.tsx        # Entry point
├── index.html
├── vite.config.ts
└── package.json
```

## 🔧 Configuración

### Variables de Entorno

Crea un archivo `.env`:

```bash
VITE_API_URL=http://localhost:3001
```

### Proxy de Desarrollo

El proxy está configurado en `vite.config.ts` para redirigir `/api` a `http://localhost:3001`.

## 📦 Tecnologías

- **React 18** - UI Framework
- **Vite** - Build tool
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Axios** - HTTP client
- **React Router** - Routing (opcional)

## 🔄 Migración de Next.js

### Cambios Principales

1. **Sin App Router** - Usamos componentes React puros
2. **Sin API Routes** - Las APIs están en el backend Node.js
3. **Sin SSR** - Todo es cliente-side
4. **Vite en lugar de Next.js** - Build tool más rápido

### Componentes Migrados

- ✅ Layout
- ✅ ImageUploadForm
- ✅ ModelTestForm
- ✅ HistoryTable
- ✅ ConsolidatedTable
- ✅ EvaluacionPorFecha
- ✅ EvaluacionDetallePlanta
- ✅ Notification

## 🚀 Desarrollo

```bash
# Iniciar frontend
npm run dev

# El frontend correrá en http://localhost:3000
# El backend debe estar corriendo en http://localhost:3001
```

## 📝 Notas

- El frontend se conecta al backend Node.js en `http://localhost:3001`
- Las variables de entorno deben empezar con `VITE_` para ser accesibles en el cliente
- El proxy de Vite redirige `/api/*` al backend automáticamente

