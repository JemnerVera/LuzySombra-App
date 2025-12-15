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
- **Contacto de demo**: `jemner.vera@agricolaandrea.com` (Agrónomo) - Este es el único contacto activo para las pruebas
- Los contactos de ejemplo (`@example.com`) se desactivan automáticamente
- **IMPORTANTE**: Asegúrate de tener `RESEND_API_KEY` configurado en `.env` para que los emails se envíen correctamente
- La consolidación y envío normalmente se hacen vía API, pero los scripts muestran el proceso

## 🔧 Uso con API

Después de ejecutar los scripts 1-3, puedes usar las APIs:

```bash
# Consolidar alertas (últimas 24 horas)
POST http://localhost:3001/api/alertas/consolidar?horasAtras=24

# Enviar mensajes pendientes
POST http://localhost:3001/api/alertas/enviar

# Enviar un mensaje específico
POST http://localhost:3001/api/alertas/enviar/:mensajeID
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

