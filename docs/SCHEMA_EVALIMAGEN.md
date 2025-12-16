# 📊 Schema evalImagen - Guía Completa

## 🎯 ¿Qué es este sistema?

El sistema **evalImagen** es una solución para evaluar el porcentaje de luz y sombra en cultivos agrícolas mediante análisis de imágenes. Cuando un lote presenta valores fuera del rango óptimo, el sistema genera alertas automáticas y envía notificaciones por email a los responsables.

---

## 📋 Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Tablas Principales](#tablas-principales)
3. [Flujo Completo del Sistema](#flujo-completo-del-sistema)
4. [Sistema de Alertas y Mensajes](#sistema-de-alertas-y-mensajes)
5. [Para DBA - Detalles Técnicos](#para-dba---detalles-técnicos)
6. [Para Usuarios Finales - Cómo Funciona](#para-usuarios-finales---cómo-funciona)

---

## 🏗️ Visión General

### ¿Qué hace el sistema?

1. **Captura de Imágenes**: Los usuarios suben fotos de cultivos desde una app móvil (AgriQR)
2. **Análisis Automático**: El sistema analiza cada imagen y calcula el porcentaje de luz y sombra
3. **Evaluación de Lotes**: Agrupa las imágenes por lote y calcula estadísticas (promedio, mínimo, máximo)
4. **Detección de Problemas**: Compara los valores con umbrales predefinidos (Crítico Rojo, Crítico Amarillo, Normal)
5. **Generación de Alertas**: Crea alertas automáticamente cuando detecta valores fuera del rango óptimo
6. **Envío de Notificaciones**: Envía emails a los contactos configurados con la información de la alerta

### Diagrama Simplificado

```
📸 Imagen → 📊 Análisis → 📈 Evaluación → ⚠️ Alerta → 📧 Email
```

---

## 📦 Tablas Principales

### 1. **AnalisisImagen** 📸
**¿Qué guarda?** Cada imagen procesada con sus resultados.

**Campos importantes:**
- `analisisID`: ID único del análisis
- `lotID`: Lote al que pertenece la imagen
- `porcentajeLuz`: Porcentaje de luz detectado (0-100%)
- `porcentajeSombra`: Porcentaje de sombra detectado (0-100%)
- `filename`: Nombre del archivo de imagen
- `fechaCaptura`: Cuándo se tomó la foto

**Ejemplo:**
```
analisisID: 123
lotID: 45
porcentajeLuz: 8.5%
porcentajeSombra: 91.5%
fechaCaptura: 2025-11-20 14:30:00
```

---

### 2. **UmbralLuz** ⚙️
**¿Qué guarda?** Los rangos de valores que definen si un lote está en estado crítico, advertencia o normal.

**Tipos de umbrales:**
- **CriticoRojo**: Valores muy fuera del rango óptimo (ej: < 10% o > 35%)
- **CriticoAmarillo**: Valores fuera del rango pero menos críticos (ej: 10-15% o 25-35%)
- **Normal**: Rango óptimo (ej: 15-25%)

**Campos importantes:**
- `umbralID`: ID único del umbral
- `tipo`: CriticoRojo, CriticoAmarillo, o Normal
- `minPorcentajeLuz`: Valor mínimo del rango
- `maxPorcentajeLuz`: Valor máximo del rango
- `variedadID`: NULL = aplica a todas las variedades, o ID específico = solo esa variedad

**Ejemplo:**
```
umbralID: 1
tipo: CriticoRojo
minPorcentajeLuz: 0.00
maxPorcentajeLuz: 9.99
variedadID: NULL (aplica a todas)
```

---

### 3. **LoteEvaluacion** 📈
**¿Qué guarda?** Estadísticas agregadas de todas las imágenes de un lote.

**Campos importantes:**
- `loteEvaluacionID`: ID único de la evaluación
- `lotID`: Lote evaluado (UNIQUE - solo una evaluación por lote)
- `porcentajeLuzPromedio`: Promedio de todas las imágenes del lote
- `porcentajeLuzMin`: Valor mínimo encontrado
- `porcentajeLuzMax`: Valor máximo encontrado
- `tipoUmbralActual`: Clasificación actual (CriticoRojo, CriticoAmarillo, Normal)
- `umbralIDActual`: ID del umbral que corresponde al valor actual
- `totalEvaluaciones`: Cuántas imágenes se han procesado para este lote

**Ejemplo:**
```
loteEvaluacionID: 10
lotID: 45
porcentajeLuzPromedio: 8.2%
tipoUmbralActual: CriticoRojo
totalEvaluaciones: 15
```

---

### 4. **Alerta** ⚠️
**¿Qué guarda?** Registro de cada vez que un lote cruza un umbral crítico.

**Campos importantes:**
- `alertaID`: ID único de la alerta
- `lotID`: Lote que generó la alerta
- `loteEvaluacionID`: Evaluación que activó la alerta
- `umbralID`: Umbral que se cruzó
- `porcentajeLuzEvaluado`: Valor que activó la alerta
- `tipoUmbral`: CriticoRojo, CriticoAmarillo, o Normal
- `severidad`: Critica, Advertencia, o Info
- `estado`: Pendiente, Enviada, Resuelta, o Ignorada
- `fechaCreacion`: Cuándo se creó la alerta

**Estados de la alerta:**
- **Pendiente**: Recién creada, esperando procesamiento
- **Enviada**: Ya se envió el email
- **Resuelta**: El lote volvió a valores normales
- **Ignorada**: Marcada manualmente como no relevante

**Ejemplo:**
```
alertaID: 5
lotID: 45
tipoUmbral: CriticoRojo
severidad: Critica
estado: Pendiente
fechaCreacion: 2025-11-20 15:00:00
```

---

### 5. **Mensaje** 📧
**¿Qué guarda?** Los emails que se envían a los contactos.

**Campos importantes:**
- `mensajeID`: ID único del mensaje
- `alertaID`: Alerta individual (NULL si es mensaje consolidado)
- `fundoID`: Fundo para mensajes consolidados (agrupa múltiples alertas)
- `asunto`: Asunto del email
- `cuerpoHTML`: Contenido del email en HTML
- `destinatarios`: Lista de emails en formato JSON
- `estado`: Pendiente, Enviando, Enviado, o Error
- `fechaEnvio`: Cuándo se envió exitosamente
- `resendMessageID`: ID retornado por el servicio de email (Resend)

**Tipos de mensajes:**
- **Individual**: Un mensaje por cada alerta (`alertaID` tiene valor)
- **Consolidado**: Un mensaje que agrupa múltiples alertas del mismo fundo (`alertaID` es NULL, `fundoID` tiene valor)

**Ejemplo:**
```
mensajeID: 3
alertaID: 5 (mensaje individual)
asunto: "🚨 Alerta Crítica - Lote 45 (8.2% luz)"
estado: Enviado
fechaEnvio: 2025-11-20 15:05:00
```

---

### 6. **MensajeAlerta** 🔗
**¿Qué guarda?** La relación entre mensajes consolidados y múltiples alertas.

**Propósito:** Permite que un solo email agrupe varias alertas del mismo fundo.

**Campos importantes:**
- `mensajeID`: ID del mensaje consolidado
- `alertaID`: ID de cada alerta incluida en el mensaje
- `fechaCreacion`: Cuándo se creó la relación

**Ejemplo:**
```
mensajeID: 10 (mensaje consolidado)
alertaID: 5 (alerta 1)
alertaID: 6 (alerta 2)
alertaID: 7 (alerta 3)
```
Esto significa que el mensaje #10 contiene las alertas 5, 6 y 7.

---

### 7. **Contacto** 👥
**¿Qué guarda?** Lista de personas que reciben alertas por email.

**Campos importantes:**
- `contactoID`: ID único del contacto
- `nombre`: Nombre del contacto
- `email`: Email del contacto (único)
- `fundoID`: NULL = recibe alertas de todos los fundos, o ID específico = solo ese fundo
- `sectorID`: NULL = recibe alertas de todos los sectores, o ID específico = solo ese sector
- `recibirAlertasCriticas`: 1 = recibe alertas críticas (CriticoRojo)
- `recibirAlertasAdvertencias`: 1 = recibe alertas de advertencia (CriticoAmarillo)
- `activo`: 1 = contacto activo, 0 = desactivado

**Ejemplo:**
```
contactoID: 1
nombre: Juan Pérez
email: juan@empresa.com
fundoID: NULL (recibe de todos)
recibirAlertasCriticas: 1
recibirAlertasAdvertencias: 1
activo: 1
```

---

### 8. **Dispositivo** 📱
**¿Qué guarda?** Dispositivos móviles autorizados para usar la app (AgriQR).

**Campos importantes:**
- `dispositivoID`: ID único del dispositivo
- `deviceId`: ID único del dispositivo Android
- `apiKey`: Clave de autenticación para la app
- `nombreDispositivo`: Nombre descriptivo (ej: "Tablet Campo 1")
- `activo`: 1 = puede hacer login, 0 = bloqueado

**Nota:** Esta tabla es independiente del sistema de alertas, solo se usa para autenticación.

---

## 🔄 Flujo Completo del Sistema

### Paso 1: Captura de Imagen 📸
**Usuario final:**
- Abre la app AgriQR en su dispositivo móvil
- Selecciona el lote, hilera y planta
- Toma una foto del cultivo
- La app sube la imagen al servidor

**Sistema:**
- Guarda la imagen en `AnalisisImagen` con:
  - `lotID`: Lote seleccionado
  - `porcentajeLuz`: Calculado por el modelo de ML
  - `porcentajeSombra`: Calculado por el modelo de ML
  - `fechaCaptura`: Timestamp de cuando se tomó la foto

---

### Paso 2: Cálculo de Estadísticas 📊
**Sistema (automático):**
- Se ejecuta el Stored Procedure `sp_CalcularLoteEvaluacion`
- Agrupa todas las imágenes del mismo lote
- Calcula:
  - Promedio de porcentaje de luz
  - Mínimo y máximo
  - Total de evaluaciones
- Actualiza o crea el registro en `LoteEvaluacion`

**Ejemplo:**
Si hay 15 imágenes del lote 45:
- Promedio: 8.2%
- Mínimo: 5.1%
- Máximo: 12.3%
- Total: 15 evaluaciones

---

### Paso 3: Clasificación por Umbral ⚙️
**Sistema (automático):**
- Compara el `porcentajeLuzPromedio` con los umbrales en `UmbralLuz`
- Determina el `tipoUmbralActual`:
  - Si promedio < 10% → **CriticoRojo**
  - Si promedio entre 10-15% → **CriticoAmarillo**
  - Si promedio entre 15-25% → **Normal**
  - Si promedio > 35% → **CriticoRojo**
- Actualiza `LoteEvaluacion.tipoUmbralActual` y `umbralIDActual`

---

### Paso 4: Generación de Alertas ⚠️
**Sistema (automático - Trigger SQL):**
- El trigger `trg_LoteEvaluacion_Alerta` se activa cuando:
  - Se INSERTA un nuevo `LoteEvaluacion` con `tipoUmbralActual = 'CriticoRojo'` o `'CriticoAmarillo'`
  - Se ACTUALIZA un `LoteEvaluacion` y el `tipoUmbralActual` cambia a crítico
- Crea automáticamente un registro en `Alerta` con:
  - `estado = 'Pendiente'`
  - `tipoUmbral`: El tipo detectado
  - `severidad`: Critica, Advertencia, o Info
  - `fechaCreacion`: Timestamp actual

**Nota importante:** La alerta se crea automáticamente, pero el mensaje NO se crea automáticamente.

---

### Paso 5: Creación de Mensajes 📧
**Sistema (manual o cron job):**
- Se ejecuta el endpoint `/api/alertas/procesar-mensajes` o `/api/alertas/consolidar`
- El servicio busca alertas con `estado = 'Pendiente'` que no tengan mensaje asociado
- Para cada alerta (o grupo de alertas del mismo fundo):
  - Obtiene información del lote (nombre, sector, fundo)
  - Obtiene información del umbral (descripción, color)
  - Busca contactos en `Contacto` que:
    - Estén activos
    - Reciban el tipo de alerta (crítica o advertencia)
    - Coincidan con el fundo/sector del lote (o NULL = todos)
  - Genera el contenido del email (HTML y texto)
  - Crea el registro en `Mensaje` con `estado = 'Pendiente'`
  - Si es consolidado, crea registros en `MensajeAlerta` para relacionar múltiples alertas

**Tipos de procesamiento:**
- **Individual**: Un mensaje por cada alerta
- **Consolidado**: Agrupa múltiples alertas del mismo fundo en un solo email

---

### Paso 6: Envío de Emails 📬
**Sistema (manual o cron job):**
- El mismo endpoint `/api/alertas/procesar-mensajes` también procesa mensajes pendientes
- El servicio busca mensajes con `estado = 'Pendiente'` y `intentosEnvio < 3`
- Para cada mensaje:
  - Actualiza `estado = 'Enviando'` e incrementa `intentosEnvio`
  - Envía el email vía Resend API
  - Si es exitoso:
    - Actualiza `estado = 'Enviado'`
    - Guarda `resendMessageID` y `fechaEnvio`
    - Actualiza `fechaEnvio` en las alertas relacionadas
  - Si falla:
    - Actualiza `estado = 'Error'`
    - Guarda `errorMessage`
    - Puede reintentar hasta 3 veces

---

## ⚠️ Sistema de Alertas y Mensajes

### ¿Cuándo se crea una alerta?

Una alerta se crea automáticamente cuando:
1. Un lote tiene un `porcentajeLuzPromedio` fuera del rango óptimo
2. El sistema clasifica el lote como `CriticoRojo` o `CriticoAmarillo`
3. El trigger SQL detecta el cambio y crea el registro en `Alerta`

### ¿Cuándo se envía un email?

Un email se envía cuando:
1. Existe una alerta con `estado = 'Pendiente'`
2. Se ejecuta el procesamiento de mensajes (manual o cron)
3. Se encuentra un contacto activo que debe recibir la alerta
4. El servicio de email (Resend) envía exitosamente el mensaje

### Estados de una Alerta

```
Pendiente → Enviada → Resuelta
    ↓
Ignorada (manual)
```

- **Pendiente**: Recién creada, esperando procesamiento
- **Enviada**: Ya se envió el email a los contactos
- **Resuelta**: El lote volvió a valores normales (se actualiza automáticamente)
- **Ignorada**: Marcada manualmente como no relevante

### Estados de un Mensaje

```
Pendiente → Enviando → Enviado
    ↓
Error (puede reintentar)
```

- **Pendiente**: Creado pero aún no enviado
- **Enviando**: En proceso de envío
- **Enviado**: Enviado exitosamente
- **Error**: Falló el envío (puede reintentar hasta 3 veces)

### Mensajes Individuales vs Consolidados

**Individual:**
- Un email por cada alerta
- `Mensaje.alertaID` tiene valor
- Útil para alertas críticas que requieren atención inmediata

**Consolidado:**
- Un email que agrupa múltiples alertas del mismo fundo
- `Mensaje.alertaID` es NULL, `Mensaje.fundoID` tiene valor
- Las relaciones se guardan en `MensajeAlerta`
- Útil para resumir todas las alertas de un fundo en un solo email

---

## 🔧 Para DBA - Detalles Técnicos

### Estructura del Schema

**Schema:** `evalImagen`

**Tablas principales:**
1. `AnalisisImagen` - Imágenes procesadas
2. `UmbralLuz` - Configuración de umbrales
3. `LoteEvaluacion` - Estadísticas agregadas por lote
4. `Alerta` - Alertas generadas
5. `Mensaje` - Emails a enviar
6. `MensajeAlerta` - Relación N:N entre mensajes y alertas
7. `Contacto` - Destinatarios de alertas
8. `Dispositivo` - Dispositivos móviles autorizados

### Relaciones Clave

```
AnalisisImagen → GROWER.LOT (lotID)
LoteEvaluacion → GROWER.LOT (lotID) [UNIQUE]
LoteEvaluacion → UmbralLuz (umbralIDActual)
Alerta → LoteEvaluacion (loteEvaluacionID)
Alerta → UmbralLuz (umbralID)
Mensaje → Alerta (alertaID) [opcional, NULL para consolidados]
MensajeAlerta → Mensaje (mensajeID)
MensajeAlerta → Alerta (alertaID)
Contacto → GROWER.FARMS (fundoID) [opcional]
Contacto → GROWER.STAGE (sectorID) [opcional]
```

### Stored Procedures y Triggers

**Stored Procedures:**
- `sp_CalcularLoteEvaluacion`: Calcula estadísticas agregadas de un lote

**Triggers:**
- `trg_LoteEvaluacion_Alerta`: Crea alertas automáticamente cuando se detecta un umbral crítico

### Índices Importantes

- `IDX_AnalisisImagen_Lot_01`: Búsquedas por lote y fecha
- `IDX_LoteEvaluacion_LotID`: Búsqueda única por lote
- `IDX_Alerta_Estado`: Búsquedas por estado
- `IDX_Mensaje_EstadoFecha`: Búsquedas por estado y fecha
- `IDX_Contacto_FundoSector`: Búsquedas de contactos activos por fundo/sector

### Soft Delete

Todas las tablas usan `statusID` para soft delete:
- `statusID = 1`: Registro activo
- `statusID = 0`: Registro eliminado (soft delete)

### Auditoría

Todas las tablas tienen campos de auditoría:
- `fechaCreacion`: Cuándo se creó el registro
- `usuarioCreaID`: Usuario que creó el registro
- `fechaActualizacion`: Última actualización (si aplica)
- `usuarioActualizaID`: Usuario que actualizó (si aplica)

---

## 👥 Para Usuarios Finales - Cómo Funciona

### ¿Qué veo en la app?

1. **Tomar Foto**: Seleccionas lote, hilera y planta, tomas la foto
2. **Resultado Inmediato**: La app muestra el porcentaje de luz y sombra calculado
3. **Historial**: Puedes ver todas las imágenes que has subido

### ¿Qué recibo por email?

Cuando un lote tiene valores fuera del rango óptimo, recibes un email con:

**Asunto:** `🚨 Alerta Crítica - Lote [Nombre] ([X]% luz)`

**Contenido:**
- Información del lote (nombre, sector, fundo)
- Porcentaje de luz detectado
- Tipo de alerta (Crítica o Advertencia)
- Fecha de evaluación
- Enlace para ver más detalles (si está configurado)

**Ejemplo de email:**
```
🚨 Alerta Crítica - Lote L-45 (8.2% luz)

Lote: L-45
Sector: Sector Norte
Fundo: Fundo Principal
Variedad: Hass

Porcentaje de Luz: 8.2%
Tipo de Umbral: CriticoRojo
Severidad: Crítica
Fecha de Evaluación: 20/11/2025 15:00:00

Este es un mensaje automático del sistema de alertas.
Por favor, revisa el lote y toma las acciones necesarias.
```

### ¿Cuándo recibo alertas?

Recibes alertas cuando:
1. Eres un contacto activo en el sistema
2. El lote está en el fundo/sector que configuraste (o todos si no especificaste)
3. El tipo de alerta coincide con tus preferencias (críticas, advertencias, o ambas)

### ¿Puedo configurar qué alertas recibo?

Sí, el administrador puede configurar en la tabla `Contacto`:
- Qué fundos/sectores quieres monitorear (o todos)
- Si quieres recibir alertas críticas
- Si quieres recibir alertas de advertencia
- Si quieres recibir notificaciones cuando vuelve a normal

### ¿Qué hago cuando recibo una alerta?

1. **Revisa el lote**: Ve al campo y verifica el estado del cultivo
2. **Toma acciones**: Ajusta riego, poda, o cualquier medida necesaria
3. **Toma más fotos**: Sube nuevas imágenes para monitorear la evolución
4. **El sistema se actualiza**: Cuando el lote vuelva a valores normales, el sistema lo detectará automáticamente

---

## 📞 Soporte

Si tienes preguntas o problemas:
- **DBA**: Revisa la documentación técnica en `docs/`
- **Usuarios**: Contacta al administrador del sistema

---

## 📝 Notas Finales

- **Las alertas se crean automáticamente** cuando se detecta un problema
- **Los emails se envían cuando se procesa** (manual o automático con cron)
- **El sistema se actualiza en tiempo real** cuando subes nuevas imágenes
- **Todos los datos se guardan** para análisis histórico y reportes

---

**Última actualización:** Noviembre 2025  
**Schema:** `evalImagen`  
**Base de datos:** `[TU_BASE_DE_DATOS]`

