# 📋 Plan de Migración: Google Sheets → SQL Server

## 🔍 **Análisis de la App Actual**

### **Cómo funciona actualmente:**

La app tiene 3 funcionalidades principales que usan Google Sheets:

#### **1. Datos de Campo (Jerarquía Organizacional)** 📊
- **API**: `/api/google-sheets/field-data`
- **Hook**: `useFieldData.ts`
- **Service**: `googleSheetsService.getFieldData()`
- **Hoja**: `Data-campo` (columnas B-I)
- **Datos**: Empresa, Fundo, Sector, Lote (jerarquía en cascada)
- **Uso**: Dropdowns/selectores en formulario de análisis de imágenes

#### **2. Historial de Análisis** 📜
- **API**: `/api/historial`
- **Service**: `googleSheetsService.getHistorial()`
- **Hoja**: `Data-app` (últimas 500 filas)
- **Datos**: Todos los análisis de imágenes procesadas
- **Uso**: Tabla de historial, ver análisis anteriores

#### **3. Guardar Resultados de Análisis** 💾
- **API**: `/api/procesar-imagen` (POST)
- **Service**: `googleSheetsService.saveProcessingResult()`
- **Hoja**: `Data-app` (append nueva fila)
- **Datos**: Guarda cada nuevo análisis de imagen
- **Campos**: ID, Fecha, Hora, Imagen, Empresa, Fundo, Sector, Lote, Hilera, Planta, Lat/Lng, %Luz, %Sombra, etc.

---

## ✅ **Estado Actual de SQL Server**

### **Tablas ya pobladas:**
- ✅ `image.pais` (1)
- ✅ `image.empresa` (5)
- ✅ `image.fundo` (12)
- ✅ `image.sector` (270)
- ✅ `image.lote` (509)
- ✅ `image.usuario` (3)
- ✅ `image.estado_fenologico` (9)
- ✅ `image.tipo_alerta` (7)

### **Tablas vacías (se llenarán con la app):**
- ⏳ `image.analisis_imagen` - Para guardar resultados de análisis
- ⏳ `image.registro_fenologia` - Para datos fenológicos
- ⏳ `image.historial_alerta` - Para alertas generadas
- ⏳ `image.mensaje` - Para comunicación

---

## 🎯 **Plan de Migración (3 fases)**

### **FASE 1: Crear servicio de SQL Server** (sin afectar la app) ✅

**Archivos a crear:**
1. ✅ `lib/db.ts` - Conexión a SQL Server
2. ✅ `lib/sqlServerService.ts` - Servicio equivalente a googleSheetsService
3. ✅ `app/api/test-db/route.ts` - Test de conexión

**Tareas:**
- [x] Instalar `mssql` y tipos
- [x] Crear utilidad de conexión
- [ ] Crear servicio con métodos:
  - `getFieldData()` - Leer jerarquía desde SQL
  - `getHistorial()` - Leer análisis desde SQL
  - `saveAnalisisResult()` - Guardar nuevo análisis
- [ ] Probar conexión

### **FASE 2: Modo híbrido** (Google Sheets + SQL Server en paralelo)

**Objetivo**: Guardar en ambos lados simultáneamente para pruebas

**Modificar:**
1. `src/app/api/procesar-imagen/route.ts`
   - Guardar en Google Sheets (mantener actual)
   - **Y TAMBIÉN** guardar en SQL Server (`image.analisis_imagen`)
   - Si SQL falla, continuar con Google Sheets

**Ventajas:**
- ✅ No se pierde funcionalidad existente
- ✅ Podemos comparar resultados
- ✅ Transición segura

### **FASE 3: Migración completa** (solo SQL Server)

**Modificar todos los endpoints para usar SQL Server:**

1. **`/api/google-sheets/field-data` → `/api/field-data`**
   - Cambiar a leer desde SQL Server
   - Usar vista `image.v_jerarquia_completa`

2. **`/api/historial`**
   - Cambiar a leer desde `image.analisis_imagen`

3. **`/api/procesar-imagen`**
   - Guardar solo en SQL Server
   - Remover llamada a Google Sheets

4. **Frontend (opcional)**
   - Actualizar URLs de API si cambian
   - Mantener la misma estructura de datos

---

## 🔧 **Implementación Detallada**

### **1. Crear `lib/sqlServerService.ts`**

```typescript
import { query } from './db';

export interface FieldDataSQL {
  empresa: string[];
  fundo: string[];
  sector: string[];
  lote: string[];
  hierarchical: Record<string, Record<string, Record<string, string[]>>>;
}

export interface AnalisisImagenSQL {
  analisisid: number;
  loteid: number;
  hilera: string;
  planta: string;
  filename: string;
  porcentaje_luz: number;
  porcentaje_sombra: number;
  fecha_captura: Date;
  latitud: number | null;
  longitud: number | null;
  // ... más campos
}

class SQLServerService {
  // 1. Obtener datos de campo (jerarquía)
  async getFieldData(): Promise<FieldDataSQL> {
    // Query a la vista v_jerarquia_completa
    const rows = await query(`
      SELECT 
        empresabrev as empresa,
        fundobrev as fundo,
        sectorbrev as sector,
        lotebrev as lote
      FROM image.v_jerarquia_completa
      ORDER BY empresa, fundo, sector, lote
    `);
    
    // Procesar igual que Google Sheets
    return this.processFieldData(rows);
  }

  // 2. Obtener historial
  async getHistorial() {
    const rows = await query(`
      SELECT TOP 500
        a.analisisid as id,
        FORMAT(a.fecha_captura, 'yyyy-MM-dd') as fecha,
        FORMAT(a.fecha_captura, 'HH:mm:ss') as hora,
        a.filename as imagen,
        a.filename as nombre_archivo,
        e.empresa,
        f.fundo,
        s.sector,
        l.lote,
        a.hilera,
        a.planta as numero_planta,
        a.latitud,
        a.longitud,
        a.porcentaje_luz,
        a.porcentaje_sombra,
        FORMAT(a.datecreated, 'yyyy-MM-ddTHH:mm:ssZ') as timestamp
      FROM image.analisis_imagen a
      INNER JOIN image.lote l ON a.loteid = l.loteid
      INNER JOIN image.sector s ON l.sectorid = s.sectorid
      INNER JOIN image.fundo f ON s.fundoid = f.fundoid
      INNER JOIN image.empresa e ON f.empresaid = e.empresaid
      WHERE a.statusid = 1
      ORDER BY a.fecha_captura DESC
    `);
    
    return {
      success: true,
      procesamientos: rows
    };
  }

  // 3. Guardar resultado de análisis
  async saveAnalisisResult(data: {
    fileName: string;
    hilera: string;
    numero_planta: string;
    porcentaje_luz: number;
    porcentaje_sombra: number;
    empresa: string;
    fundo: string;
    sector: string;
    lote: string;
    latitud: number | null;
    longitud: number | null;
    processed_image: string;
    fecha_captura?: Date;
    usercreatedid?: number;
  }) {
    // 1. Obtener loteid desde jerarquía
    const loteResult = await query<{loteid: number}>(`
      SELECT l.loteid
      FROM image.lote l
      INNER JOIN image.sector s ON l.sectorid = s.sectorid
      INNER JOIN image.fundo f ON s.fundoid = f.fundoid
      INNER JOIN image.empresa e ON f.empresaid = e.empresaid
      WHERE e.empresabrev = @empresa
        AND f.fundobrev = @fundo
        AND s.sectorbrev = @sector
        AND l.lotebrev = @lote
    `, {
      empresa: data.empresa,
      fundo: data.fundo,
      sector: data.sector,
      lote: data.lote
    });

    if (loteResult.length === 0) {
      throw new Error(`Lote no encontrado: ${data.empresa}/${data.fundo}/${data.sector}/${data.lote}`);
    }

    const loteid = loteResult[0].loteid;

    // 2. Insertar análisis
    await query(`
      INSERT INTO image.analisis_imagen (
        loteid, hilera, planta, filename,
        porcentaje_luz, porcentaje_sombra,
        fecha_captura, latitud, longitud,
        processed_image_url,
        usercreatedid, statusid
      )
      VALUES (
        @loteid, @hilera, @planta, @filename,
        @luz, @sombra,
        @fecha_captura, @latitud, @longitud,
        @processed_image,
        @userid, 1
      )
    `, {
      loteid,
      hilera: data.hilera,
      planta: data.numero_planta,
      filename: data.fileName,
      luz: data.porcentaje_luz,
      sombra: data.porcentaje_sombra,
      fecha_captura: data.fecha_captura || new Date(),
      latitud: data.latitud,
      longitud: data.longitud,
      processed_image: data.processed_image,
      userid: data.usercreatedid || 1 // Default: system user
    });

    console.log('✅ Análisis guardado en SQL Server');
  }

  private processFieldData(rows: any[]): FieldDataSQL {
    // Igual que googleSheetsService.processFieldData()
    // ...
  }
}

export const sqlServerService = new SQLServerService();
```

### **2. Modificar `/api/procesar-imagen/route.ts` (Modo Híbrido)**

```typescript
// ... imports existentes
import { sqlServerService } from '../../../lib/sqlServerService'; // NUEVO

export async function POST(request: NextRequest) {
  try {
    // ... código existente hasta processingResult ...

    // === GUARDAR EN GOOGLE SHEETS (mantener actual) ===
    try {
      await googleSheetsService.saveProcessingResult(processingResult);
      console.log('✅ Guardado en Google Sheets');
    } catch (sheetsError) {
      console.error('⚠️ Error guardando en Google Sheets:', sheetsError);
    }

    // === NUEVO: TAMBIÉN GUARDAR EN SQL SERVER ===
    try {
      await sqlServerService.saveAnalisisResult({
        fileName: processingResult.fileName,
        hilera: processingResult.hilera,
        numero_planta: processingResult.numero_planta,
        porcentaje_luz: processingResult.porcentaje_luz,
        porcentaje_sombra: processingResult.porcentaje_sombra,
        empresa: processingResult.empresa,
        fundo: processingResult.fundo,
        sector: processingResult.sector,
        lote: processingResult.lote,
        latitud: processingResult.latitud,
        longitud: processingResult.longitud,
        processed_image: processingResult.processed_image,
        fecha_captura: new Date(),
        usercreatedid: 1 // Usuario system por ahora
      });
      console.log('✅ Guardado en SQL Server');
    } catch (sqlError) {
      console.error('⚠️ Error guardando en SQL Server:', sqlError);
      // No fallar si SQL falla, continuar con Google Sheets
    }

    return NextResponse.json(processingResult);
  } catch (error) {
    // ... manejo de errores
  }
}
```

---

## 🧪 **Plan de Pruebas**

### **Fase 1: Test de conexión**
```bash
# 1. Instalar dependencias
npm install

# 2. Iniciar app
npm run dev

# 3. Probar conexión
http://localhost:3000/api/test-db
```

**Resultado esperado:**
```json
{
  "success": true,
  "counts": {
    "paises": 1,
    "empresas": 5,
    "fundos": 12,
    "sectores": 270,
    "lotes": 509,
    "usuarios": 3
  }
}
```

### **Fase 2: Test modo híbrido**
1. Subir una imagen de prueba
2. Verificar que se guarda en Google Sheets (actual)
3. **NUEVO**: Verificar que también se guarda en SQL Server
4. Comparar datos en ambos lados

### **Fase 3: Test migración completa**
1. Cambiar APIs a SQL Server
2. Probar todas las funcionalidades
3. Verificar que dropdowns funcionan (jerarquía)
4. Verificar que historial se muestra
5. Verificar que se guardan nuevos análisis

---

## 📊 **Mapeo de Datos**

### **Google Sheets → SQL Server**

| Google Sheets | SQL Server | Notas |
|---------------|------------|-------|
| `Data-campo` Col B (Empresa) | `image.empresa.empresabrev` | Match por abreviatura |
| `Data-campo` Col D (Fundo) | `image.fundo.fundobrev` | Match por abreviatura |
| `Data-campo` Col G (Sector) | `image.sector.sectorbrev` | Match por abreviatura |
| `Data-campo` Col I (Lote) | `image.lote.lotebrev` | Match por abreviatura |
| `Data-app` Fila N (ID) | `image.analisis_imagen.analisisid` | Auto-increment |
| `Data-app` Col N (%Luz) | `image.analisis_imagen.porcentaje_luz` | DECIMAL(5,2) |
| `Data-app` Col O (%Sombra) | `image.analisis_imagen.porcentaje_sombra` | DECIMAL(5,2) |
| `Data-app` Col J (Hilera) | `image.analisis_imagen.hilera` | NVARCHAR(50) |
| `Data-app` Col K (Planta) | `image.analisis_imagen.planta` | NVARCHAR(50) |

---

## ⚠️ **Consideraciones Importantes**

### **1. Abreviaturas vs Nombres Completos**
- Google Sheets usa **abreviaturas** (ej: "AGA", "CAL", "H01")
- SQL Server también tiene abreviaturas en campos `*brev`
- **Importante**: Hacer match por `empresabrev`, `fundobrev`, etc.

### **2. Usuario actual**
- Por ahora usar `usercreatedid = 1` (usuario system)
- En el futuro: implementar login y usar usuario real

### **3. Imágenes procesadas**
- Campo `processed_image_url` en SQL es NVARCHAR(MAX)
- Puede almacenar Base64 (como Google Sheets) o URL

### **4. Cache**
- Google Sheets tiene cache de 5 minutos
- SQL Server puede tener cache similar o ser en tiempo real

---

## 🚀 **Siguiente Paso Inmediato**

1. **Probar conexión a SQL Server:**
   ```bash
   npm run dev
   # Visitar: http://localhost:3000/api/test-db
   ```

2. **Si funciona**, crear `lib/sqlServerService.ts`

3. **Implementar modo híbrido** en `/api/procesar-imagen`

4. **Probar con imagen real**

¿Listo para empezar?

