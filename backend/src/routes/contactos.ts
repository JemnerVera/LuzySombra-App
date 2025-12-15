import express, { Request, Response } from 'express';
import { contactService } from '../services/contactService';
import { query } from '../lib/db';

const router = express.Router();

/**
 * Normaliza fundoID: convierte nombres de fundos a IDs, o maneja valores inválidos
 */
async function normalizeFundoID(fundoID: any): Promise<string | null> {
  if (!fundoID || fundoID === null || String(fundoID).trim() === '' || String(fundoID).trim() === '-') {
    return null;
  }
  
  const fundoIDStr = String(fundoID).trim();
  
  // Si es un nombre de fundo (más de 4 caracteres o contiene espacios), buscar el ID
  if (fundoIDStr.length > 4 || fundoIDStr.includes(' ')) {
    // Es un nombre, buscar el ID correspondiente
    const fundoResult = await query<{ farmID: string }>(`
      SELECT TOP 1 farmID
      FROM GROWER.FARMS
      WHERE Description = @fundoNombre
        AND statusID = 1
    `, { fundoNombre: fundoIDStr });
    
    if (fundoResult.length > 0) {
      return fundoResult[0].farmID.trim();
    } else {
      throw new Error(`No se encontró un fundo con el nombre "${fundoIDStr}"`);
    }
  } else {
    // Es un ID (4 caracteres o menos), usar directamente
    return fundoIDStr;
  }
}

/**
 * GET /api/contactos
 * Obtiene todos los contactos
 * Query params:
 *   - includeInactive: incluir inactivos (default: false)
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const includeInactive = req.query.includeInactive === 'true';

    const contactos = await contactService.getAllContactos(includeInactive);

    res.json({
      success: true,
      data: contactos,
      total: contactos.length
    });
  } catch (error) {
    console.error('❌ Error obteniendo contactos:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * GET /api/contactos/:id
 * Obtiene un contacto por ID
 */
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const contactoID = parseInt(req.params.id);
    
    if (isNaN(contactoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de contacto inválido'
      });
    }

    const contacto = await contactService.getContactoById(contactoID);
    
    if (!contacto) {
      return res.status(404).json({
        success: false,
        error: 'Contacto no encontrado'
      });
    }

    res.json({
      success: true,
      data: contacto
    });
  } catch (error) {
    console.error('❌ Error obteniendo contacto:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/contactos
 * Crea un nuevo contacto
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const {
      nombre,
      email,
      telefono,
      tipo,
      rol,
      recibirAlertasCriticas,
      recibirAlertasAdvertencias,
      recibirAlertasNormales,
      fundoID,
      sectorID,
      prioridad,
      activo,
      usuarioCreaID
    } = req.body;

    // Validaciones
    if (!nombre || !email) {
      return res.status(400).json({
        success: false,
        error: 'nombre y email son requeridos'
      });
    }

    if (!tipo || !['General', 'Admin', 'Agronomo', 'Manager', 'Supervisor', 'Tecnico', 'Otro'].includes(tipo)) {
      return res.status(400).json({
        success: false,
        error: 'Tipo de contacto inválido'
      });
    }

    if (usuarioCreaID === undefined) {
      return res.status(400).json({
        success: false,
        error: 'usuarioCreaID es requerido'
      });
    }

    // Normalizar fundoID si se proporciona
    const fundoIDNormalized = fundoID !== undefined ? await normalizeFundoID(fundoID) : null;
    
    const contactoID = await contactService.createContacto({
      nombre,
      email,
      telefono: telefono || null,
      tipo,
      rol: rol || null,
      recibirAlertasCriticas: recibirAlertasCriticas !== false,
      recibirAlertasAdvertencias: recibirAlertasAdvertencias !== false,
      recibirAlertasNormales: recibirAlertasNormales === true,
      fundoID: fundoIDNormalized,
      sectorID: sectorID || null,
      prioridad: prioridad || 0,
      activo: activo !== false,
      usuarioCreaID: parseInt(usuarioCreaID)
    });

    res.status(201).json({
      success: true,
      data: { contactoID },
      message: 'Contacto creado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error creando contacto:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * PUT /api/contactos/:id
 * Actualiza un contacto existente
 */
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const contactoID = parseInt(req.params.id);
    
    if (isNaN(contactoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de contacto inválido'
      });
    }

    const {
      nombre,
      email,
      telefono,
      tipo,
      rol,
      recibirAlertasCriticas,
      recibirAlertasAdvertencias,
      recibirAlertasNormales,
      fundoID,
      sectorID,
      prioridad,
      activo,
      usuarioModificaID
    } = req.body;

    if (usuarioModificaID === undefined) {
      return res.status(400).json({
        success: false,
        error: 'usuarioModificaID es requerido'
      });
    }

    if (tipo && !['General', 'Admin', 'Agronomo', 'Manager', 'Supervisor', 'Tecnico', 'Otro'].includes(tipo)) {
      return res.status(400).json({
        success: false,
        error: 'Tipo de contacto inválido'
      });
    }

    const updateData: any = {
      usuarioModificaID: parseInt(usuarioModificaID)
    };

    if (nombre !== undefined) updateData.nombre = nombre;
    if (email !== undefined) updateData.email = email;
    if (telefono !== undefined) updateData.telefono = telefono || null;
    if (tipo !== undefined) updateData.tipo = tipo;
    if (rol !== undefined) updateData.rol = rol || null;
    if (recibirAlertasCriticas !== undefined) updateData.recibirAlertasCriticas = recibirAlertasCriticas;
    if (recibirAlertasAdvertencias !== undefined) updateData.recibirAlertasAdvertencias = recibirAlertasAdvertencias;
    if (recibirAlertasNormales !== undefined) updateData.recibirAlertasNormales = recibirAlertasNormales;
    if (fundoID !== undefined) {
      // Normalizar fundoID: convertir "-", string vacío o solo espacios a null
      // También convertir nombres de fundos a IDs si es necesario
      const fundoIDNormalized = await normalizeFundoID(fundoID);
      updateData.fundoID = fundoIDNormalized;
    }
    if (sectorID !== undefined) updateData.sectorID = sectorID || null;
    if (prioridad !== undefined) updateData.prioridad = parseInt(prioridad);
    if (activo !== undefined) updateData.activo = activo;

    await contactService.updateContacto(contactoID, updateData);

    res.json({
      success: true,
      message: 'Contacto actualizado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error actualizando contacto:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * DELETE /api/contactos/:id
 * Elimina (soft delete) un contacto
 */
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const contactoID = parseInt(req.params.id);
    
    if (isNaN(contactoID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de contacto inválido'
      });
    }

    await contactService.deleteContacto(contactoID);

    res.json({
      success: true,
      message: 'Contacto eliminado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error eliminando contacto:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;

