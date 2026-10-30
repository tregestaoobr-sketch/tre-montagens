-- Execute no SQL Editor do Supabase. Nunca coloque SERVICE_ROLE_KEY no frontend.
create extension if not exists pgcrypto;
create table if not exists public.tre_push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  audience text not null check (audience in ('patrao','funcionario')),
  funcionario_id text,
  endpoint text not null unique,
  subscription jsonb not null,
  ativo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.tre_push_subscriptions enable row level security;
drop policy if exists "Usuário lê suas inscrições push" on public.tre_push_subscriptions;
create policy "Usuário lê suas inscrições push" on public.tre_push_subscriptions
for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Usuário cria sua inscrição push" on public.tre_push_subscriptions;
create policy "Usuário cria sua inscrição push" on public.tre_push_subscriptions
for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Usuário atualiza sua inscrição push" on public.tre_push_subscriptions;
create policy "Usuário atualiza sua inscrição push" on public.tre_push_subscriptions
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Usuário apaga sua inscrição push" on public.tre_push_subscriptions;
create policy "Usuário apaga sua inscrição push" on public.tre_push_subscriptions
for delete to authenticated using (auth.uid() = user_id);
grant select, insert, update, delete on public.tre_push_subscriptions to authenticated;
