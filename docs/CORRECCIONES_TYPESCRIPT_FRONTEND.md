# Correcciones TypeScript Frontend - Build CI

## Problema Principal

El backend devuelve respuestas en diferentes formatos:
- Algunas rutas: `{ success: true, data: {...} }`
- Otras rutas: `{ success: true, alertas: [...], totalPages: ... }` (propiedades en raíz)

El tipo `ApiResponse<T>` espera que todo esté en `data`, pero algunas rutas devuelven propiedades directamente.

## Solución

Actualizar el tipo `ApiResponse` para ser más flexible, o corregir todos los accesos en el código.

## Errores a Corregir

1. **AlertasDashboard.tsx**
   - `response.alertas` → `(response.data as any).alertas` o `(response as any).alertas`
   - `response.totalPages` → `(response.data as any).totalPages` o `response.pagination?.totalPages`
   - `response.mensajesCreados` → `(response.data as any).mensajesCreados`

2. **DispositivosManagement.tsx**
   - `response.dispositivos` → `(response.data as any).dispositivos` o `(response as any).dispositivos`
   - `response.apiKey` → `(response.data as any).apiKey` o `(response as any).apiKey`
   - `response.qrCodeUrl` → `(response.data as any).qrCodeUrl` o `(response as any).qrCodeUrl`
   - Remover imports no usados: `Eye`, `EyeOff`, `AlertCircle`
   - Remover variable no usada: `showApiKey`, `setShowApiKey`
   - Corregir `resetForm` para aceptar `MouseEvent`

3. **MensajesConsolidados.tsx**
   - `response.mensajes` → `(response.data as any).mensajes`
   - `response.totalPages` → `response.pagination?.totalPages`
   - `response.exitosos` → `(response.data as any).exitosos`
   - `response.errores` → `(response.data as any).errores`

4. **MensajesEnviados.tsx**
   - `response.mensaje` → `(response.data as any).mensaje`
   - `response.alertas` → `(response.data as any).alertas`

5. **AuthContext.tsx**
   - `response.user` → `(response.data as any).user`
   - `response.token` → `(response.data as any).token`
   - `response.expiresIn` → `(response.data as any).expiresIn`
   - `response.error` → `response.error` (ya está correcto)

6. **useNotifications.ts**
   - `response.nuevasAlertas` → `(response.data as any).nuevasAlertas`
   - `response.timestamp` → `(response.data as any).timestamp`
   - `response.notificaciones` → `(response.data as any).notificaciones`

7. **HistoryTable.tsx**
   - Corregir tipo de filtros
   - Corregir tipo de `exportToCSV`

8. **ImageViewModal.tsx**
   - Agregar import de `LazyImage`

9. **Layout.tsx**
   - Remover import no usado: `Layers`

10. **StatisticsDashboard.tsx**
    - Corregir tipo de `setStatistics`
    - Corregir propiedades de `PieLabelRenderProps`

11. **VirtualizedTable.tsx**
    - Corregir import de `react-window`

12. **main.tsx**
    - Agregar `@types/react-dom` a dependencies

13. **Login.tsx**
    - `response.error` → `response.error` (ya está correcto)

14. **useImageCache.ts**
    - Agregar validación para `undefined`

