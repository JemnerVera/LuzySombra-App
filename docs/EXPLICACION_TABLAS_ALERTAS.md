# Explicación de Tablas del Sistema de Alertas

## 📊 Resumen de Tablas

El sistema de alertas utiliza **3 tablas principales** que trabajan juntas para consolidar y enviar alertas por email:

1. **`evalImagen.Alerta`** - Alertas individuales (1 por lote crítico)
2. **`evalImagen.Mensaje`** - Mensajes consolidados (1 por fundo)
3. **`evalImagen.MensajeAlerta`** - Tabla intermedia (relación N:N)

---

## 1️⃣ `evalImagen.Alerta` - Alertas Individuales

### **¿Para qué sirve?**
Almacena **cada alerta individual** que se genera cuando un lote cruza un umbral crítico.

### **¿Qué datos guarda?**
- **Identificación**: `alertaID`, `lotID`, `loteEvaluacionID`
- **Datos de la alerta**: `porcentajeLuzEvaluado`, `tipoUmbral` (CriticoRojo/CriticoAmarillo), `severidad`
- **Estado**: `estado` (Pendiente/Enviada/Resuelta/Ignorada), `fechaCreacion`, `fechaEnvio`
- **Relación con mensaje**: `mensajeID` (apunta al mensaje consolidado que incluye esta alerta)

### **¿Cuándo se crea?**
Se crea **automáticamente** cuando:
- Un lote cruza un umbral crítico (por trigger SQL)
- El `tipoUmbralActual` en `evalImagen.LoteEvaluacion` cambia a `CriticoRojo` o `CriticoAmarillo`

### **Ejemplo:**
```
alertaID: 1
lotID: 101
porcentajeLuzEvaluado: 15.50
tipoUmbral: CriticoRojo
severidad: Critica
estado: Pendiente
mensajeID: NULL (todavía no se consolidó)
fechaCreacion: 2024-11-17 08:30:00
```

---

## 2️⃣ `evalImagen.Mensaje` - Mensajes Consolidados

### **¿Para qué sirve?**
Almacena **mensajes consolidados** que agrupan múltiples alertas de un mismo **Fundo** en un solo email.

### **¿Qué datos guarda?**
- **Identificación**: `mensajeID`, `fundoID` (nuevo - identifica el fundo)
- **Contenido del email**: `asunto`, `cuerpoHTML`, `cuerpoTexto`
- **Destinatarios**: `destinatarios` (JSON array de emails)
- **Estado del envío**: `estado` (Pendiente/Enviando/Enviado/Error), `fechaCreacion`, `fechaEnvio`
- **Respuesta de Resend**: `resendMessageID`, `resendResponse`, `errorMessage`

### **¿Cuándo se crea?**
Se crea **cuando se ejecuta el job de consolidación** (cada 24 horas):
- Agrupa todas las alertas pendientes del último día por `fundoID`
- Genera un solo mensaje consolidado con todas las alertas del fundo
- Crea el HTML/texto con una tabla de todas las alertas

### **Ejemplo:**
```
mensajeID: 10
fundoID: "001"
asunto: "🚨 3 Alerta(s) Crítica(s) en Fundo La Esperanza - 5 lote(s) afectado(s)"
cuerpoHTML: "<html>...tabla con 5 alertas...</html>"
destinatarios: '["admin@example.com", "agronomo@example.com"]'
estado: Pendiente
fechaCreacion: 2024-11-17 08:00:00
```

**Nota**: Este mensaje puede incluir **múltiples alertas** del mismo fundo.

---

## 3️⃣ `evalImagen.MensajeAlerta` - Tabla Intermedia (Relación N:N)

### **¿Para qué sirve?**
Conecta **múltiples alertas** con **un mensaje consolidado**. Es la "tabla puente" que permite la relación **Muchos a Muchos** (N:N).

### **¿Qué datos guarda?**
- **Relaciones**: `mensajeID` (FK a `evalImagen.Mensaje`), `alertaID` (FK a `evalImagen.Alerta`)
- **Metadata**: `fechaCreacion`, `statusID`

### **¿Cuándo se crea?**
Se crea **cuando se consolida un mensaje**:
- Por cada alerta que se incluye en el mensaje consolidado
- Crea una fila en esta tabla vinculando `mensajeID` con `alertaID`

### **Ejemplo:**
Si un mensaje consolidado incluye 5 alertas, habrá 5 filas en esta tabla:

```
mensajeAlertaID: 1, mensajeID: 10, alertaID: 1, fechaCreacion: 2024-11-17 08:00:00
mensajeAlertaID: 2, mensajeID: 10, alertaID: 2, fechaCreacion: 2024-11-17 08:00:00
mensajeAlertaID: 3, mensajeID: 10, alertaID: 3, fechaCreacion: 2024-11-17 08:00:00
mensajeAlertaID: 4, mensajeID: 10, alertaID: 4, fechaCreacion: 2024-11-17 08:00:00
mensajeAlertaID: 5, mensajeID: 10, alertaID: 5, fechaCreacion: 2024-11-17 08:00:00
```

Esto significa: **El mensaje 10 incluye las alertas 1, 2, 3, 4 y 5**.

---

## 🔗 Relaciones entre Tablas

### **Diagrama de Relaciones:**

```
evalImagen.Alerta (1 alerta por lote crítico)
    │
    │ (1:N) - Una alerta puede estar en un mensaje
    │
    ├─→ mensajeID (FK directa) ──┐
    │                            │
    └─→ alertaID ────────────────┼──→ evalImagen.MensajeAlerta (tabla intermedia)
                                  │         │
                                  │         │ (N:N)
                                  │         │
                                  └─────────┘
                                       │
                                       └──→ evalImagen.Mensaje (1 mensaje por fundo)
                                                 │
                                                 └─→ fundoID (identifica el fundo)
```

### **Relación Completa:**

1. **`evalImagen.Alerta`** → **`evalImagen.MensajeAlerta`** (1:N)
   - Una alerta puede estar en una fila de `MensajeAlerta`
   - `alertaID` es FK en `MensajeAlerta`

2. **`evalImagen.Mensaje`** → **`evalImagen.MensajeAlerta`** (1:N)
   - Un mensaje puede tener múltiples filas en `MensajeAlerta`
   - `mensajeID` es FK en `MensajeAlerta`

3. **`evalImagen.MensajeAlerta`** conecta ambas (N:N)
   - Permite que un mensaje tenga múltiples alertas
   - Permite que una alerta esté en un mensaje

4. **`evalImagen.Alerta.mensajeID`** (FK directa)
   - Apunta directamente al mensaje consolidado
   - Facilita queries rápidas: "¿Esta alerta ya tiene mensaje?"

---

## 🔄 Flujo Completo con Ejemplo

### **Escenario:**
- **Fundo "La Esperanza"** tiene 5 lotes críticos
- Se generan 5 alertas individuales
- Se consolida en 1 mensaje

### **Paso 1: Se crean alertas individuales (Trigger SQL)**
```sql
-- Se crean 5 alertas automáticamente
evalImagen.Alerta:
  alertaID: 1, lotID: 101, tipoUmbral: CriticoRojo, mensajeID: NULL
  alertaID: 2, lotID: 102, tipoUmbral: CriticoRojo, mensajeID: NULL
  alertaID: 3, lotID: 103, tipoUmbral: CriticoAmarillo, mensajeID: NULL
  alertaID: 4, lotID: 104, tipoUmbral: CriticoRojo, mensajeID: NULL
  alertaID: 5, lotID: 105, tipoUmbral: CriticoAmarillo, mensajeID: NULL
```

### **Paso 2: Job de consolidación (cada 24 horas)**
```sql
-- El job agrupa las 5 alertas por fundoID y crea 1 mensaje
evalImagen.Mensaje:
  mensajeID: 10, fundoID: "001", asunto: "🚨 3 Críticas, 2 Advertencias en Fundo La Esperanza"
```

### **Paso 3: Se crean relaciones en tabla intermedia**
```sql
-- Se crean 5 filas vinculando el mensaje con cada alerta
evalImagen.MensajeAlerta:
  mensajeID: 10, alertaID: 1
  mensajeID: 10, alertaID: 2
  mensajeID: 10, alertaID: 3
  mensajeID: 10, alertaID: 4
  mensajeID: 10, alertaID: 5
```

### **Paso 4: Se actualizan las alertas**
```sql
-- Se actualiza mensajeID en cada alerta
evalImagen.Alerta:
  alertaID: 1, mensajeID: 10  -- ✅ Ahora apunta al mensaje consolidado
  alertaID: 2, mensajeID: 10
  alertaID: 3, mensajeID: 10
  alertaID: 4, mensajeID: 10
  alertaID: 5, mensajeID: 10
```

### **Paso 5: Se envía el email**
- Se envía **1 solo email** con las 5 alertas consolidadas
- El email contiene una tabla con todos los lotes afectados
- Se actualiza `evalImagen.Mensaje.estado = 'Enviado'`

---

## 📝 Queries Útiles

### **Ver alertas pendientes por fundo:**
```sql
SELECT 
  f.Description AS fundo,
  COUNT(*) AS total_alertas
FROM evalImagen.Alerta a
INNER JOIN evalImagen.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
INNER JOIN GROWER.STAGE s ON le.sectorID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE a.estado = 'Pendiente'
  AND a.mensajeID IS NULL
GROUP BY f.farmID, f.Description;
```

### **Ver qué alertas están en un mensaje:**
```sql
SELECT 
  a.alertaID,
  a.lotID,
  a.porcentajeLuzEvaluado,
  a.tipoUmbral
FROM evalImagen.Mensaje m
INNER JOIN evalImagen.MensajeAlerta ma ON m.mensajeID = ma.mensajeID
INNER JOIN evalImagen.Alerta a ON ma.alertaID = a.alertaID
WHERE m.mensajeID = 10;
```

### **Ver mensajes consolidados con conteo de alertas:**
```sql
SELECT 
  m.mensajeID,
  f.Description AS fundo,
  m.asunto,
  m.estado,
  COUNT(ma.alertaID) AS total_alertas
FROM evalImagen.Mensaje m
LEFT JOIN evalImagen.MensajeAlerta ma ON m.mensajeID = ma.mensajeID AND ma.statusID = 1
LEFT JOIN GROWER.FARMS f ON m.fundoID = CAST(f.farmID AS VARCHAR)
WHERE m.statusID = 1
GROUP BY m.mensajeID, f.Description, m.asunto, m.estado;
```

---

## ✅ Resumen

| Tabla | Propósito | Relación |
|-------|-----------|----------|
| **`evalImagen.Alerta`** | Almacena cada alerta individual (1 por lote crítico) | 1 alerta → puede estar en 1 mensaje |
| **`evalImagen.Mensaje`** | Almacena mensajes consolidados (1 por fundo) | 1 mensaje → puede incluir N alertas |
| **`evalImagen.MensajeAlerta`** | Conecta alertas con mensajes (tabla intermedia) | Permite relación N:N |

**Ventaja del diseño:**
- ✅ **Normalizado**: Fácil de consultar y mantener
- ✅ **Escalable**: Puede manejar cualquier cantidad de alertas por mensaje
- ✅ **Rastreable**: Se puede ver qué alertas están en cada mensaje
- ✅ **Eficiente**: Reduce llamadas a Resend API (1 email por fundo en lugar de 1 por alerta)

---

**Fecha de creación**: 2024-11-17

