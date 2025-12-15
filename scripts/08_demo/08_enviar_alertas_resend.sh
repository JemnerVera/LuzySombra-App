#!/bin/bash
# Script para consolidar y enviar alertas vía Resend API
# Uso: ./08_enviar_alertas_resend.sh

BACKEND_URL="http://localhost:3001/api"

echo "🔄 Paso 1: Consolidando alertas pendientes..."
CONSOLIDAR_RESPONSE=$(curl -s -X POST "${BACKEND_URL}/alertas/consolidar?horasAtras=24")
echo "$CONSOLIDAR_RESPONSE" | jq '.'

MENSAJES_CREADOS=$(echo "$CONSOLIDAR_RESPONSE" | jq -r '.mensajesCreados // 0')

if [ "$MENSAJES_CREADOS" -eq 0 ]; then
    echo "⚠️ No se crearon mensajes. Verifica que haya alertas pendientes."
    exit 0
fi

echo ""
echo "📧 Paso 2: Enviando mensajes pendientes vía Resend API..."
ENVIAR_RESPONSE=$(curl -s -X POST "${BACKEND_URL}/alertas/enviar")
echo "$ENVIAR_RESPONSE" | jq '.'

EXITOSOS=$(echo "$ENVIAR_RESPONSE" | jq -r '.exitosos // 0')
ERRORES=$(echo "$ENVIAR_RESPONSE" | jq -r '.errores // 0')

echo ""
echo "✅ Proceso completado:"
echo "   - Mensajes creados: $MENSAJES_CREADOS"
echo "   - Enviados exitosamente: $EXITOSOS"
echo "   - Errores: $ERRORES"

