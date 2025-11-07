# Scripts SQL - Organización

## 📁 Estructura de Carpetas

```
scripts/
├── 00_setup/              # Scripts maestros (ejecutan múltiples componentes)
├── 01_tables/             # Creación de tablas
├── 02_views/              # Creación de vistas
├── 03_stored_procedures/  # Stored Procedures
├── 04_modifications/      # Modificaciones a tablas existentes (ALTER TABLE)
├── 05_triggers/           # Triggers SQL
├── 05_utilities/          # Scripts de utilidad (verificación, ejemplos, etc)
└── 06_tests/              # Scripts de prueba
```

## 📋 Orden de Ejecución Recomendado

### 1. Tablas Base
1. `01_tables/01_image.Analisis_Imagen.sql` - Crea schema `image` y tabla base
2. `01_tables/02_image.UmbralLuz.sql` - Tabla de umbrales (incluye datos iniciales)
3. `01_tables/03_image.LoteEvaluacion.sql` - Tabla de agregación por lote
4. `01_tables/04_image.Alerta.sql` - Tabla de alertas
5. `01_tables/05_image.Mensaje.sql` - Tabla de mensajes (agrega FK circular a Alerta)

### 2. Modificaciones
6. `04_modifications/01_add_originalImageUrl_column.sql` - Agrega columna a Analisis_Imagen

### 3. Vistas
7. `02_views/01_vwc_CianamidaFenologia.sql` - Vista de cianamida y fenología (puede ejecutarse antes)

### 4. Stored Procedures
8. `03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql` - SP para calcular estadísticas

### 5. Triggers
9. `05_triggers/01_trg_LoteEvaluacion_Alerta.sql` - Trigger que crea alertas automáticamente

### 6. Poblar Datos
9. Ejecutar SP para calcular estadísticas iniciales:
   ```sql
   EXEC image.sp_CalcularLoteEvaluacion;
   ```

### 7. Verificación
10. `00_setup/01_verificar_sistema_alertas.sql` - Verifica que todos los componentes existen

## 🎯 Scripts Maestros

- `00_setup/01_verificar_sistema_alertas.sql` - Verifica existencia de todos los componentes

## 🔧 Scripts de Utilidad

- `05_utilities/01_delete_analisis_imagen.sql` - Scripts para eliminar entradas (con precaución)
- `05_utilities/02_ejemplo_uso_umbrales_luz.sql` - Ejemplos de uso de umbrales
- `05_utilities/03_verificar_schemas_tablas.sql` - Verifica estructura de tablas existentes

## 🧪 Scripts de Test

- `06_tests/01_test_vwc_CianamidaFenologia.sql` - Test de la vista antes de crearla

## 📝 Convenciones de Nomenclatura

- **Tablas**: `<numero>_<schema>.<tabla>.sql` (ej: `01_image.Analisis_Imagen.sql`)
- **Vistas**: `<numero>_<nombre_vista>.sql` (ej: `01_vwc_CianamidaFenologia.sql`)
- **Stored Procedures**: `<numero>_sp_<nombre>.sql` (ej: `01_sp_CalcularLoteEvaluacion.sql`)
- **Triggers**: `<numero>_trg_<nombre>.sql` (ej: `01_trg_LoteEvaluacion_Alerta.sql`)
- **Modificaciones**: `<numero>_<accion>_<descripcion>.sql` (ej: `01_add_originalImageUrl_column.sql`)
- **Utilidades**: `<numero>_<descripcion>.sql` (ej: `01_delete_analisis_imagen.sql`)
- **Tests**: `<numero>_test_<objeto>.sql` (ej: `01_test_vwc_CianamidaFenologia.sql`)

## 📊 Headers de Archivos

Cada archivo tiene un header estándar con información de trazabilidad:

```sql
-- OBJETOS CREADOS:
--   ✅ Tablas/Vistas/SPs/Índices/Constraints:
--      - lista de objetos
-- 
-- OBJETOS MODIFICADOS:
--   ✅ Tablas modificadas:
--      - lista de objetos
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: [tablas/objetos que deben existir]
-- 
-- ORDEN DE EJECUCIÓN:
--   [número] de [total] - [descripción]
-- 
-- USADO POR:
--   - [descripción de dónde se usa]
```

Todos los headers han sido actualizados con esta información estándar para mejor trazabilidad.

