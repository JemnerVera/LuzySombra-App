# Ejemplo de Flujo Completo - Sistema de Alertas

Este documento muestra cómo ejecutar una demo completa del sistema de alertas paso a paso.

## 📋 Prerrequisitos

1. Base de datos configurada con todas las tablas y stored procedures
2. Backend corriendo en `http://localhost:3001`
3. Variables de entorno configuradas (especialmente `RESEND_API_KEY` si quieres enviar emails reales)

## 🚀 Flujo Completo

### Paso 1: Setup Inicial

Ejecuta en SQL Server Management Studio:

```sql
-- Configurar umbrales y contactos de prueba
EXEC scripts/08_demo/01_setup_demo.sql
```

**Resultado esperado:**
- ✅ 3 contactos de prueba creados
- ✅ Umbrales verificados

### Paso 2: Crear Evaluaciones que Generan Alertas

```sql
-- Crear evaluaciones con umbrales críticos
EXEC scripts/08_demo/02_crear_evaluaciones_demo.sql
```

**Resultado esperado:**
- ✅ Evaluaciones creadas con `tipoUmbralActual = 'CriticoRojo'` y `'CriticoAmarillo'`
- ✅ Alertas creadas automáticamente por el trigger
- ✅ Alertas en estado `'Pendiente'`

### Paso 3: Verificar Alertas

```sql
-- Ver estado de alertas
EXEC scripts/08_demo/03_verificar_alertas.sql
```

**Resultado esperado:**
- ✅ Ver alertas pendientes
- ✅ Ver información de lotes con alertas
- ✅ Ver contactos disponibles

### Paso 4: Consolidar Alertas (vía API)

Desde la terminal o Postman:

```bash
# Consolidar alertas de las últimas 24 horas
curl -X POST "http://localhost:3001/api/alertas/consolidar?horasAtras=24"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "mensajesCreados": 2,
  "horasAtras": 24,
  "alertasSinMensaje": 2,
  "mensaje": "Se consolidaron alertas en 2 mensaje(s)"
}
```

**O desde el frontend:**
```javascript
// En la consola del navegador
fetch('http://localhost:3001/api/alertas/consolidar?horasAtras=24', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  }
})
.then(res => res.json())
.then(data => console.log(data));
```

### Paso 5: Verificar Mensajes Creados

```sql
-- Ver mensajes consolidados
SELECT 
    m.mensajeID,
    m.alertaID,
    m.fundoID,
    m.asunto,
    m.estado,
    m.destinatarios,
    m.fechaCreacion
FROM evalImagen.mensaje m
WHERE m.statusID = 1
ORDER BY m.fechaCreacion DESC;
```

### Paso 6: Enviar Mensajes (vía API)

```bash
# Enviar todos los mensajes pendientes
curl -X POST "http://localhost:3001/api/alertas/enviar"
```

**Respuesta esperada:**
```json
{
  "success": true,
  "exitosos": 2,
  "errores": 0,
  "mensaje": "Procesados 2 mensaje(s): 2 exitoso(s), 0 error(es)"
}
```

**O enviar un mensaje específico:**
```bash
curl -X POST "http://localhost:3001/api/alertas/enviar/1"
```

### Paso 7: Verificar Mensajes Enviados

```sql
-- Ver mensajes enviados
SELECT 
    m.mensajeID,
    m.asunto,
    m.estado,
    m.fechaEnvio,
    m.resendMessageID,
    m.intentosEnvio
FROM evalImagen.mensaje m
WHERE m.statusID = 1
  AND m.estado = 'Enviado'
ORDER BY m.fechaEnvio DESC;
```

### Paso 8: Resolver Alertas

```sql
-- Cambiar umbral a Normal (esto resuelve alertas automáticamente)
EXEC scripts/08_demo/06_resolver_alertas.sql
```

**Resultado esperado:**
- ✅ Evaluaciones actualizadas a `tipoUmbralActual = 'Normal'`
- ✅ Alertas resueltas automáticamente por el trigger
- ✅ Alertas en estado `'Resuelta'` con `fechaResolucion` establecida

### Paso 9: Limpiar Datos de Demo (Opcional)

```sql
-- Eliminar datos de prueba
EXEC scripts/08_demo/07_limpiar_demo.sql
```

## 🔍 Verificación Completa

Ejecuta este query para ver el estado completo:

```sql
-- Resumen completo del sistema de alertas
SELECT 
    'Alertas' AS tipo,
    estado,
    COUNT(*) AS cantidad
FROM evalImagen.alerta
WHERE statusID = 1
GROUP BY estado

UNION ALL

SELECT 
    'Mensajes' AS tipo,
    estado,
    COUNT(*) AS cantidad
FROM evalImagen.mensaje
WHERE statusID = 1
GROUP BY estado

ORDER BY tipo, estado;
```

## 📊 Dashboard de Alertas

También puedes ver las alertas desde el frontend:

1. Inicia sesión en `http://localhost:3000`
2. Navega a la pestaña "Alertas"
3. Verás las alertas pendientes, enviadas y resueltas

## 🎯 Puntos Clave del Sistema

1. **Trigger Automático**: Las alertas se crean automáticamente cuando `tipoUmbralActual` cambia a `CriticoRojo` o `CriticoAmarillo`
2. **Consolidación**: Las alertas se agrupan por fundo en mensajes consolidados
3. **Envío**: Los mensajes se envían vía Resend API
4. **Resolución Automática**: Cuando el umbral vuelve a `Normal`, las alertas se resuelven automáticamente

## ⚠️ Notas Importantes

- Los emails de demo (`@example.com`) no se enviarán realmente
- Para producción, configura contactos reales en `evalImagen.contacto`
- Asegúrate de tener `RESEND_API_KEY` configurado si quieres enviar emails reales
- El trigger solo crea alertas para `CriticoRojo` y `CriticoAmarillo`, NO para `Normal`

