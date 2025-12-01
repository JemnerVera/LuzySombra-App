import express, { Request, Response } from 'express';
import { umbralService } from '../services/umbralService';

const router = express.Router();

/**
 * GET /api/umbrales
 * Obtiene todos los umbrales activos
 * Query params:
 *   - includeInactive: incluir inactivos (default: false)
 *   - tipo: filtrar por tipo (CriticoRojo, CriticoAmarillo, Normal)
 *   - variedadID: filtrar por variedad (null para globales)
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const includeInactive = req.query.includeInactive === 'true';
    const tipo = req.query.tipo as 'CriticoRojo' | 'CriticoAmarillo' | 'Normal' | undefined;
    const variedadID = req.query.variedadID ? parseInt(req.query.variedadID as string) : undefined;

    let umbrales;
    if (tipo) {
      umbrales = await umbralService.getUmbralesByTipo(tipo);
    } else if (variedadID !== undefined) {
      umbrales = await umbralService.getUmbralesByVariedad(variedadID);
    } else {
      umbrales = await umbralService.getAllUmbrales(includeInactive);
    }

    res.json({
      success: true,
      data: umbrales,
      total: umbrales.length
    });
  } catch (error) {
    console.error('❌ Error obteniendo umbrales:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/umbrales/:id
 * Obtiene un umbral por ID
 */
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const umbralID = parseInt(req.params.id);
    
    if (isNaN(umbralID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de umbral inválido'
      });
    }

    const umbral = await umbralService.getUmbralById(umbralID);
    
    if (!umbral) {
      return res.status(404).json({
        success: false,
        error: 'Umbral no encontrado'
      });
    }

    res.json({
      success: true,
      data: umbral
    });
  } catch (error) {
    console.error('❌ Error obteniendo umbral:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/umbrales
 * Crea un nuevo umbral
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const {
      variedadID,
      tipo,
      minPorcentajeLuz,
      maxPorcentajeLuz,
      descripcion,
      colorHex,
      orden,
      activo,
      usuarioCreaID
    } = req.body;

    // Validaciones
    if (!tipo || !['CriticoRojo', 'CriticoAmarillo', 'Normal'].includes(tipo)) {
      return res.status(400).json({
        success: false,
        error: 'Tipo de umbral inválido. Debe ser: CriticoRojo, CriticoAmarillo o Normal'
      });
    }

    if (minPorcentajeLuz === undefined || maxPorcentajeLuz === undefined) {
      return res.status(400).json({
        success: false,
        error: 'minPorcentajeLuz y maxPorcentajeLuz son requeridos'
      });
    }

    if (usuarioCreaID === undefined) {
      return res.status(400).json({
        success: false,
        error: 'usuarioCreaID es requerido'
      });
    }

    const umbralID = await umbralService.createUmbral({
      variedadID: variedadID || null,
      tipo,
      minPorcentajeLuz: parseFloat(minPorcentajeLuz),
      maxPorcentajeLuz: parseFloat(maxPorcentajeLuz),
      descripcion: descripcion || null,
      colorHex: colorHex || null,
      orden: orden || 0,
      activo: activo !== undefined ? activo : true,
      usuarioCreaID: parseInt(usuarioCreaID)
    });

    res.status(201).json({
      success: true,
      data: { umbralID },
      message: 'Umbral creado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error creando umbral:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * PUT /api/umbrales/:id
 * Actualiza un umbral existente
 */
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const umbralID = parseInt(req.params.id);
    
    if (isNaN(umbralID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de umbral inválido'
      });
    }

    const {
      variedadID,
      tipo,
      minPorcentajeLuz,
      maxPorcentajeLuz,
      descripcion,
      colorHex,
      orden,
      activo,
      usuarioModificaID
    } = req.body;

    if (usuarioModificaID === undefined) {
      return res.status(400).json({
        success: false,
        error: 'usuarioModificaID es requerido'
      });
    }

    if (tipo && !['CriticoRojo', 'CriticoAmarillo', 'Normal'].includes(tipo)) {
      return res.status(400).json({
        success: false,
        error: 'Tipo de umbral inválido. Debe ser: CriticoRojo, CriticoAmarillo o Normal'
      });
    }

    const updateData: any = {
      usuarioModificaID: parseInt(usuarioModificaID)
    };

    if (variedadID !== undefined) updateData.variedadID = variedadID || null;
    if (tipo !== undefined) updateData.tipo = tipo;
    if (minPorcentajeLuz !== undefined) updateData.minPorcentajeLuz = parseFloat(minPorcentajeLuz);
    if (maxPorcentajeLuz !== undefined) updateData.maxPorcentajeLuz = parseFloat(maxPorcentajeLuz);
    if (descripcion !== undefined) updateData.descripcion = descripcion || null;
    if (colorHex !== undefined) updateData.colorHex = colorHex || null;
    if (orden !== undefined) updateData.orden = parseInt(orden);
    if (activo !== undefined) updateData.activo = activo;

    await umbralService.updateUmbral(umbralID, updateData);

    res.json({
      success: true,
      message: 'Umbral actualizado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error actualizando umbral:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * DELETE /api/umbrales/:id
 * Elimina (soft delete) un umbral
 */
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const umbralID = parseInt(req.params.id);
    
    if (isNaN(umbralID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de umbral inválido'
      });
    }

    await umbralService.deleteUmbral(umbralID);

    res.json({
      success: true,
      message: 'Umbral eliminado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error eliminando umbral:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/umbrales/variedades/list
 * Obtiene todas las variedades disponibles
 */
router.get('/variedades/list', async (req: Request, res: Response) => {
  try {
    const variedades = await umbralService.getVariedades();

    res.json({
      success: true,
      data: variedades,
      total: variedades.length
    });
  } catch (error) {
    console.error('❌ Error obteniendo variedades:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

