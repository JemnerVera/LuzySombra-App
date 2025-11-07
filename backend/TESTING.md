# 🧪 Guía de Testing del Backend

## Prerequisitos

1. **Variables de entorno configuradas**
   - Copiar `.env.example` a `.env`
   - Configurar credenciales de SQL Server

2. **Dependencias instaladas**
   ```bash
   npm install --legacy-peer-deps
   ```

## Ejecutar Tests

### Test Automático
```bash
npm test
```

Este script ejecuta:
- ✅ Verificación de variables de entorno
- ✅ Conexión a SQL Server
- ✅ Test de servicios (fieldData, historial, consolidatedTable)

### Iniciar Servidor
```bash
npm run dev
```

El servidor iniciará en `http://localhost:3001`

## Probar Rutas Manualmente

### 1. Health Check
```bash
curl http://localhost:3001/api/health
```

### 2. Test de Base de Datos
```bash
curl http://localhost:3001/api/test-db
```

### 3. Field Data
```bash
curl http://localhost:3001/api/field-data
```

### 4. Historial
```bash
curl http://localhost:3001/api/historial?page=1&pageSize=10
```

### 5. Tabla Consolidada
```bash
curl http://localhost:3001/api/tabla-consolidada?page=1&pageSize=10
```

### 6. Detalle de Lote
```bash
curl "http://localhost:3001/api/tabla-consolidada/detalle?fundo=VAL&sector=SECTOR 1&lote=1A"
```

### 7. Imagen
```bash
curl http://localhost:3001/api/imagen/1
```

## Solución de Problemas

### Error: Variables de entorno faltantes
**Solución**: Crear archivo `.env` en `backend/` basado en `.env.example`

### Error: No se puede conectar a SQL Server
**Solución**: 
- Verificar que SQL Server esté accesible
- Verificar credenciales en `.env`
- Verificar firewall/red

### Error: Vista vwc_CianamidaFenologia no existe
**Solución**: Esto es normal si no se ha ejecutado el script SQL. No es crítico para probar el backend básico.

### Error: TensorFlow.js-node no se puede instalar
**Solución**: Esto es esperado en Windows sin Visual Studio Build Tools. No es necesario para probar las rutas básicas.

## Estado Esperado

✅ **Funcionando:**
- Health check
- Test de BD
- Field data
- Historial
- Tabla consolidada (si la vista existe)
- Imagen

⏳ **Pendiente:**
- Procesar imagen (requiere TensorFlow)

