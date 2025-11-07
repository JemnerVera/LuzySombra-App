@echo off
REM Script para iniciar backend y frontend en desarrollo
REM Requiere: Node.js y npm instalados

echo ========================================
echo   Agricola Luz-Sombra - Desarrollo
echo ========================================
echo.

REM Verificar que Node.js esté instalado
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js no está instalado o no está en el PATH
    echo Por favor, instala Node.js desde https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar que npm esté instalado
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] npm no está instalado o no está en el PATH
    pause
    exit /b 1
)

echo [INFO] Verificando dependencias...
echo.

REM Verificar dependencias del root
if not exist "node_modules\" (
    echo [INFO] Instalando dependencias del root...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Error al instalar dependencias del root
        pause
        exit /b 1
    )
)

REM Verificar dependencias del backend
if not exist "backend\node_modules\" (
    echo [INFO] Instalando dependencias del backend...
    cd backend
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Error al instalar dependencias del backend
        pause
        exit /b 1
    )
    cd ..
)

REM Verificar dependencias del frontend
if not exist "frontend\node_modules\" (
    echo [INFO] Instalando dependencias del frontend...
    cd frontend
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Error al instalar dependencias del frontend
        pause
        exit /b 1
    )
    cd ..
)

echo.
echo [INFO] Iniciando servidores...
echo.
echo Backend:  http://localhost:3001
echo Frontend: http://localhost:3000
echo.
echo Presiona Ctrl+C para detener los servidores
echo.

REM Iniciar backend y frontend con concurrently
call npm run dev

pause
