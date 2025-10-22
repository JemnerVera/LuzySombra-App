# 🐍 Guía de Instalación de Python y Ejecución del Script

## 📥 Paso 1: Instalar Python

### Descargar Python
1. Ve a: https://www.python.org/downloads/
2. Descarga la última versión estable (Python 3.11 o superior)
3. Ejecuta el instalador

### ⚠️ IMPORTANTE durante la instalación:
- ✅ **Marca la casilla**: "Add Python to PATH" (en la primera pantalla)
- ✅ Selecciona "Install Now" o "Customize installation"
- ✅ Si personalizas, asegúrate de marcar:
  - pip (gestor de paquetes)
  - Add Python to environment variables

### Verificar instalación
Abre una nueva ventana de PowerShell y ejecuta:
```powershell
python --version
```

Deberías ver algo como: `Python 3.11.x`

---

## 📦 Paso 2: Instalar Dependencias

En PowerShell (nueva ventana después de instalar Python):

```powershell
# Navegar al proyecto
cd "C:\Users\jverac\Documents\Migiva\Proyecto\Apps\Luz-sombra\agricola-nextjs"

# Instalar dependencias de Google Sheets
pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

---

## ⚙️ Paso 3: Verificar Variables de Entorno

Asegúrate de tener configuradas las variables de entorno en tu archivo `.env` o `.env.local`:

```env
GOOGLE_SHEETS_SPREADSHEET_ID=tu_spreadsheet_id
GOOGLE_SHEETS_CREDENTIALS_BASE64=tu_credentials_base64
GOOGLE_SHEETS_TOKEN_BASE64=tu_token_base64
```

Para verificar (en PowerShell):
```powershell
# Ver variables de entorno
$env:GOOGLE_SHEETS_SPREADSHEET_ID
$env:GOOGLE_SHEETS_CREDENTIALS_BASE64
$env:GOOGLE_SHEETS_TOKEN_BASE64
```

Si no están configuradas, configúralas:
```powershell
# Temporalmente en PowerShell (esta sesión solamente)
$env:GOOGLE_SHEETS_SPREADSHEET_ID = "tu_valor_aqui"
$env:GOOGLE_SHEETS_CREDENTIALS_BASE64 = "tu_valor_aqui"
$env:GOOGLE_SHEETS_TOKEN_BASE64 = "tu_valor_aqui"
```

O mejor, agrégalas al archivo `.env.local` en la raíz del proyecto.

---

## 🚀 Paso 4: Ejecutar el Script

```powershell
# Navegar a la carpeta scripts
cd "C:\Users\jverac\Documents\Migiva\Proyecto\Apps\Luz-sombra\agricola-nextjs\scripts"

# Ejecutar el script
python generar_inserts_desde_sheets.py
```

---

## 📊 Salida Esperada

Deberías ver algo como:

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
   ...

✅ GENERACIÓN COMPLETADA
```

---

## ✅ Paso 5: Verificar Archivos Generados

Los archivos SQL estarán en:
```
scripts/generated/
├── insert_0_ejecutar_todos.sql
├── insert_1_pais_empresa_fundo.sql
├── insert_2_sectores.sql
├── insert_3_lotes_part_1.sql
├── insert_3_lotes_part_2.sql
└── ...
```

---

## 🎯 Siguiente Paso: Ejecutar en SQL Server

Una vez generados los archivos SQL, ejecuta en SQL Server:

### Opción A: sqlcmd (Línea de comandos)
```powershell
cd scripts/generated
sqlcmd -S tu_servidor -U tu_usuario -P tu_password -d AgricolaDB -i insert_0_ejecutar_todos.sql
```

### Opción B: SQL Server Management Studio (SSMS)
1. Abrir SSMS
2. Conectarse a tu servidor
3. Abrir el archivo: `scripts/generated/insert_0_ejecutar_todos.sql`
4. Ejecutar (F5)

---

## 🐛 Solución de Problemas

### Error: "python no se encuentra"
**Solución**: 
1. Reinstala Python marcando "Add to PATH"
2. O cierra y abre una nueva ventana de PowerShell

### Error: "pip no se encuentra"
**Solución**:
```powershell
python -m ensurepip --upgrade
python -m pip install --upgrade pip
```

### Error: "No se pudo conectar a Google Sheets"
**Solución**:
1. Verifica que las variables de entorno estén configuradas
2. Verifica que tienes acceso al Google Spreadsheet
3. Verifica que las credenciales sean válidas

### Error: "Permission denied al crear carpeta"
**Solución**:
```powershell
# Crear la carpeta manualmente
New-Item -ItemType Directory -Path "scripts\generated" -Force
```

---

## 📝 Checklist de Instalación

- [ ] Python instalado (versión 3.11+)
- [ ] Python en PATH (ejecutar `python --version`)
- [ ] pip instalado (ejecutar `pip --version`)
- [ ] Dependencias instaladas (`google-api-python-client`, etc.)
- [ ] Variables de entorno configuradas
- [ ] Script ejecutado exitosamente
- [ ] Archivos SQL generados en `scripts/generated/`
- [ ] Listos para ejecutar en SQL Server

---

¡Una vez instalado Python, avísame y ejecutamos el script! 🚀

