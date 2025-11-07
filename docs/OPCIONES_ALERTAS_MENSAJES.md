# Opciones para Manejar Alertas y Mensajes

## 🤔 Decisión de Arquitectura

### **Opción 1: Todo desde la App (Backend TypeScript)** ⚠️

**Cómo funcionaría:**
```
1. Usuario sube imagen
2. App guarda en image.Analisis_Imagen
3. App ejecuta: EXEC image.sp_CalcularLoteEvaluacion
4. App consulta LoteEvaluacion y compara tipoUmbralActual anterior vs nuevo
5. Si cambió → App crea alerta en image.Alerta
6. App crea mensaje en image.Mensaje
7. App envía email via Resend API
```

**✅ Ventajas:**
- Control total desde TypeScript
- Fácil debugging y logging
- Manejo de errores más robusto
- Puede usar variables de entorno fácilmente
- Puede hacer retry logic para emails

**❌ Desventajas:**
- Si la app falla, no se crean alertas
- Depende de que la app esté corriendo
- Más código en la app
- Si hay múltiples instancias, podría crear duplicados

---

### **Opción 2: Triggers SQL + App para Mensajes** ✅ **RECOMENDADA**

**Cómo funcionaría:**
```
1. Usuario sube imagen
2. App guarda en image.Analisis_Imagen
3. App ejecuta: EXEC image.sp_CalcularLoteEvaluacion
4. TRIGGER en image.LoteEvaluacion detecta cambio de tipoUmbralActual
5. TRIGGER crea alerta en image.Alerta automáticamente
6. App (o job) consulta alertas sin mensaje y crea mensajes
7. App envía email via Resend API
```

**✅ Ventajas:**
- **Alertas SIEMPRE se crean** (independiente de la app)
- Más confiable y robusto
- Separación de responsabilidades
- El trigger garantiza consistencia de datos

**❌ Desventajas:**
- Más difícil de debuggear triggers
- Lógica de negocio en SQL (menos flexible)
- Para emails, igual necesitas la app

**Implementación:**
- **Trigger en `image.LoteEvaluacion`** (AFTER UPDATE)
- **App o Job** para procesar mensajes y enviar emails

---

### **Opción 3: Stored Procedure dentro de sp_CalcularLoteEvaluacion** ⚠️

**Cómo funcionaría:**
```
1. Usuario sube imagen
2. App guarda en image.Analisis_Imagen
3. App ejecuta: EXEC image.sp_CalcularLoteEvaluacion
4. Dentro del SP, después de MERGE, detecta cambio de tipoUmbralActual
5. SP crea alerta directamente en image.Alerta
6. App consulta alertas sin mensaje y crea mensajes
```

**✅ Ventajas:**
- Todo en una transacción (atómico)
- Más eficiente (menos roundtrips)
- Consistente

**❌ Desventajas:**
- SP más complejo
- Lógica de negocio mezclada con cálculo de estadísticas
- Para emails, igual necesitas la app

---

## 🎯 **Recomendación: Opción 2 (Triggers + App)**

### **Por qué Triggers para Alertas:**
1. **Confiabilidad**: Las alertas se crean SIEMPRE, incluso si la app falla
2. **Consistencia**: Garantiza que no se pierdan alertas
3. **Separación**: La lógica de detección está en la BD, donde debe estar

### **Por qué App para Mensajes:**
1. **Flexibilidad**: Retry logic, manejo de errores, logging
2. **Configuración**: Variables de entorno, plantillas, destinatarios
3. **Integración Externa**: Resend API, otros servicios

---

## 📋 Implementación Propuesta

### **1. Trigger en `image.LoteEvaluacion`**

```sql
CREATE TRIGGER trg_LoteEvaluacion_Alerta
ON image.LoteEvaluacion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Detectar cambios de tipoUmbralActual
    INSERT INTO image.Alerta (
        lotID, loteEvaluacionID, umbralID, variedadID,
        porcentajeLuzEvaluado, tipoUmbral, severidad, estado
    )
    SELECT 
        i.lotID,
        i.loteEvaluacionID,
        i.umbralIDActual,
        i.variedadID,
        i.porcentajeLuzPromedio,
        i.tipoUmbralActual,
        CASE 
            WHEN i.tipoUmbralActual = 'CriticoRojo' THEN 'Critica'
            WHEN i.tipoUmbralActual = 'CriticoAmarillo' THEN 'Advertencia'
            ELSE 'Info'
        END,
        'Pendiente'
    FROM inserted i
    INNER JOIN deleted d ON i.lotID = d.lotID
    WHERE 
        -- Solo crear alerta si cambió a CriticoRojo o CriticoAmarillo
        i.tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo')
        AND (d.tipoUmbralActual IS NULL OR d.tipoUmbralActual != i.tipoUmbralActual)
        -- Y no existe alerta Pendiente/Enviada del mismo tipo
        AND NOT EXISTS (
            SELECT 1 
            FROM image.Alerta a 
            WHERE a.lotID = i.lotID 
              AND a.tipoUmbral = i.tipoUmbralActual
              AND a.estado IN ('Pendiente', 'Enviada')
              AND a.statusID = 1
        )
        AND i.statusID = 1;
END;
```

### **2. Servicio TypeScript para Mensajes**

```typescript
// src/services/alertService.ts
export class AlertService {
  // Crear mensaje desde alerta
  async createMensajeFromAlerta(alertaID: number) { ... }
  
  // Procesar alertas pendientes
  async processPendingAlertas() { ... }
  
  // Enviar mensajes pendientes
  async sendPendingMensajes() { ... }
}
```

### **3. Job/Queue para Procesar Mensajes**

```typescript
// src/jobs/processAlerts.ts
// Usa node-cron o similar
// Ejecuta cada 5 minutos:
// 1. Busca alertas sin mensaje
// 2. Crea mensajes
// 3. Envía emails
```

---

## 🔄 Flujo Completo Propuesto

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario sube imagen                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. App guarda en image.Analisis_Imagen                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. App ejecuta: EXEC image.sp_CalcularLoteEvaluacion        │
│    → Calcula estadísticas                                   │
│    → Actualiza/Inserta en image.LoteEvaluacion              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. TRIGGER trg_LoteEvaluacion_Alerta (SQL)                  │
│    → Detecta cambio de tipoUmbralActual                     │
│    → Si cambió a CriticoRojo/CriticoAmarillo                │
│    → Crea alerta en image.Alerta automáticamente            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Job/Queue (TypeScript) - Cada 5 minutos                  │
│    → Busca alertas sin mensaje (LEFT JOIN image.Mensaje)    │
│    → Crea mensaje en image.Mensaje (estado: 'Pendiente')    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Job/Queue (TypeScript) - Cada 5 minutos                  │
│    → Busca mensajes con estado 'Pendiente'                  │
│    → Actualiza a 'Enviando'                                 │
│    → Llama a Resend API                                     │
│    → Actualiza a 'Enviado' o 'Error'                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Comparación Final

| Aspecto | App (Opción 1) | Trigger + App (Opción 2) | SP (Opción 3) |
|---------|----------------|--------------------------|---------------|
| **Confiabilidad Alertas** | ⚠️ Depende de app | ✅ Garantizada | ✅ Garantizada |
| **Facilidad Debugging** | ✅ Fácil | ⚠️ Más difícil | ⚠️ Más difícil |
| **Separación Responsabilidades** | ✅ Buena | ✅ Excelente | ⚠️ Mezclada |
| **Manejo de Errores** | ✅ Excelente | ✅ Bueno | ⚠️ Limitado |
| **Complejidad** | ⚠️ Media | ✅ Media | ❌ Alta |
| **Mantenibilidad** | ✅ Fácil | ✅ Buena | ⚠️ Difícil |

---

## 🎯 Decisión Final

**Recomendación: Opción 2 (Triggers + App)**

**Razones:**
1. **Alertas con Trigger**: Garantiza que siempre se creen, sin depender de la app
2. **Mensajes desde App**: Permite retry logic, manejo de errores, y configuración flexible
3. **Separación clara**: Lógica de detección en BD, lógica de negocio en app

**Implementación:**
- ✅ Trigger SQL para crear alertas automáticamente
- ✅ Servicio TypeScript para crear mensajes
- ✅ Queue job para procesar y enviar mensajes

