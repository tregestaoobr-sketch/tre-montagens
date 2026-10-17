-- T.R.E. Montagens: adicionar campos novos sem apagar dados existentes
alter table public.obras add column if not exists componente text;
alter table public.obras add column if not exists representante text;
