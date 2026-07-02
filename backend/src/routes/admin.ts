import { Router } from 'express';
import { pool } from '../db/pool';

export const adminRouter = Router();

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function formatDate(value: string | Date): string {
  const d = new Date(value);
  if (isNaN(d.getTime())) return String(value);
  return d.toLocaleString('pt-BR');
}

adminRouter.get('/', async (_req, res) => {
  const clientsResult = await pool.query(
    'SELECT id, name, phone, email, date, created_at FROM clients ORDER BY created_at DESC'
  );
  const appointmentsResult = await pool.query(
    `SELECT a.id, a.date, a.services, a.professional, c.name AS client_name
     FROM appointments a
     JOIN clients c ON c.id = a.client_id
     ORDER BY a.date DESC, a.created_at DESC`
  );

  const clientRows = clientsResult.rows
    .map(
      (c) => `<tr>
        <td>${escapeHtml(c.name)}</td>
        <td>${escapeHtml(c.phone)}</td>
        <td>${escapeHtml(c.email)}</td>
        <td>${escapeHtml(c.date)}</td>
        <td>${formatDate(c.created_at)}</td>
      </tr>`
    )
    .join('');

  const appointmentRows = appointmentsResult.rows
    .map(
      (a) => `<tr>
        <td>${escapeHtml(a.client_name)}</td>
        <td>${escapeHtml(a.date)}</td>
        <td>${escapeHtml(a.services)}</td>
        <td>${escapeHtml(a.professional)}</td>
      </tr>`
    )
    .join('');

  res.send(`<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Ficha Salão — Visualizador do banco</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 32px; color: #1e293b; background: #f8fafc; }
  h1 { font-size: 22px; }
  h2 { font-size: 18px; margin-top: 40px; }
  table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
  th, td { text-align: left; padding: 10px 14px; border-bottom: 1px solid #e2e8f0; font-size: 14px; }
  th { background: #f1f5f9; }
  .empty { color: #64748b; font-size: 14px; padding: 12px 0; }
</style>
</head>
<body>
  <h1>Ficha Salão — Visualizador do banco (somente leitura, uso local)</h1>

  <h2>Clientes (${clientsResult.rowCount})</h2>
  ${clientsResult.rowCount === 0
    ? '<p class="empty">Nenhum cliente cadastrado ainda.</p>'
    : `<table>
        <thead><tr><th>Nome</th><th>Telefone</th><th>Email</th><th>Data da ficha</th><th>Criado em</th></tr></thead>
        <tbody>${clientRows}</tbody>
      </table>`}

  <h2>Atendimentos (${appointmentsResult.rowCount})</h2>
  ${appointmentsResult.rowCount === 0
    ? '<p class="empty">Nenhum atendimento cadastrado ainda.</p>'
    : `<table>
        <thead><tr><th>Cliente</th><th>Data</th><th>Serviços</th><th>Profissional</th></tr></thead>
        <tbody>${appointmentRows}</tbody>
      </table>`}
</body>
</html>`);
});
