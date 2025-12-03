import jwt from 'jsonwebtoken';

/**
 * Obtiene el JWT_SECRET de las variables de entorno
 * Lanza error si no está configurado o usa el valor por defecto
 */
export function getJwtSecret(): string {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret === 'your-secret-key-change-in-production') {
    throw new Error('JWT_SECRET no está configurado. Debe configurarse en las variables de entorno.');
  }
  return secret;
}

/**
 * Firma un token JWT
 * @param payload - Payload del token
 * @param options - Opciones de firma (expiresIn puede ser string o number)
 */
export function signToken(
  payload: object | string | Buffer, 
  options?: jwt.SignOptions | { expiresIn?: string | number; [key: string]: any }
): string {
  const secret = getJwtSecret();
  return jwt.sign(payload, secret, options as jwt.SignOptions);
}

/**
 * Verifica un token JWT
 */
export function verifyToken(token: string): string | jwt.JwtPayload {
  const secret = getJwtSecret();
  return jwt.verify(token, secret);
}

