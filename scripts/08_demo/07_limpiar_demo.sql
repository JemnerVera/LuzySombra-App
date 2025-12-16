-- =====================================================
-- SCRIPT: Limpiar Demo - Eliminar datos de prueba
-- Base de datos: [CONFIGURAR - Reemplazar con nombre de tu base de datos]
-- Schema: evalImagen
-- Propósito: Limpiar datos de demo (alertas, mensajes, contactos, evaluaciones)
-- ⚠️ ADVERTENCIA: Este script elimina datos. Úsalo con precaución.
-- =====================================================

-- âš ï¸ IMPORTANTE: Reemplazar [TU_BASE_DE_DATOS] con el nombre real de tu base de datos
USE [TU_BASE_DE_DATOS];
GO

PRINT '========================================';
PRINT 'DEMO: Limpiar Datos de Prueba';
PRINT '========================================';
PRINT '';
PRINT '⚠️ ADVERTENCIA: Este script eliminará datos de demo.';
PRINT '   - Alertas de demo';
PRINT '   - Mensajes de demo';
PRINT '   - Contactos de demo (emails @example.com)';
PRINT '   - Evaluaciones de demo (solo las creadas para demo)';
PRINT '';
PRINT '¿Deseas continuar? (Ejecuta este script manualmente)';
PRINT '';

-- =====================================================
-- 1. Eliminar Mensajes de Demo
-- =====================================================
PRINT '1. Eliminando mensajes de demo...';

-- Eliminar mensajes relacionados con alertas de demo
-- (Ajusta los criterios según tus necesidades)
DECLARE @mensajesEliminados INT;

UPDATE evalImagen.mensaje
SET statusID = 0
WHERE statusID = 1
  AND (
      -- Mensajes con asunto que contenga "Demo" o "demo"
      asunto LIKE '%Demo%' OR asunto LIKE '%demo%'
      -- O mensajes creados en las últimas 24 horas (ajusta según necesites)
      OR fechaCreacion >= DATEADD(DAY, -1, GETDATE())
  );

SET @mensajesEliminados = @@ROWCOUNT;
PRINT CONCAT('   ✅ ', @mensajesEliminados, ' mensaje(s) marcado(s) como inactivos');

-- =====================================================
-- 2. Eliminar Alertas de Demo
-- =====================================================
PRINT '';
PRINT '2. Eliminando alertas de demo...';

DECLARE @alertasEliminadas INT;

UPDATE evalImagen.alerta
SET statusID = 0
WHERE statusID = 1
  AND (
      -- Alertas creadas en las últimas 24 horas (ajusta según necesites)
      fechaCreacion >= DATEADD(DAY, -1, GETDATE())
      -- O alertas relacionadas con mensajes eliminados
      OR EXISTS (
          SELECT 1 FROM evalImagen.mensaje m
          WHERE m.alertaID = evalImagen.alerta.alertaID
            AND m.statusID = 0
      )
  );

SET @alertasEliminadas = @@ROWCOUNT;
PRINT CONCAT('   ✅ ', @alertasEliminadas, ' alerta(s) marcada(s) como inactivas');

-- =====================================================
-- 3. Eliminar Contactos de Demo (excepto [TU_EMAIL_DEMO])
-- =====================================================
PRINT '';
PRINT '3. Eliminando contactos de demo...';

DECLARE @contactosEliminados INT;

UPDATE evalImagen.contacto
SET statusID = 0
WHERE statusID = 1
  AND email LIKE '%@example.com'
  AND email != '[TU_EMAIL_DEMO]'; -- NO eliminar contacto real

SET @contactosEliminados = @@ROWCOUNT;
PRINT CONCAT('   ✅ ', @contactosEliminados, ' contacto(s) de demo marcado(s) como inactivos');
PRINT '   ℹ️ Contacto [TU_EMAIL_DEMO] se mantiene activo';

-- =====================================================
-- 4. Eliminar Evaluaciones de Demo (OPCIONAL)
-- =====================================================
PRINT '';
PRINT '4. ¿Eliminar evaluaciones de demo?';
PRINT '   ⚠️ Esto eliminará las evaluaciones creadas para la demo.';
PRINT '   Por defecto, NO se eliminan (solo se marcan como comentario).';
PRINT '   Descomenta el código si deseas eliminarlas.';
PRINT '';

-- Descomenta esto si quieres eliminar evaluaciones de demo:
/*
DECLARE @evaluacionesEliminadas INT;

UPDATE evalImagen.loteEvaluacion
SET statusID = 0
WHERE statusID = 1
  AND fechaUltimaActualizacion >= DATEADD(DAY, -1, GETDATE())
  AND tipoUmbralActual IN ('CriticoRojo', 'CriticoAmarillo');

SET @evaluacionesEliminadas = @@ROWCOUNT;
PRINT CONCAT('   ✅ ', @evaluacionesEliminadas, ' evaluación(es) de demo marcada(s) como inactivas');
*/

-- =====================================================
-- 5. Resumen
-- =====================================================
PRINT '';
PRINT '========================================';
PRINT '✅ Limpieza completada';
PRINT '========================================';
PRINT '';
PRINT 'Resumen:';
PRINT CONCAT('   - Mensajes eliminados: ', @mensajesEliminados);
PRINT CONCAT('   - Alertas eliminadas: ', @alertasEliminadas);
PRINT CONCAT('   - Contactos eliminados: ', @contactosEliminados);
PRINT '';
PRINT 'NOTA: Los datos se marcaron como inactivos (statusID = 0), no se eliminaron físicamente.';
PRINT '      Para eliminarlos físicamente, usa DELETE en lugar de UPDATE.';
PRINT '';
GO

