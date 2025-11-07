# 📝 Crear archivo .env para Backend

## Pasos

1. **Copiar el archivo `.env.example` a `.env`**:
   ```bash
   copy .env.example .env
   ```

2. **Editar el archivo `.env`** y configurar las siguientes variables:

### Variables Requeridas

```bash
# Server Configuration
PORT=3001
NODE_ENV=development

# SQL Server Configuration (CRÍTICO)
SQL_SERVER=tu_servidor_sql
SQL_DATABASE=tu_base_de_datos
SQL_PORT=1433
SQL_USER=tu_usuario_sql
SQL_PASSWORD=tu_contraseña_sql
SQL_ENCRYPT=true

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000

# Data Source Configuration
DATA_SOURCE=sql
```

### Variables Opcionales

```bash
# Google Sheets (si se usa)
GOOGLE_SHEETS_SPREADSHEET_ID=...
GOOGLE_SHEETS_SHEET_NAME=Data-app
GOOGLE_SHEETS_CREDENTIALS_BASE64=...
GOOGLE_SHEETS_TOKEN_BASE64=...

# Alertas (fallback)
ALERTAS_EMAIL_DESTINATARIOS=["admin@example.com"]
ALERTAS_EMAIL_CC=["manager@example.com"]
```

## Importante

- ⚠️ **NO commitear** el archivo `.env` (ya está en `.gitignore`)
- 🔒 El archivo contiene credenciales sensibles
- ✅ Usar las mismas credenciales que el proyecto Next.js original

## Verificar

Después de crear el `.env`, ejecutar:
```bash
npm test
```

Esto verificará que todas las variables estén configuradas correctamente.

