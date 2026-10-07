# Relatório de auditoria — TrainUp (antigo Minha Ficha)

> **Nota (06/10/2026):** o app passou a se chamar **TrainUp** (`br.com.trainup.app`, pacote Dart `trainup`, banco `trainup.sqlite`). Os identificadores citados abaixo são os da época da auditoria e foram mantidos como registro.

Data: 05/10/2026 · Flutter 3.47.6 / Dart 3.13.5 · schema do banco v1

## 1. Status geral

**Pronto para beta (testes internos), não pronto para uso geral.**

- Análise estática sem ocorrências; **88 testes passando** (container Linux);
  APK **debug e release gerados** com o código final.
- Corrigidos nesta etapa: perda de valor digitado ao concluir série (alta),
  botão SALVAR desabilitado ao abrir "Editar ficha", contagem/leitura errada de
  exercício repetido, erros de gravação sem tratamento na UI e travamento da
  suíte após falha de teste.
- **Não houve validação em aparelho físico nem emulador** (indisponíveis). Os
  testes de widget não substituem esse teste.
- O release está assinado com a chave de debug (padrão do template) — não serve
  para publicação.

## 2. Arquitetura e arquivos examinados

Feature-first com `data/` (repositórios Drift), `domain/` (regras puras) e
`presentation/` (Riverpod + GoRouter). Detalhes em `docs/architecture.md`.

Examinados em detalhe nesta etapa:

| Área | Arquivos |
|---|---|
| Banco | `lib/core/database/tables.dart`, `app_database.dart`, `drift_schemas/` |
| Sessões | `lib/features/workouts/data/workout_session_repository.dart`, `domain/session_models.dart` |
| Execução | `presentation/workout_screen.dart`, `widgets/set_row.dart`, `weight_input.dart`, `repetition_input.dart`, `session_exercise_card.dart` |
| Fichas | `lib/features/workout_plans/data/workout_plan_repository.dart`, `presentation/plan_editor_screen.dart`, `widgets/plan_exercise_editor.dart` |
| Evolução | `lib/features/progress/presentation/widgets/progress_chart.dart`, `data/progress_repository.dart` |
| Plataforma | `android/app/src/*/AndroidManifest.xml`, `android/app/build.gradle.kts`, `ios/Runner/Info.plist` |
| Testes | todos em `test/` + `tool/docker_test.sh` |
| Logs | todos em `docs/audit-logs/` |

## 3. Comandos e resultados finais

Logs desta etapa: `docs/audit-logs/final-*.txt`. Os demais logs da pasta são
de momentos anteriores do código e **não** validam o estado atual.

| Comando | Resultado | Log |
|---|---|---|
| `flutter pub get` | OK (11 pacotes com versões novas incompatíveis — não atualizados) | `final-pub-get.txt` |
| `dart format .` | 103 arquivos, 0 alterados | `final-format.txt` |
| `flutter analyze` | **No issues found** | `final-analyze.txt` |
| `tool/docker_test.sh test --timeout 120s` | **88 passed, 0 failed** (≈10 s) | `final-test-container.txt` |
| `flutter test` (host Ubuntu 20.04) | 42 passed, 46 failed — **todas** por `GLIBC_2.33 not found` (limitação do ambiente) | `final-test-host.txt` |
| `flutter build apk --debug` | ✓ `app-debug.apk` | `final-build-debug.txt` |
| `flutter build apk --release` | ✓ `app-release.apk` (65,4 MB) | `final-build-release.txt` |

SHA-256: debug `13c8ff3a…f2dc4469`, release `f0952b0c…bf361b3f05b`.

Inspeção do APK release (`aapt`): `minSdk 24`, `targetSdk 36`,
`libsqlite3.so` presente para arm64-v8a, armeabi-v7a e x86_64; única permissão
declarada: `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (interna do AndroidX,
protegida por assinatura).

### Ambiente — ocorrências corrigidas

- O container de build anterior (`minha-ficha-audit-build`) rodou como root e
  foi encerrado externamente (exit 255, sem OOM) durante `assembleRelease`;
  o release nunca terminou e o `chown` final não executou, deixando 1.661
  arquivos do projeto e 219 do SDK/pub-cache como root. Além disso, o comando
  usava `chown 1000:1000`, mas o usuário é **uid 1001** (uid 1000 não existe).
  A posse foi restaurada para 1001:1001 (projeto, `~/.pub-cache`,
  `~/development/flutter`); verificação final: 0 arquivos com outro dono.
- Para reaproveitar NDK/CMake instalados naquele container, foi criada a imagem
  local `minha-ficha-audit-build:sdk-cache` (`docker commit`). O container
  original foi mantido intacto. Nenhum container de outro projeto foi tocado.
- Backup prévio: `../minha-ficha-backup-20261005-155303.tar.gz` (sem `build/`,
  `.dart_tool/`, caches Gradle/Pods).

## 4. Funcionalidades verificadas e nível de evidência

Níveis: **A** = teste automatizado com SQLite real (arquivo ou memória);
**W** = teste de widget (UI simulada, sem aparelho); **I** = inspeção de código
/artefato; **—** = não verificado.

| Funcionalidade | Evidência |
|---|---|
| Criar perfil + 95 kg (onboarding) | A, W |
| Ficha A: Supino 12×30, 10×35, 8×40 | A, W |
| Executar, concluir séries e finalizar | A, W |
| Editar ficha (42,5 kg) sem alterar histórico antigo (40 kg, snapshot de nome) | A (arquivo SQLite) |
| Editar ficha pela UI: salvar e voltar sem diálogo de descarte | W |
| Nova execução e evolução 40 → 42,5 (→ 45) | A, W |
| Nova medição 93 kg preservando 95 kg | A |
| Persistência em arquivo SQLite fechado e reaberto (sessão em andamento, série concluída, perfil, configurações, timer) | A (`durable_audit_test`) |
| `PRAGMA integrity_check` = ok, `foreign_key_check` vazio, `validateDatabaseSchema` | A |
| Retomada de treino em andamento ao reabrir | W |
| Timer: entre abas/perfil, pausar/continuar, término com o app fechado, restauração | A (controller), W |
| Timer em segundo plano real (Android/iOS) | I apenas (cálculo por relógio + `AppLifecycleListener`) — **—** em aparelho |
| 30×10 + 40×8 = 620 kg; 40→50 = +25 %; máxima 40→42,5→45 = 45 | A (`calculations_test`) |
| Digitar 42,5 e tocar ✓ direto (inclusive com eco atrasado do banco) | W |
| Gráficos: 0, 1, mesma data, 1.000 pontos, claro/escuro | W (sem exceção) + I |
| Sem rede em runtime | I (sem código de rede em `lib/`; release sem `INTERNET`) |
| Vibração/som reais, layout em telas físicas, acessibilidade com leitor de tela | **—** |

## 5. Bugs — severidade, reprodução, causa e correção

Legenda de origem: **[ant.]** correção iniciada pelo agente anterior e revisada
aqui; **[nova]** encontrada e corrigida nesta etapa.

### Alta

**B1 [nova] — Série concluída com carga intermediária da digitação.**
- *Reprodução:* digitar "42,5" e tocar ✓ enquanto o banco ainda reenvia o eco
  de "42". A série é gravada com 42,0 kg.
- *Causa:* desde a mudança do item 6 (emitir em `onChanged`), cada tecla grava
  no banco. `SetRow.didUpdateWidget` copiava qualquer valor recebido do banco
  para o estado local, incluindo ecos atrasados.
- *Correção:* `SetRow` guarda a última edição local pendente e ignora ecos até
  o banco refletir esse valor. Mudanças externas, sem edição pendente, continuam
  sendo adotadas.
- *Prova:* `workout_input_audit_test.dart` falha no código anterior
  (`Actual: (6, 42.0)`) e passa no atual.

**B2 [ant.] — Sessões encerradas ou canceladas podiam ter séries alteradas.**
`_requireRunning` foi aplicado dentro da transação em
`updateSet`/`completeSet`/`uncompleteSet`/`addSet`/`removePendingSet`/
`addExercise`/`setSkipped`/`applyValuesToPendingSets`. Revisado e testado.

**B3 [ant.] — Rascunho obsoleto ou com ID de exercício de outra ficha
alterava dados indevidamente.** `savePlan` valida existência, ficha ativa,
pertencimento e IDs repetidos (`StateError` "recarregue"). Revisado e testado.

### Média

**B4 [nova] — SALVAR desabilitado ao abrir "Editar ficha".**
- *Reprodução:* abrir a edição e tocar SALVAR sem alterar nada: nada acontece.
- *Causa:* `_draft` era atribuído dentro do `builder` do `FutureBuilder`, depois
  que a AppBar já tinha avaliado `_draft == null`, e sem `setState`.
- *Correção:* o rascunho é atribuído via `setState` quando o carregamento
  termina; um erro de carregamento agora mostra mensagem, em vez de spinner
  eterno.

**Sobre a falha do teste "edição de ficha salva e volta sem pedir descarte":**
o diagnóstico mostrou `onPressed == null` no momento do toque e o nome
inalterado no banco. Foram dois problemas somados:
- *Teste:* tocava SALVAR logo após `enterText`, sem bombear frame, e depois
  aguardava o banco dentro de `runAsync`. Mas a gravação disparada pela UI roda
  na zona de teste e só avança com `pump`, então nunca concluía.
- *App:* o B4 acima.

O teste foi refeito para avançar frames. Foi incluído o caso "salvar sem
alterações", que reproduzia o B4. A espera de um frame antes do `pop` (item 11
do agente anterior) foi mantida; ela é necessária para o `PopScope` receber
`canPop = true` e agora está coberta por teste.

**B5 [nova] — Exercício repetido na sessão contado em dobro.**
- *Reprodução:* treino com Supino duas vezes, ambas mais pesadas que antes. O
  resumo mostra "2 exercícios com aumento de carga".
- *Correção:* `compareWithPrevious` agrupa por exercício.

**B6 [nova] — "Último treino" incompleto para exercício repetido.**
`lastPerformance` retornava apenas uma ocorrência e não filtrava séries com
0 repetições. Agora junta todas as ocorrências da última sessão (em ordem) e
aplica `repetitions > 0`.

**B7 [nova] — Erros de gravação sem tratamento na tela de treino.** Alterar
peso/reps, remover/adicionar série, pular ou "usar cargas do último treino"
geravam erro não tratado se o repositório rejeitasse a operação (ex.: treino
encerrado em outra tela). Todas as chamadas do card agora passam por um
`_guard`, que mostra mensagem.

**B8 [ant.] — Séries concluídas com 0 repetições geravam recorde falso.**
`completeSet` exige reps > 0, e consultas e cálculos filtram registros antigos.
Revisado: histórico, volume, gráficos, recordes, comparação e "último treino"
(após B6) usam o mesmo critério. Peso 0 continua permitido.

**B9 [ant.] — "Atualizar ficha" copiava séries não executadas.** Agora só as
concluídas são copiadas. O texto do diálogo prometia "cargas e séries de hoje"
e foi ajustado **[nova]** para dizer que séries não concluídas saem da ficha e
que exercícios sem séries concluídas não mudam.

**B10 [ant.] — Recorde de volume de exercício repetido não agregado.** Revisado
e testado (agregação por sessão em consulta e em memória).

### Baixa

- **B11 [ant.]** — "Usar cargas do último treino" desalinhava valores quando
  havia série concluída antes. Revisado e testado.
- **B12 [ant.]** — NaN/infinito aceitos em algumas validações de intervalo.
  Revisado e testado.
- **B13 [ant.]** — Editar só a observação de um exercício não marcava a ficha
  como alterada. Revisado (`onChanged` presente).
- **B14 [ant.]** — Denominador do progresso com exercícios pulados. Revisado:
  `concluídas ⊆ séries do denominador`, então o valor fica sempre em [0, 1].
- **B15 [nova]** — Gráfico com 1.000 pontos desenhava 1.000 marcadores
  sobrepostos. Acima de 60 pontos, mostra só a linha (o toque continua
  exibindo data e valor).

### Infraestrutura de teste

**T1 [nova] — Falha de teste travava a suíte por 10 min e quebrava o teste
seguinte.**
- *Causa:* o teardown fechava o banco enquanto uma transação da UI continuava
  pendente na zona de teste.
- *Correção:* o helper `tearDownWidgetsAndDatabase` desmonta a árvore,
  avança frames e fecha o banco com timeout.
- *Prova:* um teste com falha proposital e gravação pendente terminou em ~2 s,
  e o teste seguinte passou. Os arquivos de prova foram removidos.

## 6. Banco de dados e migrations

- **Integridade:**
  - `PRAGMA foreign_keys = ON` em `beforeOpen`.
  - FKs com `CASCADE` para filhos de ficha e sessão; `RESTRICT` para
    exercícios; `SET NULL` de sessão → ficha.
  - `CHECK` de faixas (peso, reps, gordura, altura, linhas únicas `id = 1`).
  - `UNIQUE` em `normalized_name`.
- **Índices** (11): `body_measurements.date`; `workout_plans.is_active`;
  `workout_plan_exercises.workout_plan_id` e `.exercise_id`;
  `workout_plan_sets.plan_exercise_id`; `workout_sessions.workout_plan_id`,
  `.started_at` e `.status`; `workout_session_exercises.session_id` e
  `.exercise_id`; `workout_session_sets.session_exercise_id`.
  - O schema real foi conferido com `validateDatabaseSchema`, que compara o
    banco aberto com o schema esperado pelo código gerado.
  - **Não há** índice em `workout_session_exercises.plan_exercise_id` (FK
    `SET NULL`: remover um exercício de ficha varre essa tabela) nem em
    `created_at`, que hoje não é usado em consultas. Impacto baixo.
  - Adicionar índice muda o schema e exige uma migração v2; isso **não** foi
    feito para não criar uma migração sem necessidade comprovada.
- **Preservação do histórico:** snapshots de nome da ficha e do exercício;
  soft delete de fichas e de exercícios usados. Testado com arquivo real.
- **Migrations:**
  - `schemaVersion = 1`. `onUpgrade` aplica passos explícitos e lança
    `StateError` para versões sem passo. Nunca recria tabelas.
  - Teste `upgrade sem passo explícito falha sem apagar banco v1`: abrir como
    v2 falha, e reabrir como v1 mantém os dados e `user_version = 1`.
  - **Nenhuma migração v2 foi inventada.**
  - Consequência a conhecer: se uma versão futura subir o schema sem o passo
    correspondente, o app falhará ao abrir o banco, sem apagar dados. Hoje não
    há tela de erro amigável para esse caso.
  - `test/drift/app_database/` está vazio: o `make-migrations` só gera testes
    quando existir uma v2.

## 7. Backup automático e privacidade

| Plataforma | Situação | Consequências |
|---|---|---|
| Android | `allowBackup` não declarado → **Auto Backup ativo** (padrão; targetSdk 36). O banco fica em `app_flutter/` (`getApplicationDocumentsDirectory`), incluído no backup. | **Recuperação:** dados voltam ao trocar de aparelho/reinstalar se o backup do Google estiver ativo. **Privacidade:** peso, medidas e e-mail vão para o Google Drive do usuário (criptografado ponta a ponta quando há bloqueio de tela, Android 9+). Limite de 25 MB. Sem regras `dataExtractionRules`/`fullBackupContent`, não há controle fino. |
| iOS | Banco em `Documents/` → incluído em backups iCloud/Finder. | Mesmo equilíbrio: recuperação de dados × cópia na nuvem da Apple. |

**Não foi alterado.** Desativar o backup protegeria a privacidade, mas faria o
usuário perder todo o histórico ao trocar de aparelho. É uma decisão de
produto; recomenda-se informá-la na política de privacidade antes da
publicação.

**Rede:** o release não declara `INTERNET` e não há código de rede em `lib/`.
O pacote `sqlite3` baixa binários **no build**, não em runtime.

## 8. Testes adicionados ou modificados nesta etapa

- `test/widget/restore_and_progress_test.dart`: teste de edição refeito
  (avança frames) e novo teste "salvar ficha sem alterações também fecha o
  editor"; teardown robusto.
- `test/widget/workout_input_audit_test.dart`: + "eco atrasado do banco não
  sobrescreve carga digitada" e "mudança externa sem edição local é adotada".
- `test/data/audit_regression_test.dart`: + "exercício repetido: comparação
  conta uma vez e último treino junta ocorrências".
- `test/helpers/test_database.dart`: + `tearDownWidgetsAndDatabase`.
- `test/widget/app_flow_test.dart`: passa a usar o novo teardown.

Nenhuma asserção foi enfraquecida e nenhum teste foi removido. A ocorrência
`curly_braces_in_flow_control_structures` em `chart_audit_test.dart` já estava
corrigida; o analyze final está limpo.

## 9. Pendências e limitações

1. **Sem aparelho/emulador:** fluxo físico, segundo plano real, vibração, som,
   teclado numérico, fontes grandes e TalkBack/VoiceOver não foram
   verificados. `/dev/kvm` existe, mas não há `adb`/emulador nem imagem de
   sistema instalados.
2. **Release assinado com chave de debug.** Configurar keystore antes de
   publicar. iOS não compilado (requer macOS/Xcode).
3. **Testes no host** exigem container (glibc 2.31 < 2.33 exigido pelo
   SQLite pré-compilado).
4. Som do timer depende de sons do sistema (ignorados no mobile); não há
   notificação quando o descanso termina com o app em segundo plano.
5. Falha futura de migration não tem tela amigável (o app não abre, os dados
   ficam intactos).
6. Gráfico com várias medições na **mesma data** desenha pontos sobrepostos na
   mesma vertical (sem erro, mas pouco legível).
7. `SetRow`: se uma alteração externa chegar enquanto há edição local pendente,
   o valor local prevalece até o banco refletir a edição. É improvável no uso
   normal, porque só a própria tela grava nessas séries.
8. Índice ausente em `workout_session_exercises.plan_exercise_id` (ver seção 6)
   — incluir na primeira migração v2.
9. Imagem local de build (vários GB, hoje `trainup-build:sdk-cache`) e o
   container parado (hoje `trainup-audit-build`) foram mantidos. Podem ser
   removidos quando não forem mais necessários.

## 10. Checklist

- [x] Backup antes das alterações
- [x] Logs de `docs/audit-logs/` lidos e confrontados com o código atual
- [x] `pub get`, `format`, `analyze` (0 ocorrências)
- [x] Suíte completa: 88/88 (container)
- [x] APK debug gerado com código final
- [x] APK release gerado com código final
- [x] Cenário obrigatório (perfil → 95 kg → Ficha A → treino → editar 42,5 →
      histórico mantém 40 → nova execução 40→42,5 → 93 kg preservando 95) — por
      teste automatizado com SQLite em arquivo
- [x] Persistência com arquivo fechado e reaberto
- [x] Recuperação de sessão e séries em andamento (repositório e UI simulada)
- [x] Timer entre telas, pausa, término com app fechado, restauração (testes)
- [ ] Timer em segundo plano/tela bloqueada em aparelho real
- [x] 620 kg · +25 % · máxima 45 kg
- [x] Foreign keys, índices, integridade, política de migrations
- [x] Upgrade sem passo falha sem apagar dados
- [x] Sem dependência de rede em runtime (inspeção de código e APK)
- [x] Permissões e backup auditados e documentados (sem alteração)
- [x] Gráficos: vazio, 1 registro, mesma data, 1.000 registros (sem exceção)
- [ ] Validação visual dos gráficos em aparelho
- [ ] Validação em aparelho físico ou emulador
- [ ] Build iOS
- [ ] Assinatura de release para publicação

## 11. Conclusão

**Pronto para beta interno.** Os problemas críticos e altos conhecidos foram
corrigidos e cobertos por testes, e os APKs compilam. O app **precisa de
correções/validações antes de uso geral**:
- teste em aparelho real (principalmente timer em segundo plano e entrada de
  dados durante o treino);
- assinatura de release;
- decisão consciente sobre o backup automático.
