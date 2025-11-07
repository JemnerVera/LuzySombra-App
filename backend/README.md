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
```

**⚠️ IMPORTANTE**: El archivo `.env` contiene credenciales sensibles y NO debe commitrearse.

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
- `GET /api/test-db` - Test database connection
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
