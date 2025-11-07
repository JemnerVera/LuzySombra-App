# Arquitectura del Sistema de Alertas

## 🏗️ Arquitectura Recomendada (Producción)

### Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    SQL Server (BD)                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ image.LoteEvaluacion                                 │  │
│  │   ↓ (Trigger)                                        │  │
│  │ image.Alerta (estado: Pendiente)                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Next.js API: /api/alertas/procesar-mensajes         │  │
│  │   ↓ (Lee alertas pendientes)                        │  │
│  │ image.Mensaje (estado: Pendiente)                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              Worker Service (.NET)                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 1. Lee image.Mensaje (estado: Pendiente)            │  │
│  │ 2. Envía email (SMTP/Resend/API)                    │  │
│  │ 3. Actualiza estado: Enviado/Error                  │  │
│  │ 4. Logging independiente                            │  │
│  │ 5. Reintentos automáticos                           │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│        Servicio de Email (SMTP/Resend/SendGrid)            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Envía emails a destinatarios                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Flujo Completo

### 1. Creación de Alerta (SQL Trigger)
- **Cuándo**: Cuando `image.LoteEvaluacion.tipoUmbralActual` cambia a `CriticoRojo` o `CriticoAmarillo`
- **Dónde**: SQL Server Trigger (`trg_LoteEvaluacion_Alerta`)
- **Acción**: Inserta registro en `image.Alerta` con `estado = 'Pendiente'`

### 2. Creación de Mensaje (Next.js API)
- **Cuándo**: Llamada manual o programada a `/api/alertas/procesar-mensajes`
- **Dónde**: Next.js API Route
- **Acción**: 
  - Lee `image.Alerta` con `estado = 'Pendiente'` y `mensajeID IS NULL`
  - Obtiene destinatarios desde `image.Contacto` (filtrado por fundoID)
  - Crea registro en `image.Mensaje` con `estado = 'Pendiente'`
  - Actualiza `image.Alerta.mensajeID`

### 3. Envío de Email (Worker Service .NET)
- **Cuándo**: Ejecución continua del Worker Service (cada X minutos)
- **Dónde**: Servicio de Windows (.NET)
- **Acción**:
  - Lee `image.Mensaje` con `estado = 'Pendiente'`
  - Envía email (SMTP, Resend API, o cualquier servicio de email)
  - Actualiza `image.Mensaje.estado = 'Enviado'` o `'Error'`
  - Registra logs en archivo/BD
  - Maneja reintentos automáticos

## ✅ Ventajas de esta Arquitectura

1. **Separación de Responsabilidades**
   - Next.js: Lógica de negocio y creación de mensajes
   - Worker Service: Envío de emails (servicio externo)

2. **No Bloquea la BD**
   - Las llamadas a APIs externas no ralentizan SQL Server
   - El Worker Service maneja errores sin afectar la BD

3. **Mejor Manejo de Errores**
   - Reintentos automáticos
   - Logging independiente
   - No afecta la aplicación principal si Resend falla

4. **Escalabilidad**
   - Puedes tener múltiples instancias del Worker Service
   - Fácil de monitorear y mantener

5. **Seguridad**
   - Las credenciales de Resend están solo en el Worker Service
   - No expone APIs externas desde la aplicación web

## 🔄 Arquitectura Actual vs Recomendada

### ❌ Arquitectura Actual (Desarrollo/Pruebas)
```
Next.js API → Resend API (directo)
```
- ✅ Funciona para desarrollo
- ❌ Bloquea la aplicación si Resend falla
- ❌ No tiene reintentos robustos
- ❌ Logging limitado

### ✅ Arquitectura Recomendada (Producción)
```
Next.js API → image.Mensaje → Worker Service → Resend API
```
- ✅ No bloquea la aplicación
- ✅ Reintentos automáticos
- ✅ Logging robusto
- ✅ Escalable

## 🛠️ Estado de Implementación

### ✅ Fase 1: Next.js (Completado)
- Next.js crea mensajes en `image.Mensaje`
- No envía emails (removido Resend)
- Listo para producción

### 🚧 Fase 2: Worker Service (.NET) - Pendiente
- Crear Worker Service en .NET
- Implementar lectura de `image.Mensaje`
- Implementar envío de emails (SMTP recomendado)
- Instalar como servicio de Windows

## 📝 Notas Importantes

1. **El endpoint `/api/alertas/procesar-mensajes` sigue siendo útil**:
   - Para crear mensajes en `image.Mensaje`
   - Para desarrollo y pruebas
   - El Worker Service solo se encarga del envío

2. **El Worker Service puede ejecutarse en**:
   - Servidor Windows
   - Máquina virtual
   - Docker container (si usan .NET en Linux)

3. **Frecuencia de ejecución**:
   - Recomendado: Cada 1-5 minutos
   - Configurable según necesidades

4. **Manejo de errores**:
   - Reintentos con backoff exponencial
   - Logging de errores
   - Notificaciones si falla repetidamente

