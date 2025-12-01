# Mejoras Propuestas para Schema evalImagen

## 📋 Resumen Ejecutivo

Este documento detalla las mejoras propuestas para optimizar el schema `evalImagen`, basadas en análisis de diseño, normalización, rendimiento y mantenibilidad.

---

## 🔴 PRIORIDAD ALTA

### 1. Eliminar Relación Circular Alerta ↔ Mensaje

**Problema Actual:**
- `evalImagen.Alerta.mensajeID` → `evalImagen.Mensaje.mensajeID`
- `evalImagen.Mensaje.alertaID` → `evalImagen.Alerta.alertaID`
- Esto crea una dependencia circular que complica las inserciones y puede causar inconsistencias.

**Solución:**
```sql
-- Eliminar FK desde Alerta a Mensaje
ALTER TABLE evalImagen.Alerta
DROP CONSTRAINT FK_Alerta_Mensaje;

ALTER TABLE evalImagen.Alerta
DROP COLUMN mensajeID;
```

**Justificación:**
- La tabla `evalImagen.MensajeAlerta` ya maneja la relación N:N correctamente.
- `Mensaje.alertaID` puede ser NULL para mensajes consolidados (correcto).
- Simplifica el modelo y evita inconsistencias.

**Impacto:**
- ⚠️ Requiere actualizar código backend que use `Alerta.mensajeID`
- ✅ Mejora la integridad referencial
- ✅ Simplifica la lógica de inserción

---

### 2. Agregar Índices Faltantes

**Índices Recomendados:**

```sql
-- Mensaje: búsquedas por estado y fecha
CREATE NONCLUSTERED INDEX IDX_Mensaje_EstadoFecha
ON evalImagen.Mensaje(estado, fechaCreacion DESC)
WHERE statusID = 1;

-- Mensaje: búsquedas por fundo (mensajes consolidados)
CREATE NONCLUSTERED INDEX IDX_Mensaje_FundoID
ON evalImagen.Mensaje(fundoID, estado)
WHERE statusID = 1 AND fundoID IS NOT NULL;

-- Contacto: búsquedas por fundo/sector activos
CREATE NONCLUSTERED INDEX IDX_Contacto_FundoSector
ON evalImagen.Contacto(fundoID, sectorID, activo)
WHERE statusID = 1 AND activo = 1;

-- Alerta: búsquedas por fecha de creación
CREATE NONCLUSTERED INDEX IDX_Alerta_FechaCreacion
ON evalImagen.Alerta(fechaCreacion DESC)
WHERE statusID = 1;
```

**Justificación:**
- Mejora rendimiento de consultas frecuentes
- Reduce tiempo de respuesta en filtros comunes
- Índices filtrados (`WHERE statusID = 1`) optimizan espacio

---

## 🟡 PRIORIDAD MEDIA

### 3. Mejorar Validación de Email

**Problema Actual:**
```sql
CONSTRAINT CK_Contacto_Email CHECK (email LIKE '%@%.%')
```

**Solución:**
```sql
-- Crear función de validación
CREATE FUNCTION evalImagen.fn_ValidarEmail(@email NVARCHAR(255))
RETURNS BIT
AS
BEGIN
    -- Validación más robusta (RFC 5322 simplificado)
    IF @email IS NULL OR LEN(@email) < 5 RETURN 0;
    IF @email NOT LIKE '%_@_%._%' RETURN 0;
    IF @email LIKE '%..%' RETURN 0;
    IF @email LIKE '%@%@%' RETURN 0;
    IF LEFT(@email, 1) = '@' OR RIGHT(@email, 1) = '@' RETURN 0;
    RETURN 1;
END;
GO

-- Actualizar constraint
ALTER TABLE evalImagen.Contacto
DROP CONSTRAINT CK_Contacto_Email;

ALTER TABLE evalImagen.Contacto
ADD CONSTRAINT CK_Contacto_Email 
CHECK (evalImagen.fn_ValidarEmail(email) = 1);
```

**Alternativa Simple:**
```sql
-- Validación mejorada sin función
CONSTRAINT CK_Contacto_Email CHECK (
    email LIKE '%_@_%._%' 
    AND email NOT LIKE '%..%' 
    AND email NOT LIKE '%@%@%'
    AND LEN(email) >= 5
    AND LEFT(email, 1) != '@'
    AND RIGHT(email, 1) != '@'
)
```

---

### 4. Definir Longitudes Explícitas en VARCHAR

**Problema Actual:**
Algunos campos tienen longitudes, otros no. Para consistencia:

```sql
-- Revisar y estandarizar:
-- tipo VARCHAR(50) → OK
-- estado VARCHAR(20) → OK
-- severidad VARCHAR(20) → OK
-- tipoUmbral VARCHAR(20) → OK
-- tipoMensaje VARCHAR(50) → OK
```

**Recomendación:**
- Documentar estándar: todos los VARCHAR deben tener longitud explícita.
- Revisar scripts y asegurar consistencia.

---

### 5. Documentar Comportamiento de UmbralLuz.variedadID NULL

**Problema:**
- `UmbralLuz.variedadID` puede ser NULL.
- No está claro si NULL = "umbral global" o "sin variedad".

**Solución:**
- Agregar Extended Property explicando el comportamiento.
- Documentar en README que NULL = umbral global aplicable a todas las variedades.

```sql
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'NULL = Umbral global aplicable a todas las variedades. Si tiene valor, es específico para esa variedad.', 
    @level0type = N'SCHEMA', @level0name = N'evalImagen',
    @level1type = N'TABLE', @level1name = N'UmbralLuz',
    @level2type = N'COLUMN', @level2name = N'variedadID';
```

---

## 🟢 PRIORIDAD BAJA (Mejoras Futuras)

### 6. Considerar Tabla MensajeDestinatario

**Problema Actual:**
- `Mensaje.destinatarios` es JSON: `["email1@example.com", "email2@example.com"]`
- No se puede consultar fácilmente: "¿Qué mensajes recibió este email?"

**Solución (Opcional):**
```sql
CREATE TABLE evalImagen.MensajeDestinatario (
    mensajeID INT NOT NULL,
    email NVARCHAR(255) NOT NULL,
    tipo VARCHAR(10) NOT NULL, -- 'TO', 'CC', 'BCC'
    fechaEnvio DATETIME NULL,
    statusID INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_MensajeDestinatario PRIMARY KEY (mensajeID, email, tipo),
    CONSTRAINT FK_MensajeDestinatario_Mensaje 
        FOREIGN KEY (mensajeID) REFERENCES evalImagen.Mensaje(mensajeID)
);
```

**Justificación:**
- Permite consultas: "¿Qué mensajes recibió este contacto?"
- Facilita reportes de envíos
- Mejora trazabilidad

**Contra:**
- Aumenta complejidad
- Requiere migración de datos existentes
- Puede ser over-engineering si no se necesita consultar por destinatario

---

### 7. Agregar Relación Dispositivo → AnalisisImagen

**Problema:**
- `Dispositivo` no tiene relación con `AnalisisImagen`.
- No se puede trazar qué dispositivo generó qué análisis.

**Solución (Opcional):**
```sql
ALTER TABLE evalImagen.AnalisisImagen
ADD dispositivoID INT NULL;

ALTER TABLE evalImagen.AnalisisImagen
ADD CONSTRAINT FK_AnalisisImagen_Dispositivo
FOREIGN KEY (dispositivoID) REFERENCES evalImagen.Dispositivo(dispositivoID);

CREATE NONCLUSTERED INDEX IDX_AnalisisImagen_Dispositivo
ON evalImagen.AnalisisImagen(dispositivoID, fechaCreacion DESC)
WHERE statusID = 1;
```

**Justificación:**
- Trazabilidad completa del flujo de datos
- Permite reportes por dispositivo
- Útil para debugging y soporte

---

### 8. Historial de Cambios en UmbralLuz

**Problema:**
- No hay historial de cambios en `UmbralLuz`.
- Si se modifica un umbral, se pierde el valor anterior.

**Solución (Opcional):**
```sql
CREATE TABLE evalImagen.UmbralLuzHistorial (
    historialID INT IDENTITY(1,1) NOT NULL,
    umbralID INT NOT NULL,
    minPorcentajeLuz DECIMAL(5,2) NOT NULL,
    maxPorcentajeLuz DECIMAL(5,2) NOT NULL,
    descripcion NVARCHAR(500) NULL,
    activo BIT NOT NULL,
    usuarioModificoID INT NULL,
    fechaModificacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_UmbralLuzHistorial PRIMARY KEY (historialID),
    CONSTRAINT FK_UmbralLuzHistorial_Umbral
        FOREIGN KEY (umbralID) REFERENCES evalImagen.UmbralLuz(umbralID)
);
```

**Justificación:**
- Auditoría completa de cambios
- Permite rollback si es necesario
- Útil para análisis histórico

---

## 📊 Resumen de Prioridades

| Prioridad | Mejora | Impacto | Esfuerzo | Recomendación |
|-----------|--------|---------|----------|---------------|
| 🔴 Alta | Eliminar FK circular | Alto | Medio | ✅ Implementar |
| 🔴 Alta | Agregar índices | Alto | Bajo | ✅ Implementar |
| 🟡 Media | Validación email | Medio | Bajo | ✅ Considerar |
| 🟡 Media | Documentar variedadID NULL | Medio | Muy Bajo | ✅ Implementar |
| 🟢 Baja | Tabla MensajeDestinatario | Bajo | Alto | ⚠️ Solo si se necesita |
| 🟢 Baja | Relación Dispositivo | Bajo | Medio | ⚠️ Solo si se necesita |
| 🟢 Baja | Historial UmbralLuz | Bajo | Alto | ⚠️ Solo si se necesita |

---

## 🎯 Conclusión

El schema actual está **bien diseñado** y sigue buenas prácticas. Las mejoras propuestas son principalmente:

1. **Optimizaciones de rendimiento** (índices)
2. **Simplificación del modelo** (eliminar FK circular)
3. **Mejoras de validación** (email)
4. **Documentación** (comportamiento de campos NULL)

Las mejoras de prioridad baja son opcionales y dependen de requisitos futuros de negocio.

---

## 📝 Notas de Implementación

- Todas las mejoras deben probarse en ambiente de desarrollo primero.
- Actualizar código backend si se elimina `Alerta.mensajeID`.
- Crear scripts de migración para cambios estructurales.
- Documentar cambios en `CHANGELOG.md` o similar.

