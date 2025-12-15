"""
Ejemplo de integración del "Burro" con LuzSombra
Usando la Opción 1: API REST Directa

Requisitos:
    pip install requests

Configuración:
    - BASE_URL: URL del backend de LuzSombra
    - DEVICE_ID: ID del dispositivo registrado en la webapp
    - API_KEY: API Key del dispositivo (obtenida de la webapp)
"""

import requests
import os
from datetime import datetime
from pathlib import Path

# ============================================
# CONFIGURACIÓN
# ============================================
BASE_URL = "https://luzsombra-backend.azurewebsites.net/api"  # Cambiar en producción
DEVICE_ID = "BURRO_001"  # ID del dispositivo registrado en la webapp
API_KEY = "luzsombra_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # API Key del dispositivo

# ============================================
# CLASE: ClienteLuzSombra
# ============================================
class ClienteLuzSombra:
    def __init__(self, base_url: str, device_id: str, api_key: str):
        self.base_url = base_url
        self.device_id = device_id
        self.api_key = api_key
        self.token = None
        self.token_expires_at = None
    
    def login(self) -> bool:
        """
        Autentica el dispositivo y obtiene un JWT token
        
        Returns:
            bool: True si el login fue exitoso, False en caso contrario
        """
        try:
            response = requests.post(
                f"{self.base_url}/auth/login",
                json={
                    "deviceId": self.device_id,
                    "apiKey": self.api_key
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                self.token = data.get("token")
                expires_in = data.get("expiresIn", 86400)  # 24 horas por defecto
                
                # Calcular cuándo expira el token (con margen de 5 minutos)
                from datetime import timedelta
                self.token_expires_at = datetime.now() + timedelta(seconds=expires_in - 300)
                
                print(f"✅ Login exitoso. Token válido por {expires_in} segundos")
                return True
            else:
                print(f"❌ Error en login: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error de conexión en login: {e}")
            return False
    
    def is_token_valid(self) -> bool:
        """Verifica si el token actual es válido"""
        if not self.token or not self.token_expires_at:
            return False
        return datetime.now() < self.token_expires_at
    
    def ensure_authenticated(self) -> bool:
        """Asegura que hay un token válido, hace login si es necesario"""
        if not self.is_token_valid():
            print("🔄 Token expirado o no existe. Haciendo login...")
            return self.login()
        return True
    
    def subir_foto(self, foto_path: str, plant_id: str, timestamp: str = None) -> dict:
        """
        Sube una foto al servidor de LuzSombra
        
        Args:
            foto_path: Ruta al archivo de imagen
            plant_id: ID de la planta (ej: "00805221")
            timestamp: Fecha/hora ISO 8601 (opcional, se usa EXIF si no se proporciona)
        
        Returns:
            dict: Resultado del procesamiento
        """
        # Asegurar autenticación
        if not self.ensure_authenticated():
            return {"success": False, "error": "No se pudo autenticar"}
        
        # Verificar que el archivo existe
        if not os.path.exists(foto_path):
            return {"success": False, "error": f"Archivo no encontrado: {foto_path}"}
        
        # Preparar datos
        files = {
            'file': (os.path.basename(foto_path), open(foto_path, 'rb'), 'image/jpeg')
        }
        
        data = {
            'plantId': plant_id
        }
        
        if timestamp:
            data['timestamp'] = timestamp
        
        headers = {
            'Authorization': f'Bearer {self.token}'
        }
        
        try:
            print(f"📤 Subiendo foto: {foto_path} para plantId: {plant_id}")
            
            response = requests.post(
                f"{self.base_url}/photos/upload",
                files=files,
                data=data,
                headers=headers,
                timeout=60  # 60 segundos timeout (procesamiento puede tardar)
            )
            
            files['file'][1].close()  # Cerrar archivo
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Foto procesada exitosamente:")
                print(f"   - Porcentaje Luz: {result.get('porcentaje_luz', 'N/A')}%")
                print(f"   - Porcentaje Sombra: {result.get('porcentaje_sombra', 'N/A')}%")
                print(f"   - AnalisisID: {result.get('analisisID', 'N/A')}")
                return result
            else:
                error_msg = response.json().get('error', 'Error desconocido')
                print(f"❌ Error subiendo foto: {response.status_code} - {error_msg}")
                return {"success": False, "error": error_msg}
                
        except Exception as e:
            print(f"❌ Error de conexión subiendo foto: {e}")
            return {"success": False, "error": str(e)}


# ============================================
# EJEMPLO DE USO
# ============================================
def ejemplo_uso():
    """Ejemplo de cómo usar el cliente"""
    
    # Crear cliente
    cliente = ClienteLuzSombra(BASE_URL, DEVICE_ID, API_KEY)
    
    # Hacer login inicial
    if not cliente.login():
        print("❌ No se pudo hacer login. Verifica DEVICE_ID y API_KEY")
        return
    
    # Ejemplo 1: Subir una foto con plantId conocido
    foto_path = "/ruta/a/foto.jpg"
    plant_id = "00805221"  # El burro debe conocer este ID
    
    resultado = cliente.subir_foto(
        foto_path=foto_path,
        plant_id=plant_id,
        timestamp=datetime.now().isoformat()  # Opcional
    )
    
    if resultado.get("success"):
        print("✅ Foto procesada y guardada en la base de datos")
    else:
        print(f"❌ Error: {resultado.get('error')}")


# ============================================
# EJEMPLO: PROCESAR CARPETA DE FOTOS
# ============================================
def procesar_carpeta(carpeta_fotos: str, mapeo_plant_id: dict):
    """
    Procesa todas las fotos en una carpeta
    
    Args:
        carpeta_fotos: Ruta a la carpeta con fotos
        mapeo_plant_id: Diccionario {nombre_archivo: plant_id}
    """
    cliente = ClienteLuzSombra(BASE_URL, DEVICE_ID, API_KEY)
    
    if not cliente.login():
        print("❌ No se pudo hacer login")
        return
    
    carpeta = Path(carpeta_fotos)
    fotos = list(carpeta.glob("*.jpg")) + list(carpeta.glob("*.jpeg")) + list(carpeta.glob("*.png"))
    
    print(f"📁 Encontradas {len(fotos)} fotos en {carpeta_fotos}")
    
    exitosas = 0
    fallidas = 0
    
    for foto in fotos:
        # Obtener plantId del mapeo o del nombre del archivo
        plant_id = mapeo_plant_id.get(foto.name)
        
        if not plant_id:
            # Intentar extraer del nombre del archivo (ej: "00805221_2025-12-15.jpg")
            nombre_sin_ext = foto.stem
            partes = nombre_sin_ext.split("_")
            if partes:
                plant_id = partes[0]
        
        if not plant_id:
            print(f"⚠️  No se pudo determinar plantId para {foto.name}. Saltando...")
            fallidas += 1
            continue
        
        resultado = cliente.subir_foto(
            foto_path=str(foto),
            plant_id=plant_id
        )
        
        if resultado.get("success"):
            exitosas += 1
            # Opcional: mover foto a carpeta "procesadas"
            # foto.rename(carpeta / "procesadas" / foto.name)
        else:
            fallidas += 1
    
    print(f"\n📊 Resumen:")
    print(f"   ✅ Exitosas: {exitosas}")
    print(f"   ❌ Fallidas: {fallidas}")
    print(f"   📁 Total: {len(fotos)}")


# ============================================
# MAIN
# ============================================
if __name__ == "__main__":
    # Ejemplo básico
    ejemplo_uso()
    
    # Ejemplo procesar carpeta (descomentar para usar)
    # mapeo = {
    #     "foto1.jpg": "00805221",
    #     "foto2.jpg": "00805222",
    #     "foto3.jpg": "00805223"
    # }
    # procesar_carpeta("/ruta/a/fotos", mapeo)

