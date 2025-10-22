# 🔧 Habilitar SQL Server Authentication (Mixed Mode)

## ❌ Error Actual:
```
Login failed for user 'agricola_app'
```

## 🎯 Solución: Habilitar "Mixed Mode" en SQL Server

### **Opción 1: Desde SSMS (SQL Server Management Studio)** ⭐ Recomendado

1. Abrir **SQL Server Management Studio (SSMS)**
2. Conectar a `localhost\SQLEXPRESS` (Windows Authentication)
3. Click **derecho** en el servidor (en el Object Explorer) → **Properties**
4. Ir a la página **Security**
5. En "Server authentication" seleccionar:
   - ✅ **SQL Server and Windows Authentication mode**
6. Click **OK**
7. **IMPORTANTE**: Reiniciar el servicio SQL Server:
   - Click derecho en el servidor → Restart
   - O desde PowerShell (como admin):
     ```powershell
     Restart-Service MSSQL$SQLEXPRESS
     ```

8. Probar nuevamente: `node test-sql-auth.js`

---

### **Opción 2: Desde PowerShell** (Automático)

Ejecutar como Administrador:

```powershell
# 1. Habilitar Mixed Mode en el registro
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQLServer' -Name 'LoginMode' -Value 2

# 2. Reiniciar SQL Server
Restart-Service MSSQL$SQLEXPRESS

# 3. Verificar
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQLServer' -Name 'LoginMode'
```

**Notas:**
- `LoginMode = 1`: Solo Windows Authentication
- `LoginMode = 2`: Mixed Mode (Windows + SQL Server)
- Si tu versión de SQL es diferente, cambia `MSSQL16` por la que corresponda:
  - SQL 2022: MSSQL16
  - SQL 2019: MSSQL15
  - SQL 2017: MSSQL14

---

### **Opción 3: Desde T-SQL** (No funciona para cambiar modo de autenticación)

⚠️ SQL Server **NO permite cambiar el modo de autenticación** via T-SQL. Debe hacerse desde SSMS o el registro de Windows.

---

## ✅ Una vez habilitado:

1. Reiniciar SQL Server
2. Probar: `node test-sql-auth.js`
3. Deberías ver: **✅ TODO FUNCIONA PERFECTAMENTE!**
4. Luego actualizar `src/lib/db.ts` para usar SQL Authentication
5. Probar Next.js: `http://localhost:3000/api/test-db`

---

## 🔐 Credenciales creadas:

- **Usuario**: `agricola_app`
- **Password**: `Agricola2024!`
- **Permisos**: Read/Write en `AgricolaDB`

---

## 📝 Siguiente paso:

```powershell
# Ejecutar como Administrador:
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQLServer' -Name 'LoginMode' -Value 2
Restart-Service MSSQL$SQLEXPRESS
```

Luego probar:
```powershell
node test-sql-auth.js
```

¡Deberías ver ✅ CONEXIÓN EXITOSA!

