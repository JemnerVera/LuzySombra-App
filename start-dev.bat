@echo off
cls
echo ========================================
echo   Agricola Luz-Sombra - Desarrollo
echo ========================================
echo.

cd /d "%~dp0"

echo [INFO] Limpiando procesos anteriores...
echo.

REM Método 1: Buscar procesos específicos en los puertos ANTES de cerrar todos los procesos de Node.js
echo [1/5] Buscando procesos específicos en puertos 3000 y 3001...
setlocal enabledelayedexpansion
set found=0

REM Para puerto 3001
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001" ^| findstr "LISTENING"') do (
    set pid=%%a
    if not "!pid!"=="" (
        echo     Cerrando proceso PID !pid! en puerto 3001...
        taskkill /F /PID !pid! >nul 2>&1
        set found=1
    )
)

REM Para puerto 3000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do (
    set pid=%%a
    if not "!pid!"=="" (
        echo     Cerrando proceso PID !pid! en puerto 3000...
        taskkill /F /PID !pid! >nul 2>&1
        set found=1
    )
)

if !found! equ 0 (
    echo     - No se encontraron procesos en los puertos
)
endlocal

REM Método 1.5: Cerrar TODOS los procesos de node.exe que puedan estar usando los puertos
echo [2/5] Cerrando procesos de Node.js relacionados con los puertos...
setlocal enabledelayedexpansion
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001 :3000" ^| findstr "LISTENING"') do (
    set pid=%%a
    if not "!pid!"=="" (
        wmic process where "ProcessId=!pid!" get ExecutablePath 2>nul | findstr /i "node.exe" >nul
        if !errorlevel! equ 0 (
            echo     Cerrando proceso Node.js PID !pid!...
            taskkill /F /PID !pid! >nul 2>&1
        )
    )
)
endlocal

echo [3/5] Cerrando ventanas de cmd de desarrollo...
REM Cerrar ventanas de cmd con títulos específicos (Backend/Frontend)
taskkill /FI "WINDOWTITLE eq Backend*" /FI "IMAGENAME eq cmd.exe" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq Frontend*" /FI "IMAGENAME eq cmd.exe" /F >nul 2>&1

REM Método 3: Buscar procesos de nodemon (si están corriendo)
echo [4/5] Cerrando procesos de nodemon...
taskkill /F /IM nodemon.cmd >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Backend*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Frontend*" >nul 2>&1

REM Método 4: Buscar y cerrar procesos de Vite (frontend)
echo [5/5] Cerrando procesos de Vite/nodemon...
setlocal enabledelayedexpansion
for /f "tokens=2" %%a in ('tasklist /FI "IMAGENAME eq node.exe" /FO LIST 2^>nul ^| findstr "PID"') do (
    wmic process where "ProcessId=%%a" get CommandLine 2>nul | findstr /i "vite\|nodemon" >nul
    if !errorlevel! equ 0 (
        echo     Cerrando proceso Vite/nodemon PID %%a...
        taskkill /F /PID %%a >nul 2>&1
    )
)
endlocal

echo.
echo [INFO] Esperando a que los puertos se liberen...
timeout /t 5 /nobreak >nul

REM Verificar que los puertos estén libres (intentos múltiples)
echo [INFO] Verificando puertos...
set max_attempts=5
set attempt=1
set port3001_free=0
set port3000_free=0

:check_ports
if %attempt% gtr %max_attempts% (
    echo     ⚠ No se pudieron liberar todos los puertos después de %max_attempts% intentos
    goto :ports_check_done
)

REM Verificar puerto 3001
netstat -ano | findstr ":3001" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    if %attempt% equ 1 (
        echo     ⚠ Puerto 3001 aún en uso, reintentando...
    )
    REM Intentar cerrar cualquier proceso que use el puerto 3001
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3001" ^| findstr "LISTENING"') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    set port3001_free=0
) else (
    if %attempt% equ 1 (
        echo     ✓ Puerto 3001 libre
    )
    set port3001_free=1
)

REM Verificar puerto 3000
netstat -ano | findstr ":3000" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    if %attempt% equ 1 (
        echo     ⚠ Puerto 3000 aún en uso, reintentando...
    )
    REM Intentar cerrar cualquier proceso que use el puerto 3000
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do (
        taskkill /F /PID %%a >nul 2>&1
    )
    set port3000_free=0
) else (
    if %attempt% equ 1 (
        echo     ✓ Puerto 3000 libre
    )
    set port3000_free=1
)

REM Si ambos puertos están libres, salir del loop
if %port3001_free% equ 1 if %port3000_free% equ 1 goto :ports_check_done

REM Esperar antes del siguiente intento
if %attempt% lss %max_attempts% (
    timeout /t 2 /nobreak >nul
    set /a attempt+=1
    goto :check_ports
)

:ports_check_done
if %port3001_free% equ 0 (
    echo     ❌ ADVERTENCIA: El puerto 3001 aún está en uso
    echo     Intenta cerrar manualmente cualquier proceso que lo esté usando
)
if %port3000_free% equ 0 (
    echo     ❌ ADVERTENCIA: El puerto 3000 aún está en uso
    echo     Intenta cerrar manualmente cualquier proceso que lo esté usando
)
echo.

echo [INFO] Verificando dependencias...
if not exist "backend\node_modules" (
    echo     ⚠ node_modules no encontrado en backend. Instalando dependencias...
    cd /d "%~dp0backend"
    call npm install --legacy-peer-deps
    if %errorlevel% neq 0 (
        echo     ❌ Error instalando dependencias del backend
        pause
        exit /b 1
    )
    cd /d "%~dp0"
    echo     ✓ Dependencias del backend instaladas
) else (
    echo     ✓ Dependencias del backend OK
)

if not exist "frontend\node_modules" (
    echo     ⚠ node_modules no encontrado en frontend. Instalando dependencias...
    cd /d "%~dp0frontend"
    call npm install
    if %errorlevel% neq 0 (
        echo     ❌ Error instalando dependencias del frontend
        pause
        exit /b 1
    )
    cd /d "%~dp0"
    echo     ✓ Dependencias del frontend instaladas
) else (
    echo     ✓ Dependencias del frontend OK
)
echo.

echo [INFO] Iniciando servidores...
echo Backend:  http://localhost:3001
echo Frontend: http://localhost:3000
echo.
echo [INFO] Configurando variables de entorno...
set NODE_ENV=development
set PORT=3001
echo     ✓ NODE_ENV=development
echo     ✓ PORT=3001
echo.

echo [INFO] Iniciando Backend en puerto 3001...
start "Backend" cmd /k "cd /d %~dp0backend && set PORT=3001 && set NODE_ENV=development && npm run dev"
timeout /t 3 /nobreak >nul

echo [INFO] Iniciando Frontend en puerto 3000...
start "Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"
timeout /t 8 /nobreak >nul

echo [INFO] Abriendo navegador...
start http://localhost:3000

echo.
echo Servidores iniciados!
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
