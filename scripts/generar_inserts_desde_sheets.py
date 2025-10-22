#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para generar archivos SQL de inserción desde Google Sheets
Respeta la jerarquía: País -> Empresa -> Fundo -> Sector -> Lote
Compatible con filtros en cascada del frontend
"""

import os
import sys
import json

# Configurar encoding para Windows
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from collections import defaultdict
import base64

def cargar_env():
    """Cargar variables de entorno desde .env.local"""
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env.local')
    if os.path.exists(env_path):
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    os.environ[key.strip()] = value.strip()
        print("[OK] Variables de entorno cargadas desde .env.local")
    else:
        print("[!] Archivo .env.local no encontrado, usando variables del sistema")

# =====================================================
# CONFIGURACIÓN (se cargará después de cargar .env)
# =====================================================
SHEET_NAME = 'Data-campo'

# Archivos de salida
OUTPUT_DIR = 'generated'
FILE_1 = f'{OUTPUT_DIR}/insert_1_pais_empresa_fundo.sql'
FILE_2 = f'{OUTPUT_DIR}/insert_2_sectores.sql'
FILE_3_PREFIX = f'{OUTPUT_DIR}/insert_3_lotes_part'  # Se generarán múltiples archivos
FILE_MASTER = f'{OUTPUT_DIR}/insert_0_ejecutar_todos.sql'

# Límite de lotes por archivo (para evitar que se cuelgue)
LOTES_POR_ARCHIVO = 500

# =====================================================
# FUNCIONES DE AUTENTICACIÓN
# =====================================================
def get_google_sheets_service():
    """Obtener servicio de Google Sheets autenticado"""
    try:
        # Cargar credenciales desde variables de entorno
        creds_b64 = os.getenv('GOOGLE_SHEETS_CREDENTIALS_BASE64')
        token_b64 = os.getenv('GOOGLE_SHEETS_TOKEN_BASE64')
        
        if not creds_b64 or not token_b64:
            print("❌ Error: Variables de entorno no configuradas")
            print("   Necesitas: GOOGLE_SHEETS_CREDENTIALS_BASE64 y GOOGLE_SHEETS_TOKEN_BASE64")
            return None
        
        # Decodificar token
        token_json = base64.b64decode(token_b64).decode('utf-8')
        token_data = json.loads(token_json)
        
        # Crear credenciales
        creds = Credentials.from_authorized_user_info(token_data)
        
        # Crear servicio
        service = build('sheets', 'v4', credentials=creds)
        print("✅ Autenticación exitosa con Google Sheets")
        return service
        
    except Exception as e:
        print(f"❌ Error en autenticación: {e}")
        return None

# =====================================================
# FUNCIONES DE LECTURA DE DATOS
# =====================================================
def leer_datos_google_sheets(service):
    """Leer datos de la hoja Data-campo"""
    try:
        spreadsheet_id = os.getenv('GOOGLE_SHEETS_SPREADSHEET_ID')
        range_name = f'{SHEET_NAME}!A:I'  # Columnas A a I
        
        print(f"📊 Leyendo datos de {SHEET_NAME}...")
        
        result = service.spreadsheets().values().get(
            spreadsheetId=spreadsheet_id,
            range=range_name
        ).execute()
        
        values = result.get('values', [])
        
        if not values:
            print("⚠️ No se encontraron datos")
            return []
        
        # Saltar encabezados
        data = values[1:]
        print(f"✅ Se leyeron {len(data)} filas de datos")
        
        return data
        
    except Exception as e:
        print(f"❌ Error leyendo datos: {e}")
        return []

# =====================================================
# FUNCIONES DE PROCESAMIENTO
# =====================================================
def procesar_jerarquia(data):
    """
    Procesar datos y crear estructura jerárquica
    Retorna diccionarios con datos únicos para cada nivel
    """
    print("\n🔄 Procesando jerarquía organizacional...")
    
    # Estructuras para almacenar datos únicos
    paises = {}
    empresas = {}
    fundos = {}
    sectores = {}
    lotes = []
    
    # Contadores
    stats = {
        'total_rows': len(data),
        'processed': 0,
        'skipped': 0
    }
    
    for row in data:
        if len(row) < 9:
            stats['skipped'] += 1
            continue
        
        # Extraer datos (columnas A a I)
        # A: growerID, B: GrowwerDescripçion, C: farmID, D: farmDescripción
        # E: SectorID, F: CentroCosto, G: sectorDescripcion, H: lotID, I: loteDescripcion
        empresa_abrev = row[0].strip() if row[0] else ''
        empresa_nombre = row[1].strip() if row[1] else ''
        fundo_abrev = row[2].strip() if row[2] else ''
        fundo_nombre = row[3].strip() if row[3] else ''
        sector_id = row[4].strip() if row[4] else ''
        # centro_costo = row[5].strip() if row[5] else ''  # No se usa por ahora
        sector_nombre = row[6].strip() if row[6] else ''
        lote_id = row[7].strip() if row[7] else ''
        lote_nombre = row[8].strip() if row[8] else ''
        
        # Validar datos mínimos
        if not empresa_nombre or not fundo_nombre or not sector_nombre or not lote_nombre:
            stats['skipped'] += 1
            continue
        
        # País (fijo: Perú)
        pais_key = 'PE'
        if pais_key not in paises:
            paises[pais_key] = {
                'pais': 'Perú',
                'paisabrev': 'PE'
            }
        
        # Empresa
        empresa_key = empresa_abrev
        if empresa_key not in empresas:
            empresas[empresa_key] = {
                'pais': pais_key,
                'empresa': empresa_nombre,
                'empresabrev': empresa_abrev
            }
        
        # Fundo
        fundo_key = f"{empresa_key}|{fundo_abrev}"
        if fundo_key not in fundos:
            fundos[fundo_key] = {
                'empresa': empresa_key,
                'fundo': fundo_nombre,
                'fundobrev': fundo_abrev
            }
        
        # Sector
        sector_full_name = f"[{sector_id}] {sector_nombre}" if sector_id else sector_nombre
        sector_key = f"{fundo_key}|{sector_full_name}"
        if sector_key not in sectores:
            sectores[sector_key] = {
                'fundo': fundo_key,
                'sector': sector_full_name,
                'sectorbrev': sector_nombre[:50]  # Limitar a 50 caracteres
            }
        
        # Lote
        lote_full_name = f"[{lote_id}] {lote_nombre}" if lote_id else lote_nombre
        lotes.append({
            'sector': sector_key,
            'lote': lote_full_name,
            'lotebrev': lote_nombre[:50]  # Limitar a 50 caracteres
        })
        
        stats['processed'] += 1
    
    print(f"\n📊 Estadísticas de procesamiento:")
    print(f"   Total de filas: {stats['total_rows']}")
    print(f"   Procesadas: {stats['processed']}")
    print(f"   Omitidas: {stats['skipped']}")
    print(f"\n📈 Datos únicos encontrados:")
    print(f"   Países: {len(paises)}")
    print(f"   Empresas: {len(empresas)}")
    print(f"   Fundos: {len(fundos)}")
    print(f"   Sectores: {len(sectores)}")
    print(f"   Lotes: {len(lotes)}")
    
    return {
        'paises': paises,
        'empresas': empresas,
        'fundos': fundos,
        'sectores': sectores,
        'lotes': lotes
    }

# =====================================================
# FUNCIONES DE GENERACIÓN SQL
# =====================================================
def generar_header_sql(descripcion):
    """Generar encabezado estándar para archivos SQL"""
    return f"""-- =====================================================
-- {descripcion}
-- Generado automáticamente desde Google Sheets
-- Fecha: {os.popen('date').read().strip() if os.name != 'nt' else 'Auto-generated'}
-- Fuente: Data-campo
-- Base de datos: AgricolaDB
-- Schema: image
-- =====================================================

USE AgricolaDB;
GO

"""

def generar_insert_pais_empresa_fundo(jerarquia):
    """Generar archivo 1: Países, Empresas y Fundos"""
    print("\n📝 Generando insert_1_pais_empresa_fundo.sql...")
    
    sql = generar_header_sql("Script 1: Inserción de Países, Empresas y Fundos")
    
    # PAÍSES
    sql += """-- =====================================================
-- 1. INSERTAR PAÍSES
-- =====================================================

"""
    for pais_key, pais in jerarquia['paises'].items():
        sql += f"""IF NOT EXISTS (SELECT 1 FROM image.pais WHERE paisabrev = '{pais['paisabrev']}')
BEGIN
    INSERT INTO image.pais (pais, paisabrev, statusid, usercreatedid, usermodifiedid)
    VALUES ('{pais['pais']}', '{pais['paisabrev']}', 1, 1, 1);
    PRINT 'País {pais['pais']} insertado';
END
ELSE
BEGIN
    PRINT 'País {pais['pais']} ya existe';
END
GO

"""
    
    # EMPRESAS
    sql += f"""-- =====================================================
-- 2. INSERTAR EMPRESAS
-- Total: {len(jerarquia['empresas'])}
-- =====================================================

"""
    for empresa_key, empresa in jerarquia['empresas'].items():
        # Escapar comillas simples
        empresa_nombre = empresa['empresa'].replace("'", "''")
        sql += f"""-- Empresa: [{empresa['empresabrev']}] {empresa_nombre}
IF NOT EXISTS (SELECT 1 FROM image.empresa WHERE empresabrev = '{empresa['empresabrev']}' AND paisid = (SELECT paisid FROM image.pais WHERE paisabrev = '{empresa['pais']}'))
BEGIN
    INSERT INTO image.empresa (paisid, empresa, empresabrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT paisid FROM image.pais WHERE paisabrev = '{empresa['pais']}'),
        '{empresa_nombre}',
        '{empresa['empresabrev']}',
        1, 1, 1
    );
    PRINT 'Empresa [{empresa['empresabrev']}] {empresa_nombre} insertada';
END
GO

"""
    
    # FUNDOS
    sql += f"""-- =====================================================
-- 3. INSERTAR FUNDOS
-- Total: {len(jerarquia['fundos'])}
-- =====================================================

"""
    for fundo_key, fundo in jerarquia['fundos'].items():
        fundo_nombre = fundo['fundo'].replace("'", "''")
        empresa_key = fundo['empresa']
        sql += f"""-- Fundo: [{fundo['fundobrev']}] {fundo_nombre} | Empresa: [{empresa_key}]
IF NOT EXISTS (SELECT 1 FROM image.fundo WHERE fundobrev = '{fundo['fundobrev']}' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = '{empresa_key}'))
BEGIN
    INSERT INTO image.fundo (empresaid, fundo, fundobrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT empresaid FROM image.empresa WHERE empresabrev = '{empresa_key}'),
        '{fundo_nombre}',
        '{fundo['fundobrev']}',
        1, 1, 1
    );
    PRINT 'Fundo [{fundo['fundobrev']}] {fundo_nombre} insertado en empresa [{empresa_key}]';
END
GO

"""
    
    sql += "\nPRINT '✅ Script 1 completado: Países, Empresas y Fundos insertados';\nGO\n"
    
    return sql

def generar_insert_sectores(jerarquia):
    """Generar archivo 2: Sectores"""
    print("\n📝 Generando insert_2_sectores.sql...")
    
    sql = generar_header_sql("Script 2: Inserción de Sectores")
    
    sql += f"""-- =====================================================
-- INSERTAR SECTORES
-- Total: {len(jerarquia['sectores'])}
-- =====================================================

"""
    
    for sector_key, sector in jerarquia['sectores'].items():
        # Extraer empresa y fundo del key
        fundo_key = sector['fundo']
        empresa_key, fundo_abrev = fundo_key.split('|')
        
        sector_nombre = sector['sector'].replace("'", "''")
        
        sql += f"""-- Sector: {sector_nombre} | Fundo: [{fundo_abrev}] | Empresa: [{empresa_key}]
IF NOT EXISTS (
    SELECT 1 FROM image.sector 
    WHERE sector = '{sector_nombre}' 
    AND fundoid = (
        SELECT fundoid FROM image.fundo 
        WHERE fundobrev = '{fundo_abrev}' 
        AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = '{empresa_key}')
    )
)
BEGIN
    INSERT INTO image.sector (fundoid, sector, sectorbrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT fundoid FROM image.fundo WHERE fundobrev = '{fundo_abrev}' AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = '{empresa_key}')),
        '{sector_nombre}',
        '{sector['sectorbrev'].replace("'", "''")}',
        1, 1, 1
    );
    PRINT 'Sector {sector_nombre} insertado en fundo [{fundo_abrev}]';
END
GO

"""
    
    sql += "\nPRINT '✅ Script 2 completado: Sectores insertados';\nGO\n"
    
    return sql

def generar_insert_lotes(jerarquia):
    """Generar archivos 3: Lotes (divididos en partes)"""
    print("\n📝 Generando archivos de lotes...")
    
    lotes = jerarquia['lotes']
    total_lotes = len(lotes)
    num_archivos = (total_lotes // LOTES_POR_ARCHIVO) + (1 if total_lotes % LOTES_POR_ARCHIVO > 0 else 0)
    
    archivos_generados = []
    
    for parte in range(num_archivos):
        inicio = parte * LOTES_POR_ARCHIVO
        fin = min((parte + 1) * LOTES_POR_ARCHIVO, total_lotes)
        lotes_parte = lotes[inicio:fin]
        
        filename = f"{FILE_3_PREFIX}_{parte + 1}.sql"
        archivos_generados.append(filename)
        
        print(f"   Generando parte {parte + 1}/{num_archivos} ({len(lotes_parte)} lotes)...")
        
        sql = generar_header_sql(f"Script 3 Parte {parte + 1}/{num_archivos}: Inserción de Lotes ({inicio + 1}-{fin})")
        
        sql += f"""-- =====================================================
-- INSERTAR LOTES - PARTE {parte + 1} de {num_archivos}
-- Lotes: {inicio + 1} a {fin} (Total: {len(lotes_parte)})
-- =====================================================

"""
        
        for lote in lotes_parte:
            # Extraer sector, fundo y empresa del key
            sector_key = lote['sector']
            fundo_key, sector_nombre = sector_key.rsplit('|', 1)
            empresa_key, fundo_abrev = fundo_key.split('|')
            
            lote_nombre = lote['lote'].replace("'", "''")
            sector_nombre_escaped = sector_nombre.replace("'", "''")
            
            sql += f"""-- Lote: {lote_nombre}
IF NOT EXISTS (
    SELECT 1 FROM image.lote 
    WHERE lote = '{lote_nombre}' 
    AND sectorid = (
        SELECT sectorid FROM image.sector 
        WHERE sector = '{sector_nombre_escaped}'
        AND fundoid = (
            SELECT fundoid FROM image.fundo 
            WHERE fundobrev = '{fundo_abrev}' 
            AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = '{empresa_key}')
        )
    )
)
BEGIN
    INSERT INTO image.lote (sectorid, lote, lotebrev, statusid, usercreatedid, usermodifiedid)
    VALUES (
        (SELECT sectorid FROM image.sector 
         WHERE sector = '{sector_nombre_escaped}'
         AND fundoid = (
             SELECT fundoid FROM image.fundo 
             WHERE fundobrev = '{fundo_abrev}' 
             AND empresaid = (SELECT empresaid FROM image.empresa WHERE empresabrev = '{empresa_key}')
         )),
        '{lote_nombre}',
        '{lote['lotebrev'].replace("'", "''")}',
        1, 1, 1
    );
END
GO

"""
        
        sql += f"\nPRINT '✅ Script 3 Parte {parte + 1} completado: Lotes {inicio + 1}-{fin} insertados';\nGO\n"
        
        # Escribir archivo
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(sql)
        
        print(f"   ✅ Archivo generado: {filename}")
    
    return archivos_generados

def generar_script_maestro(archivos_lotes):
    """Generar script maestro que ejecuta todos los archivos en orden"""
    print("\n📝 Generando script maestro...")
    
    sql = """-- =====================================================
-- SCRIPT MAESTRO: Ejecutar todos los inserts en orden
-- =====================================================
-- IMPORTANTE: Ejecutar este script desde SQL Server Management Studio
-- o desde sqlcmd en el directorio 'scripts/generated'
--
-- Jerarquía: País -> Empresa -> Fundo -> Sector -> Lote
-- =====================================================

PRINT '🚀 Iniciando inserción de jerarquía organizacional...';
PRINT '';

-- Verificar que la base de datos existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'AgricolaDB')
BEGIN
    PRINT '❌ ERROR: La base de datos AgricolaDB no existe';
    PRINT '   Por favor, ejecuta primero: schema_agricola_luz_sombra.sql';
    RAISERROR('Base de datos no encontrada', 16, 1);
    RETURN;
END
GO

USE AgricolaDB;
GO

PRINT '📊 Base de datos: AgricolaDB';
PRINT '';

-- =====================================================
-- 1. PAÍSES, EMPRESAS Y FUNDOS
-- =====================================================
PRINT '1️⃣ Ejecutando: insert_1_pais_empresa_fundo.sql';
:r insert_1_pais_empresa_fundo.sql
PRINT '';

-- =====================================================
-- 2. SECTORES
-- =====================================================
PRINT '2️⃣ Ejecutando: insert_2_sectores.sql';
:r insert_2_sectores.sql
PRINT '';

-- =====================================================
-- 3. LOTES (múltiples archivos)
-- =====================================================
"""
    
    for idx, archivo in enumerate(archivos_lotes, 1):
        basename = os.path.basename(archivo)
        sql += f"""PRINT '3️⃣.{idx} Ejecutando: {basename}';
:r {basename}
PRINT '';

"""
    
    sql += """-- =====================================================
-- RESUMEN FINAL
-- =====================================================
PRINT '';
PRINT '=====================================================';
PRINT '✅ INSERCIÓN DE JERARQUÍA COMPLETADA';
PRINT '=====================================================';
PRINT '';

SELECT 
    'Países' AS Nivel,
    COUNT(*) AS Total
FROM image.pais
WHERE statusid = 1
UNION ALL
SELECT 
    'Empresas',
    COUNT(*)
FROM image.empresa
WHERE statusid = 1
UNION ALL
SELECT 
    'Fundos',
    COUNT(*)
FROM image.fundo
WHERE statusid = 1
UNION ALL
SELECT 
    'Sectores',
    COUNT(*)
FROM image.sector
WHERE statusid = 1
UNION ALL
SELECT 
    'Lotes',
    COUNT(*)
FROM image.lote
WHERE statusid = 1;

PRINT '';
PRINT '🎉 ¡Proceso completado exitosamente!';
GO
"""
    
    return sql

# =====================================================
# FUNCIÓN PRINCIPAL
# =====================================================
def main():
    print("=" * 60)
    print("GENERADOR DE SCRIPTS SQL DESDE GOOGLE SHEETS")
    print("=" * 60)
    print()
    
    # Cargar variables desde .env.local
    cargar_env()
    
    # Crear directorio de salida
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"[*] Directorio de salida: {OUTPUT_DIR}")
    
    # Obtener servicio de Google Sheets
    service = get_google_sheets_service()
    if not service:
        print("\n❌ No se pudo conectar a Google Sheets")
        print("   Verifica las variables de entorno:")
        print("   - GOOGLE_SHEETS_SPREADSHEET_ID")
        print("   - GOOGLE_SHEETS_CREDENTIALS_BASE64")
        print("   - GOOGLE_SHEETS_TOKEN_BASE64")
        return
    
    # Leer datos
    data = leer_datos_google_sheets(service)
    if not data:
        print("❌ No hay datos para procesar")
        return
    
    # Procesar jerarquía
    jerarquia = procesar_jerarquia(data)
    
    # Generar archivos SQL
    print("\n" + "=" * 60)
    print("📝 GENERANDO ARCHIVOS SQL")
    print("=" * 60)
    
    # Archivo 1: Países, Empresas, Fundos
    sql1 = generar_insert_pais_empresa_fundo(jerarquia)
    with open(FILE_1, 'w', encoding='utf-8') as f:
        f.write(sql1)
    print(f"✅ Generado: {FILE_1}")
    
    # Archivo 2: Sectores
    sql2 = generar_insert_sectores(jerarquia)
    with open(FILE_2, 'w', encoding='utf-8') as f:
        f.write(sql2)
    print(f"✅ Generado: {FILE_2}")
    
    # Archivos 3: Lotes (múltiples partes)
    archivos_lotes = generar_insert_lotes(jerarquia)
    
    # Script maestro
    sql_master = generar_script_maestro(archivos_lotes)
    with open(FILE_MASTER, 'w', encoding='utf-8') as f:
        f.write(sql_master)
    print(f"✅ Generado: {FILE_MASTER}")
    
    # Resumen final
    print("\n" + "=" * 60)
    print("✅ GENERACIÓN COMPLETADA")
    print("=" * 60)
    print(f"\n📊 Archivos generados:")
    print(f"   1. {FILE_1}")
    print(f"   2. {FILE_2}")
    for idx, archivo in enumerate(archivos_lotes, 1):
        print(f"   3.{idx}. {archivo}")
    print(f"   0. {FILE_MASTER} (Script maestro)")
    
    print(f"\n🎯 Siguiente paso:")
    print(f"   Ejecuta el script maestro en SQL Server:")
    print(f"   sqlcmd -S tu_servidor -d AgricolaDB -i {FILE_MASTER}")
    print()

if __name__ == "__main__":
    main()

