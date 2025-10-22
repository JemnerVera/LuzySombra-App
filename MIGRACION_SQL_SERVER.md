# 📊 Resumen del Proyecto: Migración a SQL Server

## 🎯 Estado Actual

### ✅ Completado
1. **Schema SQL creado**: `schema_agricola_luz_sombra.sql`
   - Tablas: País, Empresa, Fundo, Sector, Lote
   - Tablas de análisis: `analisis_imagen`, `registro_fenologia`, `historial_alerta`
   - Vistas y Stored Procedures incluidas

2. **Script Python de generación**: `generar_inserts_desde_sheets.py`
   - Lee datos desde Google Sheets (pestaña `Data-campo`)
   - Genera archivos SQL separados para evitar problemas de tamaño
   - Respeta la jerarquía: País → Empresa → Fundo → Sector → Lote
   - Crea script maestro para ejecutar todos en orden

3. **Documentación**: `README_INSERTS.md`
   - Instrucciones completas de uso
   - Troubleshooting
   - Ejemplos de ejecución

### 🚧 En Proceso
- Ejecutar el script Python para generar los SQL
- Ejecutar los SQL en SQL Server

## 📁 Estructura del Proyecto

```
agricola-nextjs/
├── src/
│   ├── app/                      # Next.js App (API Routes)
│   │   └── api/
│   │       ├── google-sheets/    # Actualmente usando Sheets
│   │       ├── historial/
│   │       └── procesar-imagen/
│   ├── components/               # React Components
│   ├── services/
│   │   └── googleSheetsService.ts  # 🔄 A migrar a SQL
│   └── types/
│
├── scripts/
│   ├── schema_agricola_luz_sombra.sql       # ✅ Schema completo
│   ├── generar_inserts_desde_sheets.py      # ✅ Generador de inserts
│   ├── README_INSERTS.md                     # ✅ Documentación
│   ├── insert_jerarquia_organizacional.sql  # ⚠️ Antiguo (incompleto)
│   └── generated/                            # 📁 Archivos SQL generados
│       ├── insert_0_ejecutar_todos.sql      # Script maestro
│       ├── insert_1_pais_empresa_fundo.sql  # Nivel 1-3
│       ├── insert_2_sectores.sql            # Nivel 4
│       └── insert_3_lotes_part_*.sql        # Nivel 5 (múltiples archivos)
│
└── dataset/                      # Datos de prueba para ML
    ├── imagenes/
    └── anotaciones/
```

## 🗄️ Arquitectura de Base de Datos

### Jerarquía Organizacional
```
┌──────────────────────────────────────────────────────────────┐
│ image.pais (País)                                             │
│ ├── paisid (PK)                                               │
│ ├── pais: "Perú"                                              │
│ └── paisabrev: "PE"                                           │
└──────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│ image.empresa (Empresa)                                       │
│ ├── empresaid (PK)                                            │
│ ├── paisid (FK) → image.pais                                 │
│ ├── empresa: "AGRICOLA ANDREA"                                │
│ └── empresabrev: "AGA"                                        │
└──────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│ image.fundo (Fundo)                                           │
│ ├── fundoid (PK)                                              │
│ ├── empresaid (FK) → image.empresa                           │
│ ├── fundo: "FUNDO CALIFORNIA"                                 │
│ └── fundoabrev: "CAL"                                         │
└──────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│ image.sector (Sector)                                         │
│ ├── sectorid (PK)                                             │
│ ├── fundoid (FK) → image.fundo                               │
│ ├── sector: "[2779] CAL DIST2 C011 ACR"                      │
│ └── sectorbrev: "CAL DIST2 C011 ACR"                         │
└──────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────────────────────┐
│ image.lote (Lote)                                             │
│ ├── loteid (PK)                                               │
│ ├── sectorid (FK) → image.sector                             │
│ ├── lote: "[1] Lote 1"                                        │
│ └── lotebrev: "Lote 1"                                        │
└──────────────────────────────────────────────────────────────┘
```

### Tablas de Análisis
```
┌──────────────────────────────────────────────────────────────┐
│ image.analisis_imagen                                         │
│ ├── analisisid (PK)                                           │
│ ├── loteid (FK) → image.lote                                 │
│ ├── hilera, planta                                            │
│ ├── porcentaje_luz, porcentaje_sombra                        │
│ ├── latitud, longitud                                         │
│ └── processed_image_url                                       │
└──────────────────────────────────────────────────────────────┘
```

## 🔄 Migración: De Google Sheets a SQL Server

### Google Sheets (Actual)
- **Pestaña**: `Data-campo` (jerarquía organizacional)
- **Pestaña**: `Data-app` (análisis de imágenes)
- **Ventajas**: Fácil de usar, no requiere servidor
- **Desventajas**: Lento, límites de API, no transaccional

### SQL Server (Nuevo)
- **Base de datos**: `AgricolaDB`
- **Schema**: `image`
- **Ventajas**: Rápido, transaccional, escalable, relacional
- **Desventajas**: Requiere servidor, más complejo

## 📝 Próximos Pasos

### 1. Generar SQL Inserts (Python)
```bash
cd scripts
python generar_inserts_desde_sheets.py
```

**Salida esperada**:
```
scripts/generated/
├── insert_0_ejecutar_todos.sql
├── insert_1_pais_empresa_fundo.sql
├── insert_2_sectores.sql
├── insert_3_lotes_part_1.sql
├── insert_3_lotes_part_2.sql
└── ...
```

### 2. Ejecutar en SQL Server
```bash
# Opción A: Script maestro
sqlcmd -S tu_servidor -d AgricolaDB -i scripts/generated/insert_0_ejecutar_todos.sql

# Opción B: Desde SSMS
# Abrir insert_0_ejecutar_todos.sql y ejecutar (F5)
```

### 3. Crear Servicio SQL en Next.js
```typescript
// src/services/sqlServerService.ts
import sql from 'mssql';

class SqlServerService {
  async getFieldData() {
    const result = await sql.query`
      SELECT * FROM image.v_jerarquia_completa
    `;
    return result.recordset;
  }
  
  async saveAnalysisResult(data) {
    await sql.query`
      EXEC image.sp_registrar_analisis 
        @loteid=${data.loteid},
        @hilera=${data.hilera},
        ...
    `;
  }
}
```

### 4. Actualizar API Routes
```typescript
// src/app/api/field-data/route.ts (nuevo)
import { sqlServerService } from '@/services/sqlServerService';

export async function GET() {
  const data = await sqlServerService.getFieldData();
  return NextResponse.json(data);
}
```

### 5. Actualizar Frontend
- Los componentes NO necesitan cambios
- Solo cambiar la URL del endpoint si es necesario

## 📊 Datos Esperados

Según el schema:
- **1** País (Perú)
- **5** Empresas
- **12** Fundos
- **~270** Sectores
- **~3000+** Lotes (depende de Data-campo)

## 🔧 Configuración

### Variables de Entorno Necesarias
```env
# Google Sheets (para leer datos)
GOOGLE_SHEETS_SPREADSHEET_ID=xxx
GOOGLE_SHEETS_CREDENTIALS_BASE64=xxx
GOOGLE_SHEETS_TOKEN_BASE64=xxx

# SQL Server (para la app)
SQL_SERVER_HOST=localhost
SQL_SERVER_PORT=1433
SQL_SERVER_DATABASE=AgricolaDB
SQL_SERVER_USER=sa
SQL_SERVER_PASSWORD=xxx
```

### Dependencias Python
```bash
pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

### Dependencias Node.js (para SQL)
```bash
npm install mssql
```

## 🎯 Ventajas de la Migración

1. **Performance**: Consultas más rápidas
2. **Escalabilidad**: Soporta miles de registros sin problemas
3. **Integridad**: Foreign keys garantizan consistencia
4. **Transacciones**: ACID compliance
5. **Consultas complejas**: JOINs, agregaciones, etc.
6. **Seguridad**: Control de acceso granular
7. **Backup**: Respaldos automáticos

## ⚠️ Consideraciones

1. **Compatibilidad**: Mantener Google Sheets como backup temporal
2. **Testing**: Probar exhaustivamente antes de producción
3. **Rollback**: Tener plan de contingencia
4. **Documentación**: Mantener actualizada
5. **Monitoreo**: Logs y alertas en SQL Server

## 📞 Contacto

Para dudas o problemas con la migración, revisar:
- `README_INSERTS.md` (documentación detallada)
- `schema_agricola_luz_sombra.sql` (estructura de BD)
- Logs de ejecución de los scripts

