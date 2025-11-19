# Estrategia de Variables de Entorno (.env)

## 📋 Archivos .env

### **1. `.env.local` (Raíz del proyecto) - PRIORIDAD ALTA** ⭐

**Ubicación:** `/.env.local`

**Prioridad:** Se carga primero (línea 9 en `backend/src/server.ts`)

**Uso:** Configuración principal para desarrollo local

**Contiene:**
- SQL Server credentials
- Resend API configuration
- JWT Secret
- Frontend URL
- Todas las variables necesarias

---

### **2. `backend/.env.local` - FALLBACK** 

**Ubicación:** `/backend/.env.local`

**Prioridad:** Se carga como fallback (línea 11 en `backend/src/server.ts`)

**Uso:** Copia de respaldo o configuración específica del backend

**Recomendación:** 
- ✅ Mantener ambos sincronizados
- ✅ O eliminar `backend/.env.local` y usar solo el de la raíz

---

## 🔄 Orden de Carga

El backend carga las variables en este orden:

```typescript
// 1. Primero: .env.local de la raíz
dotenv.config({ path: path.join(rootPath, '.env.local') });

// 2. Segundo: .env de la raíz (si existe)
dotenv.config({ path: path.join(rootPath, '.env') });

// 3. Tercero: backend/.env.local o backend/.env (fallback)
dotenv.config();
```

**Resultado:** El `.env.local` de la raíz tiene **prioridad**.

---

## ✅ Recomendación

**Opción 1: Usar solo `.env.local` en raíz (RECOMENDADO)**
- ✅ Un solo archivo para mantener
- ✅ Más simple
- ✅ Consistente con Next.js/React

**Opción 2: Mantener ambos sincronizados**
- ⚠️ Más trabajo de mantenimiento
- ⚠️ Puede causar confusión

---

## 📝 Variables Necesarias

Ver `env.example` para la lista completa de variables requeridas.

**Variables críticas:**
- `SQL_SERVER`
- `SQL_DATABASE`
- `SQL_USER`
- `SQL_PASSWORD`
- `RESEND_API_KEY`
- `RESEND_FROM_EMAIL`
- `JWT_SECRET`
- `FRONTEND_URL`

---

**Última actualización:** 2025-11-19

