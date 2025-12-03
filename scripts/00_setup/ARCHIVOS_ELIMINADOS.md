# 🗑️ Archivos Eliminados - Depuración

**Fecha:** 2025-01-XX
**Razón:** Archivos redundantes, obsoletos o con referencias antiguas

---

## 📄 Documentación Eliminada

1. ✅ `scripts/00_setup/VERIFICACION_ESTANDARES_AGROMIGIVA.md`
   - **Razón:** Obsoleto, reemplazado por `VERIFICACION_FINAL_ESTANDARES.md` y `CAMBIOS_ESTANDARES_AGROMIGIVA.md`

2. ✅ `scripts/00_setup/VERIFICACION_ESTANDARES_DBA.md`
   - **Razón:** Obsoleto, reemplazado por `VERIFICACION_FINAL_ESTANDARES.md`

3. ✅ `scripts/00_setup/RESUMEN_SCRIPTS_EJECUTAR.md`
   - **Razón:** Redundante, la información está en `README.md`

---

## 🧪 Tests Eliminados

4. ✅ `scripts/06_tests/02_test_trigger_alerta.sql`
   - **Razón:** Test obsoleto con referencias antiguas (`image.LoteEvaluacion`, `trg_LoteEvaluacion_Alerta`)

5. ✅ `scripts/06_tests/03_test_trigger_debug.sql`
   - **Razón:** Script de debug temporal con referencias obsoletas

---

## 🔧 Scripts de Utilidades Eliminados

6. ✅ `scripts/07_utilities/01_insertar_usuario_admin.sql`
   - **Razón:** Versión antigua, reemplazada por `03_insertar_usuario_admin_final.sql`

7. ✅ `scripts/07_utilities/02_insertar_usuario_admin_simple.sql`
   - **Razón:** Versión intermedia, reemplazada por `03_insertar_usuario_admin_final.sql`

8. ✅ `scripts/07_utilities/generar_usuario_admin.js`
   - **Razón:** Redundante, existe versión TypeScript (`generar_usuario_admin.ts`)

9. ✅ `scripts/07_utilities/insertar_contacto_jemner.sql`
   - **Razón:** Script de prueba temporal con datos específicos

10. ✅ `scripts/07_utilities/poblar_fundoID_loteEvaluacion.sql`
    - **Razón:** Script de migración temporal ya ejecutado

11. ✅ `scripts/07_utilities/verificar_plantid.sql`
    - **Razón:** Script de debug con referencias obsoletas (`image.Analisis_Imagen`)

12. ✅ `scripts/07_utilities/diagnosticar_consolidacion.sql`
    - **Razón:** Script de debug temporal

13. ✅ `scripts/07_utilities/crear_mensaje_consolidado_real.sql`
    - **Razón:** Script de prueba temporal

14. ✅ `scripts/07_utilities/02_ejemplo_uso_umbrales_luz.sql`
    - **Razón:** Script de ejemplo con referencias obsoletas (`image.UmbralLuz`)

15. ✅ `scripts/07_utilities/verificar_alertas_para_consolidar.sql`
    - **Razón:** Script de debug temporal

16. ✅ `scripts/07_utilities/verificar_contacto_destinatarios.sql`
    - **Razón:** Script de debug temporal

17. ✅ `scripts/07_utilities/01_delete_analisis_imagen.sql`
    - **Razón:** Script con referencias obsoletas (`image.Analisis_Imagen`)

18. ✅ `scripts/07_utilities/02_delete_alertas.sql`
    - **Razón:** Script con referencias obsoletas (`image.Alerta`)

---

## 📁 Carpetas Vacías Eliminadas

19. ✅ `scripts/03_migrations/`
    - **Razón:** Carpeta vacía (migraciones consolidadas en `01_tables`)

20. ✅ `scripts/04_modifications/`
    - **Razón:** Carpeta vacía (modificaciones consolidadas en `01_tables`)

21. ✅ `scripts/06_migrations/`
    - **Razón:** Carpeta vacía (migraciones consolidadas en `01_tables`)

---

## ✅ Archivos Mantenidos

### Scripts de Utilidades Útiles:
- ✅ `03_insertar_usuario_admin_final.sql` - Script final para crear usuario admin
- ✅ `generar_hash_password.js` - Utilidad para generar hash de contraseñas
- ✅ `generar_usuario_admin.ts` - Script TypeScript para generar usuario admin
- ✅ `03_verificar_schemas_tablas.sql` - Verificación de schemas (sin referencias obsoletas)

### Tests Útiles:
- ✅ `01_test_vwc_CianamidaFenologia.sql` - Test de la vista (actualizado)

---

**Total de archivos eliminados:** 21
**Estado:** ✅ Depuración completada

