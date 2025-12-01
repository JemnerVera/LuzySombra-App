# 📚 Explicación Detallada de Mejoras Pendientes

Este documento explica en detalle las tres mejoras pendientes de mayor prioridad para la aplicación LuzSombra.

---

## 1. 🔐 Autenticación de Usuarios Web (Prioridad ALTA)

### ¿Qué es?

Un sistema de login para usuarios que acceden desde el navegador web, similar a cómo los dispositivos móviles (AgriQR) se autentican actualmente, pero adaptado para usuarios humanos con roles y permisos.

### Estado Actual

**✅ Lo que SÍ existe:**
- Autenticación para dispositivos móviles (AgriQR) en `/api/auth/login`
- Los dispositivos se autentican con `deviceId` + `apiKey`
- Se genera un JWT token que expira en 24 horas
- Middleware `authenticateToken` para proteger rutas

**❌ Lo que NO existe:**
- Login para usuarios web (personas)
- Sistema de usuarios y contraseñas
- Roles y permisos (Admin, Agrónomo, Supervisor, etc.)
- Protección de rutas sensibles en el frontend
- Gestión de sesiones de usuario

### ¿Por qué es importante?

**Problema actual:**
- Cualquiera que tenga acceso a la URL puede ver y modificar:
  - Umbrales (configuración crítica del sistema)
  - Contactos (destinatarios de alertas)
  - Alertas (puede resolver/ignorar sin autorización)
  - Estadísticas y datos sensibles

**Riesgos:**
- 🔴 Sin control de acceso, cualquier persona puede modificar configuraciones críticas
- 🔴 No hay auditoría de quién hizo qué cambios
- 🔴 No se puede restringir acceso por roles (ej: solo agrónomos pueden cambiar umbrales)

### ¿Qué implicaría implementarlo?

#### Backend (Nuevo):

1. **Tabla de Usuarios** (si no existe en `MAST.USERS`):
   ```sql
   -- Usar tabla existente MAST.USERS o crear tabla específica
   -- Campos necesarios:
   - userID (PK)
   - username (único)
   - password (hash con bcrypt)
   - email
   - rol (Admin, Agronomo, Supervisor, etc.)
   - activo
   ```

2. **Nuevos Endpoints:**
   ```
   POST /api/auth/web/login
     Body: { username, password }
     Response: { token, user: { id, nombre, rol, permisos } }
   
   POST /api/auth/web/logout
     Headers: { Authorization: Bearer <token> }
   
   GET /api/auth/web/me
     Headers: { Authorization: Bearer <token> }
     Response: { user: { id, nombre, rol, permisos } }
   
   POST /api/auth/web/refresh
     Headers: { Authorization: Bearer <token> }
     Response: { token: nuevo_token }
   ```

3. **Sistema de Roles y Permisos:**
   ```typescript
   // Ejemplo de permisos
   const PERMISOS = {
     ADMIN: ['*'], // Todo
     AGRONOMO: [
       'umbrales:read',
       'umbrales:write',
       'alertas:read',
       'alertas:resolve',
       'contactos:read',
       'dashboard:read'
     ],
     SUPERVISOR: [
       'alertas:read',
       'contactos:read',
       'dashboard:read',
       'historial:read'
     ],
     LECTOR: [
       'dashboard:read',
       'historial:read'
     ]
   };
   ```

4. **Middleware de Autorización:**
   ```typescript
   // Verificar que el usuario tenga el permiso necesario
   export function requirePermission(permission: string) {
     return (req, res, next) => {
       const user = req.user; // Del middleware de auth
       if (!user.permisos.includes(permission) && !user.permisos.includes('*')) {
         return res.status(403).json({ error: 'Forbidden' });
       }
       next();
     };
   }
   ```

5. **Proteger Rutas Sensibles:**
   ```typescript
   // Ejemplo: Solo admin puede crear/editar umbrales
   router.post('/api/umbrales', 
     authenticateWebUser,
     requirePermission('umbrales:write'),
     createUmbral
   );
   ```

#### Frontend (Nuevo):

1. **Página de Login:**
   - Formulario con username/password
   - Manejo de errores (credenciales inválidas, cuenta desactivada)
   - Recordar sesión (opcional)

2. **Contexto de Autenticación:**
   ```typescript
   // AuthContext.tsx
   interface AuthContextType {
     user: User | null;
     login: (username: string, password: string) => Promise<void>;
     logout: () => void;
     isAuthenticated: boolean;
     hasPermission: (permission: string) => boolean;
   }
   ```

3. **Protección de Rutas:**
   ```typescript
   // Proteger componentes sensibles
   <ProtectedRoute permission="umbrales:write">
     <UmbralesManagement />
   </ProtectedRoute>
   ```

4. **Mostrar/Ocultar según Permisos:**
   ```typescript
   // Ocultar botones si no tiene permiso
   {hasPermission('contactos:write') && (
     <button onClick={handleCreate}>Crear Contacto</button>
   )}
   ```

5. **Interceptor de Axios:**
   ```typescript
   // Agregar token a todas las requests
   api.interceptors.request.use((config) => {
     const token = localStorage.getItem('authToken');
     if (token) {
       config.headers.Authorization = `Bearer ${token}`;
     }
     return config;
   });
   
   // Manejar expiración de token
   api.interceptors.response.use(
     (response) => response,
     (error) => {
       if (error.response?.status === 401) {
         // Token expirado, redirigir a login
         logout();
       }
       return Promise.reject(error);
     }
   );
   ```

### Beneficios

✅ **Seguridad:**
- Solo usuarios autorizados pueden acceder
- Control granular de qué puede hacer cada usuario
- Protección contra acceso no autorizado

✅ **Auditoría:**
- Saber quién hizo cada cambio
- Trazabilidad completa de acciones
- Historial de modificaciones por usuario

✅ **Flexibilidad:**
- Diferentes niveles de acceso según rol
- Fácil agregar nuevos roles
- Permisos granulares por funcionalidad

### Esfuerzo Estimado

- **Backend:** 2-3 días
  - Crear endpoints de auth
  - Sistema de roles/permisos
  - Middleware de autorización
  - Integrar con tabla de usuarios existente

- **Frontend:** 2-3 días
  - Página de login
  - Contexto de autenticación
  - Protección de rutas
  - Actualizar componentes para usar permisos

- **Total:** 4-6 días de desarrollo

---

## 2. 🔔 Notificaciones en Tiempo Real (Prioridad MEDIA)

### ¿Qué es?

Un sistema que muestra notificaciones en la aplicación web cuando ocurren eventos importantes (nuevas alertas, cambios en umbrales, etc.), sin necesidad de recargar la página o revisar el email.

### Estado Actual

**✅ Lo que SÍ existe:**
- Alertas se generan automáticamente cuando un lote cruza un umbral
- Alertas se envían por email vía Resend API
- Dashboard de alertas muestra alertas existentes

**❌ Lo que NO existe:**
- Notificaciones en la UI cuando se genera una nueva alerta
- Badge con contador de alertas pendientes
- Actualización automática sin recargar página
- Historial de notificaciones

### ¿Por qué es importante?

**Problema actual:**
- Los usuarios solo se enteran de alertas cuando:
  - Revisan su email (puede tardar horas)
  - Abren manualmente la pestaña "Alertas"
  - Recargan la página

**Escenario problemático:**
- Se genera una alerta crítica a las 2:00 PM
- El agrónomo no revisa su email hasta las 5:00 PM
- 3 horas perdidas para tomar acción

### ¿Qué implicaría implementarlo?

#### Opción 1: Polling (Más Simple) ⭐ Recomendado

**Cómo funciona:**
- El frontend hace una petición cada X segundos (ej: 30 segundos) al backend
- El backend responde con el número de alertas nuevas
- Si hay nuevas, se muestra una notificación

**Implementación:**

**Backend:**
```typescript
// GET /api/notificaciones/contador
router.get('/contador', authenticateWebUser, async (req, res) => {
  const userId = req.user.id;
  const ultimaConsulta = req.query.ultimaConsulta; // Timestamp
  
  const nuevasAlertas = await query(`
    SELECT COUNT(*) as total
    FROM evalImagen.Alerta
    WHERE estado IN ('Pendiente', 'Enviada')
      AND fechaCreacion > @ultimaConsulta
      AND statusID = 1
  `, { ultimaConsulta });
  
  res.json({
    nuevasAlertas: nuevasAlertas[0].total,
    timestamp: Date.now()
  });
});
```

**Frontend:**
```typescript
// Hook useNotifications.ts
const useNotifications = () => {
  const [contador, setContador] = useState(0);
  const [ultimaConsulta, setUltimaConsulta] = useState(Date.now());
  
  useEffect(() => {
    const interval = setInterval(async () => {
      const response = await api.get('/api/notificaciones/contador', {
        params: { ultimaConsulta }
      });
      
      if (response.data.nuevasAlertas > 0) {
        setContador(response.data.nuevasAlertas);
        // Mostrar notificación
        showNotification(`Tienes ${response.data.nuevasAlertas} nuevas alertas`, 'info');
      }
      
      setUltimaConsulta(response.data.timestamp);
    }, 30000); // Cada 30 segundos
    
    return () => clearInterval(interval);
  }, [ultimaConsulta]);
  
  return { contador };
};
```

**Ventajas:**
- ✅ Simple de implementar
- ✅ No requiere WebSockets
- ✅ Funciona con cualquier servidor
- ✅ Fácil de debuggear

**Desventajas:**
- ⚠️ Hace requests constantes (aunque pequeños)
- ⚠️ Puede haber delay de hasta 30 segundos

---

#### Opción 2: WebSockets (Más Avanzado)

**Cómo funciona:**
- Conexión persistente entre frontend y backend
- Backend envía mensajes inmediatamente cuando ocurre un evento
- Frontend recibe y muestra notificación al instante

**Implementación:**

**Backend:**
```typescript
// Instalar: npm install socket.io
import { Server } from 'socket.io';

const io = new Server(server);

// Cuando se crea una alerta
io.emit('nueva-alerta', {
  alertaID: 123,
  tipo: 'CriticoRojo',
  lote: 'Lote A',
  timestamp: Date.now()
});
```

**Frontend:**
```typescript
// Instalar: npm install socket.io-client
import io from 'socket.io-client';

const socket = io(API_URL);

socket.on('nueva-alerta', (data) => {
  showNotification(`Nueva alerta: ${data.lote}`, 'warning');
  setContador(prev => prev + 1);
});
```

**Ventajas:**
- ✅ Notificaciones instantáneas
- ✅ No hace polling constante
- ✅ Más eficiente

**Desventajas:**
- ⚠️ Más complejo de implementar
- ⚠️ Requiere mantener conexión abierta
- ⚠️ Puede tener problemas con firewalls/proxies

---

#### Componente de Notificaciones

```typescript
// NotificationCenter.tsx
const NotificationCenter = () => {
  const { contador } = useNotifications();
  const [notificaciones, setNotificaciones] = useState([]);
  
  return (
    <div className="relative">
      <button className="relative">
        <Bell className="h-6 w-6" />
        {contador > 0 && (
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
            {contador}
          </span>
        )}
      </button>
      
      {/* Dropdown con lista de notificaciones */}
      <div className="absolute right-0 mt-2 w-80 bg-white dark:bg-dark-900 rounded-lg shadow-lg">
        {notificaciones.map(notif => (
          <div key={notif.id} className="p-4 border-b">
            <h4>{notif.titulo}</h4>
            <p>{notif.mensaje}</p>
            <span className="text-xs text-gray-500">{notif.fecha}</span>
          </div>
        ))}
      </div>
    </div>
  );
};
```

### Beneficios

✅ **Inmediatez:**
- Los usuarios se enteran al instante de nuevas alertas
- No dependen solo del email
- Mejor tiempo de respuesta

✅ **Engagement:**
- Badge con contador llama la atención
- Notificaciones visuales no intrusivas
- Historial de notificaciones

✅ **Productividad:**
- No necesitan estar revisando constantemente
- La app les avisa cuando hay algo importante

### Esfuerzo Estimado

- **Opción 1 (Polling):** 1-2 días
  - Endpoint de contador
  - Hook de notificaciones
  - Componente de badge
  - Integración en Layout

- **Opción 2 (WebSockets):** 3-4 días
  - Configurar Socket.IO
  - Eventos en backend
  - Cliente en frontend
  - Manejo de reconexión

---

## 3. 📱 Gestión de Dispositivos desde la UI (Prioridad MEDIA)

### ¿Qué es?

Una interfaz web para gestionar los dispositivos móviles (AgriQR) que tienen acceso a la aplicación, similar a cómo se gestionan contactos o umbrales.

### Estado Actual

**✅ Lo que SÍ existe:**
- Tabla `evalImagen.Dispositivo` en la base de datos
- Endpoint `/api/auth/login` que valida dispositivos
- Campos: `deviceId`, `apiKey`, `nombreDispositivo`, `activo`, `ultimoAcceso`

**❌ Lo que NO existe:**
- Interfaz web para ver dispositivos
- Crear nuevos dispositivos desde la UI
- Generar API keys automáticamente
- Revocar acceso (desactivar dispositivos)
- Ver estadísticas de uso

### ¿Por qué es importante?

**Problema actual:**
- Para agregar un nuevo dispositivo o desactivar uno, hay que:
  1. Pedirle al DBA que ejecute un script SQL
  2. Esperar a que tenga tiempo
  3. Coordinar el cambio

**Escenario problemático:**
- Se pierde un dispositivo en campo
- Necesitas desactivarlo inmediatamente por seguridad
- Tienes que esperar al DBA
- Mientras tanto, el dispositivo puede seguir accediendo

### ¿Qué implicaría implementarlo?

#### Backend (Nuevo):

1. **Servicio de Dispositivos:**
   ```typescript
   // deviceService.ts
   class DeviceService {
     // Listar todos los dispositivos
     async getAllDevices(): Promise<Device[]>
     
     // Obtener un dispositivo por ID
     async getDeviceById(id: number): Promise<Device | null>
     
     // Crear nuevo dispositivo
     async createDevice(data: {
       nombreDispositivo: string;
       modeloDispositivo?: string;
       versionApp?: string;
     }): Promise<{ dispositivoID: number; apiKey: string }>
     
     // Actualizar dispositivo
     async updateDevice(id: number, data: Partial<Device>): Promise<boolean>
     
     // Generar nueva API key
     async regenerateApiKey(id: number): Promise<string>
     
     // Desactivar/Activar dispositivo
     async toggleDevice(id: number, activo: boolean): Promise<boolean>
     
     // Eliminar dispositivo (soft delete)
     async deleteDevice(id: number): Promise<boolean>
     
     // Obtener estadísticas de uso
     async getDeviceStats(id: number): Promise<{
       totalAccesos: number;
       ultimoAcceso: Date | null;
       diasInactivo: number;
     }>
   }
   ```

2. **Generación de API Keys:**
   ```typescript
   // Generar API key segura
   function generateApiKey(): string {
     const crypto = require('crypto');
     return `luzsombra_${crypto.randomBytes(32).toString('hex')}`;
   }
   ```

3. **Rutas:**
   ```
   GET    /api/dispositivos              - Listar todos
   GET    /api/dispositivos/:id          - Obtener uno
   POST   /api/dispositivos              - Crear nuevo
   PUT    /api/dispositivos/:id          - Actualizar
   DELETE /api/dispositivos/:id          - Eliminar
   POST   /api/dispositivos/:id/regenerate-key - Regenerar API key
   PUT    /api/dispositivos/:id/toggle   - Activar/Desactivar
   GET    /api/dispositivos/:id/stats    - Estadísticas
   ```

#### Frontend (Nuevo):

1. **Componente DispositivosManagement:**
   ```typescript
   // Similar a ContactosManagement.tsx
   const DispositivosManagement = () => {
     // Tabla con dispositivos
     // Columnas:
     // - Nombre
     // - Device ID
     // - Estado (Activo/Inactivo)
     // - Último Acceso
     // - Modelo/Version
     // - Acciones (Editar, Regenerar Key, Desactivar, Eliminar)
     
     // Formulario para crear/editar
     // Botón "Generar API Key" (muestra key una sola vez)
     // Botón "Regenerar Key" (con confirmación)
   };
   ```

2. **Funcionalidades:**
   - ✅ Ver lista de todos los dispositivos
   - ✅ Crear nuevo dispositivo (genera API key automáticamente)
   - ✅ Editar nombre, modelo, versión
   - ✅ Regenerar API key (invalida la anterior)
   - ✅ Activar/Desactivar dispositivo
   - ✅ Ver último acceso y días inactivos
   - ✅ Eliminar dispositivo (soft delete)
   - ✅ Filtros: Activos/Inactivos, por nombre

3. **Seguridad:**
   - ⚠️ Solo usuarios con rol Admin pueden gestionar dispositivos
   - ⚠️ Al regenerar API key, mostrar alerta de que el dispositivo actual perderá acceso
   - ⚠️ Confirmación antes de desactivar/eliminar

### Ejemplo de UI

```
┌─────────────────────────────────────────────────────────┐
│  Gestión de Dispositivos                    [+ Nuevo]   │
├─────────────────────────────────────────────────────────┤
│  Filtros: [Todos ▼] [Activos ▼]                        │
├─────────────────────────────────────────────────────────┤
│  Nombre          │ Device ID    │ Estado │ Último Acceso│
├─────────────────────────────────────────────────────────┤
│  Tablet Campo 1  │ abc123...    │ ✅ Activo│ Hace 2 horas │
│                  │              │        │ [Editar] [Key] │
├─────────────────────────────────────────────────────────┤
│  Tablet Campo 2  │ xyz789...    │ ❌ Inactivo│ Hace 15 días│
│                  │              │        │ [Activar]     │
└─────────────────────────────────────────────────────────┘
```

### Beneficios

✅ **Autonomía:**
- No dependes del DBA para cambios simples
- Agregar/desactivar dispositivos en minutos
- Control total desde la UI

✅ **Seguridad:**
- Desactivar dispositivos perdidos inmediatamente
- Regenerar keys comprometidas al instante
- Ver quién está accediendo y cuándo

✅ **Auditoría:**
- Ver historial de accesos
- Identificar dispositivos inactivos
- Estadísticas de uso

### Esfuerzo Estimado

- **Backend:** 1-2 días
  - Servicio de dispositivos
  - Generación de API keys
  - Rutas CRUD
  - Estadísticas

- **Frontend:** 1-2 días
  - Componente similar a ContactosManagement
  - Formulario de creación/edición
  - Manejo de API keys (mostrar solo una vez)
  - Filtros y acciones

- **Total:** 2-4 días de desarrollo

---

## 📊 Comparación de Esfuerzo y Prioridad

| Mejora | Prioridad | Esfuerzo | Impacto | ROI |
|--------|-----------|----------|---------|-----|
| **Autenticación Web** | 🔴 ALTA | 4-6 días | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Notificaciones Real-time** | 🟡 MEDIA | 1-4 días | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Gestión Dispositivos** | 🟡 MEDIA | 2-4 días | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎯 Recomendación de Orden de Implementación

### Fase 1: Seguridad Primero (Semana 1)
1. **Autenticación de Usuarios Web** (4-6 días)
   - Es la más crítica para seguridad
   - Permite proteger las otras funcionalidades
   - Base para auditoría

### Fase 2: Mejoras de UX (Semana 2)
2. **Gestión de Dispositivos** (2-4 días)
   - Relativamente simple
   - Alto impacto operativo
   - Reduce dependencia del DBA

3. **Notificaciones en Tiempo Real** (1-4 días)
   - Mejora significativa de UX
   - Puede empezar con polling (simple)
   - Mejorar a WebSockets después si es necesario

---

## 💡 Consideraciones Adicionales

### Para Autenticación:
- ¿Existe tabla de usuarios en `MAST.USERS`? Si sí, reutilizarla
- ¿Necesitas integración con Active Directory o LDAP?
- ¿Qué roles específicos necesitas? (definir antes de implementar)

### Para Notificaciones:
- ¿Prefieres polling simple o WebSockets desde el inicio?
- ¿Qué eventos quieres notificar? (solo alertas o también otros)
- ¿Necesitas notificaciones push en móvil también?

### Para Dispositivos:
- ¿Quién puede gestionar dispositivos? (solo Admin o también otros roles)
- ¿Necesitas logs de accesos más detallados?
- ¿Quieres límite de dispositivos activos por usuario?

---

**¿Tienes alguna pregunta específica sobre alguna de estas mejoras?** Puedo profundizar en cualquier aspecto o ayudarte a implementar alguna de ellas.

