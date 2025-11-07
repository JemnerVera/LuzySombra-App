# Diseño del Sistema de Alertas - Umbrales y Notificaciones

## 📋 Resumen Ejecutivo

Sistema de alertas basado en umbrales de porcentaje de luz que:
1. Evalúa evaluaciones a nivel de lote (promedio)
2. Compara con umbrales configurados
3. Genera alertas cuando se cruzan umbrales
4. Crea mensajes para envío por email (Resend API)

---

## 🎯 Flujo del Sistema

```
image.Analisis_Imagen (individual)
    ↓
[Agregación a nivel de lote] → image.LoteEvaluacion (cache/agregación)
    ↓
[Comparación con umbrales] → image.UmbralLuz
    ↓
[Generación de alerta] → image.Alerta
    ↓
[Creación de mensaje] → image.Mensaje
    ↓
[Envío por email] → Resend API
```

---

## 🗄️ Diseño de Tablas

### 1. `image.UmbralLuz` ✅ (Ya diseñada)
**Propósito**: Definir rangos de umbrales por tipo y variedad

**Estructura**:
- `umbralID` (PK)
- `tipo` (CriticoRojo, CriticoAmarillo, Normal)
- `minPorcentajeLuz`, `maxPorcentajeLuz`
- `variedadID` (NULL = todas las variedades)
- `colorHex`, `descripcion`, `orden`
- `activo`, `statusID`

---

### 2. `image.LoteEvaluacion` (NUEVA - Agregación)
**Propósito**: Cache de estadísticas agregadas por lote para evitar recalcular constantemente

**Estructura**:
```sql
CREATE TABLE image.LoteEvaluacion (
    loteEvaluacionID INT IDENTITY(1,1) NOT NULL,
    lotID INT NOT NULL,
    variedadID INT NULL, -- Del lote
    
    -- Estadísticas agregadas (últimas N evaluaciones o desde última fecha)
    porcentajeLuzPromedio DECIMAL(5,2) NOT NULL,
    porcentajeLuzMin DECIMAL(5,2) NULL,
    porcentajeLuzMax DECIMAL(5,2) NULL,
    porcentajeSombraPromedio DECIMAL(5,2) NOT NULL,
    porcentajeSombraMin DECIMAL(5,2) NULL,
    porcentajeSombraMax DECIMAL(5,2) NULL,
    
    -- Clasificación actual
    tipoUmbralActual VARCHAR(20) NULL, -- CriticoRojo, CriticoAmarillo, Normal
    umbralIDActual INT NULL, -- FK a UmbralLuz
    
    -- Fechas
    fechaUltimaEvaluacion DATETIME NULL,
    fechaPrimeraEvaluacion DATETIME NULL,
    totalEvaluaciones INT NOT NULL DEFAULT 0,
    
    -- Periodo de evaluación (últimos N días)
    periodoEvaluacionDias INT NOT NULL DEFAULT 30, -- Por defecto último mes
    
    -- Auditoría
    fechaUltimaActualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_LoteEvaluacion PRIMARY KEY (loteEvaluacionID),
    CONSTRAINT FK_LoteEvaluacion_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
    CONSTRAINT FK_LoteEvaluacion_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
    CONSTRAINT FK_LoteEvaluacion_Umbral FOREIGN KEY (umbralIDActual) REFERENCES image.UmbralLuz(umbralID),
    CONSTRAINT UQ_LoteEvaluacion_LOT UNIQUE (lotID)
);
```

**Ventajas**:
- ✅ Performance: No recalcular estadísticas en cada consulta
- ✅ Historial: Mantener estado actual del lote
- ✅ Flexibilidad: Permite diferentes periodos de evaluación

**Actualización**:
- **Opción A**: Trigger en `image.Analisis_Imagen` (INSERT/UPDATE) → Actualiza automáticamente
- **Opción B**: Proceso programado (Stored Procedure + Job) → Actualiza periódicamente
- **Opción C**: Backend calcula al guardar → Actualiza en la misma transacción

**Recomendación**: **Opción C** (Backend calcula) + **Opción B** (Job periódico para reconciliación)

---

### 3. `image.Alerta` (NUEVA)
**Propósito**: Registrar alertas generadas cuando un lote cruza un umbral

**Estructura**:
```sql
CREATE TABLE image.Alerta (
    alertaID INT IDENTITY(1,1) NOT NULL,
    lotID INT NOT NULL,
    loteEvaluacionID INT NULL, -- FK a LoteEvaluacion (snapshot del estado)
    umbralID INT NOT NULL, -- Umbral que activó la alerta
    variedadID INT NULL, -- Del lote
    
    -- Valores que activaron la alerta
    porcentajeLuzEvaluado DECIMAL(5,2) NOT NULL,
    tipoUmbral VARCHAR(20) NOT NULL, -- CriticoRojo, CriticoAmarillo, Normal
    severidad VARCHAR(20) NOT NULL, -- 'Critica', 'Advertencia', 'Info'
    
    -- Estado de la alerta
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente', -- Pendiente, Enviada, Resuelta, Ignorada
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    fechaEnvio DATETIME NULL, -- Cuando se envió el mensaje
    fechaResolucion DATETIME NULL, -- Cuando se resolvió (lote volvió a normal)
    
    -- Contexto adicional
    mensajeID INT NULL, -- FK a Mensaje (si se generó mensaje)
    usuarioResolvioID INT NULL, -- Quién resolvió la alerta
    notas NVARCHAR(500) NULL,
    
    -- Auditoría
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_Alerta PRIMARY KEY (alertaID),
    CONSTRAINT FK_Alerta_LOT FOREIGN KEY (lotID) REFERENCES GROWER.LOT(lotID),
    CONSTRAINT FK_Alerta_LoteEvaluacion FOREIGN KEY (loteEvaluacionID) REFERENCES image.LoteEvaluacion(loteEvaluacionID),
    CONSTRAINT FK_Alerta_Umbral FOREIGN KEY (umbralID) REFERENCES image.UmbralLuz(umbralID),
    CONSTRAINT FK_Alerta_Variety FOREIGN KEY (variedadID) REFERENCES GROWER.VARIETY(varietyID),
    CONSTRAINT FK_Alerta_Mensaje FOREIGN KEY (mensajeID) REFERENCES image.Mensaje(mensajeID),
    CONSTRAINT FK_Alerta_UsuarioResolvio FOREIGN KEY (usuarioResolvioID) REFERENCES MAST.USERS(userID),
    CONSTRAINT CK_Alerta_Estado CHECK (estado IN ('Pendiente', 'Enviada', 'Resuelta', 'Ignorada')),
    CONSTRAINT CK_Alerta_Severidad CHECK (severidad IN ('Critica', 'Advertencia', 'Info'))
);
```

**Lógica de Generación**:
- Se crea una alerta cuando `LoteEvaluacion.tipoUmbralActual` cambia a `CriticoRojo` o `CriticoAmarillo`
- Solo se crea si no hay una alerta **Pendiente** o **Enviada** del mismo tipo
- Se resuelve automáticamente cuando vuelve a `Normal`

---

### 4. `image.Mensaje` (NUEVA)
**Propósito**: Plantillas de mensajes y logs de mensajes enviados

**Estructura**:
```sql
CREATE TABLE image.Mensaje (
    mensajeID INT IDENTITY(1,1) NOT NULL,
    alertaID INT NOT NULL, -- FK a Alerta
    
    -- Contenido del mensaje
    tipoMensaje VARCHAR(50) NOT NULL, -- 'Email', 'SMS', 'Push' (por ahora solo Email)
    asunto NVARCHAR(200) NOT NULL,
    cuerpoHTML NVARCHAR(MAX) NOT NULL,
    cuerpoTexto NVARCHAR(MAX) NULL, -- Versión texto plano
    
    -- Destinatarios
    destinatarios NVARCHAR(MAX) NOT NULL, -- JSON array de emails: ["email1@example.com", "email2@example.com"]
    destinatariosCC NVARCHAR(MAX) NULL, -- JSON array para CC
    destinatariosBCC NVARCHAR(MAX) NULL, -- JSON array para BCC
    
    -- Estado del envío
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente', -- Pendiente, Enviando, Enviado, Error
    fechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    fechaEnvio DATETIME NULL,
    intentosEnvio INT NOT NULL DEFAULT 0,
    ultimoIntentoEnvio DATETIME NULL,
    
    -- Respuesta de Resend API
    resendMessageID NVARCHAR(100) NULL, -- ID retornado por Resend
    resendResponse NVARCHAR(MAX) NULL, -- Respuesta completa de Resend (JSON)
    errorMessage NVARCHAR(500) NULL, -- Si falló el envío
    
    -- Auditoría
    statusID INT NOT NULL DEFAULT 1,
    
    CONSTRAINT PK_Mensaje PRIMARY KEY (mensajeID),
    CONSTRAINT FK_Mensaje_Alerta FOREIGN KEY (alertaID) REFERENCES image.Alerta(alertaID),
    CONSTRAINT CK_Mensaje_Estado CHECK (estado IN ('Pendiente', 'Enviando', 'Enviado', 'Error')),
    CONSTRAINT CK_Mensaje_Tipo CHECK (tipoMensaje IN ('Email', 'SMS', 'Push'))
);
```

**Plantillas**:
- Las plantillas pueden estar en el código (TypeScript) o en una tabla separada `image.PlantillaMensaje`
- Por simplicidad inicial: **Plantillas en código TypeScript**

---

## 🔄 Flujo de Procesamiento

### Paso 1: Guardar Evaluación Individual
```typescript
// Al guardar en image.Analisis_Imagen
1. INSERT en image.Analisis_Imagen
2. Actualizar/Insertar en image.LoteEvaluacion (calcular estadísticas)
3. Comparar promedio con umbrales
4. Si cambió tipoUmbralActual → Generar alerta
```

### Paso 2: Generar Alerta
```sql
-- Si LoteEvaluacion.tipoUmbralActual cambia a CriticoRojo/CriticoAmarillo
-- Y no existe alerta Pendiente/Enviada del mismo tipo
INSERT INTO image.Alerta (
    lotID, loteEvaluacionID, umbralID, porcentajeLuzEvaluado,
    tipoUmbral, severidad, estado
) VALUES (...)
```

### Paso 3: Crear Mensaje
```typescript
// Backend crea mensaje basado en plantilla
1. Obtener destinatarios (configuración por lote/usuario)
2. Generar HTML con datos del lote y alerta
3. INSERT en image.Mensaje (estado: 'Pendiente')
4. Encolar para envío (queue job)
```

### Paso 4: Enviar Email (Resend API)
```typescript
// Queue job procesa mensajes Pendiente
1. Actualizar estado a 'Enviando'
2. Llamar a Resend API
3. Actualizar estado a 'Enviado' o 'Error'
4. Guardar resendMessageID y respuesta
5. Actualizar image.Alerta.fechaEnvio
```

---

## 📊 Opciones de Diseño - Comparación

### Opción A: Tabla de Agregación (`image.LoteEvaluacion`)
**✅ RECOMENDADA**

**Ventajas**:
- Performance excelente para consultas
- Historial de estado por lote
- Fácil tracking de cambios
- Soporta diferentes periodos de evaluación

**Desventajas**:
- Requiere mantenimiento (actualización)
- Puede desincronizarse si no se actualiza correctamente

**Cuándo usar**: Cuando hay muchas consultas y se necesita performance

---

### Opción B: Calcular On-the-fly (Vista/SQL)
**Ventajas**:
- Siempre actualizado
- No requiere mantenimiento
- Menos datos duplicados

**Desventajas**:
- Más lento en consultas complejas
- No mantiene historial de estados
- Difícil detectar cambios de umbral

**Cuándo usar**: Cuando las consultas son esporádicas y no se necesita historial

---

### Opción C: Híbrido (Vista + Tabla de Agregación)
**✅ MEJOR OPCIÓN**

**Ventajas**:
- Performance de tabla + exactitud de vista
- Job periódico reconcilia datos
- Vista para consultas puntuales
- Tabla para alertas y tracking

**Implementación**:
- `image.LoteEvaluacion`: Tabla principal (actualizada por trigger/job)
- `VW_LoteEvaluacionActual`: Vista para consultas que usa tabla + recalcula si es necesario
- Job SQL diario: Recalcula estadísticas de todos los lotes

---

## 🎨 Estructura de Plantillas de Mensajes

### Plantilla Crítico Rojo
```html
<h2>🚨 Alerta Crítica - Evaluación de Luz</h2>
<p><strong>Lote:</strong> {lote}</p>
<p><strong>Sector:</strong> {sector}</p>
<p><strong>Fundo:</strong> {fundo}</p>
<p><strong>Variedad:</strong> {variedad}</p>
<p><strong>Porcentaje de Luz:</strong> {porcentajeLuz}%</p>
<p><strong>Umbral:</strong> {tipoUmbral}</p>
<p><strong>Descripción:</strong> {descripcion}</p>
<p><strong>Fecha de Evaluación:</strong> {fechaEvaluacion}</p>
```

### Plantilla Crítico Amarillo
```html
<h2>⚠️ Advertencia - Evaluación de Luz</h2>
<!-- Similar estructura -->
```

---

## 🔧 Configuración de Destinatarios

### Opción 1: Tabla de Configuración
```sql
CREATE TABLE image.ConfiguracionAlerta (
    configID INT IDENTITY(1,1) NOT NULL,
    lotID INT NULL, -- NULL = configuración global
    tipoUmbral VARCHAR(20) NULL, -- NULL = todos los tipos
    destinatarios NVARCHAR(MAX) NOT NULL, -- JSON array
    activo BIT NOT NULL DEFAULT 1
);
```

### Opción 2: Variables de Entorno
```env
ALERTAS_EMAIL_DESTINATARIOS=["admin@example.com", "agronomo@example.com"]
ALERTAS_EMAIL_CC=["manager@example.com"]
```

**Recomendación**: **Opción 2** inicialmente (simpler), luego migrar a **Opción 1** si se necesita granularidad

---

## 📝 Recomendación Final

### Tablas a Crear:
1. ✅ `image.UmbralLuz` (ya diseñada)
2. ✅ `image.LoteEvaluacion` (agregación con cache)
3. ✅ `image.Alerta` (tracking de alertas)
4. ✅ `image.Mensaje` (logs de mensajes enviados)

### Proceso de Actualización:
- **Trigger o Backend**: Actualiza `LoteEvaluacion` al insertar `Analisis_Imagen`
- **Job SQL Diario**: Recalcula y reconcilia todas las estadísticas
- **Queue Job**: Procesa mensajes pendientes y envía emails

### Integración Resend:
- Servicio TypeScript separado: `src/services/resendService.ts`
- API Route: `src/app/api/alertas/enviar-mensaje/route.ts`
- Queue system: Usar `node-cron` o similar para procesar mensajes pendientes

---

## 🚀 Próximos Pasos

1. Crear scripts SQL para las 3 nuevas tablas
2. Crear función/SP para calcular estadísticas de lote
3. Crear servicio de Resend
4. Implementar lógica de generación de alertas
5. Crear job de procesamiento de mensajes

