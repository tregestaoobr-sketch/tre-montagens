-- T.R.E. Montagens: adicionar campos da obra sem apagar dados existentes
ALTER TABLE public.obras
  ADD COLUMN IF NOT EXISTS componente text,
  ADD COLUMN IF NOT EXISTS representante text,
  ADD COLUMN IF NOT EXISTS observacoes text;
