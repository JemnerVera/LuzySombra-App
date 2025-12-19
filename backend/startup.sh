#!/bin/sh
# Script de startup personalizado para Azure App Service
# Este script asegura que npm start se ejecute desde el directorio correcto

# Cambiar al directorio de la aplicación
cd /home/site/wwwroot

# Verificar que package.json existe
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json no encontrado en /home/site/wwwroot"
    echo "Contenido del directorio:"
    ls -la
    exit 1
fi

# Verificar que dist/server.js existe
if [ ! -f "dist/server.js" ]; then
    echo "❌ Error: dist/server.js no encontrado. El build no se completó correctamente."
    echo "Contenido de dist/:"
    ls -la dist/ 2>/dev/null || echo "directorio dist/ no existe"
    exit 1
fi

# Azure Oryx ya extrae node_modules automáticamente desde el build
# NO ejecutar npm install aquí porque causará errores de permisos
# Oryx extrae node_modules.tar.gz y crea un symlink a /node_modules
echo "✅ node_modules ya está disponible (extraído por Oryx durante el deploy)"

# Ejecutar npm start (que ejecuta node dist/server.js según package.json)
echo "✅ Iniciando aplicación desde /home/site/wwwroot"
npm start

