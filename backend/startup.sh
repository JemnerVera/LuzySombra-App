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

# Verificar si js-md4 existe y está completo (check crítico para evitar errores)
if [ ! -f "node_modules/js-md4/src/md4.js" ]; then
    echo "⚠️ js-md4 incompleto o faltante, reinstalando dependencias..."
    # Limpiar node_modules corrupto antes de reinstalar
    rm -rf node_modules
    npm install --production --no-audit --no-fund
    echo "✅ Dependencias reinstaladas"
else
    echo "✅ node_modules verificado (js-md4 presente)"
fi

# Ejecutar npm start (que ejecuta node dist/server.js según package.json)
echo "✅ Iniciando aplicación desde /home/site/wwwroot"
npm start

