# Script PowerShell para ejecutar el explorador de Data-campo
# Carga las variables de entorno desde .env.local y ejecuta el script Python

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "EXPLORADOR DE DATA-CAMPO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Ruta al archivo .env.local
$envFile = "..\.env.local"

if (!(Test-Path $envFile)) {
    Write-Host "[ERROR] No se encontro el archivo .env.local" -ForegroundColor Red
    exit 1
}

Write-Host "[*] Cargando variables de entorno..." -ForegroundColor Green

# Leer y cargar variables de entorno
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        $value = $value -replace '^["'']|["'']$', ''
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

Write-Host "[OK] Variables cargadas" -ForegroundColor Green
Write-Host ""

# Ejecutar el script Python explorador
$pythonPath = "C:\Users\jverac\AppData\Local\Programs\Python\Python313\python.exe"
$scriptPath = "explorar_data_campo.py"

& $pythonPath $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Exploracion completada!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[ERROR] Hubo un problema durante la exploracion" -ForegroundColor Red
}

