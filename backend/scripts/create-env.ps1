# Script para crear archivo .env desde .env.example
# Ejecutar: .\scripts\create-env.ps1

Write-Host "🔧 Creando archivo .env para backend..." -ForegroundColor Cyan

$envExamplePath = Join-Path $PSScriptRoot ".." ".env.example"
$envPath = Join-Path $PSScriptRoot ".." ".env"

if (-not (Test-Path $envExamplePath)) {
    Write-Host "❌ No se encontró .env.example" -ForegroundColor Red
    Write-Host "   Creando .env.example primero..." -ForegroundColor Yellow
    
    $envExampleContent = @"
# Server Configuration
PORT=3001
NODE_ENV=development

# SQL Server Configuration
SQL_SERVER=your_server_ip_or_hostname
SQL_DATABASE=your_database_name
SQL_PORT=1433
SQL_USER=your_sql_user
SQL_PASSWORD=your_sql_password
SQL_ENCRYPT=true

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000

# Data Source Configuration
DATA_SOURCE=sql

# Google Sheets (opcional)
GOOGLE_SHEETS_SPREADSHEET_ID=your_spreadsheet_id
GOOGLE_SHEETS_SHEET_NAME=Data-app
GOOGLE_SHEETS_CREDENTIALS_BASE64=your_credentials_base64
GOOGLE_SHEETS_TOKEN_BASE64=your_token_base64

# Alertas (fallback)
ALERTAS_EMAIL_DESTINATARIOS=["admin@example.com"]
ALERTAS_EMAIL_CC=["manager@example.com"]
"@
    
    Set-Content -Path $envExamplePath -Value $envExampleContent
    Write-Host "✅ .env.example creado" -ForegroundColor Green
}

if (Test-Path $envPath) {
    Write-Host "⚠️  El archivo .env ya existe" -ForegroundColor Yellow
    $overwrite = Read-Host "¿Deseas sobrescribirlo? (s/n)"
    if ($overwrite -ne "s") {
        Write-Host "❌ Operación cancelada" -ForegroundColor Red
        exit
    }
}

Copy-Item -Path $envExamplePath -Destination $envPath
Write-Host "✅ Archivo .env creado desde .env.example" -ForegroundColor Green
Write-Host ""
Write-Host "📝 IMPORTANTE: Edita el archivo .env y configura:" -ForegroundColor Yellow
Write-Host "   - SQL_SERVER" -ForegroundColor Yellow
Write-Host "   - SQL_DATABASE" -ForegroundColor Yellow
Write-Host "   - SQL_USER" -ForegroundColor Yellow
Write-Host "   - SQL_PASSWORD" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Puedes copiar estas variables del .env.local del proyecto Next.js principal" -ForegroundColor Cyan

