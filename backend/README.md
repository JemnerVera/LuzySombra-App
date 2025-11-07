# Agricola Backend API

Backend API para aplicación agrícola - Node.js + Express

## ⚠️ Nota Importante: TensorFlow.js-node

El paquete `@tensorflow/tfjs-node` requiere compilación nativa y Visual Studio Build Tools en Windows.

### Opción 1: Instalar Visual Studio Build Tools
1. Descargar [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
2. Instalar "Desktop development with C++" workload
3. Ejecutar `npm install` nuevamente

### Opción 2: Instalar en Azure (Recomendado)
Azure App Service tiene las herramientas necesarias preinstaladas. Instalar las dependencias directamente en Azure.

### Opción 3: Usar Docker
Crear un contenedor Docker con las dependencias necesarias.

## Instalación

```bash
npm install --legacy-peer-deps
```

## Desarrollo

```bash
npm run dev
```

## Build

```bash
npm run build
npm start
```

## Variables de Entorno

Crear archivo `.env` basado en `.env.example`:

```bash
PORT=3001
NODE_ENV=development
SQL_SERVER=...
SQL_DATABASE=...
SQL_USER=...
SQL_PASSWORD=...
FRONTEND_URL=http://localhost:3000
```

