# GitHub Actions Workflows

## Workflow Principal: `master_agromigiva-luzysombra.yml`

Este es el workflow principal que despliega tanto el backend como el frontend en el mismo Azure App Service.

### Configuración

1. **App Service**: `agromigiva-luzysombra`
2. **URL**: `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net`
3. **Node.js**: 22.x LTS

### Secret Requerido

Configurar en GitHub: **Settings → Secrets and variables → Actions → New repository secret**

- **Nombre**: `AZURE_WEBAPP_PUBLISH_PROFILE`
- **Valor**: Contenido del archivo Publish Profile descargado desde Azure Portal
  - Azure Portal → App Service → Deployment Center → Manage publish profile → Download

### Proceso de Deploy

1. **Build Backend**: Compila TypeScript a JavaScript
2. **Build Frontend**: Compila React con Vite
3. **Copy Frontend**: Copia `frontend/dist/*` a `backend/public/`
4. **Deploy**: Despliega el backend (que incluye el frontend) a Azure App Service

### Notas

- El frontend se sirve desde el mismo dominio que el backend (rutas relativas)
- No se necesita configurar `VITE_API_URL` en producción
- Los archivos estáticos se sirven desde `backend/public/` mediante Express

## Workflows Deshabilitados

- `deploy-backend-azure.yml` - No se usa (backend se despliega con el workflow principal)
- `deploy-frontend-azure.yml` - No se usa (frontend se despliega con el workflow principal)

