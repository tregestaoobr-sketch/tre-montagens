/*
 T.R.E. MONTAGENS — V5.0
 INSTALAÇÃO / CORREÇÃO DURÁVEL — NÃO DESTRUTIVA

 IMPORTANTE:
 - Este arquivo NÃO apaga tabelas nem dados.
 - Pode ser executado sobre uma instalação existente.
 - Ele cria o que estiver faltando, adiciona colunas ausentes e atualiza
   somente as funções usadas pelo aplicativo.
 - Não use service_role no aplicativo.
 - Depois de executar, crie/garanta o usuário administrador em
   Authentication > Users e marque o perfil como admin na seção final.
*/

begin;

create extension if not exists pgcrypto with schema extensions;

/* ================================================================
   1. ESTRUTURA — CRIA SE NÃO EXISTIR / COMPLETA O QUE FALTAR
   ================================================================ */

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'user' check (role in ('admin','user')),
  created_at timestamptz not null default now()
);

alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists role text not null default 'user';
alter table public.profiles add column if not exists created_at timestamptz not null default now();

create table if not exists public.obras (
  id text primary key,
  nome text not null,
  local text not null,
  status text not null default 'Em Andamento',
  atualizado_por text,
  created_at timestamptz not null default now()
);
alter table public.obras add column if not exists nome text;
alter table public.obras add column if not exists local text;
alter table public.obras add column if not exists componente text;
alter table public.obras add column if not exists representante text;
alter table public.obras add column if not exists status text default 'Em Andamento';
alter table public.obras add column if not exists atualizado_por text;
alter table public.obras add column if not exists created_at timestamptz not null default now();

create table if not exists public.equipe (
  id text primary key,
  nome text not null,
  whatsapp text,
  diaria numeric(12,2) not null default 0,
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.equipe add column if not exists nome text;
alter table public.equipe add column if not exists whatsapp text;
alter table public.equipe add column if not exists diaria numeric(12,2) default 0;
alter table public.equipe add column if not exists ativo boolean not null default true;
alter table public.equipe add column if not exists created_at timestamptz not null default now();

create table if not exists public.equipe_seguranca (
  funcionario_id text primary key references public.equipe(id) on delete cascade,
  pin_hash text not null,
  updated_at timestamptz not null default now()
);
alter table public.equipe_seguranca add column if not exists pin_hash text;
alter table public.equipe_seguranca add column if not exists updated_at timestamptz not null default now();

create table if not exists public.pontos (
  id text primary key,
  funcionario_id text not null references public.equipe(id) on update cascade on delete restrict,
  obra_id text not null references public.obras(id) on update cascade on delete restrict,
  data text not null,
  hora text not null,
  gps jsonb,
  created_at timestamptz not null default now()
);
alter table public.pontos add column if not exists funcionario_id text;
alter table public.pontos add column if not exists obra_id text;
alter table public.pontos add column if not exists data text;
alter table public.pontos add column if not exists hora text;
alter table public.pontos add column if not exists gps jsonb;
alter table public.pontos add column if not exists created_at timestamptz not null default now();

create table if not exists public.vales (
  id text primary key,
  tipo text not null default 'Vale',
  funcionario_id text not null references public.equipe(id) on update cascade on delete restrict,
  obra_id text not null references public.obras(id) on update cascade on delete restrict,
  valor numeric(12,2) not null default 0,
  data text not null,
  descricao text,
  comprovante text,
  created_at timestamptz not null default now()
);
alter table public.vales add column if not exists tipo text default 'Vale';
alter table public.vales add column if not exists funcionario_id text;
alter table public.vales add column if not exists obra_id text;
alter table public.vales add column if not exists valor numeric(12,2) default 0;
alter table public.vales add column if not exists data text;
alter table public.vales add column if not exists descricao text;
alter table public.vales add column if not exists comprovante text;
alter table public.vales add column if not exists created_at timestamptz not null default now();

create table if not exists public.fotos_obra (
  id text primary key,
  funcionario_id text not null references public.equipe(id) on update cascade on delete restrict,
  obra_id text not null references public.obras(id) on update cascade on delete restrict,
  tipo text,
  observacao text,
  imagem text,
  is_video boolean not null default false,
  data text not null,
  file_name text,
  created_at timestamptz not null default now()
);
alter table public.fotos_obra add column if not exists funcionario_id text;
alter table public.fotos_obra add column if not exists obra_id text;
alter table public.fotos_obra add column if not exists tipo text;
alter table public.fotos_obra add column if not exists observacao text;
alter table public.fotos_obra add column if not exists imagem text;
alter table public.fotos_obra add column if not exists is_video boolean not null default false;
alter table public.fotos_obra add column if not exists data text;
alter table public.fotos_obra add column if not exists file_name text;
alter table public.fotos_obra add column if not exists created_at timestamptz not null default now();

create table if not exists public.pdfs_obra (
  id text primary key,
  obra_id text not null references public.obras(id) on update cascade on delete cascade,
  titulo text,
  url text,
  data text not null,
  created_at timestamptz not null default now()
);
alter table public.pdfs_obra add column if not exists obra_id text;
alter table public.pdfs_obra add column if not exists titulo text;
alter table public.pdfs_obra add column if not exists url text;
alter table public.pdfs_obra add column if not exists data text;
alter table public.pdfs_obra add column if not exists created_at timestamptz not null default now();

create table if not exists public.designacoes (
  id text primary key,
  funcionario_id text not null references public.equipe(id) on update cascade on delete restrict,
  obra_id text not null references public.obras(id) on update cascade on delete restrict,
  data text,
  tipo_contratacao text,
  quantidade numeric(12,2),
  valor_unitario numeric(12,2),
  valor_total numeric(12,2),
  observacao text,
  created_at timestamptz not null default now()
);
alter table public.designacoes add column if not exists funcionario_id text;
alter table public.designacoes add column if not exists obra_id text;
alter table public.designacoes add column if not exists data text;
alter table public.designacoes add column if not exists tipo_contratacao text;
alter table public.designacoes add column if not exists quantidade numeric(12,2);
alter table public.designacoes add column if not exists valor_unitario numeric(12,2);
alter table public.designacoes add column if not exists valor_total numeric(12,2);
alter table public.designacoes add column if not exists observacao text;
alter table public.designacoes add column if not exists created_at timestamptz not null default now();

/* Compatibilidade com versões antigas que usavam data_inicio/instrucao. */
do $$
begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='designacoes' and column_name='data_inicio') then
    update public.designacoes
       set data = coalesce(data, data_inicio)
     where data is null;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='designacoes' and column_name='instrucao') then
    update public.designacoes
       set observacao = coalesce(observacao, instrucao)
     where observacao is null;
  end if;
end $$;

create table if not exists public.employee_sessions (
  token_hash text primary key,
  funcionario_id text not null references public.equipe(id) on delete cascade,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table if not exists public.employee_login_attempts (
  funcionario_id text not null references public.equipe(id) on delete cascade,
  attempted_at timestamptz not null default now()
);

create index if not exists pontos_func_idx on public.pontos(funcionario_id);
create index if not exists pontos_obra_idx on public.pontos(obra_id);
create index if not exists pontos_data_idx on public.pontos(data);
create index if not exists equipe_nome_idx on public.equipe(nome);
create index if not exists vales_func_idx on public.vales(funcionario_id);
create index if not exists fotos_obra_idx on public.fotos_obra(obra_id);
create index if not exists pdfs_obra_idx on public.pdfs_obra(obra_id);
create index if not exists designacoes_func_idx on public.designacoes(funcionario_id);
create index if not exists designacoes_obra_idx on public.designacoes(obra_id);
create index if not exists employee_sessions_func_idx on public.employee_sessions(funcionario_id);
create index if not exists employee_sessions_exp_idx on public.employee_sessions(expires_at);
create index if not exists employee_login_attempts_idx on public.employee_login_attempts(funcionario_id, attempted_at);

/* ================================================================
   2. AUTH / PERFIL ADMIN
   ================================================================ */

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles(id, email, role)
  values (new.id, new.email, 'user')
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

insert into public.profiles(id, email, role)
select id, email, 'user' from auth.users
on conflict (id) do update set email = excluded.email;

create or replace function public.get_my_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

revoke all on function public.get_my_role() from public;
grant execute on function public.get_my_role() to anon, authenticated;

/* ================================================================
   3. RLS — FECHA O ACESSO DIRETO E LIBERA APENAS ADMIN AUTH
   ================================================================ */

alter table public.profiles enable row level security;
alter table public.obras enable row level security;
alter table public.equipe enable row level security;
alter table public.equipe_seguranca enable row level security;
alter table public.pontos enable row level security;
alter table public.vales enable row level security;
alter table public.fotos_obra enable row level security;
alter table public.pdfs_obra enable row level security;
alter table public.designacoes enable row level security;
alter table public.employee_sessions enable row level security;
alter table public.employee_login_attempts enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
for select to authenticated using (id = auth.uid());

/* Policies administrativas idempotentes. */
do $$
declare
  t text;
begin
  foreach t in array array['obras','equipe','equipe_seguranca','pontos','vales','fotos_obra','pdfs_obra','designacoes'] loop
    execute format('drop policy if exists %I_admin_all on public.%I', t, t);
    execute format('create policy %I_admin_all on public.%I for all to authenticated using (public.get_my_role() = ''admin'') with check (public.get_my_role() = ''admin'')', t, t);
  end loop;
end $$;

/* ================================================================
   4. FUNÇÕES DO APLICATIVO — FONTE OFICIAL PARA FUNCIONÁRIO
   ================================================================ */

create or replace function public.admin_save_employee(
  p_id text,
  p_nome text,
  p_whatsapp text,
  p_diaria numeric,
  p_pin text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_id text := coalesce(nullif(btrim(p_id), ''), gen_random_uuid()::text);
begin
  if public.get_my_role() <> 'admin' then raise exception 'Acesso administrativo necessário'; end if;
  if p_nome is null or btrim(p_nome) = '' then raise exception 'Nome obrigatório'; end if;
  if p_diaria is null or p_diaria <= 0 then raise exception 'Diária inválida'; end if;
  if coalesce(p_pin,'') !~ '^[0-9]{4}$' then raise exception 'PIN deve conter exatamente 4 dígitos'; end if;

  insert into public.equipe(id, nome, whatsapp, diaria, ativo)
  values (v_id, btrim(p_nome), nullif(btrim(p_whatsapp), ''), p_diaria, true)
  on conflict (id) do update set
    nome = excluded.nome,
    whatsapp = excluded.whatsapp,
    diaria = excluded.diaria,
    ativo = true;

  insert into public.equipe_seguranca(funcionario_id, pin_hash, updated_at)
  values (v_id, crypt(p_pin, gen_salt('bf', 10)), now())
  on conflict (funcionario_id) do update set
    pin_hash = excluded.pin_hash,
    updated_at = now();

  return jsonb_build_object('ok', true, 'id', v_id);
end;
$$;
revoke all on function public.admin_save_employee(text,text,text,numeric,text) from public;
grant execute on function public.admin_save_employee(text,text,text,numeric,text) to authenticated;

create or replace function public.employee_directory()
returns table(id text, nome text, ativo boolean)
language sql stable security definer
set search_path = public
as $$
  select e.id, e.nome, e.ativo
  from public.equipe e
  where e.ativo = true
  order by e.nome;
$$;
revoke all on function public.employee_directory() from public;
grant execute on function public.employee_directory() to anon, authenticated;

create or replace function public.employee_obras()
returns table(id text, nome text, local text, status text)
language sql stable security definer
set search_path = public
as $$
  select o.id, o.nome, o.local, o.status
  from public.obras o
  order by o.nome;
$$;
revoke all on function public.employee_obras() from public;
grant execute on function public.employee_obras() to anon, authenticated;

create or replace function public.employee_login(p_funcionario_id text, p_pin text)
returns jsonb
language plpgsql security definer
set search_path = public, extensions
as $$
declare
  v_hash text; v_nome text; v_token text; v_token_hash text; v_attempts integer;
begin
  delete from public.employee_sessions where expires_at < now();
  delete from public.employee_login_attempts where attempted_at < now() - interval '1 hour';

  select count(*) into v_attempts from public.employee_login_attempts
  where funcionario_id = p_funcionario_id and attempted_at >= now() - interval '15 minutes';
  if v_attempts >= 10 then return jsonb_build_object('ok',false,'message','Muitas tentativas. Aguarde 15 minutos.'); end if;

  select e.nome, s.pin_hash into v_nome, v_hash
  from public.equipe e join public.equipe_seguranca s on s.funcionario_id=e.id
  where e.id=p_funcionario_id and e.ativo=true;

  if v_hash is null or crypt(coalesce(p_pin,''),v_hash) <> v_hash then
    insert into public.employee_login_attempts(funcionario_id) values (p_funcionario_id);
    return jsonb_build_object('ok',false,'message','PIN incorreto.');
  end if;

  delete from public.employee_login_attempts where funcionario_id=p_funcionario_id;
  v_token := encode(gen_random_bytes(32),'hex');
  v_token_hash := encode(digest(v_token,'sha256'),'hex');
  insert into public.employee_sessions(token_hash, funcionario_id, expires_at)
  values (v_token_hash,p_funcionario_id,now()+interval '8 hours');

  return jsonb_build_object('ok',true,'token',v_token,'funcionario_id',p_funcionario_id,'nome',v_nome,'expires_at',now()+interval '8 hours');
end;
$$;
revoke all on function public.employee_login(text,text) from public;
grant execute on function public.employee_login(text,text) to anon, authenticated;

create or replace function public.employee_session_employee(p_session_token text)
returns text
language plpgsql stable security definer
set search_path = public, extensions
as $$
declare v_id text;
begin
  if p_session_token is null or length(p_session_token) < 32 then return null; end if;
  select funcionario_id into v_id from public.employee_sessions
  where token_hash=encode(digest(p_session_token,'sha256'),'hex') and expires_at>now();
  return v_id;
end;
$$;
revoke all on function public.employee_session_employee(text) from public;
grant execute on function public.employee_session_employee(text) to anon, authenticated;

create or replace function public.employee_register_point(
  p_session_token text, p_funcionario_id text, p_obra_id text,
  p_data text, p_hora text, p_gps jsonb
)
returns jsonb
language plpgsql security definer
set search_path = public, extensions
as $$
declare v_auth_id text;
begin
  v_auth_id := public.employee_session_employee(p_session_token);
  if v_auth_id is null or v_auth_id <> p_funcionario_id then raise exception 'Sessão de funcionário inválida ou expirada'; end if;
  if not exists(select 1 from public.equipe where id=p_funcionario_id and ativo=true) then raise exception 'Funcionário inativo'; end if;
  if not exists(select 1 from public.obras where id=p_obra_id) then raise exception 'Obra não encontrada'; end if;
  if nullif(btrim(coalesce(p_data,'')),'') is null then raise exception 'Data do ponto obrigatória'; end if;
  if nullif(btrim(coalesce(p_hora,'')),'') is null then raise exception 'Hora do ponto obrigatória'; end if;

  insert into public.pontos(id,funcionario_id,obra_id,data,hora,gps)
  values(gen_random_uuid()::text,p_funcionario_id,p_obra_id,p_data,p_hora,p_gps);
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.employee_register_point(text,text,text,text,text,jsonb) from public;
grant execute on function public.employee_register_point(text,text,text,text,text,jsonb) to anon, authenticated;

create or replace function public.employee_register_vale(
  p_session_token text,p_funcionario_id text,p_obra_id text,p_tipo text,
  p_valor numeric,p_data text,p_descricao text,p_comprovante text
)
returns jsonb language plpgsql security definer set search_path=public,extensions
as $$
declare v_auth_id text;
begin
  v_auth_id:=public.employee_session_employee(p_session_token);
  if v_auth_id is null or v_auth_id<>p_funcionario_id then raise exception 'Sessão de funcionário inválida ou expirada'; end if;
  if p_valor is null or p_valor<=0 then raise exception 'Valor inválido'; end if;
  if not exists(select 1 from public.obras where id=p_obra_id) then raise exception 'Obra não encontrada'; end if;
  insert into public.vales(id,tipo,funcionario_id,obra_id,valor,data,descricao,comprovante)
  values(gen_random_uuid()::text,coalesce(nullif(p_tipo,''),'Vale'),p_funcionario_id,p_obra_id,p_valor,p_data,p_descricao,p_comprovante);
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.employee_register_vale(text,text,text,text,numeric,text,text,text) from public;
grant execute on function public.employee_register_vale(text,text,text,text,numeric,text,text,text) to anon, authenticated;

create or replace function public.employee_upload_photo(
  p_session_token text,p_funcionario_id text,p_obra_id text,p_tipo text,
  p_observacao text,p_imagem text,p_is_video boolean,p_data text,p_file_name text
)
returns jsonb language plpgsql security definer set search_path=public,extensions
as $$
declare v_auth_id text;
begin
  v_auth_id:=public.employee_session_employee(p_session_token);
  if v_auth_id is null or v_auth_id<>p_funcionario_id then raise exception 'Sessão de funcionário inválida ou expirada'; end if;
  if not exists(select 1 from public.obras where id=p_obra_id) then raise exception 'Obra não encontrada'; end if;
  insert into public.fotos_obra(id,funcionario_id,obra_id,tipo,observacao,imagem,is_video,data,file_name)
  values(gen_random_uuid()::text,p_funcionario_id,p_obra_id,p_tipo,p_observacao,p_imagem,coalesce(p_is_video,false),p_data,p_file_name);
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.employee_upload_photo(text,text,text,text,text,text,boolean,text,text) from public;
grant execute on function public.employee_upload_photo(text,text,text,text,text,text,boolean,text,text) to anon, authenticated;

create or replace function public.employee_update_obra_status(
  p_session_token text,p_funcionario_id text,p_obra_id text,p_status text
)
returns jsonb language plpgsql security definer set search_path=public,extensions
as $$
declare v_auth_id text; v_nome text;
begin
  v_auth_id:=public.employee_session_employee(p_session_token);
  if v_auth_id is null or v_auth_id<>p_funcionario_id then raise exception 'Sessão de funcionário inválida ou expirada'; end if;
  select nome into v_nome from public.equipe where id=p_funcionario_id and ativo=true;
  if v_nome is null then raise exception 'Funcionário inativo'; end if;
  if p_status not in ('Em Andamento','Pronta','Finalizada') then raise exception 'Status inválido'; end if;
  update public.obras set status=p_status,atualizado_por=v_nome where id=p_obra_id;
  if not found then raise exception 'Obra não encontrada'; end if;
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.employee_update_obra_status(text,text,text,text) from public;
grant execute on function public.employee_update_obra_status(text,text,text,text) to anon, authenticated;

create or replace function public.employee_get_history(p_session_token text)
returns jsonb language plpgsql stable security definer set search_path=public
as $$
declare v_id text; v_result jsonb;
begin
  v_id:=public.employee_session_employee(p_session_token);
  if v_id is null then raise exception 'Sessão inválida ou expirada'; end if;
  select coalesce(jsonb_agg(x order by x.created_at desc),'[]'::jsonb) into v_result
  from (select p.data,p.hora,e.nome as funcionario_nome,o.nome as obra_nome,p.created_at
        from public.pontos p join public.equipe e on e.id=p.funcionario_id
        left join public.obras o on o.id=p.obra_id
        where p.funcionario_id=v_id order by p.created_at desc limit 20) x;
  return v_result;
end;
$$;
revoke all on function public.employee_get_history(text) from public;
grant execute on function public.employee_get_history(text) to anon, authenticated;

create or replace function public.employee_list_pdfs(p_session_token text,p_obra_id text)
returns table(id text,titulo text,url text,data text)
language plpgsql stable security definer set search_path=public
as $$
declare v_id text;
begin
  v_id:=public.employee_session_employee(p_session_token);
  if v_id is null then raise exception 'Sessão inválida ou expirada'; end if;
  return query select p.id,p.titulo,p.url,p.data from public.pdfs_obra p where p.obra_id=p_obra_id order by p.created_at desc;
end;
$$;
revoke all on function public.employee_list_pdfs(text,text) from public;
grant execute on function public.employee_list_pdfs(text,text) to anon, authenticated;

/* ================================================================
   5. REALTIME — ADICIONA SOMENTE O QUE AINDA NÃO ESTÁ PUBLICADO
   ================================================================ */

do $$
declare t text;
begin
  foreach t in array array['obras','equipe','pontos','vales','fotos_obra','pdfs_obra','designacoes'] loop
    if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename=t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

commit;

/* ================================================================
   6. DEFINIR O ADMINISTRADOR — EXECUTE SOMENTE ESTA LINHA,
      TROCANDO O E-MAIL PELO SEU.
   ================================================================

update public.profiles
set role='admin'
where email='SEU_EMAIL_DE_ADMIN@EXEMPLO.COM';

select id,email,role from public.profiles order by email;
*/
