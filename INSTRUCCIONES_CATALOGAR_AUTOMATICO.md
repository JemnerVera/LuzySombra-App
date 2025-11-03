# 🐍 Instrucciones: Catalogar Schemas Automáticamente con Python

## 🎯 Objetivo

Usar un script Python para conectarse automáticamente a la base de datos y generar un catálogo completo de todas las estructuras de tablas.

## 📋 Requisitos Previos

### 1. Instalar Python

Si no tienes Python instalado:
- Descargar desde: https://www.python.org/downloads/
- Versión recomendada: Python 3.8 o superior

### 2. Instalar pyodbc

```bash
pip install pyodbc
```

**Nota para Windows**: Es posible que necesites instalar el "ODBC Driver 17 for SQL Server":
- Descargar desde: https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server

### 3. Verificar .env.local

Asegúrate de que el archivo `.env.local` existe y tiene las credenciales correctas:
- `SQL_SERVER=***REMOVED***`
- `SQL_DATABASE=***REMOVED***`
- `SQL_USER=ucser_powerbi_desa` (o ***REMOVED***)
- `SQL_PASSWORD=D3s4S3r03` (o ***REMOVED***)

## 🚀 Ejecutar Script

### Opción 1: Desde línea de comandos

```bash
cd scripts
python catalogar_schemas.py
```

### Opción 2: Desde la raíz del proyecto

```bash
python scripts/catalogar_schemas.py
```

## 📊 Resultados Generados

El script generará dos archivos:

1. **`CATALOGO_SCHEMAS_TABLAS.md`** - Catálogo completo en formato Markdown
   - Estructura de todas las tablas
   - Primary Keys
   - Foreign Keys
   - Índices
   - Estadísticas

2. **`CATALOGO_SCHEMAS_TABLAS.json`** - Datos en formato JSON
   - Útil para procesamiento programático
   - Puede usarse para validaciones automáticas

## ✅ Ventajas del Script Python

- ✅ **Automático**: No requiere ejecutar queries manualmente
- ✅ **Completo**: Extrae columnas, PKs, FKs, índices, conteo de registros
- ✅ **Rápido**: Procesa todas las tablas en segundos
- ✅ **Documentado**: Genera Markdown listo para usar
- ✅ **Reproducible**: Puede ejecutarse cuantas veces sea necesario

## 🔍 Qué Verifica el Script

Para cada tabla:
- ✅ Todas las columnas con tipos de datos
- ✅ Primary Keys
- ✅ Foreign Keys y sus relaciones
- ✅ Índices
- ✅ Conteo de registros
- ✅ Información de nullable/default

## 📝 Ejemplo de Salida

```
🔍 Catalogando schemas de tablas existentes...

✅ Conectado a ***REMOVED***/***REMOVED***
📊 Verificando MAST.USERS... ✅ (14 columnas, 25 registros)
📊 Verificando MAST.ORIGIN... ✅ (8 columnas, 5 registros)
📊 Verificando GROWER.GROWERS... ✅ (12 columnas, 15 registros)
...

📝 Generando catálogo...
✅ Catálogo generado: CATALOGO_SCHEMAS_TABLAS.md
✅ JSON generado: CATALOGO_SCHEMAS_TABLAS.json

✅ ¡Catálogo completo generado exitosamente!
```

## ⚠️ Troubleshooting

### Error: "pyodbc no está instalado"
```bash
pip install pyodbc
```

### Error: "No se encontró .env.local"
- Verificar que el archivo existe en la raíz del proyecto
- Verificar que tiene las credenciales correctas

### Error: "ODBC Driver 17 for SQL Server not found"
- Instalar el driver desde Microsoft
- O usar otro driver disponible: `DRIVER={{SQL Server}}` en lugar de `DRIVER={{ODBC Driver 17 for SQL Server}}`

### Error de conexión
- Verificar que el servidor es accesible desde tu red
- Verificar credenciales
- Verificar que el firewall permite la conexión

---

**Archivo del script**: `scripts/catalogar_schemas.py`

