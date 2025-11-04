#!/usr/bin/env python3
"""
Script para catalogar automáticamente los schemas de todas las tablas existentes
Base de datos: BD_PACKING_AGROMIGIVA_DESA

⚠️ IMPORTANTE: Este script es SOLO DE LECTURA (exploratorio)
   - Solo ejecuta queries SELECT sobre INFORMATION_SCHEMA y vistas del sistema
   - NO modifica, crea, elimina ni altera ninguna tabla o dato
   - Únicamente lee la estructura y genera documentación en Markdown/JSON
"""

import os
import sys
from pathlib import Path
from typing import Dict, List, Any
import json

# Configurar codificación UTF-8 para Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

try:
    import pyodbc
except ImportError:
    print("❌ Error: pyodbc no está instalado")
    print("   Instalar con: pip install pyodbc")
    sys.exit(1)

# Cargar variables de entorno desde .env.local
def load_env_file():
    """Carga variables de entorno desde .env.local"""
    env_path = Path(__file__).parent.parent / '.env.local'
    env_vars = {}
    
    if not env_path.exists():
        print(f"❌ Error: No se encontró .env.local en {env_path.parent}")
        print("   Por favor, crea el archivo .env.local con las credenciales")
        sys.exit(1)
    
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                env_vars[key.strip()] = value.strip()
    
    return env_vars

def get_connection():
    """Obtiene conexión a SQL Server"""
    env = load_env_file()
    
    server = env.get('SQL_SERVER')
    database = env.get('SQL_DATABASE')
    user = env.get('SQL_USER')
    password = env.get('SQL_PASSWORD')
    port = env.get('SQL_PORT', '1433')
    
    if not all([server, database, user, password]):
        print("❌ Error: Faltan variables de entorno requeridas")
        print("   Requeridas: SQL_SERVER, SQL_DATABASE, SQL_USER, SQL_PASSWORD")
        sys.exit(1)
    
    # String de conexión para SQL Server
    # Intentar diferentes drivers disponibles en Windows
    drivers_to_try = [
        "ODBC Driver 17 for SQL Server",
        "ODBC Driver 18 for SQL Server",
        "ODBC Driver 13 for SQL Server",
        "SQL Server Native Client 11.0",
        "SQL Server"
    ]
    
    conn = None
    last_error = None
    
    for driver in drivers_to_try:
        try:
            connection_string = (
                f"DRIVER={{{driver}}};"
                f"SERVER={server},{port};"
                f"DATABASE={database};"
                f"UID={user};"
                f"PWD={password};"
                f"TrustServerCertificate=yes;"
            )
            conn = pyodbc.connect(connection_string, timeout=10)
            print(f"✅ Conectado a {server}/{database} usando driver: {driver}")
            return conn
        except pyodbc.Error as e:
            last_error = e
            continue
    
    # Si ningún driver funcionó, lanzar error
    print(f"❌ Error conectando a SQL Server: {last_error}")
    print("\n💡 Posibles soluciones:")
    print("   1. Verificar credenciales en .env.local")
    print("   2. Verificar que el servidor sea accesible")
    print("   3. Instalar ODBC Driver for SQL Server desde Microsoft")
    print(f"   4. Drivers probados: {', '.join(drivers_to_try)}")
    sys.exit(1)
    

def get_table_structure(conn, schema: str, table: str) -> Dict[str, Any]:
    """Obtiene la estructura completa de una tabla"""
    cursor = conn.cursor()
    
    # Primero verificar si la tabla existe
    check_query = """
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
    """
    cursor.execute(check_query, (schema, table))
    if cursor.fetchone()[0] == 0:
        raise ValueError(f"Tabla {schema}.{table} no existe")
    
    # Obtener columnas - probar primero un query simple para ver qué columnas están disponibles
    # Usamos sys.columns como alternativa si INFORMATION_SCHEMA falla
    try:
        query = """
        SELECT 
            COLUMN_NAME,
            DATA_TYPE,
            CHARACTER_MAXIMUM_LENGTH,
            NUMERIC_PRECISION,
            NUMERIC_SCALE,
            IS_NULLABLE,
            COLUMN_DEFAULT,
            ORDINAL_POSITION
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION
        """
        cursor.execute(query, (schema, table))
    except Exception as e:
        # Si falla INFORMATION_SCHEMA, usar sys.columns
        print(f"  ⚠️  INFORMATION_SCHEMA falló, usando sys.columns...")
        query = """
        SELECT 
            c.name AS COLUMN_NAME,
            t.name AS DATA_TYPE,
            c.max_length AS CHARACTER_MAXIMUM_LENGTH,
            c.precision AS NUMERIC_PRECISION,
            c.scale AS NUMERIC_SCALE,
            CASE WHEN c.is_nullable = 1 THEN 'YES' ELSE 'NO' END AS IS_NULLABLE,
            dc.definition AS COLUMN_DEFAULT,
            c.column_id AS ORDINAL_POSITION
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        LEFT JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
        WHERE c.object_id = OBJECT_ID(? + '.' + ?)
        ORDER BY c.column_id
        """
        safe_schema = schema.replace(']', ']]').replace("'", "''")
        safe_table = table.replace(']', ']]').replace("'", "''")
        # OBJECT_ID necesita una cadena completa, no parámetros
        query = query.replace('OBJECT_ID(? + \'.\' + ?)', f"OBJECT_ID('[{safe_schema}].[{safe_table}]')")
        cursor.execute(query)
    columns = []
    for row in cursor.fetchall():
        columns.append({
            'name': row[0],
            'data_type': row[1],
            'max_length': row[2],
            'numeric_precision': row[3],
            'numeric_scale': row[4],
            'is_nullable': row[5] == 'YES',
            'default': row[6],
            'position': row[7]
        })
    
    # Obtener Primary Key - usar sys si INFORMATION_SCHEMA falla
    try:
        pk_query = """
        SELECT 
            c.COLUMN_NAME,
            c.DATA_TYPE
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
        INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
            ON tc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
            AND tc.TABLE_SCHEMA = c.TABLE_SCHEMA
            AND tc.TABLE_NAME = c.TABLE_NAME
        WHERE tc.TABLE_SCHEMA = ? 
          AND tc.TABLE_NAME = ?
          AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
        ORDER BY c.ORDINAL_POSITION
        """
        cursor.execute(pk_query, (schema, table))
        primary_keys = [{'name': row[0], 'data_type': row[1]} for row in cursor.fetchall()]
    except:
        # Usar sys si INFORMATION_SCHEMA falla
        safe_schema = schema.replace(']', ']]').replace("'", "''")
        safe_table = table.replace(']', ']]').replace("'", "''")
        pk_query = f"""
        SELECT 
            c.name AS COLUMN_NAME,
            t.name AS DATA_TYPE
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND i.is_primary_key = 1
        INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE i.object_id = OBJECT_ID('[{safe_schema}].[{safe_table}]')
        ORDER BY ic.key_ordinal
        """
        cursor.execute(pk_query)
        primary_keys = [{'name': row[0], 'data_type': row[1]} for row in cursor.fetchall()]
    
    # Obtener Foreign Keys
    fk_query = """
    SELECT 
        fk.name AS ForeignKeyName,
        COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ParentColumn,
        OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ReferencedSchema,
        OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
        COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
    FROM sys.foreign_keys AS fk
    INNER JOIN sys.foreign_key_columns AS fc 
        ON fk.object_id = fc.constraint_object_id
    WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = ?
      AND OBJECT_NAME(fk.parent_object_id) = ?
    ORDER BY fk.name, fc.constraint_column_id
    """
    
    cursor.execute(fk_query, (schema, table))
    foreign_keys = []
    for row in cursor.fetchall():
        foreign_keys.append({
            'name': row[0],
            'column': row[1],
            'referenced_schema': row[2],
            'referenced_table': row[3],
            'referenced_column': row[4]
        })
    
    # Obtener índices
    # Nota: Usamos formato directo porque OBJECT_ID requiere una cadena completa
    safe_schema = schema.replace(']', ']]')
    safe_table = table.replace(']', ']]')
    index_query = f"""
    SELECT 
        i.name AS IndexName,
        i.type_desc AS IndexType,
        i.is_unique AS IsUnique,
        STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Columns
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID('[{safe_schema}].[{safe_table}]')
      AND i.type > 0
    GROUP BY i.name, i.type_desc, i.is_unique
    ORDER BY i.name
    """
    
    cursor.execute(index_query)
    indexes = []
    for row in cursor.fetchall():
        indexes.append({
            'name': row[0],
            'type': row[1],
            'is_unique': bool(row[2]),
            'columns': row[3]
        })
    
    # Contar registros (solo lectura - exploratorio)
    # Nota: Usamos parámetros seguros aunque schema/table vienen de lista controlada
    try:
        # Validar que schema y table solo contengan caracteres alfanuméricos y guiones bajos
        if not (schema.replace('_', '').isalnum() and table.replace('_', '').isalnum()):
            raise ValueError(f"Nombre de esquema o tabla inválido: {schema}.{table}")
        # Escapar nombres para prevenir cualquier problema
        safe_schema = schema.replace(']', ']]')
        safe_table = table.replace(']', ']]')
        cursor.execute(f"SELECT COUNT(*) FROM [{safe_schema}].[{safe_table}]")
        row_count = cursor.fetchone()[0]
    except Exception as e:
        print(f"  ⚠️  No se pudo contar registros: {e}")
        row_count = None
    
    return {
        'columns': columns,
        'primary_keys': primary_keys,
        'foreign_keys': foreign_keys,
        'indexes': indexes,
        'row_count': row_count
    }

def format_data_type(col: Dict) -> str:
    """Formatea el tipo de dato para mostrar"""
    dt = col['data_type'].upper()
    
    if col['max_length']:
        if dt in ['NVARCHAR', 'VARCHAR', 'NCHAR', 'CHAR']:
            if col['max_length'] == -1:
                return f"{dt}(MAX)"
            return f"{dt}({col['max_length']})"
    elif col['numeric_precision']:
        if col['numeric_scale']:
            return f"{dt}({col['numeric_precision']},{col['numeric_scale']})"
        return f"{dt}({col['numeric_precision']})"
    
    return dt

def generate_markdown_catalog(tables_data: Dict[str, Dict], output_file: str):
    """Genera un catálogo en formato Markdown"""
    
    # Tablas según el orden de tablas_existentes.txt
    table_order = [
        ('MAST', 'USERS', 'USUARIO'),
        ('MAST', 'ORIGIN', 'PAIS'),
        ('GROWER', 'GROWERS', 'EMPRESA'),
        ('GROWER', 'FARMS', 'FUNDO'),
        ('GROWER', 'STAGE', 'SECTOR'),
        ('GROWER', 'LOT', 'LOTE'),
        ('GROWER', 'PLANTATION', 'UNION PLANTAS'),
        ('GROWER', 'PLANT', 'PLANTAS POR LOTE'),
        ('GROWER', 'VARIETY', 'VARIEDAD'),
        ('PPP', 'ESTADOFENOLOGICO', 'ESTADO_FENOLOGICO'),
        ('PPP', 'GRUPOFENOLOGICO', 'GRUPO_FENOLOGICO'),
        ('GROWER', 'CAMPAIGN', 'CAMPAÑA'),
    ]
    
    md_content = []
    md_content.append("# 📚 Catálogo de Schemas - Tablas Existentes AgroMigiva\n")
    md_content.append("## Base de Datos\n")
    md_content.append("**BD_PACKING_AGROMIGIVA_DESA** en servidor `10.1.10.4`\n")
    md_content.append("**Generado automáticamente** el " + 
                      __import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S') + "\n")
    md_content.append("\n---\n")
    
    md_content.append("## 📊 Tabla de Contenido\n")
    for i, (schema, table, desc) in enumerate(table_order, 1):
        if (schema, table) in tables_data:
            md_content.append(f"{i}. [{schema}.{table}](#{i}-{schema.lower()}{table.lower()}) - {desc}\n")
    md_content.append("\n---\n\n")
    
    for i, (schema, table, desc) in enumerate(table_order, 1):
        key = (schema, table)
        if key not in tables_data or tables_data[key] is None:
            md_content.append(f"## {i}. {schema}.{table} - {desc}\n\n")
            md_content.append("⚠️ **Tabla no encontrada o sin acceso**\n\n")
            md_content.append("---\n\n")
            continue
        
        data = tables_data[key]
        md_content.append(f"## {i}. {schema}.{table} - {desc}\n\n")
        md_content.append(f"**Propósito**: {desc}\n\n")
        
        # Estructura
        md_content.append("### Estructura\n\n")
        md_content.append("| COLUMN_NAME | DATA_TYPE | MAX_LENGTH | IS_NULLABLE | DEFAULT | NOTAS |\n")
        md_content.append("|-------------|-----------|------------|-------------|---------|-------|\n")
        
        pk_columns = {pk['name'] for pk in data['primary_keys']}
        
        for col in data['columns']:
            col_name = col['name']
            notes = []
            if col_name in pk_columns:
                notes.append("**PK**")
            
            # Verificar si es FK
            for fk in data['foreign_keys']:
                if fk['column'] == col_name:
                    notes.append(f"FK → {fk['referenced_schema']}.{fk['referenced_table']}.{fk['referenced_column']}")
            
            # Verificar si es estado
            if 'status' in col_name.lower() or 'active' in col_name.lower():
                notes.append("**Estado**")
            
            max_len = col['max_length'] if col['max_length'] else ''
            default = col['default'] if col['default'] else ''
            nullable = 'YES' if col['is_nullable'] else 'NO'
            
            md_content.append(f"| **{col_name}** | {format_data_type(col)} | {max_len} | {nullable} | {default} | {' / '.join(notes) if notes else ''} |\n")
        
        # Primary Keys
        if data['primary_keys']:
            md_content.append("\n### Primary Keys\n\n")
            for pk in data['primary_keys']:
                md_content.append(f"- `{pk['name']}` ({pk['data_type']})\n")
        
        # Foreign Keys
        if data['foreign_keys']:
            md_content.append("\n### Foreign Keys\n\n")
            for fk in data['foreign_keys']:
                md_content.append(f"- `{fk['column']}` → `{fk['referenced_schema']}.{fk['referenced_table']}.{fk['referenced_column']}`\n")
        
        # Índices
        if data['indexes']:
            md_content.append("\n### Índices\n\n")
            for idx in data['indexes']:
                unique = "UNIQUE " if idx['is_unique'] else ""
                md_content.append(f"- `{idx['name']}` ({unique}{idx['type']}) - Columnas: {idx['columns']}\n")
        
        # Estadísticas
        if data['row_count'] is not None:
            md_content.append(f"\n### Estadísticas\n\n")
            md_content.append(f"- **Total de registros**: {data['row_count']:,}\n")
        
        md_content.append("\n---\n\n")
    
    # Relaciones
    md_content.append("## 🔗 Relaciones Entre Tablas\n\n")
    md_content.append("```\n")
    md_content.append("GROWER.GROWERS (empresa)\n")
    md_content.append("  └─ GROWER.FARMS (fundo)\n")
    md_content.append("      └─ GROWER.STAGE (sector)\n")
    md_content.append("          └─ GROWER.LOT (lote)\n")
    md_content.append("              ├─ GROWER.PLANTATION (relación lote-variedad)\n")
    md_content.append("              │   └─ GROWER.VARIETY (variedad)\n")
    md_content.append("              └─ image.Analisis_Imagen (nuestra tabla nueva)\n")
    md_content.append("\nMAST.USERS (usuarios)\n")
    md_content.append("```\n\n")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(''.join(md_content))
    
    print(f"✅ Catálogo generado: {output_file}")

def main():
    """Función principal"""
    print("🔍 Catalogando schemas de tablas existentes...\n")
    
    # Tablas a verificar según tablas_existentes.txt
    tables_to_check = [
        ('MAST', 'USERS'),
        ('MAST', 'ORIGIN'),
        ('GROWER', 'GROWERS'),
        ('GROWER', 'FARMS'),
        ('GROWER', 'STAGE'),
        ('GROWER', 'LOT'),
        ('GROWER', 'PLANTATION'),
        ('GROWER', 'PLANT'),
        ('GROWER', 'VARIETY'),
        ('PPP', 'ESTADOFENOLOGICO'),
        ('PPP', 'GRUPOFENOLOGICO'),
        ('GROWER', 'CAMPAIGN'),
    ]
    
    conn = None
    tables_data = {}
    
    try:
        conn = get_connection()
        
        for schema, table in tables_to_check:
            print(f"📊 Verificando {schema}.{table}...", end=' ')
            try:
                data = get_table_structure(conn, schema, table)
                tables_data[(schema, table)] = data
                row_count = data['row_count'] if data['row_count'] is not None else 'N/A'
                print(f"✅ ({len(data['columns'])} columnas, {row_count} registros)")
            except Exception as e:
                print(f"❌ Error: {e}")
                tables_data[(schema, table)] = None
        
        print("\n📝 Generando catálogo...")
        
        # Generar Markdown
        output_md = Path(__file__).parent.parent / 'CATALOGO_SCHEMAS_TABLAS.md'
        generate_markdown_catalog(tables_data, str(output_md))
        
        # Generar JSON también (para uso programático)
        # Convertir tuplas a strings para JSON
        json_data = {f"{schema}.{table}": data for (schema, table), data in tables_data.items() if data is not None}
        output_json = Path(__file__).parent.parent / 'CATALOGO_SCHEMAS_TABLAS.json'
        with open(output_json, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, default=str)
        print(f"✅ JSON generado: {output_json}")
        
        print("\n✅ ¡Catálogo completo generado exitosamente!")
        
    except KeyboardInterrupt:
        print("\n\n⚠️ Interrumpido por el usuario")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        if conn:
            conn.close()
            print("\n🔌 Conexión cerrada")

if __name__ == '__main__':
    main()

