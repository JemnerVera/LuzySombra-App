# Visualización del Schema evalImagen

Esta carpeta contiene archivos para visualizar y documentar el schema `evalImagen`.

## 📁 Contenido

- **`eraser_io_schema.txt`** - Script para generar ERD en eraser.io (herramienta online)
- **`FLUJO_AGRICQR_DIAGRAMA.md`** - Diagrama de flujo del proceso AgriQR

## 🚀 Visualizar ERD con eraser.io

1. Ir a: https://app.eraser.io/
2. Crear nuevo diagrama
3. Copiar y pegar el contenido de `eraser_io_schema.txt`
4. El diagrama se generará automáticamente

## 📝 Tablas del Schema

El schema `evalImagen` contiene 9 tablas:

1. `AnalisisImagen` - Resultados de análisis de imágenes
2. `UmbralLuz` - Configuración de umbrales de luz/sombra
3. `LoteEvaluacion` - Estadísticas agregadas por lote
4. `Alerta` - Alertas generadas por umbrales
5. `Mensaje` - Logs de mensajes enviados
6. `Contacto` - Destinatarios de alertas
7. `Dispositivo` - Dispositivos Android autorizados
8. `MensajeAlerta` - Relación muchos-a-muchos (junction table)
9. `UsuarioWeb` - Usuarios web del sistema

## 🔧 Ejecutar Scripts SQL

**Los scripts SQL se ejecutan manualmente en SSMS:**

1. Abrir SQL Server Management Studio
2. Conectarse al servidor
3. Abrir el script desde `scripts/01_tables/`
4. Ejecutar el script (F5)

**Ver guía completa:** `scripts/00_setup/GUIA_CREAR_TABLAS_EVALIMAGEN.md`

