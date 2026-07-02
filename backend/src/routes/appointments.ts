import { Router, Request } from 'express';
import { z } from 'zod';
import { pool } from '../db/pool';
import { requireAuth } from '../middleware/auth';
import { appointmentRowToJson } from '../utils/mappers';

type ClientParams = { clientId: string };
type AppointmentParams = { clientId: string; apptId: string };

// mergeParams para ter acesso a :clientId vindo do router pai
export const appointmentsRouter = Router({ mergeParams: true });
appointmentsRouter.use(requireAuth);

const appointmentSchema = z.object({
  date: z.string().default(''),
  services: z.string().default(''),
  products: z.string().default(''),
  notes: z.string().default(''),
  professional: z.string().default(''),
});

// GET /clients/:clientId/appointments
appointmentsRouter.get('/', async (req: Request<ClientParams>, res) => {
  const result = await pool.query(
    'SELECT * FROM appointments WHERE client_id = $1 ORDER BY date DESC, created_at DESC',
    [req.params.clientId]
  );
  res.json(result.rows.map(appointmentRowToJson));
});

// POST /clients/:clientId/appointments
appointmentsRouter.post('/', async (req: Request<ClientParams>, res) => {
  const parsed = appointmentSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Dados inválidos', details: parsed.error.flatten() });
  }
  const a = parsed.data;

  const clientExists = await pool.query('SELECT 1 FROM clients WHERE id = $1', [req.params.clientId]);
  if (clientExists.rowCount === 0) {
    return res.status(404).json({ error: 'Cliente não encontrado' });
  }

  const result = await pool.query(
    `INSERT INTO appointments (client_id, date, services, products, notes, professional)
     VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
    [req.params.clientId, a.date, a.services, a.products, a.notes, a.professional]
  );
  res.status(201).json(appointmentRowToJson(result.rows[0]));
});

// PUT /clients/:clientId/appointments/:apptId
appointmentsRouter.put('/:apptId', async (req: Request<AppointmentParams>, res) => {
  const parsed = appointmentSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Dados inválidos', details: parsed.error.flatten() });
  }
  const a = parsed.data;

  const result = await pool.query(
    `UPDATE appointments SET date=$1, services=$2, products=$3, notes=$4, professional=$5
     WHERE id=$6 AND client_id=$7 RETURNING *`,
    [a.date, a.services, a.products, a.notes, a.professional, req.params.apptId, req.params.clientId]
  );
  const row = result.rows[0];
  if (!row) return res.status(404).json({ error: 'Agendamento não encontrado' });
  res.json(appointmentRowToJson(row));
});

// DELETE /clients/:clientId/appointments/:apptId
appointmentsRouter.delete('/:apptId', async (req: Request<AppointmentParams>, res) => {
  const result = await pool.query(
    'DELETE FROM appointments WHERE id = $1 AND client_id = $2',
    [req.params.apptId, req.params.clientId]
  );
  if (result.rowCount === 0) return res.status(404).json({ error: 'Agendamento não encontrado' });
  res.status(204).send();
});
