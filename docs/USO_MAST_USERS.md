# 📋 Uso de MAST.USERS en la Aplicación LuzSombra

Este documento explica para qué se usa la tabla `MAST.USERS` en la aplicación y cómo se relaciona con el nuevo sistema de autenticación web.

---

## 🎯 Propósito Principal: **Auditoría y Trazabilidad**

`MAST.USERS` se usa **únicamente para auditoría** - registrar quién creó, modificó o resolvió registros en las tablas del sistema. **NO se usa para autenticación**.

---

## 📊 Tablas que Usan MAST.USERS

### 1. **evalImagen.AnalisisImagen**
```sql
usuarioCreaID INT → MAST.USERS.userID
```
**Uso:** Registra qué usuario del sistema creó el análisis de imagen.

**Código actual:**
```typescript
// backend/src/services/sqlServerService.ts (línea 358-372)
let userCreatedID = 1;
try {
  const usuarioResult = await query<{ userID: number }>(`
    SELECT TOP 1 userID 
    FROM MAST.USERS 
    WHERE statusID = 1 
    ORDER BY userID
  `);
  
  if (usuarioResult.length > 0 && usuarioResult[0].userID) {
    userCreatedID = Number(usuarioResult[0].userID);
  }
} catch (userError) {
  console.warn('⚠️ Error al obtener usuario de MAST.USERS, usando valor por defecto:', userError);
}
```

**Problema actual:** 
- Usa el primer usuario activo de MAST.USERS como valor por defecto
- No identifica realmente quién subió la foto (AgriQR o web)

---

### 2. **evalImagen.UmbralLuz**
```sql
usuarioCreaID INT → MAST.USERS.userID
usuarioActualizaID INT → MAST.USERS.userID
```
**Uso:** Registra quién creó y quién modificó cada umbral de luz.

**Código actual:**
```typescript
// backend/src/routes/umbrales.ts
// Requiere usuarioCreaID y usuarioActualizaID como parámetros
```

---

### 3. **evalImagen.Contacto**
```sql
usuarioCreaID INT → MAST.USERS.userID
usuarioActualizaID INT → MAST.USERS.userID
```
**Uso:** Registra quién creó y quién modificó cada contacto.

**Código actual:**
```typescript
// backend/src/routes/contactos.ts
// Requiere usuarioCreaID y usuarioActualizaID como parámetros
```

---

### 4. **evalImagen.Alerta**
```sql
usuarioResolvioID INT → MAST.USERS.userID
```
**Uso:** Registra qué usuario resolvió o ignoró una alerta.

**Código actual:**
```typescript
// backend/src/routes/alertas/listar.ts
// Requiere usuarioResolvioID como parámetro
await alertService.resolverAlerta(alertaID, parseInt(usuarioResolvioID), notas);
await alertService.ignorarAlerta(alertaID, parseInt(usuarioResolvioID), notas);
```

---

### 5. **evalImagen.Dispositivo**
```sql
usuarioCreaID INT → MAST.USERS.userID
usuarioModificaID INT → MAST.USERS.userID
```
**Uso:** Registra quién creó y quién modificó cada dispositivo (AgriQR).

---

## 🔄 Situación Actual vs Futura

### ❌ **Situación Actual (Problemas)**

1. **No identifica realmente al usuario:**
   - Cuando AgriQR sube una foto, se usa un usuario genérico de MAST.USERS
   - No hay forma de saber qué dispositivo o usuario web hizo la acción

2. **Requiere pasar `usuarioCreaID` manualmente:**
   - Las rutas de umbrales, contactos, alertas requieren `usuarioCreaID` como parámetro
   - El frontend debe enviarlo, pero no hay autenticación web aún

3. **Valor por defecto genérico:**
   - `sqlServerService.ts` usa el primer usuario activo de MAST.USERS
   - No es preciso para auditoría

---

### ✅ **Situación Futura (Con Autenticación Web)**

Cuando se implemente la autenticación web, hay dos opciones:

#### **Opción 1: Mantener MAST.USERS para Auditoría (Recomendado)**

**Ventajas:**
- ✅ No requiere cambios en la estructura de BD
- ✅ Compatible con otros sistemas que usan MAST.USERS
- ✅ Mantiene historial de auditoría existente

**Cómo funciona:**
- Usuarios web se autentican con `evalImagen.UsuarioWeb`
- Cuando hacen una acción, se obtiene su `usuarioID` del token JWT
- Se busca o crea el usuario correspondiente en `MAST.USERS` (si existe)
- Se guarda `usuarioCreaID` apuntando a `MAST.USERS.userID`

**Implementación:**
```typescript
// Cuando un usuario web crea un umbral
const userWeb = req.user; // Del middleware authenticateWebUser
// Buscar o crear en MAST.USERS
const mastUser = await findOrCreateMastUser(userWeb.usuarioID, userWeb.username);
// Guardar con usuarioCreaID = mastUser.userID
```

---

#### **Opción 2: Migrar a evalImagen.UsuarioWeb**

**Ventajas:**
- ✅ Más simple - todo en un solo lugar
- ✅ No depende de MAST.USERS

**Desventajas:**
- ❌ Requiere cambios en todas las tablas (Foreign Keys)
- ❌ Puede romper compatibilidad con otros sistemas
- ❌ Requiere migración de datos históricos

**Implementación:**
```sql
-- Cambiar Foreign Keys
ALTER TABLE evalImagen.UmbralLuz
DROP CONSTRAINT FK_UmbralLuz_UsuarioCrea;

ALTER TABLE evalImagen.UmbralLuz
ADD CONSTRAINT FK_UmbralLuz_UsuarioCrea 
FOREIGN KEY (usuarioCreaID) 
REFERENCES evalImagen.UsuarioWeb(usuarioID);
```

---

## 🎯 Recomendación: **Opción 1 - Mantener MAST.USERS**

### Razones:

1. **MAST.USERS es compartida:**
   - Puede ser usada por otros sistemas de AgroMigiva
   - Mantener compatibilidad es importante

2. **Separación de responsabilidades:**
   - `evalImagen.UsuarioWeb` → Autenticación web
   - `MAST.USERS` → Auditoría y trazabilidad

3. **Menos cambios:**
   - No requiere modificar Foreign Keys existentes
   - No requiere migración de datos

4. **Flexibilidad:**
   - Puede registrar acciones de usuarios web Y dispositivos
   - Puede mantener historial incluso si se elimina un usuario web

---

## 🔧 Implementación Recomendada

### 1. **Crear función helper para obtener usuario de auditoría**

```typescript
// backend/src/services/auditService.ts

import { query } from '../lib/db';

/**
 * Obtiene o crea un usuario en MAST.USERS para auditoría
 * Si el usuario viene de evalImagen.UsuarioWeb, busca o crea en MAST.USERS
 * Si viene de un dispositivo, usa un usuario genérico o el dispositivo
 */
export async function getAuditUser(
  source: 'web' | 'device',
  sourceId: number,
  username?: string
): Promise<number> {
  try {
    if (source === 'web') {
      // Buscar usuario web en MAST.USERS por username
      const result = await query<{ userID: number }>(`
        SELECT TOP 1 userID
        FROM MAST.USERS
        WHERE userName = @username
          AND statusID = 1
      `, { username: username || `usuario_web_${sourceId}` });

      if (result.length > 0) {
        return result[0].userID;
      }

      // Si no existe, crear uno nuevo (opcional)
      // O usar un usuario genérico
      return 1; // Usuario genérico por ahora
    } else {
      // Para dispositivos, usar usuario genérico o dispositivo
      return 1; // Usuario genérico "Sistema/AgriQR"
    }
  } catch (error) {
    console.warn('⚠️ Error obteniendo usuario de auditoría, usando valor por defecto:', error);
    return 1; // Fallback
  }
}
```

### 2. **Actualizar rutas para usar auditoría automática**

```typescript
// backend/src/routes/umbrales.ts
import { authenticateWebUser } from '../middleware/auth-web';
import { getAuditUser } from '../services/auditService';

router.post('/', authenticateWebUser, async (req, res) => {
  const user = req.user; // Del middleware
  const auditUserID = await getAuditUser('web', user.usuarioID, user.username);
  
  // Usar auditUserID en lugar de req.body.usuarioCreaID
  await umbralService.createUmbral({
    ...req.body,
    usuarioCreaID: auditUserID
  });
});
```

### 3. **Actualizar sqlServerService para identificar origen**

```typescript
// backend/src/services/sqlServerService.ts

async saveProcessingResult(result: {
  // ... campos existentes
  source?: 'web' | 'agriqr';
  deviceId?: string;
  usuarioWebID?: number;
}): Promise<number> {
  // Determinar usuario de auditoría según origen
  let userCreatedID = 1;
  
  if (result.source === 'web' && result.usuarioWebID) {
    // Usuario web - buscar en MAST.USERS
    userCreatedID = await getAuditUser('web', result.usuarioWebID);
  } else if (result.source === 'agriqr' && result.deviceId) {
    // Dispositivo - usar usuario genérico o dispositivo
    userCreatedID = await getAuditUser('device', 0, result.deviceId);
  } else {
    // Fallback - usuario genérico
    userCreatedID = 1;
  }
  
  // ... resto del código
}
```

---

## 📋 Resumen

### **MAST.USERS se usa para:**

1. ✅ **Auditoría** - Registrar quién creó/modificó/resolvió registros
2. ✅ **Trazabilidad** - Saber el origen de cambios en el sistema
3. ✅ **Compatibilidad** - Mantener consistencia con otros sistemas

### **MAST.USERS NO se usa para:**

1. ❌ **Autenticación** - Eso lo hace `evalImagen.UsuarioWeb` (web) y `evalImagen.Dispositivo` (AgriQR)
2. ❌ **Permisos** - Los permisos están en `evalImagen.UsuarioWeb.rol`
3. ❌ **Sesiones** - Las sesiones se manejan con JWT tokens

### **Relación entre tablas:**

```
┌─────────────────┐
│ UsuarioWeb      │ → Autenticación web (username + password)
│ (evalImagen)    │
└────────┬────────┘
         │
         │ Cuando hace acción, busca/crea en:
         ▼
┌─────────────────┐
│ MAST.USERS      │ → Auditoría (usuarioCreaID, usuarioActualizaID)
│ (compartida)    │
└────────┬────────┘
         │
         │ Referenciado por:
         ▼
┌─────────────────┐
│ Tablas evalImagen│ → UmbralLuz, Contacto, Alerta, etc.
│ (usuarioCreaID) │
└─────────────────┘
```

---

## 🔄 Migración Futura (Opcional)

Si en el futuro se decide migrar completamente a `evalImagen.UsuarioWeb`:

1. **Crear script de migración:**
   - Mapear usuarios de MAST.USERS a UsuarioWeb
   - Actualizar Foreign Keys
   - Migrar datos históricos

2. **Actualizar todas las tablas:**
   - Cambiar Foreign Keys de MAST.USERS a UsuarioWeb
   - Actualizar código que referencia MAST.USERS

3. **Mantener compatibilidad:**
   - Crear vista o función que mapee entre ambas
   - O mantener ambas durante período de transición

---

**Conclusión:** `MAST.USERS` es una tabla de **auditoría compartida** que registra quién hizo qué en el sistema. No se usa para autenticación, solo para trazabilidad. Con la autenticación web, se puede mantener esta estructura y crear una función helper que mapee usuarios web a MAST.USERS para auditoría.

