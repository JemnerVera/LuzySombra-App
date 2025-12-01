-- =====================================================
-- Script: Crear Mensaje Consolidado Real
-- Descripción: Crea un mensaje consolidado similar al que genera
--              el sistema cuando consolida alertas por fundo
-- Fecha: 2025-11-19
-- Autor: Sistema LuzSombra
-- =====================================================

USE BD_PACKING_AGROMIGIVA_DESA;
GO

-- Verificar que existe el contacto
IF NOT EXISTS (SELECT 1 FROM image.Contacto WHERE email = 'jemner.vera@agricolaandrea.com' AND activo = 1)
BEGIN
    PRINT '⚠️ No existe contacto jemner.vera@agricolaandrea.com. Ejecuta primero: insertar_contacto_jemner.sql';
    RETURN;
END
GO

-- Obtener alertas reales sin mensaje para crear un mensaje consolidado
DECLARE @fundoID VARCHAR(4);
DECLARE @fundoNombre NVARCHAR(200);
DECLARE @alertasCount INT;

-- Buscar alertas sin mensaje para obtener fundo
SELECT TOP 1
    @fundoID = RTRIM(COALESCE(le.fundoID, CAST(f.farmID AS VARCHAR))),
    @fundoNombre = f.Description,
    @alertasCount = COUNT(*)
FROM image.Alerta a
INNER JOIN image.LoteEvaluacion le ON a.loteEvaluacionID = le.loteEvaluacionID
LEFT JOIN GROWER.STAGE s ON le.sectorID = s.stageID
LEFT JOIN GROWER.FARMS f ON COALESCE(le.fundoID, s.farmID) = f.farmID
WHERE a.estado IN ('Pendiente', 'Enviada')
    AND a.statusID = 1
    AND a.mensajeID IS NULL
    AND COALESCE(le.fundoID, f.farmID) IS NOT NULL
GROUP BY RTRIM(COALESCE(le.fundoID, CAST(f.farmID AS VARCHAR))), f.Description
ORDER BY COUNT(*) DESC;

-- Si no hay alertas, usar datos de ejemplo
IF @fundoID IS NULL
BEGIN
    SET @fundoID = 'VAL';
    SET @fundoNombre = 'FDO. VALERIE';
    SET @alertasCount = 2;
    PRINT '⚠️ No se encontraron alertas sin mensaje. Usando datos de ejemplo para fundo VAL';
END
ELSE
BEGIN
    PRINT '✅ Se encontraron ' + CAST(@alertasCount AS VARCHAR) + ' alerta(s) para fundo ' + @fundoID;
END
GO

-- Crear mensaje consolidado con datos reales o de ejemplo
DECLARE @mensajeID INT;
DECLARE @fundoID VARCHAR(4) = 'VAL';
DECLARE @fundoNombre NVARCHAR(200) = 'FDO. VALERIE';
DECLARE @destinatarios NVARCHAR(MAX) = '["jemner.vera@agricolaandrea.com"]';
DECLARE @asunto NVARCHAR(500) = '🚨 Resumen de Alertas - Fundo: ' + @fundoNombre;
DECLARE @cuerpoHTML NVARCHAR(MAX);
DECLARE @cuerpoTexto NVARCHAR(MAX);

-- Generar HTML consolidado
SET @cuerpoHTML = '
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 800px; margin: 0 auto; padding: 20px; }
    .header { background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
    .summary { margin: 20px 0; }
    .alert-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    .alert-table th, .alert-table td { 
      padding: 12px; 
      text-align: left; 
      border-bottom: 1px solid #ddd; 
    }
    .alert-table th { background-color: #f9fafb; font-weight: bold; }
    .alert-table tr:hover { background-color: #f9fafb; }
    .critica { color: #dc2626; font-weight: bold; }
    .advertencia { color: #f59e0b; font-weight: bold; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>🚨 Resumen de Alertas - Fundo: ' + @fundoNombre + '</h2>
      <p><strong>Total de alertas:</strong> 2</p>
      <p><strong>Críticas:</strong> <span class="critica">1</span> | 
         <strong>Advertencias:</strong> <span class="advertencia">1</span></p>
    </div>

    <table class="alert-table">
      <thead>
        <tr>
          <th>Lote</th>
          <th>Sector</th>
          <th>Tipo</th>
          <th>% Luz</th>
          <th>Severidad</th>
          <th>Fecha</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>LOTE-001</td>
          <td>Sector A</td>
          <td class="critica">🚨 Crítica</td>
          <td><strong>25.50%</strong></td>
          <td>Critica</td>
          <td>' + CONVERT(VARCHAR, DATEADD(day, -1, GETDATE()), 120) + '</td>
        </tr>
        <tr>
          <td>LOTE-002</td>
          <td>Sector B</td>
          <td class="advertencia">⚠️ Advertencia</td>
          <td><strong>35.75%</strong></td>
          <td>Advertencia</td>
          <td>' + CONVERT(VARCHAR, DATEADD(day, -1, GETDATE()), 120) + '</td>
        </tr>
      </tbody>
    </table>

    <div class="footer">
      <p>Este es un mensaje automático consolidado del sistema de alertas de evaluación de luz.</p>
      <p>Por favor, revisa los lotes afectados y toma las acciones necesarias.</p>
    </div>
  </div>
</body>
</html>
';

-- Generar texto plano
SET @cuerpoTexto = '
🚨 Resumen de Alertas - Fundo: ' + @fundoNombre + '

Total de alertas: 2
Críticas: 1 | Advertencias: 1

Detalle por lote:
' + REPLICATE('=', 80) + '

Lote: LOTE-001
Sector: Sector A
Tipo: 🚨 Crítica
% Luz: 25.50%
Severidad: Critica
Fecha: ' + CONVERT(VARCHAR, DATEADD(day, -1, GETDATE()), 120) + '

' + REPLICATE('-', 80) + '

Lote: LOTE-002
Sector: Sector B
Tipo: ⚠️ Advertencia
% Luz: 35.75%
Severidad: Advertencia
Fecha: ' + CONVERT(VARCHAR, DATEADD(day, -1, GETDATE()), 120) + '

' + REPLICATE('=', 80) + '

Este es un mensaje automático consolidado del sistema de alertas de evaluación de luz.
Por favor, revisa los lotes afectados y toma las acciones necesarias.

Sistema de Alertas LuzSombra
Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);

-- Insertar mensaje consolidado
INSERT INTO image.Mensaje (
    alertaID,
    fundoID,
    tipoMensaje,
    asunto,
    cuerpoHTML,
    cuerpoTexto,
    destinatarios,
    destinatariosCC,
    destinatariosBCC,
    estado,
    intentosEnvio,
    fechaCreacion,
    statusID
)
VALUES (
    NULL, -- alertaID (NULL porque es mensaje consolidado)
    @fundoID,
    'Email',
    @asunto,
    @cuerpoHTML,
    @cuerpoTexto,
    @destinatarios,
    NULL, -- destinatariosCC
    NULL, -- destinatariosBCC
    'Pendiente',
    0,
    GETDATE(),
    1
);

SET @mensajeID = SCOPE_IDENTITY();

PRINT '';
PRINT '✅ Mensaje consolidado creado exitosamente';
PRINT '   MensajeID: ' + CAST(@mensajeID AS VARCHAR);
PRINT '   Fundo: ' + @fundoNombre + ' (' + @fundoID + ')';
PRINT '   Destinatario: jemner.vera@agricolaandrea.com';
PRINT '   Estado: Pendiente';
PRINT '   Total alertas en mensaje: 2 (1 crítica, 1 advertencia)';
PRINT '';
PRINT '📧 Para enviar el mensaje, ejecuta:';
PRINT '   POST http://localhost:3001/api/alertas/enviar/' + CAST(@mensajeID AS VARCHAR);
PRINT '   O: POST http://localhost:3001/api/alertas/enviar (envía todos los pendientes)';
GO

