# Auditoria de prontidão para publicação — TrainUp (antigo Minha Ficha)

> **Nota (06/10/2026):** o app passou a se chamar **TrainUp** (`br.com.trainup.app`, pacote Dart `trainup`, banco `trainup.sqlite`). Os identificadores citados abaixo são os da época da auditoria e foram mantidos como registro.

Data: **06/10/2026**, America/Sao_Paulo. Projeto: `/home/wagner/Documentos/projetos/minha-ficha`.

## Parecer

**NÃO ESTÁ PRONTO PARA PUBLICAÇÃO NO GOOGLE PLAY OU NA APP STORE.**

A base funcional permite continuar testes internos, mas há bloqueios de assinatura e privacidade, preparação iOS não validada e quatro problemas funcionais reproduzidos em verificações adicionais.

A suíte normal passou com **123 testes** e a análise estática ficou limpa. Isso não cobre os quatro cenários novos: os testes diagnósticos correspondentes falharam, confirmando problemas que precisam ser corrigidos. O AAB release foi gerado nesta auditoria, mas continua assinado com certificado **Android Debug**.

Esta etapa auditou o estado atual; **não alterou a implementação do aplicativo**. Gerou documentação, logs, artefato AAB e testes diagnósticos temporários. O relatório anterior de 05/10, `audit-report.md`, foi preservado e não representa todos os achados atuais.

## Resultados por loja

| Loja | Status | Razões principais |
|---|---|---|
| Google Play | Não pronto para submissão | AAB com assinatura debug; política de privacidade ausente no app; textos de armazenamento incompatíveis com backups; bugs funcionais pendentes |
| App Store | Não pronto para submissão | Política e contato de suporte ausentes no app; exigência de contato no onboarding; ícone de template; sem archive/assinatura/validação iOS |
| Testes internos locais | Pode continuar com ressalvas | Builds Android e suíte normal passam; corrigir os cenários reproduzidos antes de ampliar o público |

Este é o parecer desta auditoria. Não houve envio às lojas nem uma decisão real de seus revisores. Configurações de console e contas não foram acessadas.

## Comandos e artefatos

| Verificação | Resultado | Evidência desta etapa |
|---|---|---|
| `flutter --version` | Flutter 3.47.6 / Dart 3.13.5 | Terminal e SDK local |
| `flutter pub get` | PASS | `publication-logs/pub-get.txt` |
| `dart format --output=none --set-exit-if-changed .` | PASS — 105 arquivos, 0 mudanças | `publication-logs/format.txt` |
| `flutter analyze` | PASS — No issues found | `publication-logs/analyze.txt` |
| `tool/docker_test.sh test --timeout 120s` | PASS — 123 testes | `publication-logs/tests.txt` |
| Dois testes diagnósticos de repositório | FAIL — 2 problemas reproduzidos | `publication-logs/reproductions.txt` |
| Dois testes diagnósticos de interface | FAIL — 2 problemas reproduzidos | `publication-logs/ui-reproductions.txt` |
| `flutter build appbundle --release` | PASS — 63,1 MB, aproximadamente 56 s | `publication-logs/build-aab.txt` |
| Certificado do AAB, `keytool -printcert -jarfile` | Android Debug — bloqueio de publicação | `publication-logs/aab-signature.txt` |
| APK release existente, `apksigner verify --print-certs` | Assinatura válida, certificado debug | `publication-logs/apk-signature.txt` |
| APK release existente, `aapt dump badging` | minSdk 24 / targetSdk 36 / compileSdk 36 | `publication-logs/apk-metadata.txt` |
| APK release existente, `zipalign -c -P 16 -v 4` | PASS — Verification successful | `publication-logs/apk-zipalign.txt` |
| ELF de bibliotecas 64 bits em APK e AAB | PT_LOAD com alinhamento de pelo menos 16 KB | `publication-logs/native-alignment.txt` |
| Build e execução iOS | NÃO EXECUTADOS — host Linux, sem Xcode | Pendente em macOS |
| Instalação e fluxo em dispositivo/emulador | NÃO EXECUTADOS | ADB sem aparelhos; sem AVD/imagem de sistema disponível |

O container compatível é necessário devido à incompatibilidade já documentada entre glibc do host e a biblioteca SQLite usada nos testes. A suíte desta etapa executou Flutter 3.47.6 sobre o mesmo código e dependências, em Linux compatível. Não foi substituído o SQLite por um mock para obter aprovação.

A tentativa inicial dos testes de interface tinha um problema no próprio teste: faltava inicializar formatação de datas. Ela foi corrigida antes da reprodução válida. O log inicial foi preservado em `ui-reproductions-initial.txt`; não é evidência de defeito do aplicativo.

Os testes diagnósticos foram removidos da descoberta automática após execução, pois esta tarefa não incluiu as respectivas correções. O código exato continua em `reproduction-tests.dart.txt` e `ui-reproduction-tests.dart.txt`, junto aos logs de falha; nenhum teste existente foi removido ou enfraquecido.

### Artefatos identificados

- AAB gerado em 06/10: `build/app/outputs/bundle/release/app-release.aab`.
- APK release inspecionado: `build/app/outputs/flutter-apk/app-release.apk`, existente desde 05/10; não foi reconstruído nesta etapa.
- APK debug existente: `build/app/outputs/flutter-apk/app-debug.apk`; sua geração anterior não foi contada como um build novo nesta etapa.

SHA-256:

```text
APK release: a8716f14424811a9f41dc2a88cfef6207eb94249491c24bf330636455951ed42
AAB release: eeeeb83e83f77da2f641bdcb20802e1b5c79c8afe5be9ba767384954fca12261
```

## Bloqueios e pendências de publicação

### P01 — Release Android assinado com debug

- **Severidade:** bloqueador técnico.
- **Arquivo:** `android/app/build.gradle.kts:36`.
- **Evidência:** `signingConfig = signingConfigs.getByName("debug")`. Certificados tanto do APK quanto do novo AAB apresentam `CN=Android Debug`.
- **Correção necessária:** configurar chave de upload/release, armazenar segredos fora do código, usar Play App Signing e gerar novamente o AAB. Não reutilizar a chave de debug nem criar uma chave definitiva sem definir sua custódia.
- **Status:** pendente. A compilação bem-sucedida não resolve a assinatura. [Documentação de assinatura Android](https://developer.android.com/studio/publish/app-signing).

### P02 — Política de privacidade ausente no aplicativo

- **Severidade:** bloqueador de preparação para ambas as lojas.
- **Evidência:** nenhuma política, rota ou link correspondente encontrado em `lib/`; configurações não têm seção legal.
- **Correção necessária:** política pública com responsável identificado e acesso fácil dentro do app. Explicar uso local de perfil/medidas/treinos, ausência de backend, backups do sistema e remoção de dados. Uma cópia legível offline pode acompanhar o link público.
- **Status:** pendente. Não foi possível verificar se há uma página ou metadado já configurado fora do repositório. A obrigação de acesso dentro do app está ausente. [Apple, seção 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/), [Google, Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en).

### P03 — Informação sobre armazenamento contradiz os backups

- **Severidade:** alta, transparência de privacidade.
- **Arquivos:** `lib/features/profile/presentation/onboarding_screen.dart:117`; `lib/features/settings/presentation/settings_screen.dart:115`; `android/app/src/main/AndroidManifest.xml`; `lib/core/database/app_database.dart`.
- **Evidência:** textos dizem que tudo fica apenas no celular. Android não exclui Auto Backup, e SQLite fica no diretório de documentos do app; Documents também é incluído em backups iOS por padrão.
- **Correção necessária:** informar que a operação é offline e os dados podem integrar backups do sistema, dependendo das configurações do usuário. Definir política de backup e recuperação conscientemente; desligar backup sem alternativa reduz a possibilidade de recuperar anos de histórico.
- **Status:** pendente. Não se constatou transmissão direta do app para um backend. [Android Auto Backup](https://developer.android.com/identity/data/autobackup), [Apple, uso do sistema de arquivos](https://developer.apple.com/documentation/foundation/using-the-file-system-effectively).

### P04 — Onboarding condiciona o acesso a nome e e-mail

- **Severidade:** alta, risco de revisão Apple.
- **Arquivos:** `lib/features/profile/presentation/widgets/profile_form_fields.dart:75` e `:84`; `lib/core/utils/validators.dart:12`; `lib/features/profile/data/profile_repository.dart:48`.
- **Evidência:** campos obrigatórios e validação impedem continuar sem contato, apesar de não haver conta, autenticação ou envio de e-mail.
- **Correção necessária:** tornar contato opcional ou retirar sua exigência; permitir uso das funções de treino sem e-mail. Adaptar UI e validação de persistência de forma consistente.
- **Status:** pendente. O risco é uma inferência da regra 5.1.1(x), que condiciona pedidos de contato à opção do usuário; não é uma rejeição já emitida pela Apple. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).

### P09 — Suporte e identidade de lançamento incompletos

- **Severidade:** alta para contato de suporte; média para identidade.
- **Evidência:** não há contato de suporte no app. Ícones Android e iOS continuam sendo os do template Flutter; ícone iOS de 1024 px tem hash idêntico ao template do SDK.
- **Correção necessária:** disponibilizar contato do responsável e URL de suporte; substituir os ícones por recursos definitivos. Preparar ícone de loja, screenshots e descrição correspondentes ao produto.
- **Status:** pendente. A URL de suporte externa e os metadados dos consoles não foram acessados. Ícone adaptativo/monocromático Android é melhoria de acabamento, não foi identificado como impedimento técnico obrigatório. [Apple, seções 1.5 e 2.1](https://developer.apple.com/app-store/review/guidelines/).

## Problemas funcionais adicionais

### P05 — Zero repetições em uma série já concluída remove sua contribuição

- **Severidade:** alta para consistência dos registros; não há exclusão física da linha.
- **Arquivos:** `lib/features/workouts/data/workout_session_repository.dart:269`; `lib/features/workouts/presentation/widgets/set_row.dart:128`; `lib/features/workouts/domain/session_models.dart:5`.
- **Como reproduzir:** iniciar treino, concluir série 30 kg × 12, editar suas repetições para 0 e finalizar.
- **Causa:** `completeSet` exige repetições positivas, mas `updateSet` aceita zero em uma série concluída. A UI mantém a conclusão e os cálculos/consultas excluem o registro com zero.
- **Efeito:** marcação e estatísticas divergem; série pode sumir da apresentação de histórico e volume.
- **Prova:** diagnóstico esperava rejeição, mas a operação completou normalmente (`Expected throws ArgumentError; emitted null`).
- **Correção proposta:** impedir zero em série concluída ou desfazer a conclusão explicitamente, com mensagem e estado coerentes. Incluir teste da edição após conclusão.
- **Status:** reproduzido, não corrigido nesta etapa.

### P06 — Atualização opcional da ficha excluída interrompe o fluxo de finalização

- **Severidade:** média; a sessão fica concluída e seu histórico permanece salvo.
- **Arquivos:** `lib/features/workouts/presentation/workout_screen.dart:107`; `lib/features/workout_plans/data/workout_plan_repository.dart:71`, `:171` e `updatePlanFromSession`.
- **Como reproduzir:** iniciar treino, voltar para fichas, excluir a ficha, retomar o treino e finalizar marcando “Atualizar a ficha”.
- **Causa:** `getPlan` retorna ficha inativa; UI oferece atualização. `finishSession` já foi executado quando `savePlan` rejeita a ficha inativa. `_finish` não captura a falha para continuar ao resumo.
- **Prova:** sequência de repositórios reproduziu `Bad state: Ficha não encontrada ou desativada`.
- **Correção proposta:** conferir se a ficha está ativa e tratar falha da atualização opcional sem impedir acesso ao resumo. Preservar a conclusão já gravada.
- **Status:** falha de repositório reproduzida e caminho da UI confirmado por leitura; fluxo completo desse cenário em aparelho não executado.

### P07 — SALVAR aceita reentrada e dispara duas operações de criação de medição

- **Severidade:** média, duplicação e navegação concorrente.
- **Arquivo:** `lib/features/body_measurements/presentation/measurement_form_screen.dart:69` e `:160`.
- **Como reproduzir:** preencher peso e acionar SALVAR duas vezes enquanto a primeira persistência está pendente.
- **Causa:** falta bloqueio de reentrada e estado `_saving`; cada chamada usa `repo.create`, que representa uma nova linha. Cada conclusão também tenta sair da tela.
- **Prova:** teste de widget com repositório atrasado esperava uma chamada `create` e registrou duas. A duplicação de chamadas foi reproduzida; duas linhas em banco e duplo retorno de navegação não foram exercitados nesse diagnóstico.
- **Correção proposta:** bloquear reentrada imediatamente e desabilitar o botão durante a gravação; restaurar o estado ao falhar. Revisar os formulários de perfil e exercício, que possuem padrão semelhante.
- **Status:** reproduzido na interface com persistência controlada, não corrigido.

### P08 — Swipe com exclusão pendente deixa Dismissible em estado inválido

- **Severidade:** média, remoção visual e tratamento de falha.
- **Arquivos:** `lib/features/workouts/presentation/widgets/set_row.dart:154` e `:167`; `lib/features/workouts/presentation/widgets/session_exercise_card.dart:186`.
- **Como reproduzir:** arrastar série para remover, manter a exclusão assíncrona pendente e reconstruir o card antes de removê-lo da árvore.
- **Causa:** `onDismissed` inicia uma operação assíncrona, mas não retira a linha da árvore imediatamente. Não há espera em `confirmDismiss` nem restauração da linha se o banco rejeitar a exclusão.
- **Prova:** teste de widget com exclusão pendente registrou `A dismissed Dismissible widget is still part of the tree` após reconstrução.
- **Correção proposta:** coordenar confirmação/exclusão antes de concluir o swipe ou fazer remoção otimista com restauração em caso de erro.
- **Status:** reproduzido em debug com atraso controlado. Não se afirma crash nativo em release; o risco de linha oculta após erro deve ser validado no comportamento final.

## Android: requisitos verificados e pendentes

- `applicationId` próprio: `br.com.minhaficha.minha_ficha`, versão `1.0.0+1`.
- minSdk 24, target/compile 36; target 36 atende à regra vigente para novos apps e atualizações desde 31/08/2026. [Requisitos de API](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en).
- AAB release gerado; certificado debug ainda bloqueia sua utilização. Não foi feito upload para testar respostas do Play Console.
- APK release sem `INTERNET`, permissões perigosas, publicidade ou Health Connect. Só consta a permissão interna AndroidX `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, protegida por assinatura. `INTERNET` de debug/profile serve à ferramenta de desenvolvimento.
- AGP 9.1.0 e NDK 28.2.13676358. Os segmentos ELF das bibliotecas 64 bits no APK e no AAB estão alinhados a pelo menos 16 KB; ZIP do APK passa `zipalign -P 16`. Execução em dispositivo 16 KB e verificação dos APKs derivados pelo Google Play continuam pendentes. Alinhamento estático não prova funcionamento de todos os plugins. [Suporte Android a páginas de 16 KB](https://developer.android.com/guide/practices/page-sizes).
- Preencher **Health apps declaration**, categoria Activity and Fitness, conforme as funções de treino e medidas. O preenchimento real não foi auditado. [Declaração de apps de saúde](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en).
- Preencher Data safety com a definição correta de transmissão/coleta. Processamento só no dispositivo não deve ser declarado automaticamente como coleta remota. Rever backups e acesso efetivo do responsável. [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).
- Conta de desenvolvedor, identidade, situação de produção, ficha da loja, classificação, países e formulários: desconhecidos. **Condicional:** contas pessoais criadas depois de 13/11/2023 têm requisito de teste fechado com pelo menos 12 participantes por 14 dias e solicitação de produção. Não atribuir esse bloqueio à conta sem verificar seu tipo/data. [Requisitos de testes](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

## iOS: requisitos verificados e pendentes

- Bundle ID: `br.com.minhaficha.minhaFicha`; deployment target 15.0; iPhone e iPad habilitados.
- O mínimo de deployment target 13+ vigente desde 09/09/2026 é atendido. A submissão também exige Xcode 26+ e SDK iOS/iPadOS 26+ desde 28/04/2026. Não houve compilação iOS neste host. [Requisitos Apple atuais](https://developer.apple.com/news/upcoming-requirements/).
- `DEVELOPMENT_TEAM` não está configurado no projeto. Confirmar equipe, registro do Bundle ID, certificados, provisioning e archive validado. Isso não prova ausência de uma conta Apple existente.
- Não existe archive/IPA auditável. Compilação Dart/Android não prova que iOS compila, instala ou funciona.
- Privacy manifests não foram encontrados no projeto/pacotes/artefatos iOS locais examinados. O archive final deve ser verificado para manifests e razões de APIs requeridas dos SDKs, incluindo Flutter/path_provider. Como o binário iOS final não existe neste ambiente, ausência em fontes não foi tratada como rejeição binária confirmada. [SDKs de terceiros](https://developer.apple.com/support/third-party-SDK-requirements/), [Required reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
- Conferir App Privacy conforme os dados realmente acessíveis/transmitidos; campos SQLite locais não equivalem automaticamente a coleta pela empresa. [App Privacy](https://developer.apple.com/app-store/app-privacy-details/).
- Validar iPhone/iPad, paisagem, teclado, fontes grandes e VoiceOver; usar TestFlight antes de produção.

## Banco, offline e cobertura funcional

A inspeção e os testes atuais confirmam separação entre planejamento e execução, snapshots, transações, soft delete, FKs e recuperação de sessão. Há testes com SQLite em arquivo fechado e reaberto, integridade e migração não implementada que falha sem apagar dados. Schema atual permanece v1; não existe atualização de schema a validar como sucesso.

Volume, evolução de cargas/medidas, decimais, histórico, restauração de timer e temas possuem testes. A suíte atual também contém verificações de contraste e aviso visual do timer. Não foi encontrado login, backend, analytics, anúncios, crash reporting remoto ou chamadas HTTP em `lib/`.

Limitações restantes:

- Dados locais não têm exportação/importação manual. Backup automático ajuda recuperação, mas não equivale a uma estratégia de recuperação testada em todos os aparelhos.
- Falha de leitura/corrupção de banco na inicialização ocorre antes de `runApp`, sem tela de recuperação. Não se constatou corrupção real; é uma limitação de robustez.
- Timer calcula tempo absoluto corretamente por código/testes, mas som/vibração reais e ciclo completo de background/lock não foram testados nesta etapa. Não há notificação agendada quando o app está suspenso/fechado.
- Gráficos com muitos registros passam testes de widget; desempenho em hardware de entrada, teclado e acessibilidade ainda precisam de validação.
- As 11 notificações de versões incompatíveis disponíveis no `pub get` não são defeitos por si mesmas. Não houve atualização de dependências em massa.

## Plano necessário antes da submissão

1. Corrigir P05–P08 com testes de regressão permanentes, incluindo falhas e latência de persistência.
2. Resolver P02/P03/P04/P09: política, suporte, contato opcional, informação correta sobre backups e ícones definitivos.
3. Configurar assinatura Android de upload; gerar novo AAB e conferir seu certificado. Manter chaves/segredos fora do repositório.
4. Gerar e validar archive iOS com Xcode/SDK exigidos, assinatura e privacy manifests corretos.
5. Executar testes de release em Android e iOS reais: primeiro acesso offline, treino completo, encerramento forçado, recuperação, background, teclado, back/swipe, textos grandes e exclusões.
6. Conferir consoles e metadados: política pública, suporte, Data safety/App Privacy, Health declaration, classificação etária, descrição sem alegações médicas indevidas e requisitos da conta.
7. Fazer distribuição interna/TestFlight e validações automáticas dos consoles, depois repetir os checks sobre o candidato definitivo.

## Checklist de saída

- [x] Código e relatório anterior confrontados com o estado atual
- [x] Análise estática limpa
- [x] Suíte normal atual passa: 123 testes
- [x] Falhas adicionais documentadas com reproduções
- [x] AAB release gerado nesta etapa
- [x] Assinatura e metadados Android auditados
- [x] Alinhamento ELF 64 bits em APK/AAB e ZIP do APK conferidos
- [ ] Quatro problemas funcionais reproduzidos corrigidos
- [ ] Assinatura Android adequada à publicação
- [ ] Política e contato acessíveis no app
- [ ] Privacidade alinhada ao comportamento de backups
- [ ] Exigência de contato no onboarding revisada
- [ ] Ícones definitivos
- [ ] Archive/assinatura/privacy manifests iOS validados
- [ ] Release validado em dispositivos e ambiente 16 KB
- [ ] Declarações, metadados e situação das contas nas lojas conferidos
- [ ] Aprovação dos consoles/revisão de loja

## Conclusão

**PRECISA DE CORREÇÕES E PREPARAÇÃO DE RELEASE.** O aplicativo tem uma base testada, mas a combinação de assinatura debug, ausência de política/suporte no app, riscos de revisão de privacidade, falhas adicionais reproduzidas e ausência de validação iOS impede recomendação de publicação agora.
