# Uso de la Tabla image.Contacto

## 📋 Descripción

La tabla `image.Contacto` permite gestionar destinatarios de alertas de forma flexible y dinámica, sin necesidad de modificar variables de entorno.

## 🎯 Ventajas

1. **Múltiples destinatarios**: Puedes agregar tantos contactos como necesites
2. **Filtros por tipo de alerta**: Cada contacto puede elegir qué tipos de alertas recibir
3. **Filtros por variedad**: Contactos específicos para variedades específicas
4. **Gestión desde BD**: Agregar/quitar contactos sin reiniciar la aplicación
5. **Fallback**: Si no hay contactos en BD, usa la variable de entorno `ALERTAS_EMAIL_DESTINATARIOS`

## 📊 Estructura de la Tabla

### Campos Principales

- `nombre`: Nombre del contacto
- `email`: Email del contacto (único, validado)
- `tipo`: Tipo de contacto (Admin, Agronomo, Manager, Supervisor, Tecnico, Otro)
- `recibirAlertasCriticas`: Si recibe alertas críticas (CriticoRojo)
- `recibirAlertasAdvertencias`: Si recibe alertas de advertencia (CriticoAmarillo)
- `recibirAlertasNormales`: Si recibe notificaciones cuando vuelve a Normal
- `fundoID`: NULL = todos los fundos, específico = solo ese fundo (match con el fundo del lote)
- `sectorID`: NULL = todos los sectores, específico = solo ese sector (match con el sector del lote)
- `prioridad`: Orden de destinatarios (mayor = primero)
- `activo`: Si el contacto está activo

## 🔧 Cómo Funciona

1. **Cuando se crea un mensaje**, el sistema:
   - Obtiene el `lotID` de la alerta
   - Obtiene el `fundoID` y `sectorID` del lote (desde GROWER.LOT → GROWER.STAGE → GROWER.FARMS)
   - Busca contactos activos en `image.Contacto`
   - Filtra por tipo de alerta (CriticoRojo, CriticoAmarillo, Normal)
   - Filtra por `fundoID`: contactos con `fundoID = NULL` (todos) O `fundoID = fundoID_del_lote`
   - Filtra por `sectorID`: contactos con `sectorID = NULL` (todos) O `sectorID = sectorID_del_lote`
   - Si no encuentra contactos, usa la variable de entorno como fallback

2. **Múltiples destinatarios**: Todos los contactos que cumplan los filtros recibirán el email

## 📝 Ejemplos de Uso

### Ejemplo 1: Contacto que recibe todas las alertas

```sql
INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    activo,
    statusID
)
VALUES (
    'Administrador',
    'admin@example.com',
    'Admin',
    1,  -- Recibe críticas
    1,  -- Recibe advertencias
    1,  -- Activo
    1
);
```

### Ejemplo 2: Contacto solo para alertas críticas

```sql
INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    activo,
    statusID
)
VALUES (
    'Gerente',
    'gerente@example.com',
    'Manager',
    1,  -- Recibe críticas
    0,  -- NO recibe advertencias
    1,  -- Activo
    1
);
```

### Ejemplo 3: Contacto para un fundo específico

```sql
-- Primero verificar los fundos disponibles:
SELECT farmID, Description FROM GROWER.FARMS WHERE statusID = 1;

INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    fundoID,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    activo,
    statusID
)
VALUES (
    'Agrónomo del Fundo X',
    'agronomo.fundo@example.com',
    'Agronomo',
    1,   -- ID del fundo (cambiar por el ID real)
    1,   -- Recibe críticas
    1,   -- Recibe advertencias
    1,   -- Activo
    1
);
```

### Ejemplo 3b: Contacto para un sector específico (más específico)

```sql
-- Primero verificar los sectores disponibles:
SELECT s.stageID, s.stage, f.Description AS fundo 
FROM GROWER.STAGE s 
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID 
WHERE s.statusID = 1;

INSERT INTO image.Contacto (
    nombre,
    email,
    tipo,
    sectorID,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    activo,
    statusID
)
VALUES (
    'Supervisor del Sector Y',
    'supervisor.sector@example.com',
    'Supervisor',
    5,   -- ID del sector (cambiar por el ID real)
    1,   -- Recibe críticas
    1,   -- Recibe advertencias
    1,   -- Activo
    1
);
```

### Ejemplo 4: Múltiples contactos

```sql
INSERT INTO image.Contacto (
    nombre, email, tipo,
    recibirAlertasCriticas, recibirAlertasAdvertencias,
    activo, statusID
)
VALUES 
    ('Juan Pérez', 'juan@example.com', 'Agronomo', 1, 1, 1, 1),
    ('María García', 'maria@example.com', 'Supervisor', 1, 0, 1, 1),
    ('Carlos López', 'carlos@example.com', 'Tecnico', 1, 1, 1, 1);
```

## 🔍 Consultas Útiles

### Ver todos los contactos activos

```sql
SELECT 
    contactoID,
    nombre,
    email,
    tipo,
    recibirAlertasCriticas,
    recibirAlertasAdvertencias,
    variedadID,
    activo
FROM image.Contacto
WHERE statusID = 1
ORDER BY prioridad DESC, nombre ASC;
```

### Ver contactos que recibirían una alerta específica

```sql
-- Para una alerta CriticoAmarillo de un lote específico (lotID = 1022)
DECLARE @LotID INT = 1022;

-- Obtener fundoID y sectorID del lote
DECLARE @FundoID INT;
DECLARE @SectorID INT;

SELECT 
    @FundoID = f.farmID,
    @SectorID = s.stageID
FROM GROWER.LOT l
INNER JOIN GROWER.STAGE s ON l.stageID = s.stageID
INNER JOIN GROWER.FARMS f ON s.farmID = f.farmID
WHERE l.lotID = @LotID;

SELECT 
    nombre,
    email,
    tipo,
    fundoID,
    sectorID
FROM image.Contacto
WHERE activo = 1
  AND statusID = 1
  AND recibirAlertasAdvertencias = 1
  AND (fundoID IS NULL OR fundoID = @FundoID)
  AND (sectorID IS NULL OR sectorID = @SectorID)
ORDER BY prioridad DESC, nombre ASC;
```

### Desactivar un contacto (sin eliminarlo)

```sql
UPDATE image.Contacto
SET activo = 0
WHERE email = 'contacto@example.com';
```

### Reactivar un contacto

```sql
UPDATE image.Contacto
SET activo = 1
WHERE email = 'contacto@example.com';
```

## 🔄 Flujo Completo

1. **Se crea una alerta** (trigger SQL) → `image.Alerta`
2. **Se ejecuta el procesamiento** → `POST /api/alertas/procesar-mensajes`
3. **El servicio busca contactos** en `image.Contacto`:
   - Filtra por tipo de alerta
   - Filtra por variedad (si aplica)
   - Ordena por prioridad
4. **Crea un mensaje** con todos los destinatarios → `image.Mensaje`
5. **Envía el email** a todos los destinatarios → Resend API

## ✅ Ventajas vs Variable de Entorno

| Característica | Variable de Entorno | Tabla image.Contacto |
|----------------|---------------------|---------------------|
| Múltiples destinatarios | ✅ | ✅ |
| Filtros por tipo de alerta | ❌ | ✅ |
| Filtros por fundo/sector | ❌ | ✅ |
| Cambios sin reiniciar | ❌ | ✅ |
| Gestión desde BD | ❌ | ✅ |
| Fallback | N/A | ✅ |

## 🚀 Próximos Pasos

1. **Ejecuta el script** `scripts/01_tables/06_image.Contacto.sql` para crear la tabla
2. **Inserta contactos** usando `scripts/04_modifications/02_insert_contactos_ejemplo.sql`
3. **Prueba el flujo** ejecutando `POST /api/alertas/procesar-mensajes`
4. **Verifica** que los emails se envíen a todos los contactos configurados

