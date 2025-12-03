# 🔄 Flujo del QR Code de Activación

## 📋 Resumen

**Respuesta corta:** El QR Code se **invalida inmediatamente** después de ser usado por AgriQR. No queda activo después de la configuración inicial.

---

## 🔄 Flujo Completo

### **1. Generación del QR (Admin en Web UI)**

```
Admin → POST /api/dispositivos/:id/generate-qr
  ↓
Backend genera:
  - activationCode (código único de 64 caracteres)
  - activationCodeExpires (24 horas desde ahora)
  ↓
Backend retorna:
  - qrCodeUrl (imagen base64 del QR)
  - qrData (datos JSON dentro del QR)
```

**Estado en BD:**
```sql
activationCode = "luzsombra_abc123..."
activationCodeExpires = "2025-01-16 14:30:00"
```

---

### **2. Escaneo del QR (AgriQR App)**

```
AgriQR escanea QR
  ↓
Extrae datos del QR:
  {
    "type": "agriqr-setup",
    "baseUrl": "https://...",
    "deviceId": "device-001",
    "activationCode": "luzsombra_abc123...",
    "expiresAt": "2025-01-16T14:30:00.000Z"
  }
  ↓
AgriQR llama: POST /api/auth/activate
  {
    "deviceId": "device-001",
    "activationCode": "luzsombra_abc123..."
  }
```

---

### **3. Activación (Backend)**

```
Backend valida:
  ✅ activationCode existe
  ✅ activationCode no ha expirado
  ✅ deviceId coincide
  ✅ dispositivo está activo
  ↓
Backend genera JWT token
  ↓
Backend INVALIDA el código:
  UPDATE Dispositivo SET
    activationCode = NULL,
    activationCodeExpires = NULL
  ↓
Backend regenera API key (seguridad) y retorna:
  {
    "success": true,
    "token": "eyJhbGc...",
    "apiKey": "luzsombra_xyz...",  // ⚠️ NUEVA API key (solo se muestra esta vez)
    "expiresIn": 86400,
    "deviceId": "device-001",
    "message": "Device activated successfully. Save the API key for future logins."
  }
```

**Estado en BD después de activación:**
```sql
activationCode = NULL          ← ❌ Ya no existe
activationCodeExpires = NULL   ← ❌ Ya no existe
ultimoAcceso = "2025-01-15 14:30:00"
```

---

### **4. Después de la Activación**

**El QR ya NO funciona:**
- Si alguien intenta escanear el mismo QR nuevamente → ❌ Error: "Invalid activation code"
- El código fue borrado de la BD
- Es de **un solo uso** por seguridad

**AgriQR ahora tiene todo lo necesario:**
- Guarda el **JWT token** recibido (válido por 24 horas)
- Guarda la **API key** recibida (para futuros logins)
- Para futuros logins, usa: `POST /api/auth/login` con `deviceId` + `apiKey`
- **NO vuelve a usar el QR**

---

## 🔒 Seguridad

### **¿Por qué se invalida el QR?**

1. **Prevenir reutilización maliciosa:**
   - Si alguien toma foto del QR, no puede usarlo después
   - Solo funciona una vez

2. **Control de acceso:**
   - El admin puede revocar acceso y generar nuevo QR
   - Cada activación requiere nuevo QR

3. **Auditoría:**
   - Se puede rastrear cuándo se activó cada dispositivo
   - `ultimoAcceso` se actualiza en la activación

---

## 🔄 Escenarios

### **Escenario 1: Primera Configuración (Normal)**

```
1. Admin genera QR → QR activo por 24 horas
2. Operario escanea QR en AgriQR → QR se invalida
3. AgriQR recibe JWT token
4. AgriQR guarda token y usa autenticación normal
5. QR ya no funciona (invalido)
```

### **Escenario 2: Reconfiguración (Dispositivo Perdido/Reasignado)**

```
1. Admin revoca acceso: PUT /api/dispositivos/:id/revoke
   → activo = 0, fechaRevocacion = GETDATE()
   
2. Admin reasigna: PUT /api/dispositivos/:id/reassign
   → activo = 1, operarioNombre = "Nuevo Operario"
   
3. Admin genera NUEVO QR: POST /api/dispositivos/:id/generate-qr
   → Nuevo activationCode generado
   
4. Nuevo operario escanea NUEVO QR
   → QR se invalida nuevamente
```

### **Escenario 3: QR Expirado (No Usado)**

```
1. Admin genera QR → Expira en 24 horas
2. Nadie lo usa en 24 horas
3. QR expira automáticamente
4. Si alguien intenta usarlo → Error: "Activation code expired"
5. Admin debe generar nuevo QR
```

---

## ❓ Preguntas Frecuentes

### **¿El QR queda activo después de la configuración?**

**NO.** El QR se invalida inmediatamente después de ser usado. Es de un solo uso.

### **¿Puedo reutilizar el mismo QR?**

**NO.** Una vez usado, el código se borra de la BD. Debes generar un nuevo QR.

### **¿Qué pasa si el QR expira antes de usarse?**

El QR expira automáticamente después de 24 horas. Si nadie lo usó, simplemente expira. Debes generar un nuevo QR.

### **¿Cómo funciona después de la activación inicial?**

Después de la activación, AgriQR:
1. Guarda el JWT token recibido
2. Usa autenticación normal: `POST /api/auth/login` con `deviceId` + `apiKey`
3. **NO vuelve a usar el QR**

### **¿Necesito generar nuevo QR para cada login?**

**NO.** El QR solo se usa **una vez** para la configuración inicial. Después, AgriQR usa autenticación normal con `deviceId` + `apiKey`.

### **¿Qué pasa si alguien más quiere conectarse después?**

**Cada dispositivo tiene UNA API key:**
- La primera persona que escanea el QR obtiene la API key
- Esa API key se guarda en AgriQR
- Cualquier persona que use ese dispositivo (con esa app configurada) puede conectarse
- **NO es necesario escanear el QR nuevamente**

**Si necesitas cambiar de operario:**
1. Admin revoca acceso: `PUT /api/dispositivos/:id/revoke`
2. Admin reasigna: `PUT /api/dispositivos/:id/reassign`
3. Admin genera nuevo QR: `POST /api/dispositivos/:id/generate-qr`
4. Nuevo operario escanea nuevo QR → Obtiene nueva API key

---

## 📊 Diagrama de Estados

```
┌─────────────────┐
│ QR Generado     │
│ activationCode  │
│ = "abc123..."   │
│ expires = +24h  │
└────────┬────────┘
         │
         │ Escaneado y usado
         ↓
┌─────────────────┐
│ QR Invalido     │
│ activationCode  │
│ = NULL          │
│ expires = NULL  │
└─────────────────┘
         │
         │ AgriQR ahora usa
         │ deviceId + apiKey
         ↓
┌─────────────────┐
│ Autenticación   │
│ Normal          │
│ POST /login     │
└─────────────────┘
```

---

## 🔧 Código Relevante

### **Invalidación del Código:**

```typescript
// En: backend/src/routes/auth.ts (línea 205)
await deviceService.clearActivationCode(device.dispositivoID);

// En: backend/src/services/deviceService.ts (línea 377-385)
async clearActivationCode(dispositivoID: number): Promise<boolean> {
  await query(`
    UPDATE evalImagen.Dispositivo
    SET activationCode = NULL,
        activationCodeExpires = NULL,
        ultimoAcceso = GETDATE()
    WHERE dispositivoID = @dispositivoID
  `, { dispositivoID });
}
```

---

## ✅ Resumen Final

| Aspecto | Estado |
|---------|--------|
| **QR después de activación** | ❌ Invalido (NULL en BD) |
| **Reutilización del QR** | ❌ No posible (código borrado) |
| **Expiración** | ✅ 24 horas si no se usa |
| **Uso único** | ✅ Sí, solo una vez |
| **Autenticación posterior** | ✅ Normal (deviceId + apiKey) |
| **API key en activación** | ✅ Se regenera y retorna (solo esta vez) |
| **Múltiples usuarios mismo dispositivo** | ✅ Sí, comparten la misma API key |

---

**Conclusión:** El QR es un **código de activación temporal de un solo uso**. Una vez que AgriQR lo usa para configurarse, se invalida y nunca más se puede usar. Después de eso, AgriQR usa autenticación normal con `deviceId` + `apiKey`.

