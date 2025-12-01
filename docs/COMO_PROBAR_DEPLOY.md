# 🧪 Cómo Probar el Deploy Antes de Merge a Main

## ✅ Opción 1: Usar workflow_dispatch (RECOMENDADO)

El workflow ya está configurado con `workflow_dispatch`, lo que permite ejecutarlo manualmente desde GitHub.

### Pasos:

1. **Ir a GitHub Actions:**
   - URL: `https://github.com/JemnerVera/LuzySombra-App/actions`
   - Click en el workflow: **"Deploy Backend to Azure App Service"**

2. **Ejecutar manualmente:**
   - Click en **"Run workflow"** (botón en la parte superior derecha)
   - Seleccionar branch: `feature/migracion-nodejs-react`
   - Click en **"Run workflow"** (botón verde)

3. **Monitorear el deploy:**
   - Ver logs en tiempo real
   - Verificar que cada step sea exitoso
   - Verificar que el deploy a Azure sea exitoso

4. **Probar el endpoint:**
   - Abrir: `http://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/health`
   - Debe responder: `{"status":"ok"}`

5. **Verificar logs en Azure:**
   - Azure Portal → App Service → Log stream
   - Verificar que el backend inicia correctamente
   - Verificar conexión a SQL Server

---

## ✅ Opción 2: Hacer Merge a Master (Después de Probar)

Una vez confirmado que el deploy funciona:

1. **Hacer merge a master:**
   ```bash
   git checkout master
   git merge feature/migracion-nodejs-react
   git push origin master
   ```

2. **El deploy se ejecutará automáticamente:**
   - GitHub Actions detectará el push a `master`
   - Ejecutará el workflow automáticamente
   - Deployará a Azure

---

## 🎯 Recomendación

**Usar Opción 1 primero** para:
- ✅ Probar sin afectar `master`
- ✅ Verificar que todo funciona
- ✅ Identificar problemas antes del deploy automático
- ✅ Tener control total sobre cuándo hacer deploy

**Luego usar Opción 2** para:
- ✅ Activar deploy automático
- ✅ Mantener `master` siempre actualizado
- ✅ Deployar automáticamente en cada push

---

**Última actualización:** 2025-11-19

