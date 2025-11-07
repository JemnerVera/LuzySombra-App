# Plan de Implementación - Worker Service para Envío de Alertas

## 📋 Resumen Ejecutivo

El sistema de alertas funciona en dos etapas:
1. **Next.js**: Crea mensajes en `image.Mensaje` (estado: Pendiente)
2. **Worker Service (.NET)**: Lee `image.Mensaje` y envía emails desde el servidor

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    SQL Server (BD)                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ image.LoteEvaluacion                                 │  │
│  │   ↓ (Trigger SQL)                                    │  │
│  │ image.Alerta (estado: Pendiente)                    │  │
│  │   ↓ (Next.js API)                                    │  │
│  │ image.Mensaje (estado: Pendiente)                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│          Worker Service (.NET) - Servidor Windows           │
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
│              Servicio de Email (SMTP/Resend)                │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Flujo Completo

### 1. Creación de Alerta (SQL Trigger)
- **Cuándo**: Cuando `image.LoteEvaluacion.tipoUmbralActual` cambia a `CriticoRojo` o `CriticoAmarillo`
- **Dónde**: SQL Server Trigger (`trg_LoteEvaluacion_Alerta`)
- **Acción**: Inserta registro en `image.Alerta` con `estado = 'Pendiente'`

### 2. Creación de Mensaje (Next.js API)
- **Cuándo**: Llamada a `/api/alertas/procesar-mensajes` (manual o programada)
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
  - Envía email (SMTP, Resend API, o cualquier servicio)
  - Actualiza `image.Mensaje.estado = 'Enviado'` o `'Error'`
  - Registra logs en archivo/BD

## 🛠️ Especificaciones del Worker Service

### Tecnología
- **.NET 6.0 o superior** (Worker Service template)
- **SQL Server Client** (para leer `image.Mensaje`)
- **Email Library** (SMTP, Resend SDK, o HttpClient para API)

### Funcionalidades Requeridas

#### 1. Lectura de Mensajes Pendientes
```sql
SELECT 
    mensajeID,
    alertaID,
    tipoMensaje,
    asunto,
    cuerpoHTML,
    cuerpoTexto,
    destinatarios,  -- JSON array
    destinatariosCC,
    destinatariosBCC,
    estado,
    fechaCreacion,
    intentosEnvio
FROM image.Mensaje
WHERE estado = 'Pendiente'
  AND statusID = 1
  AND intentosEnvio < 3  -- Máximo 3 intentos
ORDER BY fechaCreacion ASC
```

#### 2. Envío de Email
- Parsear `destinatarios` (JSON array)
- Enviar email con `asunto`, `cuerpoHTML`, `cuerpoTexto`
- Manejar CC y BCC si existen
- Obtener respuesta del servicio de email (ID de mensaje, estado)

#### 3. Actualización de Estado
```sql
UPDATE image.Mensaje
SET 
    estado = 'Enviado',  -- o 'Error'
    fechaEnvio = GETDATE(),
    intentosEnvio = intentosEnvio + 1,
    resendMessageID = @messageID,  -- ID del servicio de email
    errorMessage = @errorMessage   -- Si hay error
WHERE mensajeID = @mensajeID
```

#### 4. Manejo de Errores
- Reintentos automáticos (máximo 3 intentos)
- Backoff exponencial entre reintentos
- Logging de errores
- Actualizar `estado = 'Error'` si falla después de 3 intentos

#### 5. Logging
- Logs en archivo (NLog, Serilog, etc.)
- Registrar: mensajes procesados, exitosos, errores
- Logs de errores detallados

### Configuración

#### appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=...;User Id=...;Password=...;"
  },
  "EmailService": {
    "Provider": "SMTP",  // o "Resend", "SendGrid", etc.
    "SmtpServer": "smtp.gmail.com",
    "SmtpPort": 587,
    "SmtpUser": "...",
    "SmtpPassword": "...",
    "FromEmail": "noreply@agricolaandrea.com",
    "FromName": "Sistema de Alertas"
  },
  "WorkerService": {
    "IntervalMinutes": 5,
    "MaxRetries": 3,
    "BatchSize": 10
  }
}
```

### Estructura del Proyecto .NET

```
WorkerService.Alertas/
├── Program.cs
├── Worker.cs
├── Services/
│   ├── MensajeService.cs      # Lee y actualiza image.Mensaje
│   ├── EmailService.cs         # Envía emails (SMTP/Resend)
│   └── LoggingService.cs       # Logging
├── Models/
│   ├── Mensaje.cs              # Modelo de image.Mensaje
│   └── EmailResult.cs          # Resultado del envío
└── appsettings.json
```

## 📝 Pasos de Implementación

### Fase 1: Preparación
- [x] Eliminar código de Resend de Next.js
- [x] Modificar endpoint para solo crear mensajes
- [ ] Crear estructura del proyecto .NET Worker Service

### Fase 2: Desarrollo del Worker Service
- [ ] Crear proyecto .NET Worker Service
- [ ] Implementar `MensajeService` (lectura/actualización de BD)
- [ ] Implementar `EmailService` (envío de emails)
- [ ] Implementar lógica de reintentos
- [ ] Implementar logging

### Fase 3: Configuración
- [ ] Configurar conexión a SQL Server
- [ ] Configurar servicio de email (SMTP/Resend)
- [ ] Configurar intervalo de ejecución
- [ ] Configurar logging

### Fase 4: Testing
- [ ] Probar lectura de mensajes pendientes
- [ ] Probar envío de emails
- [ ] Probar manejo de errores
- [ ] Probar reintentos

### Fase 5: Despliegue
- [ ] Instalar como servicio de Windows
- [ ] Configurar inicio automático
- [ ] Monitorear logs
- [ ] Verificar envío de emails

## 🔧 Código de Ejemplo (.NET)

### Worker.cs (Estructura básica)
```csharp
public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly MensajeService _mensajeService;
    private readonly EmailService _emailService;
    private readonly int _intervalMinutes;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                // 1. Leer mensajes pendientes
                var mensajes = await _mensajeService.GetMensajesPendientes();
                
                // 2. Procesar cada mensaje
                foreach (var mensaje in mensajes)
                {
                    try
                    {
                        // 3. Enviar email
                        var result = await _emailService.SendEmail(mensaje);
                        
                        // 4. Actualizar estado
                        await _mensajeService.UpdateEstado(
                            mensaje.MensajeID, 
                            result.Success ? "Enviado" : "Error",
                            result.MessageID,
                            result.ErrorMessage
                        );
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, $"Error procesando mensaje {mensaje.MensajeID}");
                        // Actualizar con error
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en ciclo de procesamiento");
            }

            // Esperar antes del siguiente ciclo
            await Task.Delay(TimeSpan.FromMinutes(_intervalMinutes), stoppingToken);
        }
    }
}
```

## 📊 Tabla image.Mensaje

### Campos Importantes para el Worker Service

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `mensajeID` | INT | PK, identificador único |
| `alertaID` | INT | FK a image.Alerta |
| `tipoMensaje` | VARCHAR | 'Email', 'SMS', 'Push' |
| `asunto` | NVARCHAR | Asunto del email |
| `cuerpoHTML` | NVARCHAR(MAX) | Cuerpo HTML del email |
| `cuerpoTexto` | NVARCHAR(MAX) | Cuerpo texto plano |
| `destinatarios` | NVARCHAR(MAX) | JSON array de emails |
| `destinatariosCC` | NVARCHAR(MAX) | JSON array de CC |
| `destinatariosBCC` | NVARCHAR(MAX) | JSON array de BCC |
| `estado` | VARCHAR | 'Pendiente', 'Enviando', 'Enviado', 'Error' |
| `fechaCreacion` | DATETIME | Fecha de creación |
| `fechaEnvio` | DATETIME | Fecha de envío (NULL si no enviado) |
| `intentosEnvio` | INT | Número de intentos (máximo 3) |
| `resendMessageID` | NVARCHAR | ID del mensaje del servicio de email |
| `errorMessage` | NVARCHAR(MAX) | Mensaje de error si falla |

## ✅ Ventajas de esta Arquitectura

1. **Separación de Responsabilidades**
   - Next.js: Lógica de negocio
   - Worker Service: Envío de emails

2. **No Bloquea la BD**
   - Las llamadas a APIs externas no ralentizan SQL Server
   - El Worker Service maneja errores sin afectar la BD

3. **Mejor Manejo de Errores**
   - Reintentos automáticos
   - Logging independiente
   - No afecta la aplicación principal

4. **Escalabilidad**
   - Puedes tener múltiples instancias del Worker Service
   - Fácil de monitorear y mantener

5. **Seguridad**
   - Las credenciales de email están solo en el servidor
   - No expone APIs externas desde la aplicación web

## 🚀 Próximos Pasos

1. **Crear proyecto .NET Worker Service**
2. **Implementar servicios de lectura y envío**
3. **Configurar conexión a SQL Server**
4. **Configurar servicio de email (SMTP recomendado para servidor)**
5. **Instalar como servicio de Windows**
6. **Monitorear y ajustar**

## 📚 Recursos

- [.NET Worker Service Documentation](https://learn.microsoft.com/en-us/dotnet/core/extensions/workers)
- [SQL Server Client for .NET](https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient)
- [SMTP Client for .NET](https://learn.microsoft.com/en-us/dotnet/api/system.net.mail.smtpclient)



