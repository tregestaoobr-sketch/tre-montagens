-- T.R.E. Montagens: datas de início e finalização das obras
-- Execute uma única vez no Supabase > SQL Editor.

ALTER TABLE public.obras
  ADD COLUMN IF NOT EXISTS inicio_em date,
  ADD COLUMN IF NOT EXISTS finalizada_em date;

-- Aproveita a data real de criação já registrada, quando disponível.
UPDATE public.obras
SET inicio_em = created_at::date
WHERE inicio_em IS NULL
  AND created_at IS NOT NULL;

CREATE OR REPLACE FUNCTION public.tre_registrar_datas_obra()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Obras novas recebem a data de início automaticamente.
  IF TG_OP = 'INSERT' THEN
    IF NEW.inicio_em IS NULL THEN
      NEW.inicio_em := CURRENT_DATE;
    END IF;

    IF NEW.status = 'Finalizada' AND NEW.finalizada_em IS NULL THEN
      NEW.finalizada_em := CURRENT_DATE;
    END IF;

    RETURN NEW;
  END IF;

  -- Ao mudar o status para Finalizada, grava a data daquele momento.
  -- Funciona também quando a mudança vem da função RPC do funcionário.
  IF NEW.status = 'Finalizada'
     AND OLD.status IS DISTINCT FROM 'Finalizada' THEN
    NEW.finalizada_em := CURRENT_DATE;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tre_datas_obra_trigger ON public.obras;

CREATE TRIGGER tre_datas_obra_trigger
BEFORE INSERT OR UPDATE OF status
ON public.obras
FOR EACH ROW
EXECUTE FUNCTION public.tre_registrar_datas_obra();
