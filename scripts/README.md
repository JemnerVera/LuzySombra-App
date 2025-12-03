# Scripts SQL - Organización

## 📁 Estructura de Carpetas

```
scripts/
├── 00_setup/              # Scripts maestros y guías
├── 01_tables/             # Creación de tablas (schema evalImagen)
├── 02_views/              # Creación de vistas
├── 03_stored_procedures/  # Stored Procedures
├── 05_triggers/           # Triggers SQL
├── 06_tests/              # Scripts de prueba
└── 07_utilities/          # Scripts de utilidad (verificación, ejemplos, etc)
```

## 📋 Orden de Ejecución Recomendado

### 1. Tablas Base (Schema evalImagen)
1. `01_tables/01_evalImagen.AnalisisImagen.sql` - Crea schema `evalImagen` y tabla base
2. `01_tables/02_evalImagen.UmbralLuz.sql` - Tabla de umbrales (incluye datos iniciales)
3. `01_tables/03_evalImagen.LoteEvaluacion.sql` - Tabla de agregación por lote
4. `01_tables/04_evalImagen.Alerta.sql` - Tabla de alertas
5. `01_tables/05_evalImagen.Mensaje.sql` - Tabla de mensajes
6. `01_tables/06_evalImagen.Contacto.sql` - Tabla de contactos
7. `01_tables/07_evalImagen.Dispositivo.sql` - Tabla de dispositivos (incluye apiKeyHash y campos de activación)
8. `01_tables/08_evalImagen.MensajeAlerta.sql` - Tabla de relación (junction table)
9. `01_tables/09_evalImagen.UsuarioWeb.sql` - Tabla de usuarios web
10. `01_tables/10_evalImagen.IntentoLogin.sql` - Tabla de auditoría para rate limiting

**Nota:** Las tablas ya incluyen todas las columnas necesarias (`originalImageUrl`, `fundoID`, `sectorID`, `apiKeyHash`, campos de activación, etc.). No se requieren scripts de modificación o migración.

### 2. Vistas
11. `02_views/01_vwc_CianamidaFenologia.sql` - Vista de cianamida y fenología (puede ejecutarse antes)

### 3. Stored Procedures
12. `03_stored_procedures/01_sp_CalcularLoteEvaluacion.sql` - SP para calcular estadísticas

### 4. Triggers
13. `05_triggers/01_trg_LoteEvaluacion_Alerta.sql` - Trigger que crea alertas automáticamente

### 5. Poblar Datos
14. Ejecutar SP para calcular estadísticas iniciales:
   ```sql
   EXEC evalImagen.sp_CalcularLoteEvaluacion @LotID = <lotID>;
   ```

### 6. Verificación
15. `00_setup/01_verificar_sistema_alertas.sql` - Verifica que todos los componentes existen

## 🎯 Scripts Maestros

- `00_setup/01_verificar_sistema_alertas.sql` - Verifica existencia de todos los componentes

## 🔧 Scripts de Utilidad

- `07_utilities/01_delete_analisis_imagen.sql` - Scripts para eliminar entradas (con precaución)
- `07_utilities/02_ejemplo_uso_umbrales_luz.sql` - Ejemplos de uso de umbrales
- `07_utilities/03_verificar_schemas_tablas.sql` - Verifica estructura de tablas existentes

## 🧪 Scripts de Test

- `06_tests/01_test_vwc_CianamidaFenologia.sql` - Test de la vista antes de crearla

## 📝 Convenciones de Nomenclatura

- **Tablas**: `<numero>_<schema>.<tabla>.sql` (ej: `01_evalImagen.AnalisisImagen.sql`)
- **Vistas**: `<numero>_<nombre_vista>.sql` (ej: `01_vwc_CianamidaFenologia.sql`)
- **Stored Procedures**: `<numero>_sp_<nombre>.sql` (ej: `01_sp_CalcularLoteEvaluacion.sql`)
- **Triggers**: `<numero>_trg_<nombre>.sql` (ej: `01_trg_LoteEvaluacion_Alerta.sql`)
- **Modificaciones**: (Ya no se requieren - las tablas están completas)
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

