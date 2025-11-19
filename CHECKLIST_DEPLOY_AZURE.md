# ✅ Checklist para Deploy en Azure

## 📋 Estado Actual

- ✅ **Backend funcionando localmente**
- ✅ **Resend API configurado y probado**
- ✅ **Código listo para producción**
- ✅ **GitHub Actions workflow configurado**

---

## 🔧 Configuración Necesaria en Azure

### **1. Crear Azure App Service** ⚠️ PENDIENTE

**Pasos:**
- [ ] Crear Azure App Service Plan (Linux, Node.js 18)
- [ ] Crear Azure App Service (nombre: `luzsombra-backend`)
- [ ] Configurar runtime: Node.js 18 LTS
- [ ] Configurar región (preferiblemente cerca de SQL Server)

**Comando Azure CLI:**
```bash
# Crear App Service Plan
az appservice plan create \
  --name luzsombra-plan \
  --resource-group luzsombra-rg \
  --sku B1 \
  --is-linux

# Crear App Service
az webapp create \
  --name luzsombra-backend \
  --resource-group luzsombra-rg \
  --plan luzsombra-plan \
  --runtime "NODE:18-lts"
```

---

### **2. Configurar Variables de Entorno** ⚠️ PENDIENTE

**En Azure Portal → App Service → Configuration → Application Settings:**

```env
# SQL Server
SQL_SERVER=***REMOVED***
SQL_DATABASE=***REMOVED***
SQL_PORT=1433
SQL_USER=***REMOVED***
SQL_PASSWORD=[SECRETO - usar Key Vault]
SQL_ENCRYPT=true

# Server
PORT=3001
NODE_ENV=production

# Resend API
RESEND_API_KEY=[SECRETO - usar Key Vault]
RESEND_FROM_EMAIL=no-reply@updates.agricolaandrea.com
RESEND_FROM_NAME=Sistema de Alertas LuzSombra

# Frontend URL (después de crear frontend)
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
- [ ] ¿Puedo acceder directamente a `***REMOVED***`?

**Si SÍ está en la misma red:**
- [ ] Habilitar VNet Integration en App Service
- [ ] Conectar a VNet existente
- [ ] Verificar conectividad: `ping ***REMOVED***`

**Si NO está en la misma red:**
- [ ] Solicitar a IT configurar VNet + VPN Gateway
- [ ] O usar Web Service intermedio (plan alternativo)

---

### **4. Configurar Startup Command** ⚠️ PENDIENTE

**En Azure Portal → App Service → Configuration → General Settings:**

```
Startup Command: node backend/dist/server.js
```

O crear archivo `package.json` en raíz con:
```json
{
  "scripts": {
    "start": "node backend/dist/server.js"
  }
}
```

---

### **5. Configurar GitHub Actions Secrets** ⚠️ PENDIENTE

**En GitHub → Settings → Secrets → Actions:**

- [ ] `AZURE_WEBAPP_PUBLISH_PROFILE` - Obtener desde Azure Portal
  - Azure Portal → App Service → Get publish profile
  - Copiar contenido y agregar como secret

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

### **7. Probar Deploy** ⚠️ PENDIENTE

**Después de configurar todo:**

- [ ] Hacer push a branch `main`
- [ ] Verificar que GitHub Actions ejecuta
- [ ] Verificar que deploy es exitoso
- [ ] Probar endpoint: `GET https://luzsombra-backend.azurewebsites.net/api/health`
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

## ✅ Checklist Final

Antes de considerar el deploy completo:

- [ ] App Service creado y configurado
- [ ] Variables de entorno configuradas
- [ ] VNet Integration configurada (o Web Service)
- [ ] GitHub Actions funcionando
- [ ] Deploy exitoso
- [ ] Health check funcionando
- [ ] Conexión a SQL Server funcionando
- [ ] Resend API funcionando
- [ ] Logs monitoreados
- [ ] Documentación actualizada

---

**Última actualización:** 2025-11-19

