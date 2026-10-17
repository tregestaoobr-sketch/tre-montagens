-- T.R.E. Montagens V5.3 - datas do cronograma
-- Execute uma única vez no Supabase > SQL Editor.
-- Não apaga nem recria tabelas e não altera os registros existentes.

ALTER TABLE public.obras
  ADD COLUMN IF NOT EXISTS inicio_em date,
  ADD COLUMN IF NOT EXISTS finalizada_em date;

-- Para obras antigas, usa a data de criação já salva como referência inicial.
-- Se a data real de início for diferente, ela deve ser corrigida manualmente no banco.
UPDATE public.obras
SET inicio_em = created_at::date
WHERE inicio_em IS NULL
  AND created_at IS NOT NULL;

CREATE OR REPLACE FUNCTION public.tre_registrar_datas_obra()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.inicio_em IS NULL THEN
      NEW.inicio_em := CURRENT_DATE;
    END IF;
    IF NEW.status = 'Finalizada' AND NEW.finalizada_em IS NULL THEN
      NEW.finalizada_em := CURRENT_DATE;
    END IF;
    RETURN NEW;
  END IF;

  IF NEW.inicio_em IS NULL AND NEW.created_at IS NOT NULL THEN
    NEW.inicio_em := NEW.created_at::date;
  END IF;

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
