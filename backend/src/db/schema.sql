CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  birth_date TEXT NOT NULL DEFAULT '',
  date TEXT NOT NULL DEFAULT '',

  -- HealthInfo
  health_allergies TEXT NOT NULL DEFAULT '',
  health_medications TEXT NOT NULL DEFAULT '',
  health_skin_conditions TEXT NOT NULL DEFAULT '',

  -- ProcedureInfo
  proc_has_smoothing TEXT NOT NULL DEFAULT '',
  proc_smoothing_type TEXT NOT NULL DEFAULT '',
  proc_smoothing_date TEXT NOT NULL DEFAULT '',
  proc_has_coloring TEXT NOT NULL DEFAULT '',
  proc_coloring_type TEXT NOT NULL DEFAULT '',
  proc_coloring_date TEXT NOT NULL DEFAULT '',
  proc_today_desire TEXT NOT NULL DEFAULT '',
  proc_has_inspiration_photo TEXT NOT NULL DEFAULT '',
  proc_willing_to_cut TEXT NOT NULL DEFAULT '',
  proc_pre_treatment TEXT NOT NULL DEFAULT '',
  proc_post_treatment TEXT NOT NULL DEFAULT '',
  proc_professional_advice TEXT NOT NULL DEFAULT '',
  proc_last_strand_test_date TEXT NOT NULL DEFAULT '',

  observations TEXT NOT NULL DEFAULT '',

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  date TEXT NOT NULL DEFAULT '',
  services TEXT NOT NULL DEFAULT '',
  products TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  professional TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_appointments_client_id ON appointments(client_id);
