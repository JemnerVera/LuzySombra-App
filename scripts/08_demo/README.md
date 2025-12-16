# Demo del Sistema de Alertas y Mensajes

Este directorio contiene scripts SQL para hacer una demostración completa del sistema de alertas y mensajes de LuzSombra.

## 📋 Flujo del Sistema

1. **Trigger automático**: Cuando `evalImagen.loteEvaluacion.tipoUmbralActual` cambia a `CriticoRojo` o `CriticoAmarillo`, se crea automáticamente una alerta en `evalImagen.alerta`
2. **Consolidación**: Las alertas pendientes se consolidan en mensajes por fundo (vía API `/api/alertas/consolidar`)
3. **Envío**: Los mensajes se envían vía Resend API (vía API `/api/alertas/enviar`)
4. **Resolución**: Cuando el umbral vuelve a `Normal`, las alertas se resuelven automáticamente

## 🚀 Orden de Ejecución

Ejecuta los scripts en este orden:

1. `01_setup_demo.sql` - Configura datos iniciales (umbrales, contactos de prueba)
2. `02_crear_evaluaciones_demo.sql` - Crea evaluaciones que generan alertas
3. `03_verificar_alertas.sql` - Verifica que las alertas se hayan creado
4. `04_consolidar_alertas.sql` - **OPCIONAL**: Muestra cómo consolidar (normalmente se hace vía API)
5. `05_simular_envio.sql` - **OPCIONAL**: Simula el envío (normalmente se hace vía API)
6. `06_resolver_alertas.sql` - Resuelve alertas cambiando umbrales a Normal
7. `07_limpiar_demo.sql` - Limpia los datos de demo

## 📝 Notas Importantes

- Los scripts usan datos de prueba. Ajusta los `lotID`, `fundoID`, etc. según tu base de datos
- **Contacto de demo**: Configurar un contacto de prueba en la tabla `evalImagen.contacto` - Este será el único contacto activo para las pruebas
- Los contactos de ejemplo (`@example.com`) se desactivan automáticamente
- **IMPORTANTE**: Asegúrate de tener `RESEND_API_KEY` configurado en `.env` para que los emails se envíen correctamente
- La consolidación y envío normalmente se hacen vía API, pero los scripts muestran el proceso

## 🔧 Enviar Correos con Resend API

### Prerrequisitos

1. **Configurar `RESEND_API_KEY` en `.env.local`**:
   ```env
   RESEND_API_KEY=re_tu_api_key_aqui
   RESEND_FROM_EMAIL=no-reply@updates.agricolaandrea.com
   RESEND_FROM_NAME=Sistema de Alertas LuzSombra
   ```

2. **Obtener API Key de Resend**:
   - Ve a https://resend.com/api-keys
   - Crea una nueva API key
   - Cópiala a `.env.local`

3. **Verificar dominio en Resend**:
   - El dominio `updates.agricolaandrea.com` debe estar verificado en Resend
   - O cambia `RESEND_FROM_EMAIL` a un dominio verificado

### Método 1: Usar Scripts Automáticos

**Windows:**
```bash
cd scripts/08_demo
08_enviar_alertas_resend.bat
```

**Linux/Mac:**
```bash
cd scripts/08_demo
chmod +x 08_enviar_alertas_resend.sh
./08_enviar_alertas_resend.sh
```

### Método 2: Usar APIs Directamente

**Paso 1: Consolidar alertas** (agrupa alertas pendientes en mensajes por fundo):
```bash
# Windows (PowerShell)
curl -X POST "http://localhost:3001/api/alertas/consolidar?horasAtras=24"

# Linux/Mac
curl -X POST "http://localhost:3001/api/alertas/consolidar?horasAtras=24"
```

**Paso 2: Enviar mensajes** (envía los mensajes consolidados vía Resend):
```bash
# Windows (PowerShell)
curl -X POST "http://localhost:3001/api/alertas/enviar"

# Linux/Mac
curl -X POST "http://localhost:3001/api/alertas/enviar"
```

### Método 3: Desde el Navegador (usando DevTools)

1. Abre la consola del navegador (F12)
2. Ejecuta:

```javascript
// Consolidar alertas
fetch('http://localhost:3001/api/alertas/consolidar?horasAtras=24', {
  method: 'POST'
}).then(r => r.json()).then(console.log);

// Enviar mensajes
fetch('http://localhost:3001/api/alertas/enviar', {
  method: 'POST'
}).then(r => r.json()).then(console.log);
```

### Método 4: Enviar un Mensaje Específico

Si quieres enviar un mensaje específico por ID:

```bash
curl -X POST "http://localhost:3001/api/alertas/enviar/1"
```

### Verificar Resultados

Después de enviar, verifica en la base de datos:

```sql
-- Ver mensajes enviados
SELECT 
    mensajeID,
    fundoID,
    asunto,
    estado,
    fechaEnvio,
    resendMessageID,
    errorMessage
FROM evalImagen.mensaje
WHERE statusID = 1
ORDER BY fechaCreacion DESC;

-- Ver alertas relacionadas
SELECT 
    a.alertaID,
    a.estado,
    a.fechaEnvio,
    m.mensajeID,
    m.estado AS mensajeEstado
FROM evalImagen.alerta a
LEFT JOIN evalImagen.mensajeAlerta ma ON a.alertaID = ma.alertaID
LEFT JOIN evalImagen.mensaje m ON ma.mensajeID = m.mensajeID
WHERE a.statusID = 1
ORDER BY a.fechaCreacion DESC;
```

## 📊 Verificación

Después de cada paso, puedes verificar los datos:

```sql
-- Ver alertas
SELECT * FROM evalImagen.alerta WHERE statusID = 1 ORDER BY fechaCreacion DESC;

-- Ver mensajes
SELECT * FROM evalImagen.mensaje WHERE statusID = 1 ORDER BY fechaCreacion DESC;

-- Ver contactos
SELECT * FROM evalImagen.contacto WHERE statusID = 1;
```

