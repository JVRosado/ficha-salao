import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { pool } from '../db/pool';
import { signToken } from '../utils/jwt';

export const authRouter = Router();

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

authRouter.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Email ou senha inválidos' });
  }
  const { email, password } = parsed.data;

  const result = await pool.query('SELECT id, email, password_hash FROM users WHERE email = $1', [email]);
  const user = result.rows[0];
  if (!user) {
    return res.status(401).json({ error: 'Credenciais inválidas' });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    return res.status(401).json({ error: 'Credenciais inválidas' });
  }

  const token = signToken({ userId: user.id, email: user.email });
  res.json({ token });
});
