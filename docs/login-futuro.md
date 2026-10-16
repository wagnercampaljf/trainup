# Login e sincronização no futuro: análise de viabilidade

Situação em outubro de 2026 (versão 1.1.0). **Nada daqui está implementado.**
É um estudo para decidir se e como o TrainUp pode ganhar conta de usuário sem
jogar fora o que já existe.

## Conclusão

**É viável, e a arquitetura atual ajuda.** O app já separa UI, repositórios e
banco, guarda tudo em SQLite (Drift) e trata as sessões de treino como cópias
independentes da ficha. Um login sozinho tem pouco valor. O que o usuário
ganha com ele é **backup na nuvem, troca de aparelho e o personal acompanhar o
aluno**. Isso exige **sincronização**, e é na sincronização que está o
trabalho de verdade.

O caminho recomendado é **offline-first**:

- o banco local continua sendo a fonte da verdade da interface;
- a conta é opcional;
- um serviço de sincronização roda em segundo plano quando há internet.

O app continua funcionando sem login e sem rede, como hoje.

## O que já está pronto

| Ponto | Por que ajuda |
|---|---|
| Repositórios concretos sobre o `AppDatabase` | A sincronização entra como mais uma camada sobre o mesmo banco; as telas não mudam. |
| Leituras por `Stream` do Drift | Dados que chegam da nuvem e são gravados no banco aparecem sozinhos na tela. |
| Exclusão lógica (`is_active`) em fichas e exercícios | Já é meio caminho para propagar exclusões. |
| Sessões independentes da ficha (snapshots) | Conflitos entre editar uma ficha e o histórico de treinos não existem. |
| `created_at`/`updated_at` na maioria das tabelas | Base para "o que mudou desde a última sincronização". |
| Exportação/importação de fichas em JSON (por nome de exercício) | Já é um formato independente dos ids locais. Pode ser reaproveitado no envio de fichas do personal para o aluno. |
| Migrações explícitas e versionadas | Permitem adicionar colunas de sincronização sem perder dados. |

## O que precisa mudar

### 1. Identificadores globais

Hoje as chaves são inteiros autoincrementais (`id`), que só valem no
aparelho. Dois celulares criariam a "ficha 3" com conteúdos diferentes.

- Adicionar uma coluna `uuid` (texto, única, gerada no aparelho) em todas as
  tabelas sincronizáveis.
- Os `id` inteiros continuam como chave local. As relações (`workout_plan_id`
  etc.) continuam por `id` no aparelho e são traduzidas para `uuid` no envio.
- Migração: preencher `uuid` nas linhas existentes no passo de upgrade.

### 2. Controle de alterações

- **`updated_at` em todas as tabelas sincronizáveis.** As séries
  (`workout_plan_sets`, `workout_session_sets`) e
  `workout_session_exercises` ainda não têm.
- **Marca de "pendente de envio".** Uma coluna `dirty` ou uma tabela
  `sync_outbox`.
- **Exclusões propagáveis.** Hoje algumas exclusões são físicas: séries
  regravadas em `savePlan`, treino excluído do histórico, exercício nunca
  usado. A nuvem precisa saber delas, por meio de uma coluna `deleted_at`
  (*tombstone*) ou de um registro no outbox.
- **Séries regravadas.** `savePlan` hoje apaga e recria as séries da ficha.
  Para sincronizar bem, elas precisam manter o `uuid` ou passar a ser tratadas
  como um bloco único, versionado junto com o exercício da ficha.

### 3. Perfil e catálogo

- `user_profiles` tem `CHECK (id = 1)`: um perfil por aparelho. Com conta, o
  perfil local vira "o usuário logado". A trava pode continuar, porque o app
  continua tendo um usuário por vez, mas trocar de conta exige limpar ou
  separar o banco.
- A coluna `email` existe e hoje é gravada vazia. Ela pode receber o e-mail da
  conta.
- **Exercícios do sistema** (seed) são iguais em todos os aparelhos. Podem
  ganhar `uuid` fixo, definido no código, para não duplicar.
- **Exercícios personalizados** ganham `uuid` como os demais dados. Hoje a
  unicidade é por `normalized_name`. Na sincronização, o mesmo nome criado em
  dois aparelhos precisa ser unificado (*merge* por nome normalizado, como a
  importação de fichas já faz).

### 4. Conflitos

Regra simples, suficiente para um app pessoal: **a última gravação vence**
(`updated_at`), por registro.

- **Treinos concluídos** praticamente não são editados depois de prontos, então
  conflitos são raros.
- **Treino em andamento** é local ao aparelho: só sincroniza depois de
  finalizado ou cancelado.
- **Fichas** podem ser editadas em dois aparelhos. "Última vence" no nível da
  ficha inteira é aceitável.

### 5. Estado que não deve sincronizar

- `timer_states` (temporizador): é do aparelho.
- Algumas preferências (`app_settings`), como o tema, podem ficar locais.
  Outras, como o descanso padrão e o incremento de peso, podem acompanhar a
  conta.

## Opções de backend

| Opção | Prós | Contras |
|---|---|---|
| **Supabase** (Postgres + Auth) | Login com Google/Apple/e-mail pronto; SQL relacional parecido com o esquema local; Row Level Security por usuário; servidor no Brasil (São Paulo). | Sincronização offline-first é feita por nós (outbox + `updated_at`), ou com uma biblioteca como PowerSync. |
| **Firebase** (Auth + Firestore) | Cache offline nativo do Firestore; login pronto. | Modelo de documentos diferente do SQLite; duplicaria a fonte da verdade, ou exigiria espelhar o Drift. Custo por leitura/gravação. |
| **API própria** | Controle total. | Mais código e infraestrutura para manter. |

**Recomendação:** Supabase Auth + Postgres, com sincronização própria
via outbox. Considerar PowerSync se a sincronização ficar complexa.

## Impactos fora do código

- **Privacidade (LGPD):** a política atual diz que os dados nunca saem do
  aparelho, o que deixaria de ser verdade.
  - Peso, gordura e medidas são **dados sensíveis de saúde**. A sincronização
    deles deve ser opcional e exigir consentimento explícito.
  - Será preciso definir controlador, operador (Supabase), local de
    armazenamento e prazo de retenção.
  - O app precisa oferecer **exclusão da conta e dos dados na nuvem** pelo
    próprio app, uma exigência de Google Play e App Store.
- **Google Play, "Segurança dos dados":** declarar coleta de e-mail, dados de
  saúde e de atividade física, criptografia em trânsito e exclusão.
- **App Store:** se houver login com Google, é obrigatório oferecer também
  "Iniciar sessão com a Apple".
- **Custos:** o plano gratuito do Supabase atende o início. Prever um plano
  pago se houver muitos usuários ativos.

## Plano sugerido, em etapas

1. **Preparar o banco** (sem nenhuma mudança visível): schema v2 com `uuid`,
   `updated_at` nas tabelas que faltam e `deleted_at` onde há exclusão física.
   Testes de migração a partir da v1.
2. **Backup manual em arquivo:** exportar e importar tudo (fichas,
   histórico e medidas) num JSON. Resolve a troca de aparelho sem servidor e
   valida o formato que a sincronização vai usar.
3. **Conta opcional + backup na nuvem:** login (Google/Apple), envio e
   restauração completos.
4. **Sincronização contínua** entre aparelhos (outbox, "última vence").
5. **Personal ↔ aluno:** o personal publica fichas para alunos vinculados.
   Hoje isso é feito com o arquivo exportado; depois, direto pela conta.

As etapas 1 e 2 já trazem valor sozinhas e não dependem de decidir o backend.
