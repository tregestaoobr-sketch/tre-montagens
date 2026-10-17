/*
 T.R.E. MONTAGENS — LIMPEZA OPCIONAL DE DADOS DE TESTE
 NÃO execute junto com a instalação principal.

 Este arquivo APAGA registros de negócio, mas NÃO apaga usuários Auth,
 perfis, funções, RLS ou a estrutura do banco.
 Só use se você realmente quiser começar a base operacional zerada.
*/

begin;

truncate table
  public.pontos,
  public.vales,
  public.fotos_obra,
  public.pdfs_obra,
  public.designacoes,
  public.employee_sessions,
  public.employee_login_attempts,
  public.equipe_seguranca,
  public.equipe,
  public.obras
restart identity cascade;

commit;
