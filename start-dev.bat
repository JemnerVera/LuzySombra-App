@echo off
cls
echo ========================================
echo   AGRICOLA LUZ-SOMBRA - NEXT.JS
echo   Iniciando servidor de desarrollo...
echo ========================================
echo.
echo [1/2] Verificando dependencias...
if not exist "node_modules\" (
    echo.
    echo No se encontraron dependencias instaladas.
    echo Instalando dependencias...
    echo.
    call npm install
)
echo.
echo [2/2] Iniciando Next.js en modo desarrollo...
echo.
echo ----------------------------------------
echo   App estara disponible en:
echo   http://localhost:3000
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

REM Abrir el navegador
echo Abriendo navegador...
start http://localhost:3000

REM Mantener la ventana abierta para ver los logs
echo.
echo ========================================
echo   Servidor iniciado correctamente!
echo   Navegador abierto en http://localhost:3000
echo ========================================
echo.
echo Presiona Ctrl+C para detener el servidor
echo.

REM Esperar indefinidamente (para mantener la ventana abierta)
pause >nul
