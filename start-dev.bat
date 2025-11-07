@echo off
cls
echo ========================================
echo   Agricola Luz-Sombra - Desarrollo
echo   Backend: Node.js + Express
echo   Frontend: React + Vite
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

REM Detener procesos anteriores si existen
echo [INFO] Deteniendo procesos anteriores...
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Iniciar backend en nueva ventana CMD
echo [INFO] Iniciando backend...
start "Backend - Agricola Luz-Sombra" cmd /k "cd /d %~dp0backend && npm run dev"

REM Esperar un poco para que el backend inicie
timeout /t 3 /nobreak >nul

REM Iniciar frontend en nueva ventana CMD
echo [INFO] Iniciando frontend...
start "Frontend - Agricola Luz-Sombra" cmd /k "cd /d %~dp0frontend && npm run dev"

REM Esperar a que los servidores estén listos
echo.
echo [INFO] Esperando a que los servidores estén listos...
timeout /t 8 /nobreak >nul

REM Abrir navegador
echo [INFO] Abriendo navegador...
start http://localhost:3000

echo.
echo ========================================
echo   Servidores iniciados correctamente!
echo ========================================
echo.
echo Backend:  http://localhost:3001
echo Frontend: http://localhost:3000
echo.
echo Presiona cualquier tecla para cerrar esta ventana
echo (Los servidores continuarán ejecutándose en las ventanas separadas)
echo.
pause >nul
