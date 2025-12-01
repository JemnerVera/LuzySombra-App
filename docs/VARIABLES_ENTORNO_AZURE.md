# Variables de Entorno en Azure - Verificación

## ✅ Variables Configuradas

Has configurado las siguientes variables en Azure App Service. Aquí está el análisis de cuáles se usan y cuáles son redundantes.

---

## 📋 Variables que SÍ se Usan (NECESARIAS)

### **SQL Server (sin prefijo AZURE_)**

El código usa estas variables **sin** el prefijo `AZURE_`:

```env
✅ SQL_SERVER          → Usado en backend/src/lib/db.ts
✅ SQL_DATABASE        → Usado en backend/src/lib/db.ts
✅ SQL_PORT            → Usado en backend/src/lib/db.ts
✅ SQL_USER            → Usado en backend/src/lib/db.ts
✅ SQL_PASSWORD        → Usado en backend/src/lib/db.ts
✅ SQL_ENCRYPT         → Usado en backend/src/lib/db.ts
```

**Ubicación en código:**
- `backend/src/lib/db.ts` (líneas 24-28)

---

### **Resend API**

```env
✅ RESEND_API_KEY      → Usado en backend/src/services/resendService.ts
✅ RESEND_FROM_EMAIL   → Usado en backend/src/services/resendService.ts
✅ RESEND_FROM_NAME    → Usado en backend/src/services/resendService.ts
```

**Ubicación en código:**
- `backend/src/services/resendService.ts` (líneas 14-16)

---

### **Server Configuration**

```env
✅ PORT                → Usado en backend/src/server.ts (línea 31)
✅ FRONTEND_URL        → Usado en backend/src/server.ts (línea 35) - CORS
✅ NODE_ENV            → Usado en múltiples lugares (development/production)
✅ DATA_SOURCE         → Usado en backend/src/routes/image-processing.ts
```

---

## ⚠️ Variables Redundantes (NO se Usan)

Estas variables **NO** se usan en el código actual:

```env
❌ AZURE_SQL_DATABASE
❌ AZURE_SQL_PASSWORD
❌ AZURE_SQL_PORT
❌ AZURE_SQL_SERVER
❌ AZURE_SQL_USERNAME
```

**Razón:** El código busca variables con nombres `SQL_*` (sin prefijo `AZURE_`).

**Recomendación:** Puedes eliminarlas para evitar confusión, o mantenerlas si planeas usarlas en el futuro.

---

## 🔍 Verificación del Código

### **1. SQL Server Connection (`backend/src/lib/db.ts`)**

```typescript
const config: sql.config = {
  user: process.env.SQL_USER!,           // ✅ SQL_USER
  password: process.env.SQL_PASSWORD!,   // ✅ SQL_PASSWORD
  server: process.env.SQL_SERVER!,       // ✅ SQL_SERVER
  database: process.env.SQL_DATABASE!,   // ✅ SQL_DATABASE
  port: parseInt(process.env.SQL_PORT || '1433'),  // ✅ SQL_PORT
  options: {
    encrypt: process.env.SQL_ENCRYPT !== 'false',  // ✅ SQL_ENCRYPT
  },
};
```

**❌ NO busca:** `AZURE_SQL_*`

---

### **2. Resend Service (`backend/src/services/resendService.ts`)**

```typescript
const apiKey = process.env.RESEND_API_KEY;           // ✅ RESEND_API_KEY
this.fromEmail = process.env.RESEND_FROM_EMAIL;     // ✅ RESEND_FROM_EMAIL
this.fromName = process.env.RESEND_FROM_NAME;       // ✅ RESEND_FROM_NAME
```

---

### **3. Server Configuration (`backend/src/server.ts`)**

```typescript
const PORT = process.env.PORT || 3001;              // ✅ PORT

app.use(cors({
  origin: process.env.FRONTEND_URL || '...',        // ✅ FRONTEND_URL
  credentials: true
}));
```

---

## ✅ Checklist de Variables Necesarias

### **Obligatorias (sin estas, la app NO funciona):**

- [x] `SQL_SERVER`
- [x] `SQL_DATABASE`
- [x] `SQL_USER`
- [x] `SQL_PASSWORD`
- [x] `SQL_PORT`
- [x] `SQL_ENCRYPT`
- [x] `RESEND_API_KEY`
- [x] `RESEND_FROM_EMAIL`
- [x] `RESEND_FROM_NAME`
- [x] `FRONTEND_URL`
- [x] `PORT`
- [x] `NODE_ENV`
- [x] `DATA_SOURCE`

### **Opcionales (tienen valores por defecto):**

- `JWT_SECRET` - Tiene fallback: `'your-secret-key-change-in-production'`
- `ALERTAS_EMAIL_DESTINATARIOS` - Solo si no hay contactos en `evalImagen.Contacto`

---

## 🧹 Limpieza Recomendada

**Puedes eliminar estas variables (no se usan):**

```env
❌ AZURE_SQL_DATABASE
❌ AZURE_SQL_PASSWORD
❌ AZURE_SQL_PORT
❌ AZURE_SQL_SERVER
❌ AZURE_SQL_USERNAME
```

**O mantenerlas si:**
- Planeas modificar el código para usarlas
- Son para referencia/documentación
- Las usa otro sistema

---

## 🔒 Seguridad

**Variables Sensibles (usar Key Vault):**

- ⚠️ `SQL_PASSWORD` - Contraseña de SQL Server
- ⚠️ `RESEND_API_KEY` - API Key de Resend
- ⚠️ `JWT_SECRET` - Secret para tokens JWT (si lo agregas)

**Recomendación:** Configurar Azure Key Vault y referenciar estas variables desde allí.

---

## 📝 Resumen

| Estado | Cantidad | Variables |
|--------|----------|-----------|
| ✅ **Necesarias** | 13 | SQL_*, RESEND_*, PORT, FRONTEND_URL, NODE_ENV, DATA_SOURCE |
| ❌ **Redundantes** | 5 | AZURE_SQL_* (no se usan) |
| ⚠️ **Faltantes** | 0 | Todas las necesarias están configuradas |

---

## ✅ Conclusión

**Todas las variables necesarias están configuradas.** ✅

Las variables con prefijo `AZURE_` son redundantes y pueden eliminarse, pero no causan problemas si se mantienen.

**Próximo paso:** Verificar que los valores sean correctos y hacer el deploy.

---

**Última actualización:** 2025-11-19


