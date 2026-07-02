import 'dotenv/config';
import { readFileSync } from 'fs';
import { join } from 'path';
import { pool } from './pool';

async function migrate() {
  const sql = readFileSync(join(__dirname, 'schema.sql'), 'utf-8');
  await pool.query(sql);
  console.log('Migração aplicada com sucesso.');
  await pool.end();
}

migrate().catch((err) => {
  console.error('Falha na migração:', err);
  process.exit(1);
});
