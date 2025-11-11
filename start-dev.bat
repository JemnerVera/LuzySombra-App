@echo off
cls
echo ========================================
echo   Agricola Luz-Sombra - Desarrollo
echo ========================================
echo.

cd /d "%~dp0"

echo [INFO] Liberando puertos 3000 y 3001...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3001"') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":3000"') do taskkill /F /PID %%a >nul 2>&1
timeout /t 2 /nobreak >nul

echo [INFO] Iniciando servidores...
echo Backend:  http://localhost:3001
echo Frontend: http://localhost:3000
echo.

start "Backend" cmd /k "cd /d %~dp0backend && npm run dev"
timeout /t 2 /nobreak >nul
start "Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"
timeout /t 5 /nobreak >nul

start http://localhost:3000

echo.
echo Servidores iniciados!
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
