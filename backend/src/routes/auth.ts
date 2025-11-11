import express, { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { query } from '../lib/db';

const router = express.Router();

/**
 * POST /api/auth/login
 * Autenticación de dispositivo Android
 * 
 * Body:
 * - deviceId: ID único del dispositivo
 * - apiKey: API key del dispositivo
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { deviceId, apiKey } = req.body;

    if (!deviceId || !apiKey) {
      return res.status(400).json({
        error: 'deviceId and apiKey are required'
      });
    }

    // Validar deviceId y apiKey contra base de datos
    const device = await validateDeviceCredentials(deviceId, apiKey);
    
    if (!device) {
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }
    
    // Verificar que el dispositivo esté activo
    if (!device.activo) {
      return res.status(403).json({
        error: 'Device is disabled'
      });
    }
    
    // Actualizar último acceso
    await updateLastAccess(device.dispositivoID);

    // Generar JWT token
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const token = jwt.sign(
      { deviceId },
      jwtSecret,
      { expiresIn: '24h' } // Token válido por 24 horas
    );

    res.json({
      success: true,
      token,
      expiresIn: 86400, // 24 horas en segundos
      deviceId
    });
  } catch (error) {
    console.error('❌ Error in login:', error);
    res.status(500).json({
      error: 'Login error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Valida las credenciales del dispositivo contra la base de datos
 * @param deviceId ID del dispositivo
 * @param apiKey API Key del dispositivo
 * @returns Información del dispositivo si las credenciales son válidas, null si no
 */
async function validateDeviceCredentials(
  deviceId: string,
  apiKey: string
): Promise<{
  dispositivoID: number;
  deviceId: string;
  nombreDispositivo: string | null;
  activo: boolean;
} | null> {
  try {
    const result = await query<{
      dispositivoID: number;
      deviceId: string;
      nombreDispositivo: string | null;
      activo: boolean;
    }>(`
      SELECT 
        dispositivoID,
        deviceId,
        nombreDispositivo,
        activo
      FROM image.Dispositivo WITH (NOLOCK)
      WHERE deviceId = @deviceId
        AND apiKey = @apiKey
        AND statusID = 1
    `, { deviceId, apiKey });

    if (result.length === 0) {
      console.warn(`⚠️ Login fallido: deviceId=${deviceId}, apiKey no válida`);
      return null;
    }

    return result[0];
  } catch (error) {
    console.error('❌ Error validando credenciales del dispositivo:', error);
    return null;
  }
}

/**
 * Actualiza la fecha de último acceso del dispositivo
 * @param dispositivoID ID del dispositivo
 */
async function updateLastAccess(dispositivoID: number): Promise<void> {
  try {
    await query(`
      UPDATE image.Dispositivo
      SET ultimoAcceso = GETDATE()
      WHERE dispositivoID = @dispositivoID
    `, { dispositivoID });
  } catch (error) {
    // No es crítico si falla, solo logging
    console.warn('⚠️ No se pudo actualizar último acceso:', error);
  }
}

export default router;

