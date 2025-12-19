# Variables de Entorno - Azure y GitHub

Este documento lista todas las variables de entorno que deben configurarse en Azure App Service y GitHub Secrets.

---

## 📋 Índice

1. [Variables para Azure Application Settings](#variables-para-azure-application-settings)
2. [Secrets para GitHub](#secrets-para-github)
3. [Variables Opcionales](#variables-opcionales)
4. [Configuración en Azure Portal](#configuración-en-azure-portal)
5. [Configuración en GitHub](#configuración-en-github)

---

## 🔐 Variables para Azure Application Settings

Configurar en: **Azure Portal → App Service → Configuration → Application settings**

### ⚠️ OBLIGATORIAS (Críticas)

| Variable | Descripción | Ejemplo | Notas |
|----------|-------------|---------|-------|
| `SQL_SERVER` | IP o hostname del servidor SQL Server | `10.1.10.4` o `sql-server.agromigiva.local` | ⚠️ **REQUERIDA** |
| `SQL_DATABASE` | Nombre de la base de datos | `BD_PACKING_AGROMIGIVA_DESA` | ⚠️ **REQUERIDA** |
| `SQL_USER` | Usuario SQL Server | `ucser_luzsombra` | ⚠️ **REQUERIDA** |
| `SQL_PASSWORD` | Contraseña del usuario SQL Server | `********` | ⚠️ **REQUERIDA** - Marcar como "Secret" |
| `JWT_SECRET` | Secret key para firmar tokens JWT | `tu-super-secret-key-aleatoria-256-bits` | ⚠️ **REQUERIDA** - Marcar como "Secret" |
| `RESEND_API_KEY` | API Key de Resend para envío de emails | `re_xxxxxxxxxxxxx` | ⚠️ **REQUERIDA** - Marcar como "Secret" |
| `RESEND_FROM_EMAIL` | Email remitente (debe estar verificado en Resend) | `no-reply@your-domain.com` | ⚠️ **REQUERIDA** |

### 📧 Resend Email (Opcionales con valores por defecto)

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `RESEND_FROM_NAME` | Nombre del remitente | `Sistema de Alertas` | `Sistema de Alertas LuzSombra` |
| `ALERTAS_EMAIL_DESTINATARIOS` | JSON array de emails fallback | `[]` | `["admin@example.com"]` |
| `ALERTAS_EMAIL_CC` | JSON array de emails CC | `[]` | `["manager@example.com"]` |

### 🔧 Configuración del Servidor

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `PORT` | Puerto del servidor backend | `3001` | `3001` |
| `FRONTEND_URL` | URL del frontend (mismo dominio en producción) | `http://localhost:3000` | `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net` |
| `BACKEND_BASE_URL` | URL base del backend (para QR codes) | `http://localhost:3001/api/` | `https://agromigiva-luzysombra-fdfzhje4ascbc3dr.eastus2-01.azurewebsites.net/api/` |
| `NODE_ENV` | Entorno de ejecución | `development` | `production` |

### 🗄️ SQL Server (Opcionales con valores por defecto)

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `SQL_PORT` | Puerto de SQL Server | `1433` | `1433` |
| `SQL_ENCRYPT` | Habilitar encriptación TLS | `true` | `true` o `false` |
| `DATA_SOURCE` | Fuente de datos (siempre 'sql') | `sql` | `sql` |

### ⏰ Scheduler de Alertas

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `ENABLE_ALERT_SCHEDULER` | Habilitar scheduler automático | `true` | `true` o `false` |

### 🔒 Seguridad (Opcionales con valores por defecto)

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `JWT_EXPIRES_IN` | Expiración de tokens JWT | `24h` | `24h`, `7d`, `30d` |
| `BCRYPT_ROUNDS` | Rondas de bcrypt para hash de passwords | `10` | `10` |
| `LOG_LEVEL` | Nivel de logging (info/debug) | `info` (prod) / `debug` (dev) | `info` |

---

## 🔑 Secrets para GitHub

Configurar en: **GitHub Repo → Settings → Secrets and variables → Actions → New repository secret**

### ⚠️ OBLIGATORIO

| Secret | Descripción | Cómo Obtenerlo |
|--------|-------------|----------------|
| `AZURE_WEBAPP_PUBLISH_PROFILE` | Publish Profile de Azure App Service | Azure Portal → App Service → Deployment Center → Manage publish profile → Download |

**Nota:** Azure puede generar automáticamente un secret con un nombre como `AZUREAPPSERVICE_PUBLISHPROFILE_...` cuando se configura el Deployment Center. Si ese es el caso, el workflow ya está configurado para usar ambos nombres.

---

## 📝 Variables Opcionales

Estas variables tienen valores por defecto y no son obligatorias, pero pueden personalizarse:

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `SQL_PORT` | Puerto SQL Server | `1433` |
| `SQL_ENCRYPT` | Encriptación TLS | `true` |
| `PORT` | Puerto del servidor | `3001` |
| `FRONTEND_URL` | URL del frontend | `http://localhost:3000` |
| `BACKEND_BASE_URL` | URL base del backend | `http://localhost:3001/api/` |
| `NODE_ENV` | Entorno | `development` |
| `JWT_EXPIRES_IN` | Expiración JWT | `24h` |
| `BCRYPT_ROUNDS` | Rondas bcrypt | `10` |
| `ENABLE_ALERT_SCHEDULER` | Scheduler de alertas | `true` |
| `RESEND_FROM_NAME` | Nombre remitente | `Sistema de Alertas` |
| `LOG_LEVEL` | Nivel de logging | `info` (prod) / `debug` (dev) |

---

## 🚀 Configuración en Azure Portal

### Paso 1: Acceder a Application Settings

1. Ir a **Azure Portal** → **App Service** → `agromigiva-luzysombra`
2. En el menú lateral, ir a **Configuration** → **Application settings**
3. Click en **+ New application setting**

### Paso 2: Agregar Variables

Para cada variable de la lista anterior:

1. **Name**: Nombre de la variable (ej: `SQL_SERVER`)
2. **Value**: Valor de la variable
3. **Deployment slot setting**: Marcar si es específico del slot
4. Para variables sensibles (passwords, keys), marcar **"Deployment slot setting"** y considerar usar **Azure Key Vault**

### Paso 3: Configurar Startup Command

1. Ir a **Configuration** → **General settings**
2. En **Stack settings**:
   - **Stack**: `Node.js`
   - **Major version**: `22 LTS`
3. En **Startup Command**:
   ```
   node dist/server.js
   ```
   O alternativamente:
   ```
   npm start
   ```

### Paso 4: Guardar y Reiniciar

1. Click en **Save**
2. Azure pedirá confirmación para reiniciar el App Service
3. Click en **Continue**

---

## 🔧 Configuración en GitHub

### Paso 1: Obtener Publish Profile

1. Ir a **Azure Portal** → **App Service** → `agromigiva-luzysombra`
2. Ir a **Deployment Center** → **Settings**
3. Click en **Manage publish profile** → **Download**
4. Se descargará un archivo `.PublishSettings`

### Paso 2: Agregar Secret en GitHub

1. Ir a **GitHub Repo** → **Settings** → **Secrets and variables** → **Actions**
2. Click en **New repository secret**
3. **Name**: `AZURE_WEBAPP_PUBLISH_PROFILE`
4. **Secret**: Abrir el archivo `.PublishSettings` descargado y copiar TODO su contenido
5. Click en **Add secret**

### Paso 3: Verificar Workflow

El workflow `.github/workflows/master_agromigiva-luzysombra.yml` ya está configurado para usar este secret.

---

## ✅ Checklist de Configuración

### Azure Application Settings

- [ ] `SQL_SERVER` configurado
- [ ] `SQL_DATABASE` configurado
- [ ] `SQL_USER` configurado
- [ ] `SQL_PASSWORD` configurado (marcado como Secret)
- [ ] `JWT_SECRET` configurado (marcado como Secret)
- [ ] `RESEND_API_KEY` configurado (marcado como Secret)
- [ ] `RESEND_FROM_EMAIL` configurado
- [ ] `FRONTEND_URL` configurado con URL de producción
- [ ] `BACKEND_BASE_URL` configurado con URL de producción
- [ ] `NODE_ENV` configurado como `production`
- [ ] `PORT` configurado (opcional, default: 3001)
- [ ] `ENABLE_ALERT_SCHEDULER` configurado (opcional, default: true)
- [ ] Startup Command configurado: `node dist/server.js`

### GitHub Secrets

- [ ] `AZURE_WEBAPP_PUBLISH_PROFILE` configurado

---

## 🔒 Seguridad

### Variables Sensibles (Marcar como "Secret" en Azure)

- `SQL_PASSWORD`
- `JWT_SECRET`
- `RESEND_API_KEY`

### Recomendaciones

1. **Azure Key Vault**: Para producción, considerar usar Azure Key Vault para almacenar secrets sensibles
2. **Rotación de Secrets**: Rotar `JWT_SECRET` y `SQL_PASSWORD` periódicamente
3. **Principio de Menor Privilegio**: El usuario SQL debe tener solo los permisos necesarios
4. **HTTPS**: Asegurar que `FRONTEND_URL` y `BACKEND_BASE_URL` usen HTTPS en producción

---

## 📚 Referencias

- [Azure App Service Configuration](https://docs.microsoft.com/en-us/azure/app-service/configure-common)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Resend API Documentation](https://resend.com/docs)
- [JWT Best Practices](https://jwt.io/introduction)

---

## 🆘 Troubleshooting

### Error: "JWT_SECRET no está configurado"
- Verificar que `JWT_SECRET` esté configurado en Azure Application Settings
- Reiniciar el App Service después de agregar la variable

### Error: "Variables de entorno SQL Server faltantes"
- Verificar que `SQL_USER`, `SQL_PASSWORD`, `SQL_SERVER`, `SQL_DATABASE` estén configurados
- Verificar que los valores no tengan espacios al inicio/final

### Error: "Resend no está configurado"
- Verificar que `RESEND_API_KEY` esté configurado
- Verificar que `RESEND_FROM_EMAIL` esté verificado en Resend

### Error: "Cannot connect to SQL Server"
- Verificar que `SQL_SERVER` sea accesible desde Azure (misma VNet o firewall configurado)
- Verificar que `SQL_USER` y `SQL_PASSWORD` sean correctos
- Verificar que `SQL_ENCRYPT` esté configurado correctamente

---

**Última actualización**: 2025-01-16

