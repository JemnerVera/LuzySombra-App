# 🚀 Pasos Finales para Deploy en Azure

## ✅ Estado Actual

- ✅ Variables de entorno configuradas en Azure
- ✅ Secret `AZURE_WEBAPP_PUBLISH_PROFILE` configurado en GitHub
- ✅ `ENABLE_ALERT_SCHEDULER = false` configurado
- ✅ Workflow de GitHub Actions listo

---

## 📋 Verificaciones Finales en Azure

### 1. Verificar Startup Command

**Azure Portal → App Service → Configuration → General settings**

- **Startup Command**: Debe estar vacío o configurado como `npm start`
  - Azure detectará automáticamente `package.json` y ejecutará `npm start`
  - `npm start` ejecuta `node dist/server.js` (definido en `backend/package.json`)

**Si está vacío, está bien** - Azure usará `npm start` automáticamente.

### 2. Verificar URLs de Producción

**Azure Portal → App Service → Configuration → Application settings**

Verificar que estas variables tengan las URLs correctas:

| Variable | Valor Esperado |
|----------|----------------|
| `FRONTEND_URL` | `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net` |
| `BACKEND_BASE_URL` | `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/` |

**⚠️ IMPORTANTE**: Ambas deben usar `https://` (no `http://`)

### 3. Verificar Stack y Versión

**Azure Portal → App Service → Configuration → General settings**

- **Stack**: `Node.js`
- **Major version**: `22 LTS` ✅

---

## 🔧 Commit y Push

### Paso 1: Agregar cambios pendientes

```bash
git add .
```

### Paso 2: Commit

```bash
git commit -m "chore: Configurar deploy a Azure - workflows y documentación"
```

### Paso 3: Push a master

```bash
git push origin master
```

**⚠️ IMPORTANTE**: El push activará automáticamente el workflow de GitHub Actions.

---

## 📊 Monitorear el Deploy

### 1. GitHub Actions

Ir a: `https://github.com/JemnerVera/LuzySombra-App/actions`

Verificar que:
- ✅ El workflow `Build and deploy Node.js app to Azure Web App - agromigiva-luzysombra` se ejecuta
- ✅ El job `build` completa exitosamente
- ✅ El job `deploy` completa exitosamente
- ✅ No hay errores en los logs

### 2. Azure Portal - Log Stream

**Azure Portal → App Service → Monitoring → Log stream**

Verificar que:
- ✅ El servidor inicia correctamente
- ✅ No hay errores de conexión a SQL Server
- ✅ No hay errores de variables de entorno faltantes

### 3. Health Check

Abrir en el navegador:
```
https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/health
```

**Respuesta esperada:**
```json
{
  "status": "ok",
  "timestamp": "2025-01-16T..."
}
```

### 4. Verificar Frontend

Abrir en el navegador:
```
https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net
```

**Respuesta esperada:**
- ✅ La aplicación React se carga correctamente
- ✅ No hay errores en la consola del navegador
- ✅ Las llamadas a `/api/*` funcionan correctamente

---

## 🐛 Troubleshooting

### Error: "Cannot find module"

**Causa**: El build no se ejecutó correctamente o faltan archivos.

**Solución**:
1. Verificar que el workflow de GitHub Actions completó el build
2. Verificar que `backend/dist/server.js` existe en el deploy
3. Revisar logs de Azure para más detalles

### Error: "JWT_SECRET no está configurado"

**Causa**: Variable de entorno no configurada o no se aplicó.

**Solución**:
1. Verificar en Azure Portal que `JWT_SECRET` está configurada
2. Reiniciar el App Service después de agregar variables
3. Verificar que no hay espacios al inicio/final del valor

### Error: "Variables de entorno SQL Server faltantes"

**Causa**: Faltan variables de SQL Server.

**Solución**:
1. Verificar que `SQL_SERVER`, `SQL_DATABASE`, `SQL_USER`, `SQL_PASSWORD` estén configuradas
2. Verificar que los valores son correctos
3. Reiniciar el App Service

### Error: "Cannot connect to SQL Server"

**Causa**: Problema de conectividad de red.

**Solución**:
1. Verificar que Azure puede acceder a SQL Server (misma VNet o firewall configurado)
2. Verificar que `SQL_SERVER` tiene el valor correcto (IP o hostname)
3. Verificar que `SQL_ENCRYPT` está configurado correctamente
4. Revisar logs de Azure para más detalles del error

### Error: "Resend no está configurado"

**Causa**: `RESEND_API_KEY` no está configurada.

**Solución**:
1. Verificar que `RESEND_API_KEY` está configurada en Azure
2. Verificar que el valor es correcto (empieza con `re_`)
3. Reiniciar el App Service

---

## ✅ Checklist Final

Antes de considerar el deploy exitoso:

- [ ] Startup Command verificado (vacío o `npm start`)
- [ ] `FRONTEND_URL` tiene la URL correcta de producción
- [ ] `BACKEND_BASE_URL` tiene la URL correcta de producción
- [ ] Commit realizado
- [ ] Push a `master` realizado
- [ ] GitHub Actions workflow ejecutado exitosamente
- [ ] Health check (`/api/health`) responde correctamente
- [ ] Frontend se carga correctamente
- [ ] No hay errores en los logs de Azure
- [ ] Conexión a SQL Server funciona (probar desde la app)

---

## 🎉 ¡Deploy Completado!

Si todos los checks pasan, el deploy está completo y la aplicación está funcionando en producción.

**URLs de Producción:**
- **Frontend/Backend**: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net`
- **Health Check**: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/health`

---

**Última actualización**: 2025-01-16

