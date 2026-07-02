import { Request, Response, NextFunction } from 'express';
import { verifyToken, AuthTokenPayload } from '../utils/jwt';

export interface AuthRequest extends Request {
  user?: AuthTokenPayload;
}

export function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token ausente' });
  }

  const token = header.slice('Bearer '.length);
  try {
    req.user = verifyToken(token);
    next();
  } catch {
    return res.status(401).json({ error: 'Token inválido ou expirado' });
  }
}
