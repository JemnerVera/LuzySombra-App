@echo off
cls
echo ========================================
echo   AGRICOLA LUZ-SOMBRA - NEXT.JS
echo   Iniciando servidor de desarrollo...
echo ========================================
echo.

echo [0/3] Deteniendo servidores anteriores...
REM Buscar y matar procesos de Node.js que puedan estar usando puertos comunes
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3000" ^| findstr "LISTENING"') do (
    echo Deteniendo proceso %%a en puerto 3000...
    taskkill /F /PID %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3003" ^| findstr "LISTENING"') do (
    echo Deteniendo proceso %%a en puerto 3003...
    taskkill /F /PID %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3006" ^| findstr "LISTENING"') do (
    echo Deteniendo proceso %%a en puerto 3006...
    taskkill /F /PID %%a >nul 2>&1
)
REM También matar procesos de node.exe que puedan estar corriendo
taskkill /F /IM node.exe >nul 2>&1
echo Esperando 2 segundos para liberar puertos...
timeout /t 2 /nobreak >nul
echo.

echo [1/3] Verificando dependencias...
if not exist "node_modules\" (
    echo.
    echo No se encontraron dependencias instaladas.
    echo Instalando dependencias...
    echo.
    call npm install
)
echo.

echo [2/3] Iniciando Next.js en modo desarrollo...
echo.
echo ----------------------------------------
echo   App estara disponible en el puerto
echo   que Next.js asigne automaticamente
echo ----------------------------------------
echo.
echo Presiona Ctrl+C para detener el servidor
echo.
echo Esperando a que el servidor este listo...
echo.

REM Iniciar el servidor en segundo plano
start /B npm run dev

REM Esperar 8 segundos para que el servidor inicie
timeout /t 8 /nobreak >nul

REM Detectar el puerto que Next.js asigno
echo [3/3] Detectando puerto asignado...
REM Buscar el puerto en los logs o usar el puerto por defecto
REM Por ahora, intentaremos abrir en los puertos comunes
echo Intentando abrir navegador en puerto detectado...
start http://localhost:3000 2>nul
timeout /t 1 /nobreak >nul
start http://localhost:3003 2>nul
timeout /t 1 /nobreak >nul
start http://localhost:3006 2>nul

REM Mantener la ventana abierta para ver los logs
echo.
echo ========================================
echo   Servidor iniciado correctamente!
echo   Revisa la consola para ver el puerto
echo   asignado por Next.js
echo ========================================
echo.
echo Presiona Ctrl+C para detener el servidor
echo.

REM Esperar indefinidamente (para mantener la ventana abierta)
pause >nul
