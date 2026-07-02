import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { authRouter } from './routes/auth';
import { clientsRouter } from './routes/clients';
import { appointmentsRouter } from './routes/appointments';
import { adminRouter } from './routes/admin';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true }));

app.use('/auth', authRouter);
app.use('/clients', clientsRouter);
app.use('/clients/:clientId/appointments', appointmentsRouter);

// Visualizador somente leitura para uso local — sem autenticação, não expor publicamente.
app.use('/admin', adminRouter);

app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({ error: 'Erro interno do servidor' });
});

const port = process.env.PORT ? Number(process.env.PORT) : 3000;
app.listen(port, () => {
  console.log(`API rodando em http://localhost:${port}`);
});
