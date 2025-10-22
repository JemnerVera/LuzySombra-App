# Script PowerShell para ejecutar el generador de inserts SQL
# Carga las variables de entorno desde .env.local y ejecuta el script Python

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "GENERADOR DE SCRIPTS SQL" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Ruta al archivo .env.local
$envFile = "..\.env.local"

if (!(Test-Path $envFile)) {
    Write-Host "[ERROR] No se encontro el archivo .env.local" -ForegroundColor Red
    Write-Host "Por favor, crea el archivo .env.local en la raiz del proyecto" -ForegroundColor Yellow
    exit 1
}

Write-Host "[*] Cargando variables de entorno desde .env.local..." -ForegroundColor Green

# Leer y cargar variables de entorno
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        # Remover comillas si existen
        $value = $value -replace '^["'']|["'']$', ''
        
        # Establecer variable de entorno
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
        
        if ($name -like "*SPREADSHEET_ID") {
            Write-Host "   GOOGLE_SHEETS_SPREADSHEET_ID: $value" -ForegroundColor Gray
        }
    }
}

Write-Host ""

# Verificar que las variables necesarias esten configuradas
$spreadsheetId = [Environment]::GetEnvironmentVariable("GOOGLE_SHEETS_SPREADSHEET_ID", "Process")
$credentials = [Environment]::GetEnvironmentVariable("GOOGLE_SHEETS_CREDENTIALS_BASE64", "Process")
$token = [Environment]::GetEnvironmentVariable("GOOGLE_SHEETS_TOKEN_BASE64", "Process")

if ([string]::IsNullOrEmpty($spreadsheetId) -or 
    [string]::IsNullOrEmpty($credentials) -or 
    [string]::IsNullOrEmpty($token)) {
    Write-Host "[ERROR] Variables de entorno no configuradas correctamente" -ForegroundColor Red
    Write-Host "Asegurate de tener en .env.local:" -ForegroundColor Yellow
    Write-Host "   - GOOGLE_SHEETS_SPREADSHEET_ID" -ForegroundColor Yellow
    Write-Host "   - GOOGLE_SHEETS_CREDENTIALS_BASE64" -ForegroundColor Yellow
    Write-Host "   - GOOGLE_SHEETS_TOKEN_BASE64" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Variables de entorno cargadas correctamente" -ForegroundColor Green
Write-Host ""

# Ejecutar el script Python
Write-Host "[*] Ejecutando generador de SQL..." -ForegroundColor Cyan
Write-Host ""

$pythonPath = "C:\Users\jverac\AppData\Local\Programs\Python\Python313\python.exe"
$scriptPath = "generar_inserts_desde_sheets.py"

& $pythonPath $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "[OK] Generacion completada exitosamente!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Los archivos SQL se encuentran en: scripts/generated/" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "[ERROR] Hubo un problema durante la generacion" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
}

