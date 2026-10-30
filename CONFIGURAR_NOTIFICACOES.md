T.R.E. Montagens — ordem de presenças e base para notificações

ORDEM DOS PONTOS
A tabela agora ordena pela data/hora trabalhadas, mais recentes primeiro, em vez de ordenar pelo momento em que o registro foi enviado. Para lançar um ponto esquecido, selecione a data correta no formulário antes de registrar. O sistema não tem como adivinhar o dia esquecido e não altera automaticamente registros antigos.

NOTIFICAÇÕES
Arquivos incluídos: SUPABASE_TRE_NOTIFICACOES.sql, supabase/functions/tre-notificacoes/index.ts e service worker com suporte a push. O HTML chama a função após registrar ponto e após criar obra. A chamada é tolerante a falhas e não impede o registro principal.

Para ativar de verdade:
1. Execute SUPABASE_TRE_NOTIFICACOES.sql no SQL Editor do projeto Supabase.
2. Gere chaves VAPID para Web Push.
3. Configure secrets na Edge Function: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY, VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY e VAPID_SUBJECT.
4. Publique a função `tre-notificacoes`.
5. Cada aparelho precisa permitir notificações e gravar uma inscrição Push válida em `tre_push_subscriptions`.
6. A chamada atual exige sessão Supabase Auth válida no aparelho do patrão. Não exponha SERVICE_ROLE_KEY no HTML/GitHub.

Importante: esta entrega deixa a ordenação pronta e inclui a base de backend/gatilhos, mas ainda exige implementar o fluxo de inscrição push no navegador (Notification.requestPermission + serviceWorker PushManager.subscribe + salvar subscription). A notificação de obra para funcionário também precisa ser disparada depois de designar a obra e incluir funcionario_id; criar uma obra geral não identifica o destinatário. Sem esses passos, não prometa que os avisos chegarão.
