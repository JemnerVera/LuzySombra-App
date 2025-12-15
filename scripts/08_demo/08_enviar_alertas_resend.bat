@echo off
REM Script para consolidar y enviar alertas vía Resend API (Windows)
REM Uso: 08_enviar_alertas_resend.bat

set BACKEND_URL=http://localhost:3001/api

echo.
echo ========================================
echo Consolidar y Enviar Alertas vía Resend
echo ========================================
echo.

echo Paso 1: Consolidando alertas pendientes...
curl -s -X POST "%BACKEND_URL%/alertas/consolidar?horasAtras=24" > temp_consolidar.json
type temp_consolidar.json
echo.

echo Paso 2: Enviando mensajes pendientes vía Resend API...
curl -s -X POST "%BACKEND_URL%/alertas/enviar" > temp_enviar.json
type temp_enviar.json
echo.

echo ========================================
echo Proceso completado
echo ========================================
echo.
echo Revisa los archivos temp_consolidar.json y temp_enviar.json para ver los detalles.
echo.

del temp_consolidar.json temp_enviar.json 2>nul

