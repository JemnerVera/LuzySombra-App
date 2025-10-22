#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para explorar la estructura de Data-campo en Google Sheets
"""

import os
import sys
import json
import base64

# Configurar encoding para Windows
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

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

def get_google_sheets_service():
    """Obtener servicio de Google Sheets autenticado"""
    try:
        creds_b64 = os.getenv('GOOGLE_SHEETS_CREDENTIALS_BASE64')
        token_b64 = os.getenv('GOOGLE_SHEETS_TOKEN_BASE64')
        
        if not creds_b64 or not token_b64:
            print("[ERROR] Variables de entorno no configuradas")
            return None
        
        token_json = base64.b64decode(token_b64).decode('utf-8')
        token_data = json.loads(token_json)
        creds = Credentials.from_authorized_user_info(token_data)
        service = build('sheets', 'v4', credentials=creds)
        print("[OK] Autenticacion exitosa con Google Sheets")
        return service
        
    except Exception as e:
        print(f"[ERROR] Error en autenticacion: {e}")
        return None

def explorar_data_campo(service, spreadsheet_id):
    """Explorar la estructura de Data-campo"""
    try:
        print("\n" + "="*60)
        print("EXPLORANDO PESTAÑA: Data-campo")
        print("="*60)
        
        # Leer todas las columnas (A hasta la que tenga datos)
        range_name = 'Data-campo!A1:Z1000'
        
        print(f"\n[*] Leyendo rango: {range_name}")
        
        result = service.spreadsheets().values().get(
            spreadsheetId=spreadsheet_id,
            range=range_name
        ).execute()
        
        values = result.get('values', [])
        
        if not values:
            print("[!] No se encontraron datos")
            return
        
        print(f"[OK] Se leyeron {len(values)} filas")
        
        # Mostrar encabezados (primera fila)
        print("\n" + "-"*60)
        print("ENCABEZADOS (Fila 1):")
        print("-"*60)
        headers = values[0] if values else []
        for idx, header in enumerate(headers):
            col_letter = chr(65 + idx) if idx < 26 else f"A{chr(65 + idx - 26)}"
            print(f"  Columna {col_letter} ({idx}): '{header}'")
        
        # Mostrar primeras 5 filas de datos
        print("\n" + "-"*60)
        print("PRIMERAS 5 FILAS DE DATOS:")
        print("-"*60)
        
        for row_idx in range(1, min(6, len(values))):
            row = values[row_idx]
            print(f"\nFila {row_idx + 1}:")
            for col_idx, cell in enumerate(row):
                col_letter = chr(65 + col_idx) if col_idx < 26 else f"A{chr(65 + col_idx - 26)}"
                header = headers[col_idx] if col_idx < len(headers) else f"Col{col_idx}"
                print(f"  {col_letter} ({header}): '{cell}'")
        
        # Estadísticas
        print("\n" + "-"*60)
        print("ESTADISTICAS:")
        print("-"*60)
        print(f"  Total de filas (incluyendo encabezado): {len(values)}")
        print(f"  Total de filas de datos: {len(values) - 1}")
        print(f"  Total de columnas: {len(headers)}")
        
        # Contar valores únicos en columnas clave
        if len(values) > 1:
            print("\n" + "-"*60)
            print("VALORES UNICOS EN COLUMNAS PRINCIPALES:")
            print("-"*60)
            
            # Intentar identificar columnas importantes
            for col_idx, header in enumerate(headers):
                header_lower = header.lower()
                if any(keyword in header_lower for keyword in ['empresa', 'fundo', 'sector', 'lote']):
                    unique_values = set()
                    for row in values[1:]:
                        if col_idx < len(row) and row[col_idx]:
                            unique_values.add(row[col_idx].strip())
                    
                    col_letter = chr(65 + col_idx) if col_idx < 26 else f"A{chr(65 + col_idx - 26)}"
                    print(f"  {col_letter} - {header}: {len(unique_values)} valores unicos")
                    
                    if len(unique_values) <= 20:
                        for val in sorted(unique_values)[:10]:
                            print(f"     - {val}")
                        if len(unique_values) > 10:
                            print(f"     ... y {len(unique_values) - 10} mas")
        
        print("\n" + "="*60)
        print("[OK] Exploracion completada")
        print("="*60)
        
    except Exception as e:
        print(f"[ERROR] Error explorando datos: {e}")
        import traceback
        traceback.print_exc()

def main():
    print("="*60)
    print("EXPLORADOR DE DATA-CAMPO")
    print("="*60)
    print()
    
    # Cargar variables desde .env.local
    cargar_env()
    
    spreadsheet_id = os.getenv('GOOGLE_SHEETS_SPREADSHEET_ID')
    
    if not spreadsheet_id:
        print("[ERROR] GOOGLE_SHEETS_SPREADSHEET_ID no configurado")
        return
    
    print(f"[*] Spreadsheet ID: {spreadsheet_id}")
    
    service = get_google_sheets_service()
    if not service:
        print("\n[ERROR] No se pudo conectar a Google Sheets")
        return
    
    explorar_data_campo(service, spreadsheet_id)

if __name__ == "__main__":
    main()

