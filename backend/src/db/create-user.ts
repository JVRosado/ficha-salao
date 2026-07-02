import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { pool } from './pool';

// Uso: npx tsx src/db/create-user.ts email@exemplo.com senha123
async function main() {
  const [email, password] = process.argv.slice(2);
  if (!email || !password) {
    console.error('Uso: npx tsx src/db/create-user.ts <email> <senha>');
    process.exit(1);
  }

  const passwordHash = await bcrypt.hash(password, 10);
  await pool.query(
    `INSERT INTO users (email, password_hash) VALUES ($1, $2)
     ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash`,
    [email, passwordHash]
  );
  console.log(`Usuário ${email} criado/atualizado com sucesso.`);
  await pool.end();
}

main().catch((err) => {
  console.error('Falha ao criar usuário:', err);
  process.exit(1);
});
