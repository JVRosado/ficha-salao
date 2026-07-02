import { Router } from 'express';
import { z } from 'zod';
import { pool } from '../db/pool';
import { requireAuth } from '../middleware/auth';
import { clientRowToJson, clientSummaryRowToJson } from '../utils/mappers';

export const clientsRouter = Router();
clientsRouter.use(requireAuth);

const healthSchema = z.object({
  allergies: z.string().default(''),
  medications: z.string().default(''),
  skinConditions: z.string().default(''),
});

const proceduresSchema = z.object({
  hasSmoothing: z.string().default(''),
  smoothingType: z.string().default(''),
  smoothingDate: z.string().default(''),
  hasColoring: z.string().default(''),
  coloringType: z.string().default(''),
  coloringDate: z.string().default(''),
  todayDesire: z.string().default(''),
  hasInspirationPhoto: z.string().default(''),
  willingToCut: z.string().default(''),
  preTreatment: z.string().default(''),
  postTreatment: z.string().default(''),
  professionalAdvice: z.string().default(''),
  lastStrandTestDate: z.string().default(''),
});

const clientSchema = z.object({
  name: z.string().min(1),
  phone: z.string().default(''),
  email: z.string().default(''),
  birthDate: z.string().default(''),
  date: z.string().default(''),
  health: healthSchema.default({}),
  procedures: proceduresSchema.default({}),
  observations: z.string().default(''),
});

// GET /clients — lista resumida (para home/busca)
clientsRouter.get('/', async (_req, res) => {
  const result = await pool.query('SELECT id, name, phone, date FROM clients ORDER BY updated_at DESC');
  res.json(result.rows.map(clientSummaryRowToJson));
});

// GET /clients/:id — ficha completa
clientsRouter.get('/:id', async (req, res) => {
  const result = await pool.query('SELECT * FROM clients WHERE id = $1', [req.params.id]);
  const row = result.rows[0];
  if (!row) return res.status(404).json({ error: 'Cliente não encontrado' });
  res.json(clientRowToJson(row));
});

// POST /clients — cria ficha
clientsRouter.post('/', async (req, res) => {
  const parsed = clientSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Dados inválidos', details: parsed.error.flatten() });
  }
  const c = parsed.data;

  const result = await pool.query(
    `INSERT INTO clients (
      name, phone, email, birth_date, date,
      health_allergies, health_medications, health_skin_conditions,
      proc_has_smoothing, proc_smoothing_type, proc_smoothing_date,
      proc_has_coloring, proc_coloring_type, proc_coloring_date,
      proc_today_desire, proc_has_inspiration_photo, proc_willing_to_cut,
      proc_pre_treatment, proc_post_treatment, proc_professional_advice, proc_last_strand_test_date,
      observations
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22)
    RETURNING *`,
    [
      c.name, c.phone, c.email, c.birthDate, c.date,
      c.health.allergies, c.health.medications, c.health.skinConditions,
      c.procedures.hasSmoothing, c.procedures.smoothingType, c.procedures.smoothingDate,
      c.procedures.hasColoring, c.procedures.coloringType, c.procedures.coloringDate,
      c.procedures.todayDesire, c.procedures.hasInspirationPhoto, c.procedures.willingToCut,
      c.procedures.preTreatment, c.procedures.postTreatment, c.procedures.professionalAdvice, c.procedures.lastStrandTestDate,
      c.observations,
    ]
  );
  res.status(201).json(clientRowToJson(result.rows[0]));
});

// PUT /clients/:id — atualiza ficha
clientsRouter.put('/:id', async (req, res) => {
  const parsed = clientSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: 'Dados inválidos', details: parsed.error.flatten() });
  }
  const c = parsed.data;

  const result = await pool.query(
    `UPDATE clients SET
      name=$1, phone=$2, email=$3, birth_date=$4, date=$5,
      health_allergies=$6, health_medications=$7, health_skin_conditions=$8,
      proc_has_smoothing=$9, proc_smoothing_type=$10, proc_smoothing_date=$11,
      proc_has_coloring=$12, proc_coloring_type=$13, proc_coloring_date=$14,
      proc_today_desire=$15, proc_has_inspiration_photo=$16, proc_willing_to_cut=$17,
      proc_pre_treatment=$18, proc_post_treatment=$19, proc_professional_advice=$20, proc_last_strand_test_date=$21,
      observations=$22, updated_at=now()
    WHERE id=$23
    RETURNING *`,
    [
      c.name, c.phone, c.email, c.birthDate, c.date,
      c.health.allergies, c.health.medications, c.health.skinConditions,
      c.procedures.hasSmoothing, c.procedures.smoothingType, c.procedures.smoothingDate,
      c.procedures.hasColoring, c.procedures.coloringType, c.procedures.coloringDate,
      c.procedures.todayDesire, c.procedures.hasInspirationPhoto, c.procedures.willingToCut,
      c.procedures.preTreatment, c.procedures.postTreatment, c.procedures.professionalAdvice, c.procedures.lastStrandTestDate,
      c.observations, req.params.id,
    ]
  );
  const row = result.rows[0];
  if (!row) return res.status(404).json({ error: 'Cliente não encontrado' });
  res.json(clientRowToJson(row));
});

// DELETE /clients/:id
clientsRouter.delete('/:id', async (req, res) => {
  const result = await pool.query('DELETE FROM clients WHERE id = $1', [req.params.id]);
  if (result.rowCount === 0) return res.status(404).json({ error: 'Cliente não encontrado' });
  res.status(204).send();
});
