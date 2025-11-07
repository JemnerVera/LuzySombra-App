# Reorganización de Scripts SQL

## 📋 Plan de Reorganización

### Estructura Propuesta

```
scripts/
├── 00_setup/                          # Scripts maestros
│   └── 01_crear_sistema_completo.sql
│
├── 01_tables/                         # Tablas (orden de creación)
│   ├── 01_create_table_analisis_imagen.sql
│   ├── 02_create_table_umbral_luz.sql
│   ├── 03_create_table_lote_evaluacion.sql
│   ├── 04_create_table_alerta.sql
│   └── 05_create_table_mensaje.sql
│
├── 02_views/                          # Vistas
│   └── 01_create_view_cianamida_fenologia.sql
│
├── 03_stored_procedures/              # Stored Procedures
│   └── 01_create_sp_calcular_lote_evaluacion.sql
│
├── 04_modifications/                  # Modificaciones a tablas existentes
│   └── 01_add_original_image_column.sql
│
├── 05_utilities/                      # Utilidades
│   ├── 01_delete_analisis_imagen.sql
│   ├── 02_verificar_schemas_tablas_existentes.sql
│   └── 03_ejemplo_uso_umbrales_luz.sql
│
└── 06_tests/                          # Scripts de prueba
    └── 01_test_view_cianamida_fenologia.sql
```

## 📝 Header Estándar para Archivos

Cada archivo debe tener este header:

```sql
-- =====================================================
-- SCRIPT: [Nombre del Script]
-- Base de datos: ***REMOVED***
-- Schema: [schema]
-- Propósito: [Descripción breve]
-- =====================================================
-- 
-- OBJETOS CREADOS:
--   ✅ Tablas:
--      - image.Analisis_Imagen
--   ✅ Índices:
--      - IDX_Analisis_Imagen_FECHA_01
--      - IDX_Analisis_Imagen_LOT_01
--   ✅ Constraints:
--      - PK_Analisis_Imagen
--      - FK_Analisis_Imagen_LOT_01
-- 
-- OBJETOS MODIFICADOS:
--   ❌ Ninguno
-- 
-- DEPENDENCIAS:
--   ⚠️  Requiere: GROWER.LOT (tabla existente)
--   ⚠️  Requiere: MAST.USERS (tabla existente)
-- 
-- ORDEN DE EJECUCIÓN:
--   1. Este script debe ejecutarse primero (crea schema image)
-- 
-- =====================================================
```

## 🔄 Archivos a Mover/Eliminar

### Archivos a Mover:

1. `create_table_analisis_imagen_agromigiva.sql` 
   → `01_tables/01_create_table_analisis_imagen.sql`

2. `create_table_umbral_luz.sql`
   → `01_tables/02_create_table_umbral_luz.sql`

3. `create_table_lote_evaluacion.sql`
   → `01_tables/03_create_table_lote_evaluacion.sql`

4. `create_table_alerta.sql`
   → `01_tables/04_create_table_alerta.sql`

5. `create_table_mensaje.sql`
   → `01_tables/05_create_table_mensaje.sql`

6. `create_view_cianamida_fenologia.sql`
   → `02_views/01_create_view_cianamida_fenologia.sql`

7. `create_sp_calcular_lote_evaluacion.sql`
   → `03_stored_procedures/01_create_sp_calcular_lote_evaluacion.sql`

8. `add_original_image_column.sql`
   → `04_modifications/01_add_original_image_column.sql`

9. `00_crear_sistema_alertas_completo.sql`
   → `00_setup/01_crear_sistema_completo.sql`

10. `delete_analisis_imagen.sql`
    → `05_utilities/01_delete_analisis_imagen.sql`

11. `verificar_schemas_tablas_existentes.sql`
    → `05_utilities/02_verificar_schemas_tablas_existentes.sql`

12. `ejemplo_uso_umbrales_luz.sql`
    → `05_utilities/03_ejemplo_uso_umbrales_luz.sql`

13. `test_view_cianamida_fenologia.sql`
    → `06_tests/01_test_view_cianamida_fenologia.sql`

### Archivos a Eliminar/Depurar:

- `catalogar_schemas.py` - Script Python de exploración, puede moverse a `tools/` o eliminarse si ya no se usa

## ✅ Checklist de Reorganización

- [ ] Crear carpetas (00_setup, 01_tables, 02_views, etc.)
- [ ] Mover archivos a sus nuevas ubicaciones
- [ ] Actualizar headers con información de trazabilidad
- [ ] Actualizar referencias en documentación
- [ ] Verificar que todos los scripts funcionan desde nuevas ubicaciones

