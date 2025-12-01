# Configuración de Resend API

## 📋 Resumen

Este documento explica cómo configurar Resend API para enviar emails de alertas y cómo se relacionan los mensajes con los contactos.

---

## 🔑 1. Configurar API Key de Resend

### **Paso 1: Obtener API Key**

Ya tienes la API Key de Resend:
```
re_5GLLDG46_H5ftoxQsNKDidV7rqmNpCAAc
```

### **Paso 2: Agregar al archivo `.env.local`**

Crea o edita el archivo `backend/.env.local` (o `.env` en la raíz del proyecto):

```env
# Resend API Configuration
RESEND_API_KEY=re_5GLLDG46_H5ftoxQsNKDidV7rqmNpCAAc
RESEND_FROM_EMAIL=noreply@tudominio.com
RESEND_FROM_NAME=Sistema de Alertas LuzSombra
```

**Nota**: El `RESEND_FROM_EMAIL` debe ser un dominio verificado en Resend. El DBA ya configuró el DNS, así que usa el dominio de tu empresa.

---

## 📧 2. Cómo se Relacionan Mensajes con Contactos

### **Flujo Completo:**

```
1. Se crea una alerta → evalImagen.Alerta
   ↓
2. Job consolida alertas por fundo → evalImagen.Mensaje (con fundoID)
   ↓
3. alertService.getDestinatarios() busca contactos en evalImagen.Contacto:
   - Filtra por fundoID del mensaje
   - Filtra por tipo de alerta (Crítica/Advertencia)
   - Filtra por activo = 1
   ↓
4. Se guardan los emails en evalImagen.Mensaje.destinatarios (JSON array)
   ↓
5. resendService.processPendingMensajes() envía el email:
   - Lee evalImagen.Mensaje.destinatarios
   - Envía email vía Resend API a todos los destinatarios
```

### **Tabla `evalImagen.Contacto`:**

La tabla `evalImagen.Contacto` contiene los destinatarios de las alertas. Cada contacto puede:

- **Recibir alertas críticas** (`recibirAlertasCriticas = 1`)
- **Recibir alertas de advertencia** (`recibirAlertasAdvertencias = 1`)
- **Filtrar por fundo** (`fundoID = NULL` = todos, `fundoID = '001'` = solo ese fundo)
- **Filtrar por sector** (`sectorID = NULL` = todos, `sectorID = 123` = solo ese sector)

### **Ejemplo de Contacto:**

```sql
INSERT INTO evalImagen.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    fundoID,  -- NULL = todos los fundos, '001' = solo fundo 001
    sectorID, -- NULL = todos los sectores, 123 = solo sector 123
    activo,
    statusID
)
VALUES (
    'Juan Pérez',
    'juan.perez@empresa.com',
    'Agronomo',
    1,  -- Recibe críticas
    1,  -- Recibe advertencias
    NULL, -- Todos los fundos
    NULL, -- Todos los sectores
    1,  -- Activo
    1
);
```

### **Cómo se Filtran los Contactos:**

Cuando se crea un mensaje consolidado para un fundo:

1. **Se obtiene el `fundoID`** del mensaje (ej: `'001'`)
2. **Se buscan contactos** en `evalImagen.Contacto` que:
   - `activo = 1` y `statusID = 1`
   - `recibirAlertasCriticas = 1` (si hay alertas críticas) O `recibirAlertasAdvertencias = 1` (si hay advertencias)
   - `fundoID IS NULL` (todos los fundos) O `fundoID = '001'` (solo ese fundo)
   - `sectorID IS NULL` (todos los sectores) O `sectorID = sectorID_del_lote` (solo ese sector)
3. **Se guardan los emails** en `evalImagen.Mensaje.destinatarios` como JSON array:
   ```json
   ["juan.perez@empresa.com", "maria.garcia@empresa.com"]
   ```

---

## 🔄 3. Proceso de Envío

### **Paso 1: Crear Mensajes Consolidados**

```bash
POST http://localhost:3001/api/alertas/consolidar
```

Esto:
- Agrupa alertas por fundo
- Busca contactos en `evalImagen.Contacto` para cada fundo
- Crea mensajes en `evalImagen.Mensaje` con los destinatarios

### **Paso 2: Enviar Emails**

Necesitas crear un endpoint o job que llame a:

```typescript
import { resendService } from './services/resendService';

// Procesar mensajes pendientes
const resultado = await resendService.processPendingMensajes();
console.log(`Enviados: ${resultado.exitosos}, Errores: ${resultado.errores}`);
```

O crear un endpoint:

```typescript
// backend/src/routes/alertas/enviar.ts
import express, { Request, Response } from 'express';
import { resendService } from '../../services/resendService';

const router = express.Router();

router.post('/', async (req: Request, res: Response) => {
  try {
    const resultado = await resendService.processPendingMensajes();
    res.json({
      success: true,
      exitosos: resultado.exitosos,
      errores: resultado.errores
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
```

---

## 📊 4. Verificar Configuración

### **Verificar que Resend está configurado:**

```typescript
// En el backend, verifica que se inicializó:
// Deberías ver: "✅ Resend Service inicializado"
```

### **Verificar contactos en BD:**

```sql
-- Ver todos los contactos activos
SELECT 
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    fundoID,
    sectorID
FROM evalImagen.Contacto
WHERE activo = 1 AND statusID = 1;
```

### **Ver mensajes pendientes:**

```sql
-- Ver mensajes que están listos para enviar
SELECT 
    mensajeID,
    fundoID,
    asunto,
    destinatarios,
    estado,
    intentosEnvio
FROM evalImagen.Mensaje
WHERE estado = 'Pendiente'
  AND statusID = 1;
```

---

## ✅ Checklist de Configuración

- [ ] API Key de Resend agregada a `.env.local`
- [ ] `RESEND_FROM_EMAIL` configurado (dominio verificado en Resend)
- [ ] `RESEND_FROM_NAME` configurado
- [ ] Contactos agregados en `evalImagen.Contacto`
- [ ] Servicio de Resend instalado (`npm install resend`)
- [ ] Endpoint/job para enviar mensajes creado
- [ ] Probar consolidación de alertas
- [ ] Probar envío de emails

---

## 🚀 Próximos Pasos

1. **Instalar paquete Resend:**
   ```bash
   cd backend
   npm install resend
   ```

2. **Agregar API Key a `.env.local`**

3. **Crear contactos en `evalImagen.Contacto`**

4. **Crear endpoint para enviar mensajes** (o usar el job)

5. **Probar el flujo completo**

---

**Fecha de creación**: 2024-11-17

