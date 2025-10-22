# 🔧 Solución: Error de Conexión SQL Server

## ❌ Error Actual:
```
"Failed to connect to localhost\\SQLEXPRESS in 15000ms"
```

## 🔍 Causa:
SQL Server Express por defecto **NO tiene TCP/IP habilitado**. Solo permite conexiones locales por Named Pipes.

## ✅ SOLUCIÓN RÁPIDA (2 opciones):

### **Opción 1: Usar Named Pipes en lugar de TCP/IP** (Más rápido)

Modificar `src/lib/db.ts`:

```typescript
const config: sql.config = {
  server: 'localhost\\SQLEXPRESS',  // Sin puerto
  database: process.env.SQL_DATABASE || 'AgricolaDB',
  
  // Autenticación Windows
  options: {
    trustedConnection: true,
    trustServerCertificate: true,
    enableArithAbort: true,
    encrypt: false,
    // NUEVO: Usar Named Pipes en lugar de TCP/IP
    instanceName: 'SQLEXPRESS',  // Añadir esto
  },
  
  // NO especificar puerto para Named Pipes
  // pool: { ... }
};
```

### **Opción 2: Habilitar TCP/IP en SQL Server** (Producción)

#### Paso 1: Abrir SQL Server Configuration Manager
1. Presiona `Win + R`
2. Escribe: `SQLServerManager16.msc` (o `SQLServerManager15.msc`)
3. Enter

#### Paso 2: Habilitar TCP/IP
1. Ir a: **SQL Server Network Configuration** → **Protocols for SQLEXPRESS**
2. Click derecho en **TCP/IP** → **Enable**
3. Click derecho en **TCP/IP** → **Properties**
4. Tab **IP Addresses**
5. Ir a **IPAll** al final
6. Configurar:
   - **TCP Dynamic Ports**: (dejar vacío)
   - **TCP Port**: `1433`
7. Click **OK**

#### Paso 3: Reiniciar SQL Server
1. Ir a: **SQL Server Services**
2. Click derecho en **SQL Server (SQLEXPRESS)**
3. **Restart**

---

## 🚀 SOLUCIÓN INMEDIATA (Usar Opción 1)

Voy a modificar el archivo ahora para usar Named Pipes...

