# Arquitetura

## Visão geral

```
UI (presentation)  ──watch──▶  Providers (Riverpod)  ──▶  Repositórios (data)  ──▶  Drift / SQLite
       │                                                        │
       └──────────── usa modelos e regras puras ◀── domain ◀────┘
```

- **Repositórios** são classes concretas sobre o `AppDatabase` (sem interfaces
  extras). Leituras expõem `Stream`s do Drift, então qualquer gravação
  atualiza automaticamente as telas que observam aquelas tabelas.
- **Domain** contém regras puras e testáveis: volume, evolução percentual,
  métricas de exercício, `TimerSnapshot`, validações.
- **Estado global**: `databaseProvider`, `settingsProvider`,
  `timerControllerProvider` e `onboardingStatusProvider` são criados uma vez
  no `ProviderScope` raiz. `main.dart` carrega perfil, configurações e timer
  antes do primeiro frame.

## Entidades e relacionamentos

```
UserProfile (id = 1)            BodyMeasurement[]  (histórico; peso obrigatório)

Exercise ◀───────────────┐
  ▲                      │ (restrict)
  │ (restrict)           │
WorkoutPlan ─┬─▶ WorkoutPlanExercise ─┬─▶ WorkoutPlanSet[]
             │      (cascade)         │      (cascade)
             │                        │
             │ (set null)             │ (set null, só referência)
             ▼                        ▼
WorkoutSession ──▶ WorkoutSessionExercise ──▶ WorkoutSessionSet[]
   (cascade)          (snapshot nome/grupo)      (reps, carga, concluída)

AppSettings (id = 1)            TimerState (id = 1)
```

| Tabela | Papel | Destaques |
|---|---|---|
| `user_profiles` | Perfil único | `CHECK (id = 1)`, altura 50–272 cm |
| `body_measurements` | Histórico corporal | peso 20–400 kg, gordura 0–100 %, medidas opcionais, índice em `date` |
| `exercises` | Catálogo | `normalized_name UNIQUE`, `is_active`, `is_custom` |
| `workout_plans` | Fichas | `is_active` (soft delete) |
| `workout_plan_exercises` | Exercício na ficha | `position`, `rest_seconds`, `notes` |
| `workout_plan_sets` | Série planejada | `position`, `repetitions ≥ 0`, `weight_kg ≥ 0` |
| `workout_sessions` | Treino executado | `plan_name_snapshot`, `status` (running/completed/cancelled), `duration_seconds` |
| `workout_session_exercises` | Exercício executado | `exercise_name_snapshot`, `muscle_group_snapshot`, `skipped`, `plan_exercise_id` |
| `workout_session_sets` | Série executada | `planned_*`, `repetitions`, `weight_kg`, `completed`, `completed_at` |
| `app_settings` | Configurações | tema, timer automático, som, vibração, descanso padrão, incremento, unidade |
| `timer_states` | Timer persistido | `status`, `duration_ms`, `started_at_ms`, `elapsed_before_ms` |

### Diferenças em relação ao modelo sugerido

- **Peso/medidas não ficam no perfil.** A medição inicial do onboarding é a
  primeira linha de `body_measurements`; o "peso atual" é a mais recente.
  Isso garante histórico sem lógica de "copiar antes de sobrescrever".
- **`plan_exercise_id` na sessão** (nullable, `ON DELETE SET NULL`): permite a
  opção "atualizar a ficha com este treino" sem acoplar o histórico à ficha.
- **Séries planejadas copiadas para `planned_*`** na série executada, para
  comparar plano × realizado no futuro.
- **Datas** em epoch segundos (padrão Drift); o timer usa epoch **ms** para
  precisão.

### Integridade e exclusões

- Ficha excluída → `is_active = 0`; sessões mantêm `plan_name_snapshot`.
- Exercício usado em ficha ou treino → desativado (não apagado). Recriar com o
  mesmo nome reativa o registro original (mesmo histórico).
- Exercício nunca usado → exclusão física.
- Excluir um treino do histórico é ação explícita (com confirmação) e apaga
  suas séries em cascata.

## Fluxo de criação da ficha

1. `PlanEditorScreen` carrega a ficha como `PlanDraft` (mutável, em memória).
2. Usuário edita nome, adiciona exercícios (`/exercises/pick` retorna o
   `Exercise`), reordena (`ReorderableListView`), define descanso e séries.
3. `WorkoutPlanRepository.savePlan` grava tudo em **uma transação**:
   exercícios existentes mantêm o id (update), removidos são apagados, novos
   inseridos, e as séries de cada exercício são regravadas.

## Fluxo de execução do treino

1. **Iniciar** (`startFromPlan`): falha se já houver sessão `running`; cria a
   sessão e copia exercícios/séries da ficha (snapshot).
2. **Executar**: `WorkoutScreen` observa `sessionDetailProvider`. Cada ação
   (−/+, digitação, ✓, adicionar/remover série, pular, adicionar exercício)
   grava imediatamente; o stream reconstrói a tela.
3. **Concluir série**: `completeSet` salva reps/carga reais e `completed_at`;
   se configurado, inicia o timer com o descanso do exercício (ou o padrão) e
   rola até a próxima série pendente (destacada com borda).
4. **Último treino**: `lastPerformance` busca a sessão concluída mais recente
   com séries concluídas daquele exercício.
5. **Finalizar**: `finishSession` grava `finished_at` e `duration_seconds`;
   opcionalmente `updatePlanFromSession` copia séries/cargas para a ficha.
   Séries não marcadas permanecem como não executadas (fora das estatísticas).
6. **Resumo**: volume, comparação com a sessão anterior da mesma ficha,
   exercícios com aumento de carga e recordes.
7. **App fechado no meio**: `RunningSessionGuard` pergunta, na abertura,
   "Continuar treino" ou "Encerrar treino" (encerrar = finalizar com o que já
   foi registrado).

### Cálculos

- Volume da série = `peso × repetições`; volume do exercício = soma das séries
  **concluídas**; volume do treino = soma dos exercícios.
- Evolução % = `(atual − inicial) / inicial × 100` (`null` se inicial = 0).
- Recordes (somente se houver histórico anterior): maior carga do exercício,
  maior volume do exercício em um treino, maior volume total de treino.

## Timer global

- **Um único `TimerController`** (Riverpod `Notifier`) para o app inteiro. O
  botão flutuante (`TimerOverlay`) fica no `MaterialApp.builder`, acima do
  `Navigator`, então nunca é desmontado ao navegar.
- **Estado = `TimerSnapshot`** imutável: `status`, `duration`, `startedAt`,
  `elapsedBefore`. Restante = `duration − (elapsedBefore + (agora − startedAt))`.
  Pausar acumula em `elapsedBefore`; continuar define novo `startedAt`.
- **Segundo plano / tela bloqueada**: nenhum contador roda; ao voltar
  (`AppLifecycleListener.onResume`) o restante é recalculado pelo relógio.
- **Persistência**: cada mudança de estado grava `timer_states`. Ao reabrir:
  se ainda há tempo, continua; se acabou, mostra "Descanso concluído".
- **Término**: status `finished`, vibração/som conforme configurações (apenas
  se terminou há ≤ 10 s, para não vibrar horas depois).
- Um `Timer.periodic` de 250 ms existe **somente** enquanto está rodando, só
  para atualizar a UI.
- **Aviso de término** (`TimerButton`): ao concluir, mostra "Descanso
  concluído" com X; após 5 s minimiza para um ícone de relógio com check
  (tocar reabre o aviso). Um descanso que terminou com o app fechado abre já
  minimizado.
- **Fim do treino**: finalizar ou cancelar a sessão (inclusive "Encerrar
  treino" na retomada) reseta o timer — o descanso perde o sentido.
- Enquanto os controles (bottom sheet) estão abertos, o botão flutuante fica
  oculto (`timerSheetOpenProvider`). O `TimerOverlay` mantém sempre o mesmo
  `Stack`, para não remontar o `Navigator` ao mostrar/ocultar o botão.

## Histórico

- `watchHistory(limit)` agrega por sessão em SQL (exercícios com séries
  concluídas, séries concluídas, volume) e pagina por `LIMIT` crescente
  (`HistoryLimit`, 20 por página, carregando ao chegar ao fim da lista).
- Somente sessões `completed` aparecem; canceladas são ignoradas.

## Gráficos

- `ProgressChart` (fl_chart): linha única, X = dias desde o primeiro ponto
  (espaçamento proporcional ao tempo real), Y = valor; rótulos `dd/MM`,
  tooltip com data e valor, cor primária do tema (claro/escuro).
- **Exercício**: `watchExerciseHistory` retorna uma entrada por sessão com as
  séries concluídas; `ExerciseMetric` deriva a série (maior peso — padrão —,
  peso médio, volume total, melhor série = maior peso × reps em uma série).
- **Corporal**: `BodyProgressView` lista apenas indicadores com dados e usa a
  ordem cronológica das medições.
- Resumos (`ProgressSummary`): inicial, atual, maior, diferença e %.

## Preparação para o futuro (não implementado)

- Backup/importação: o banco é um arquivo SQLite único; exportar/importar pode
  ser feito copiando o arquivo ou serializando as tabelas.
- Sincronização/login: repositórios isolam o acesso a dados; um repositório
  remoto pode ser adicionado sem tocar nas telas. Colunas `created_at` /
  `updated_at` já existem para resolução de conflitos.
