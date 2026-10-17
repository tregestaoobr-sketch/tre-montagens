-- T.R.E. Montagens: corrigir consulta pública das informações da obra
-- Execute no Supabase > SQL Editor.
-- Não apaga obras nem altera os dados já cadastrados.

ALTER TABLE public.obras
  ADD COLUMN IF NOT EXISTS componente text,
  ADD COLUMN IF NOT EXISTS representante text,
  ADD COLUMN IF NOT EXISTS observacoes text;

-- É necessário remover a versão antiga porque o retorno da função mudou.
DROP FUNCTION IF EXISTS public.employee_obras();

CREATE FUNCTION public.employee_obras()
RETURNS TABLE(
  id text,
  nome text,
  local text,
  status text,
  componente text,
  representante text,
  observacoes text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    o.id,
    o.nome,
    o.local,
    o.status,
    o.componente,
    o.representante,
    o.observacoes
  FROM public.obras AS o
  ORDER BY o.nome;
$$;

REVOKE ALL ON FUNCTION public.employee_obras() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.employee_obras() TO anon, authenticated;
