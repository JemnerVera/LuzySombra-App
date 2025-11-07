# 🚀 Guía de Deploy en Azure

## 📋 Arquitectura de Deploy

### Desarrollo Local
```
Tu PC → FortiClient VPN → Red Interna → SQL Server (10.1.10.4)
```

### Producción (Azure)
```
Azure App Service → Azure VNet/VPN Site-to-Site → Red Interna → SQL Server (10.1.10.4)
```

## 🔧 Configuración en Azure

### Paso 1: Crear Azure App Service

1. Ir a Azure Portal
2. Crear nuevo App Service:
   - **Nombre:** agricola-backend (o el que prefieras)
   - **Runtime:** Node.js 18 LTS o superior
   - **OS:** Linux (recomendado) o Windows
   - **Plan:** App Service Plan (básico o superior)

### Paso 2: Configurar Variables de Entorno

**⚠️ IMPORTANTE:** En Azure NO usas archivos `.env`. Usas Application Settings.

1. Ir a: App Service → Configuration → Application Settings
2. Agregar las siguientes variables:

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

3. **Marcar como "Slot Setting"** si usas deployment slots
4. Hacer clic en "Save"

### Paso 3: Configurar Conexión de Red

#### Opción A: Azure Virtual Network (VNet) Integration (Recomendado)

1. Ir a: App Service → Networking → VNet integration
2. Configurar VNet que tenga acceso a la red interna
3. Esto permite que App Service acceda directamente a `10.1.10.4`

#### Opción B: VPN Site-to-Site

1. Configurar VPN Site-to-Site desde Azure a la red interna
2. Esto requiere configuración de red a nivel de infraestructura
3. Contactar al equipo de infraestructura/redes

#### Opción C: SQL Server Público (NO recomendado por seguridad)

1. Exponer SQL Server públicamente (no recomendado)
2. Configurar firewall de SQL Server para permitir IPs de Azure
3. Menos seguro, pero más simple

### Paso 4: Deploy del Backend

#### Opción 1: Deploy desde Git (Recomendado)

1. Conectar repositorio en Azure Portal:
   - App Service → Deployment Center
   - Seleccionar GitHub/Azure DevOps/Git
   - Conectar repositorio

2. Configurar build:
   ```yaml
   # .github/workflows/azure-deploy.yml (ejemplo)
   - name: Build backend
     run: |
       cd backend
       npm install
       npm run build
   ```

3. Configurar start command:
   - App Service → Configuration → General Settings
   - Startup Command: `node backend/dist/server.js`

#### Opción 2: Deploy Manual (Azure CLI)

```bash
# Build del backend
cd backend
npm install
npm run build

# Deploy a Azure
az webapp deploy \
  --resource-group tu-resource-group \
  --name agricola-backend \
  --src-path backend/dist \
  --type zip
```

#### Opción 3: Deploy desde Visual Studio Code

1. Instalar extensión "Azure App Service"
2. Hacer clic derecho en `backend/dist`
3. Seleccionar "Deploy to Web App"

### Paso 5: Configurar Frontend (Azure Static Web Apps)

1. Crear Azure Static Web App:
   - Azure Portal → Static Web Apps → Create
   - Conectar repositorio
   - Configurar build:
     - App location: `frontend`
     - Build command: `npm run build`
     - Output location: `dist`

2. Configurar variables de entorno (opcional):
   - Settings → Configuration → Application Settings
   - Agregar: `VITE_API_URL=https://agricola-backend.azurewebsites.net`

## 🔐 Seguridad en Azure

### Variables de Entorno

**✅ SÍ hacer:**
- Usar Azure Application Settings para credenciales
- Marcar valores sensibles como "Hidden" (no se muestran en logs)
- Usar Azure Key Vault para secretos críticos

**❌ NO hacer:**
- Commitear credenciales en código
- Usar archivos `.env` en producción
- Exponer SQL Server públicamente sin firewall

### Azure Key Vault (Recomendado para producción)

1. Crear Azure Key Vault
2. Guardar secretos:
   - `SQL-PASSWORD`
   - `SQL-USER` (si es sensible)
3. Configurar App Service para acceder a Key Vault:
   - App Service → Configuration → Application Settings
   - Referenciar secretos de Key Vault: `@Microsoft.KeyVault(SecretUri=...)`

## 📊 Comparación: Desarrollo vs Producción

| Aspecto | Desarrollo Local | Producción (Azure) |
|---------|-----------------|-------------------|
| **VPN** | FortiClient manual | Azure VNet/VPN Site-to-Site (automático) |
| **Credenciales** | `backend/.env` | Azure Application Settings |
| **Conexión SQL** | A través de VPN local | A través de Azure VNet |
| **Deploy** | `npm run dev` | Git/Azure DevOps/CLI |
| **Variables** | Archivo `.env` | Application Settings en Portal |

## 🚀 Checklist de Deploy

### Backend

- [ ] Crear Azure App Service
- [ ] Configurar Application Settings (variables de entorno)
- [ ] Configurar VNet Integration o VPN Site-to-Site
- [ ] Configurar Startup Command: `node backend/dist/server.js`
- [ ] Probar conexión a SQL Server desde Azure
- [ ] Configurar HTTPS (automático en Azure)
- [ ] Configurar CORS para el frontend
- [ ] Configurar logs/monitoring

### Frontend

- [ ] Crear Azure Static Web App
- [ ] Conectar repositorio
- [ ] Configurar build settings
- [ ] Configurar `VITE_API_URL` si es necesario
- [ ] Probar que el frontend se conecte al backend

### Seguridad

- [ ] Variables de entorno configuradas (no en código)
- [ ] SQL Server accesible solo desde Azure VNet
- [ ] Firewall de SQL Server configurado
- [ ] HTTPS habilitado (automático)
- [ ] CORS configurado correctamente

## 🔍 Verificar Deploy

### 1. Health Check

```bash
curl https://agricola-backend.azurewebsites.net/api/health
```

Debería retornar:
```json
{
  "status": "ok",
  "timestamp": "2024-..."
}
```

### 2. Test de Base de Datos

```bash
curl https://agricola-backend.azurewebsites.net/api/test-db
```

Debería retornar información del servidor SQL.

### 3. Logs

Ver logs en tiempo real:
- Azure Portal → App Service → Log stream
- O usar: `az webapp log tail --name agricola-backend --resource-group tu-resource-group`

## 📝 Notas Importantes

### VPN en Azure

- **NO necesitas** configurar FortiClient en Azure
- La conexión se maneja a nivel de infraestructura (VNet/VPN)
- Azure se conecta automáticamente a la red interna
- Contactar al equipo de infraestructura para configurar VNet/VPN

### Variables de Entorno

- **NO usar** archivos `.env` en producción
- Usar Azure Application Settings
- Considerar Azure Key Vault para secretos sensibles
- Las variables están disponibles como `process.env.*` en el código

### CORS

Asegúrate de configurar CORS en el backend para permitir el frontend:

```typescript
// backend/src/server.ts
app.use(cors({
  origin: process.env.FRONTEND_URL || 'https://tu-frontend.azurestaticapps.net',
  credentials: true
}));
```

## 🆘 Troubleshooting

### Error: Cannot connect to SQL Server

**Posibles causas:**
1. VNet no configurada correctamente
2. SQL Server firewall bloqueando IPs de Azure
3. Variables de entorno incorrectas
4. VPN Site-to-Site no configurada

**Soluciones:**
1. Verificar VNet Integration en Azure Portal
2. Agregar IPs de Azure al firewall de SQL Server
3. Verificar Application Settings
4. Contactar al equipo de infraestructura

### Error: CORS

**Solución:**
- Verificar `FRONTEND_URL` en Application Settings
- Verificar configuración de CORS en `backend/src/server.ts`

## 📚 Recursos

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/)
- [Azure VNet Integration](https://docs.microsoft.com/azure/app-service/web-sites-integrate-with-vnet)
- [Azure Key Vault](https://docs.microsoft.com/azure/key-vault/)

