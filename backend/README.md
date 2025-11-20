# Agricola Backend API

Backend API para aplicación agrícola - Node.js + Express

## Instalación

```bash
npm install --legacy-peer-deps
```

## Desarrollo

```bash
npm run dev
```

El servidor se iniciará en `http://localhost:3001`

## Build

```bash
npm run build
npm start
```

## Variables de Entorno

Crear archivo `.env` en el directorio `backend/`:

```bash
# SQL Server Configuration
SQL_SERVER=your_server_ip_or_hostname
SQL_DATABASE=your_database_name
SQL_PORT=1433
SQL_USER=your_sql_user
SQL_PASSWORD=your_sql_password
SQL_ENCRYPT=true

# Server Configuration
PORT=3001
FRONTEND_URL=http://localhost:3000

# Data Source (sql | google_sheets)
DATA_SOURCE=sql

# Development
NODE_ENV=development
```

**⚠️ IMPORTANTE**: El archivo `.env` contiene credenciales sensibles y NO debe commitrearse.

## Diagnóstico de Conectividad

Si tienes problemas de conexión a SQL Server, ejecuta el script de diagnóstico:

```bash
# Windows
.\test-connectivity.bat

# O directamente con PowerShell
powershell -ExecutionPolicy Bypass -File test-connectivity.ps1
```

Este script verificará:
- Conectividad de red (ping)
- Accesibilidad del puerto 1433
- Resolución DNS
- Conexión TCP

## Solución de Problemas

### Error ESOCKET / ETIMEDOUT

**Síntomas:**
- `Failed to connect to 10.1.10.4:1433 - Could not connect (sequence)`
- `ETIMEDOUT` después de ~21 segundos

**Soluciones:**
1. **Conectar a la VPN de la empresa** (más común)
   - La IP `10.1.10.4` es privada y requiere VPN
   - Verificar que la VPN esté conectada y activa

2. **Verificar firewall**
   - Asegurarse de que el puerto 1433 no esté bloqueado
   - Verificar reglas de firewall de Windows

3. **Verificar con SSMS**
   - Intentar conectar con SQL Server Management Studio
   - Si SSMS funciona, el problema puede ser de configuración
   - Si SSMS no funciona, el problema es de red/VPN

4. **Verificar ping**
   ```bash
   ping 10.1.10.4
   ```
   - Si el ping funciona pero SQL no, puede ser firewall
   - Si el ping no funciona, es problema de VPN/red

### Error ELOGIN

**Síntomas:**
- `Login failed for user`
- `Authentication failed`

**Soluciones:**
- Verificar credenciales en `.env`
- Contactar al DBA para verificar permisos del usuario

## Estructura

```
backend/
├── src/
│   ├── routes/          # API routes
│   ├── services/        # Business logic
│   ├── lib/            # Database connection
│   ├── utils/          # Utilities
│   └── types/          # TypeScript types
├── package.json
├── tsconfig.json
└── .env.example
```

## API Endpoints

- `GET /api/health` - Health check
- `GET /api/test-db` - Test database connection (con diagnóstico detallado)
- `GET /api/field-data` - Get hierarchical field data
- `POST /api/procesar-imagen` - Process image and save to DB
- `POST /api/test-model` - Test model (doesn't save to DB)
- `POST /api/check-gps-info` - Check GPS info from image
- `GET /api/historial` - Get processing history
- `GET /api/tabla-consolidada` - Get consolidated table
- `GET /api/tabla-consolidada/detalle` - Get lot detail history
- `GET /api/tabla-consolidada/detalle-planta` - Get plant detail
- `GET /api/imagen` - Get image by ID
- `GET /api/estadisticas` - Get statistics

## Testing

```bash
npm run test
```

Esto ejecutará pruebas de conexión a la base de datos.

## Logs de Debug

El backend incluye logs detallados para diagnóstico:

- `🔧 [DB]` - Configuración de conexión
- `🔌 [DB]` - Intento de conexión
- `✅ [DB]` - Conexión exitosa
- `❌ [DB]` - Error de conexión
- `📊 [DB]` - Ejecución de queries
- `🔍 [DIAGNÓSTICO]` - Información de diagnóstico

Todos los logs incluyen:
- Tiempo de ejecución
- Códigos de error
- Mensajes de diagnóstico
- Sugerencias de solución
