import express, { Request, Response } from 'express';
import { userService } from '../services/userService';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();

/**
 * GET /api/usuarios
 * Obtiene todos los usuarios
 */
router.get('/', authenticateToken, async (req: Request, res: Response) => {
  try {
    const usuarios = await userService.getAllUsers();
    res.json({
      success: true,
      data: usuarios
    });
  } catch (error) {
    console.error('❌ Error obteniendo usuarios:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Error obteniendo usuarios'
    });
  }
});

/**
 * GET /api/usuarios/:id
 * Obtiene un usuario por ID
 */
router.get('/:id', authenticateToken, async (req: Request, res: Response) => {
  try {
    const usuarioID = parseInt(req.params.id);
    if (isNaN(usuarioID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de usuario inválido'
      });
    }

    const usuario = await userService.getUserById(usuarioID);
    if (!usuario) {
      return res.status(404).json({
        success: false,
        error: 'Usuario no encontrado'
      });
    }

    res.json({
      success: true,
      data: usuario
    });
  } catch (error) {
    console.error('❌ Error obteniendo usuario:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Error obteniendo usuario'
    });
  }
});

/**
 * POST /api/usuarios
 * Crea un nuevo usuario
 */
router.post('/', authenticateToken, async (req: Request, res: Response) => {
  try {
    const { username, password, email, nombreCompleto, rol, activo } = req.body;
    const usuarioCreaID = (req as any).usuarioID || 1; // TODO: Obtener del token JWT

    if (!username || !password || !email || !rol) {
      return res.status(400).json({
        success: false,
        error: 'Faltan campos requeridos: username, password, email, rol'
      });
    }

    if (!['Admin', 'Agronomo', 'Supervisor', 'Lector'].includes(rol)) {
      return res.status(400).json({
        success: false,
        error: 'Rol inválido. Debe ser: Admin, Agronomo, Supervisor o Lector'
      });
    }

    const usuarioID = await userService.createUser({
      username,
      password,
      email,
      nombreCompleto: nombreCompleto || null,
      rol,
      activo: activo !== undefined ? activo : true,
      usuarioCreaID
    });

    res.status(201).json({
      success: true,
      data: { usuarioID },
      message: 'Usuario creado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error creando usuario:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Error creando usuario'
    });
  }
});

/**
 * PUT /api/usuarios/:id
 * Actualiza un usuario
 */
router.put('/:id', authenticateToken, async (req: Request, res: Response) => {
  try {
    const usuarioID = parseInt(req.params.id);
    if (isNaN(usuarioID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de usuario inválido'
      });
    }

    const { username, password, email, nombreCompleto, rol, activo } = req.body;
    const usuarioModificaID = (req as any).usuarioID || 1; // TODO: Obtener del token JWT

    const updateData: any = { usuarioModificaID };

    if (username !== undefined) updateData.username = username;
    if (password !== undefined) updateData.password = password;
    if (email !== undefined) updateData.email = email;
    if (nombreCompleto !== undefined) updateData.nombreCompleto = nombreCompleto;
    if (rol !== undefined) {
      if (!['Admin', 'Agronomo', 'Supervisor', 'Lector'].includes(rol)) {
        return res.status(400).json({
          success: false,
          error: 'Rol inválido. Debe ser: Admin, Agronomo, Supervisor o Lector'
        });
      }
      updateData.rol = rol;
    }
    if (activo !== undefined) updateData.activo = activo;

    await userService.updateUser(usuarioID, updateData);

    res.json({
      success: true,
      message: 'Usuario actualizado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error actualizando usuario:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Error actualizando usuario'
    });
  }
});

/**
 * DELETE /api/usuarios/:id
 * Elimina un usuario (soft delete)
 */
router.delete('/:id', authenticateToken, async (req: Request, res: Response) => {
  try {
    const usuarioID = parseInt(req.params.id);
    if (isNaN(usuarioID)) {
      return res.status(400).json({
        success: false,
        error: 'ID de usuario inválido'
      });
    }

    const usuarioModificaID = (req as any).usuarioID || 1; // TODO: Obtener del token JWT

    await userService.deleteUser(usuarioID, usuarioModificaID);

    res.json({
      success: true,
      message: 'Usuario eliminado exitosamente'
    });
  } catch (error) {
    console.error('❌ Error eliminando usuario:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Error eliminando usuario'
    });
  }
});

export default router;

