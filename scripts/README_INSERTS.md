# 📝 Generación de Scripts SQL desde Google Sheets

Este documento explica cómo generar automáticamente los scripts SQL de inserción desde la hoja `Data-campo` de Google Sheets.

## 🎯 Objetivo

Generar scripts SQL separados para insertar la jerarquía organizacional:
- **País** → **Empresa** → **Fundo** → **Sector** → **Lote**

## 📋 Requisitos Previos

1. **Python 3.7+** instalado
2. **Variables de entorno configuradas:**
   ```bash
   GOOGLE_SHEETS_SPREADSHEET_ID=tu_spreadsheet_id
   GOOGLE_SHEETS_CREDENTIALS_BASE64=tu_credentials_base64
   GOOGLE_SHEETS_TOKEN_BASE64=tu_token_base64
   ```

3. **Dependencias de Python:**
   ```bash
   pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
   ```

## 🚀 Uso

### Paso 1: Ejecutar el script Python

```bash
cd scripts
python generar_inserts_desde_sheets.py
```

### Paso 2: Archivos generados

El script creará la carpeta `scripts/generated/` con los siguientes archivos:

```
scripts/generated/
├── insert_0_ejecutar_todos.sql          # Script maestro
├── insert_1_pais_empresa_fundo.sql      # Países, empresas y fundos
├── insert_2_sectores.sql                 # Sectores (~270)
├── insert_3_lotes_part_1.sql            # Lotes parte 1 (hasta 500)
├── insert_3_lotes_part_2.sql            # Lotes parte 2 (hasta 500)
└── insert_3_lotes_part_N.sql            # Lotes parte N...
```

### Paso 3: Ejecutar en SQL Server

#### Opción A: Script Maestro (Recomendado)
```bash
# Desde la carpeta scripts/generated/
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -i insert_0_ejecutar_todos.sql
```

#### Opción B: Archivos individuales
```bash
# 1. Países, Empresas, Fundos
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -i insert_1_pais_empresa_fundo.sql

# 2. Sectores
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -i insert_2_sectores.sql

# 3. Lotes (cada archivo)
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -i insert_3_lotes_part_1.sql
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -i insert_3_lotes_part_2.sql
# ... etc
```

#### Opción C: SQL Server Management Studio (SSMS)
1. Abrir SSMS
2. Conectarse a tu servidor
3. Abrir `insert_0_ejecutar_todos.sql`
4. Ejecutar (F5)

## 📊 Estructura de Datos

### Data-campo (Google Sheets)

El script lee las columnas **B a I** de la hoja `Data-campo`:

| Col | Campo         | Descripción                    |
|-----|---------------|--------------------------------|
| B   | Empresa       | Nombre de la empresa           |
| C   | Empresa Abrev | Abreviatura de la empresa      |
| D   | Fundo         | Nombre del fundo               |
| E   | Fundo Abrev   | Abreviatura del fundo          |
| F   | Sector ID     | ID del sector                  |
| G   | Sector        | Nombre del sector              |
| H   | Lote ID       | ID del lote                    |
| I   | Lote          | Nombre del lote                |

### Jerarquía en la Base de Datos

```
image.pais
  └── image.empresa (FK: paisid)
      └── image.fundo (FK: empresaid)
          └── image.sector (FK: fundoid)
              └── image.lote (FK: sectorid)
```

## 🔧 Características del Script

### ✅ Ventajas

1. **Generación automática**: Lee directamente desde Google Sheets
2. **Archivos separados**: Evita que SQL Server se cuelgue
3. **Validación de duplicados**: Usa `IF NOT EXISTS` para evitar errores
4. **Respeta jerarquía**: Mantiene las relaciones FK correctas
5. **Manejo de caracteres especiales**: Escapa comillas simples
6. **Logs informativos**: `PRINT` en cada inserción

### 🎛️ Configuración

Puedes ajustar estas constantes en el script:

```python
# Límite de lotes por archivo (para evitar que se cuelgue)
LOTES_POR_ARCHIVO = 500  # Ajustar según necesidad
```

## 🐛 Troubleshooting

### Error: "No se pudo conectar a Google Sheets"

**Causa**: Variables de entorno no configuradas

**Solución**:
```bash
# Verificar que las variables estén configuradas
echo $GOOGLE_SHEETS_SPREADSHEET_ID
echo $GOOGLE_SHEETS_CREDENTIALS_BASE64
echo $GOOGLE_SHEETS_TOKEN_BASE64
```

### Error: "Base de datos no encontrada"

**Causa**: El schema no ha sido creado

**Solución**:
```bash
# Ejecutar primero el schema
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -i schema_agricola_luz_sombra.sql
```

### Error: "Violation of PRIMARY KEY constraint"

**Causa**: Ya existen registros con las mismas claves

**Solución**: El script usa `IF NOT EXISTS`, así que este error no debería ocurrir. Si ocurre:
1. Verificar que no hay datos duplicados en Google Sheets
2. Limpiar la base de datos y volver a ejecutar

## 📈 Ejemplo de Salida

```
====================================================================
🌱 GENERADOR DE SCRIPTS SQL DESDE GOOGLE SHEETS
====================================================================

📁 Directorio de salida: scripts/generated
✅ Autenticación exitosa con Google Sheets
📊 Leyendo datos de Data-campo...
✅ Se leyeron 3245 filas de datos

🔄 Procesando jerarquía organizacional...

📊 Estadísticas de procesamiento:
   Total de filas: 3245
   Procesadas: 3200
   Omitidas: 45

📈 Datos únicos encontrados:
   Países: 1
   Empresas: 5
   Fundos: 12
   Sectores: 270
   Lotes: 3200

====================================================================
📝 GENERANDO ARCHIVOS SQL
====================================================================

📝 Generando insert_1_pais_empresa_fundo.sql...
✅ Generado: scripts/generated/insert_1_pais_empresa_fundo.sql

📝 Generando insert_2_sectores.sql...
✅ Generado: scripts/generated/insert_2_sectores.sql

📝 Generando archivos de lotes...
   Generando parte 1/7 (500 lotes)...
   ✅ Archivo generado: scripts/generated/insert_3_lotes_part_1.sql
   Generando parte 2/7 (500 lotes)...
   ✅ Archivo generado: scripts/generated/insert_3_lotes_part_2.sql
   ...

📝 Generando script maestro...
✅ Generado: scripts/generated/insert_0_ejecutar_todos.sql

====================================================================
✅ GENERACIÓN COMPLETADA
====================================================================

📊 Archivos generados:
   1. scripts/generated/insert_1_pais_empresa_fundo.sql
   2. scripts/generated/insert_2_sectores.sql
   3.1. scripts/generated/insert_3_lotes_part_1.sql
   3.2. scripts/generated/insert_3_lotes_part_2.sql
   ...
   0. scripts/generated/insert_0_ejecutar_todos.sql (Script maestro)

🎯 Siguiente paso:
   Ejecuta el script maestro en SQL Server:
   sqlcmd -S tu_servidor -d AgricolaDB -i scripts/generated/insert_0_ejecutar_todos.sql
```

## 🔄 Actualización de Datos

Si los datos en Google Sheets cambian:

1. Re-ejecutar el script Python
2. Los archivos SQL se regenerarán
3. Ejecutar de nuevo en SQL Server (los `IF NOT EXISTS` evitarán duplicados)

## 📝 Notas Importantes

- ⚠️ **Respaldo**: Antes de ejecutar, haz un respaldo de la base de datos
- 🔒 **Producción**: Prueba primero en un ambiente de desarrollo
- 📊 **Logs**: Revisa los `PRINT` statements para verificar el progreso
- ⏱️ **Tiempo**: Puede tomar varios minutos dependiendo de la cantidad de lotes

## 🤝 Soporte

Si encuentras problemas, verifica:
1. Las variables de entorno están correctas
2. Tienes permisos de lectura en Google Sheets
3. El schema existe en SQL Server
4. No hay errores de sintaxis en Google Sheets (comillas, caracteres especiales)

