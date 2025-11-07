# 🧹 Plan de Limpieza - Eliminar Archivos Obsoletos de Next.js

## 📋 Archivos a Eliminar

### 1. Configuración de Next.js (Raíz)
- ❌ `next.config.ts` - Configuración de Next.js (ya no se usa)
- ❌ `next-env.d.ts` - Tipos de Next.js (ya no se usa)
- ⚠️ `package.json` - Actualizar para eliminar dependencias de Next.js (mantener scripts útiles)
- ⚠️ `tsconfig.json` - Actualizar o eliminar si no se usa
- ⚠️ `tailwind.config.ts` - Verificar si se comparte con frontend (ya está en frontend/)
- ⚠️ `postcss.config.js` - Verificar si se comparte con frontend (ya está en frontend/)
- ⚠️ `eslint.config.mjs` - Actualizar para eliminar config de Next.js

### 2. Carpeta `src/app/` (Next.js App Router)
- ❌ `src/app/` - Toda la carpeta (ya migrada a frontend/ y backend/)
  - `src/app/page.tsx` - Ya migrado a `frontend/src/App.tsx`
  - `src/app/layout.tsx` - Ya migrado a `frontend/src/components/Layout.tsx`
  - `src/app/api/` - Ya migrado a `backend/src/routes/`
  - `src/app/globals.css` - Ya migrado a `frontend/src/index.css`
  - `src/app/favicon.ico` - Mover a `frontend/public/` si se necesita

### 3. Componentes (Ya migrados)
- ❌ `src/components/` - Toda la carpeta (ya migrada a `frontend/src/components/`)

### 4. Hooks (Ya migrados)
- ❌ `src/hooks/` - Toda la carpeta (ya migrada a `frontend/src/hooks/`)

### 5. Servicios (Verificar duplicados)
- ⚠️ `src/services/alertService.ts` - Verificar si se usa en backend (parece específico)
- ❌ `src/services/api.ts` - Ya migrado a `frontend/src/services/api.ts`
- ⚠️ `src/services/googleSheetsService.ts` - Verificar si se usa (parece obsoleto)
- ❌ `src/services/sqlServerService.ts` - Ya migrado a `backend/src/services/sqlServerService.ts`
- ❌ `src/services/tensorflowService.ts` - Ya migrado a `frontend/src/services/tensorflowService.ts`

### 6. Utilidades (Verificar duplicados)
- ❌ `src/utils/constants.ts` - Ya migrado a `frontend/src/utils/constants.ts`
- ⚠️ `src/utils/exif-server.ts` - Verificar si se usa en backend (puede estar duplicado)
- ❌ `src/utils/exif.ts` - Ya migrado a `frontend/src/utils/exif.ts`
- ❌ `src/utils/filenameParser.ts` - Ya migrado a `frontend/src/utils/filenameParser.ts`
- ❌ `src/utils/helpers.ts` - Ya migrado a `frontend/src/utils/helpers.ts`
- ⚠️ `src/utils/imageThumbnail.ts` - Verificar si se usa

### 7. Lib (Ya migrado)
- ❌ `src/lib/db.ts` - Ya migrado a `backend/src/lib/db.ts`

### 8. Config (Next.js específico)
- ❌ `src/config/environment.ts` - Específico de Next.js (ya no se usa)

### 9. Types (Verificar duplicados)
- ⚠️ `src/types/index.ts` - Verificar si es igual a `frontend/src/types/index.ts`
- ⚠️ `src/types/piexifjs.d.ts` - Verificar si es igual a `backend/src/types/piexifjs.d.ts`

### 10. Jobs (Vacío)
- ❌ `src/jobs/` - Carpeta vacía, eliminar

### 11. Scripts de inicio (Next.js)
- ⚠️ `start-dev.bat` - Actualizar para usar frontend/ y backend/

## ✅ Archivos a Mantener

- ✅ `scripts/` - Scripts SQL (mantener)
- ✅ `docs/` - Documentación (mantener)
- ✅ `public/` - Archivos estáticos (mover a frontend/public/ si se necesita)
- ✅ `.gitignore` - Actualizar para incluir frontend/ y backend/
- ✅ `README.md` - Actualizar para reflejar nueva arquitectura
- ✅ `env.example` - Mantener o mover a backend/.env.example

## 📝 Pasos de Limpieza

1. ✅ Eliminar `src/app/` completa
2. ✅ Eliminar `src/components/`
3. ✅ Eliminar `src/hooks/`
4. ✅ Eliminar `src/lib/`
5. ✅ Eliminar `src/config/`
6. ✅ Eliminar `src/jobs/`
7. ⚠️ Verificar y eliminar servicios duplicados
8. ⚠️ Verificar y eliminar utilidades duplicadas
9. ⚠️ Verificar y eliminar tipos duplicados
10. ✅ Eliminar `next.config.ts`
11. ✅ Eliminar `next-env.d.ts`
12. ⚠️ Actualizar `package.json` del root
13. ⚠️ Actualizar `tsconfig.json` del root
14. ⚠️ Actualizar `.gitignore`
15. ⚠️ Actualizar `README.md`

