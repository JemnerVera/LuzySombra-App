import express, { Request, Response } from 'express';
import multer from 'multer';
import { extractLotIdFromExifServer } from '../utils/exif-server';

const router = express.Router();

// Configurar multer para manejar archivos en memoria
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

/**
 * POST /api/extract-lot-id
 * Endpoint ligero para extraer solo el lotID desde EXIF de una imagen
 * 
 * Body (multipart/form-data):
 * - file: archivo de imagen (REQUERIDO)
 * 
 * Response:
 * - success: boolean
 * - lotID: number | null (el lotID encontrado, o null si no se encuentra)
 * - error: string (solo si hay error)
 */
router.post('/', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No file provided',
        lotID: null
      });
    }

    const file = req.file;
    const imageBuffer = file.buffer;

    // Extraer lotID desde EXIF
    let lotID: number | null = null;
    try {
      lotID = await extractLotIdFromExifServer(imageBuffer, file.originalname);
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Error extracting lotID from EXIF',
        lotID: null
      });
    }

    if (!lotID || lotID <= 0) {
      return res.json({
        success: true,
        lotID: null,
        message: 'lotID not found in EXIF metadata'
      });
    }

    return res.json({
      success: true,
      lotID: lotID
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      lotID: null
    });
  }
});

export default router;

