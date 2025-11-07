# 🚀 Setup de Azure para Agricola App

## 📋 Resumen

En Azure, **NO necesitas** configurar VPN manualmente como en desarrollo local. La conexión se maneja a nivel de infraestructura.

## 🔄 Diferencias: Desarrollo vs Producción

### Desarrollo Local
```
Tu PC → FortiClient VPN (manual) → Red Interna → SQL Server
```

### Producción (Azure)
```
Azure App Service → Azure VNet (automático) → Red Interna → SQL Server
```

## 🔧 Configuración en Azure

### 1. Azure App Service (Backend)

**Variables de Entorno (Application Settings):**
```
SQL_SERVER=10.1.10.4
SQL_DATABASE=BD_PACKING_AGROMIGIVA_DESA
SQL_PORT=1433
SQL_USER=ucown_powerbi_desa
SQL_PASSWORD=D3s4Own03
SQL_ENCRYPT=true
PORT=3001
FRONTEND_URL=https://tu-frontend.azurestaticapps.net
DATA_SOURCE=sql
NODE_ENV=production
```

**Startup Command:**
```
node backend/dist/server.js
```

**VNet Integration:**
- App Service → Networking → VNet integration
- Conectar a VNet que tenga acceso a la red interna
- Esto permite acceso a `10.1.10.4` sin VPN manual

### 2. Azure Static Web Apps (Frontend)

**Build Configuration:**
- App location: `frontend`
- Build command: `npm run build`
- Output location: `dist`

**Variables de Entorno (opcional):**
```
VITE_API_URL=https://agricola-backend.azurewebsites.net
```

### 3. Conexión de Red

**Opción A: VNet Integration (Recomendado)**
- Azure App Service se conecta a Azure Virtual Network
- VNet tiene acceso a la red interna de la empresa
- No requiere configuración manual de VPN

**Opción B: VPN Site-to-Site**
- Azure tiene VPN Site-to-Site configurada con la empresa
- Se maneja a nivel de infraestructura
- No requiere configuración en la aplicación

**Opción C: ExpressRoute**
- Conexión dedicada entre Azure y la empresa
- Más rápido y seguro
- Requiere configuración de infraestructura

## ✅ Checklist de Deploy

- [ ] Crear Azure App Service para backend
- [ ] Configurar Application Settings (variables de entorno)
- [ ] Configurar VNet Integration o VPN Site-to-Site
- [ ] Configurar Startup Command
- [ ] Crear Azure Static Web App para frontend
- [ ] Configurar build settings del frontend
- [ ] Probar conexión a SQL Server desde Azure
- [ ] Verificar logs y monitoreo

## 🔐 Seguridad

- ✅ Variables de entorno en Azure Application Settings (no en código)
- ✅ Considerar Azure Key Vault para secretos sensibles
- ✅ SQL Server accesible solo desde Azure VNet
- ✅ HTTPS habilitado automáticamente
- ✅ CORS configurado correctamente

## 📝 Notas

**VPN:**
- ❌ NO necesitas FortiClient en Azure
- ✅ La conexión se maneja a nivel de infraestructura
- ✅ Contactar al equipo de infraestructura para configurar VNet/VPN

**Variables de Entorno:**
- ❌ NO usar archivos `.env` en producción
- ✅ Usar Azure Application Settings
- ✅ Considerar Azure Key Vault para secretos

Ver `DEPLOY_AZURE.md` para guía completa de deploy.

