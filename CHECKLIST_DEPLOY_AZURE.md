# ✅ Checklist para Deploy en Azure - LuzSombra

## 📋 Estado Actual

- ✅ **Backend funcionando localmente**
- ✅ **Resend API configurado y probado**
- ✅ **Código listo para producción**
- ✅ **GitHub Actions workflow configurado**
- ✅ **Azure App Service ya creado** (`agromigiva-luzysombra`)
- ✅ **Publish Profile descargado** (`agromigiva-luzysombra.PublishSettings.txt`)

---

## ✅ INFORMACIÓN DEL APP SERVICE (Confirmado)

- **Nombre del App Service:** `agromigiva-luzysombra`
- **URL:** `http://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net`
- **Región:** `East US 2 (eastus2-01)`
- **Publish Profile:** Ya descargado ✅

---

## 🔧 Configuración Necesaria en Azure

### **1. Azure App Service** ✅ COMPLETADO

**Información:**
- ✅ App Service: `agromigiva-luzysombra`
- ✅ Runtime: Node.js 22 LTS
- ✅ Sistema Operativo: Linux
- ⚠️ Verificar plan: Básico o superior (recomendado B1)

---

### **2. Configurar Variables de Entorno** ✅ COMPLETADO

**En Azure Portal → App Service → Configuration → Application Settings:**

```env
# SQL Server
SQL_SERVER=10.1.10.4
SQL_DATABASE=BD_PACKING_AGROMIGIVA_DESA
SQL_PORT=1433
SQL_USER=ucown_powerbi_desa
SQL_PASSWORD=[SECRETO - usar Key Vault]
SQL_ENCRYPT=true

# Server
PORT=3001
NODE_ENV=production

# Resend API
RESEND_API_KEY=[SECRETO - usar Key Vault]
RESEND_FROM_EMAIL=no-reply@updates.agricolaandrea.com
RESEND_FROM_NAME=Sistema de Alertas LuzSombra

# Frontend URL (OBLIGATORIO para CORS - ver docs/EXPLICACION_FRONTEND_URL.md)
# Si no configuras esto, el frontend NO podrá hacer requests al backend
# Opciones:
# - Si frontend está en Azure Static Web Apps: https://luzsombra-frontend.azurestaticapps.net
# - Si frontend está en otro dominio: https://tu-dominio.com
# - Si solo backend (sin frontend web): puedes usar la URL del backend o dejar localhost
FRONTEND_URL=https://luzsombra-frontend.azurestaticapps.net

# Data Source
DATA_SOURCE=sql
```

**⚠️ IMPORTANTE:** Usar Azure Key Vault para secretos (SQL_PASSWORD, RESEND_API_KEY)

---

### **3. Configurar VNet Integration** ⚠️ PENDIENTE

**Verificar con IT/DBA:**
- [ ] ¿Azure está en la misma red privada?
- [ ] ¿Existe VNet configurada?
- [ ] ¿Puedo acceder directamente a `10.1.10.4`?

**Si SÍ está en la misma red:**
- [ ] Habilitar VNet Integration en App Service
- [ ] Conectar a VNet existente
- [ ] Verificar conectividad: `ping 10.1.10.4`

**Si NO está en la misma red:**
- [ ] Solicitar a IT configurar VNet + VPN Gateway
- [ ] O usar Web Service intermedio (plan alternativo)

---

### **4. Configurar Startup Command** ✅ AUTOMÁTICO

**Azure App Service ejecutará automáticamente:**
- `npm start` desde el directorio `backend/`
- Que ejecuta: `node dist/server.js` (definido en `backend/package.json`)

**⚠️ Si necesitas override manual:**
- Azure Portal → App Service → Configuration → General Settings
- Startup Command: `npm start` (o dejar vacío para usar package.json)

---

### **5. Configurar GitHub Actions Secrets** ✅ COMPLETADO

**En GitHub → Settings → Secrets → Actions:**

- [x] `AZURE_WEBAPP_PUBLISH_PROFILE` - Agregar publish profile ✅
  - **Archivo ya descargado:** `agromigiva-luzysombra.PublishSettings.txt`
  - **Secret configurado:** `https://github.com/JemnerVera/LuzySombra-App/settings/secrets/actions`

**⚠️ IMPORTANTE:** El archivo `agromigiva-luzysombra.PublishSettings.txt` ya está en `.gitignore` (no se commitea)

---

### **6. Configurar CORS** ⚠️ PENDIENTE

**Verificar en código:**
- [ ] CORS configurado para frontend URL
- [ ] Variables de entorno para CORS

**En `backend/src/server.ts`:**
```typescript
const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
app.use(cors({
  origin: frontendUrl,
  credentials: true
}));
```

---

### **7. Actualizar GitHub Actions Workflow** ✅ COMPLETADO

**Archivo:** `.github/workflows/deploy-backend-azure.yml`

**Estado:**
- ✅ Nombre del App Service actualizado: `agromigiva-luzysombra` (línea 13)
- ✅ Secret verificado: `${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}`
- ⚠️ **Nota:** El workflow usa Node.js 18.x para build (compatible con runtime Node 22 en Azure)

---

### **8. Probar Deploy** ⚠️ PENDIENTE

**Después de configurar todo:**

- [ ] Hacer commit de cambios al workflow
- [ ] Hacer push a branch `main` (o el branch configurado)
- [ ] Verificar que GitHub Actions ejecuta
- [ ] Monitorear deploy en: `https://github.com/JemnerVera/LuzySombra-App/actions`
- [ ] Verificar que deploy es exitoso
- [ ] Probar endpoint: `GET http://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/health`
- [ ] Verificar logs en Azure Portal
- [ ] Probar conexión a SQL Server desde Azure

---

## 📊 Frontend (Opcional - Después)

### **Azure Static Web Apps**

- [ ] Crear Azure Static Web App
- [ ] Conectar repositorio
- [ ] Configurar build settings
- [ ] Configurar variables de entorno (VITE_API_URL)
- [ ] Deploy automático

---

## 🔒 Seguridad

### **Azure Key Vault** ⚠️ RECOMENDADO

- [ ] Crear Azure Key Vault
- [ ] Agregar secretos:
  - `SQL-PASSWORD`
  - `RESEND-API-KEY`
- [ ] Configurar App Service para usar Key Vault
- [ ] Referenciar secretos en Application Settings

---

## 📝 Documentación

- [ ] Actualizar README con URL de producción
- [ ] Documentar proceso de deploy
- [ ] Documentar troubleshooting

---

## 🚨 Troubleshooting

### **Problemas Comunes:**

1. **Error de conexión a SQL Server:**
   - Verificar VNet Integration
   - Verificar firewall de SQL Server
   - Verificar credenciales

2. **Error en build:**
   - Verificar Node.js version
   - Verificar dependencias
   - Verificar scripts de build

3. **Error en runtime:**
   - Verificar startup command
   - Verificar variables de entorno
   - Verificar logs en Azure Portal

---

## 📝 PASOS SIGUIENDO EL PROCESO DE JOYSENSE

### **Paso 1: Verificar App Service** ✅ COMPLETADO

- [x] App Service ya existe: `agromigiva-luzysombra`
- [x] Verificar en Azure Portal que está activo
- [x] Runtime: Node.js 22 LTS ✅
- [x] Sistema Operativo: Linux ✅
- [ ] Verificar plan: B1 o superior (recomendado)

### **Paso 2: Agregar Publish Profile a GitHub Secrets** ✅ COMPLETADO

- [x] Abrir `agromigiva-luzysombra.PublishSettings.txt`
- [x] Copiar TODO el contenido (XML completo)
- [x] Ir a GitHub → Settings → Secrets → Actions
- [x] Crear nuevo secret: `AZURE_WEBAPP_PUBLISH_PROFILE`
- [x] Pegar contenido completo
- [x] Guardar

### **Paso 3: Actualizar Workflow YAML** ✅ COMPLETADO

- [x] Abrir `.github/workflows/deploy-backend-azure.yml`
- [x] Cambiar línea 13: `AZURE_WEBAPP_NAME: agromigiva-luzysombra`
- [x] Verificar que el secret se llama correctamente
- [ ] Commit cambios (pendiente)

### **Paso 4: Configurar Variables de Entorno en Azure** ✅ COMPLETADO

- [x] Ir a Azure Portal → App Services → `agromigiva-luzysombra`
- [x] Configuration → Application settings
- [x] Agregar todas las variables (ver sección 2)
- [x] Click **"Save"** (reiniciará el App Service)

### **Paso 5: Configurar VNet Integration** ⚠️

- [ ] Verificar con IT/DBA si Azure está en la misma red
- [ ] Si SÍ: Habilitar VNet Integration
- [ ] Si NO: Usar Web Service o solicitar VNet

### **Paso 6: Commit y Push** ⚠️

```bash
git add .github/workflows/deploy-backend-azure.yml
git commit -m "chore: Configurar deploy a Azure (agromigiva-luzysombra)"
git push origin main
```

⚠️ **IMPORTANTE:** El push iniciará el deploy automáticamente.

### **Paso 7: Monitorear Deploy**

- [ ] Ver GitHub Actions: `https://github.com/JemnerVera/LuzySombra-App/actions`
- [ ] Verificar que el workflow se ejecuta
- [ ] Ver logs de cada step
- [ ] Verificar que "Deploy to Azure Web App" es exitoso

### **Paso 8: Verificar que Funciona**

- [ ] Abrir: `http://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/health`
- [ ] Verificar respuesta: `{"status":"ok"}`
- [ ] Verificar logs en Azure Portal → Log stream
- [ ] Probar conexión a SQL Server
- [ ] Probar Resend API

---

## ✅ Checklist Final

Antes de considerar el deploy completo:

- [x] App Service creado (`agromigiva-luzysombra`)
- [x] Publish Profile descargado
- [x] Variables de entorno configuradas en Azure
- [x] GitHub Secret configurado (`AZURE_WEBAPP_PUBLISH_PROFILE`)
- [x] Workflow YAML actualizado
- [ ] VNet Integration configurada (o Web Service) - **Pendiente verificación**
- [ ] Commit y push realizado
- [ ] Deploy exitoso en GitHub Actions
- [ ] Health check funcionando
- [ ] Conexión a SQL Server funcionando
- [ ] Resend API funcionando
- [ ] Logs monitoreados

---

## 🔗 URLs y Referencias

**Azure App Service:**
- **Nombre:** `agromigiva-luzysombra`
- **URL:** `http://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net`
- **Health Check:** `http://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/health`

**Azure Portal:**
- App Services → `agromigiva-luzysombra`
- Configuration → Application settings
- Deployment Center → Logs
- Monitoring → Log stream

**GitHub:**
- **Repositorio:** `https://github.com/JemnerVera/LuzySombra-App`
- **Secrets:** `https://github.com/JemnerVera/LuzySombra-App/settings/secrets/actions`
- **Actions:** `https://github.com/JemnerVera/LuzySombra-App/actions`

---

**Última actualización:** 2025-11-19
**Basado en:** Proceso de deploy de JoySense (PASOS_DEPLOY_JOYSENSE_PROD.md)

