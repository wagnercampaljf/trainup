# Publicação na Google Play — TrainUp

Guia do que já está pronto no projeto e do que precisa ser feito no Play
Console (ações da sua conta, que não podem ser feitas daqui).

## 1. Artefatos prontos

| Item | Arquivo | Especificação |
|---|---|---|
| App bundle assinado | `build/app/outputs/bundle/release/app-release.aab` | `br.com.trainup.app`, versão 1.0.0 (1), alvo Android 16 (API 36), assinado com a chave de envio |
| Ícone da loja | `docs/branding/trainup-icon-play-512.png` | 512 × 512, PNG 32 bits |
| Banner (feature graphic) | `docs/play-store/feature-graphic-1024x500.png` | 1024 × 500, PNG 24 bits |
| Capturas de celular | `docs/play-store/screenshots/01…08` | 8 imagens 1080 × 1920 (9:16), PNG 24 bits |
| Política de privacidade | `docs/legal/politica-de-privacidade.html` | Mesma redação exibida no app (Perfil e Configurações) |

Para regenerar: `python3 tool/generate_icons.py`,
`python3 tool/generate_store_assets.py`, `python3 tool/generate_privacy_html.py`
e `flutter build appbundle --release`.

## 2. Chave de envio (faça backup agora)

- Keystore: `android/keystore/trainup-upload.jks` (alias `upload`).
- Senha: em `android/key.properties`.
- **Guarde os dois fora deste computador** (gerenciador de senhas ou cofre).
  Sem a chave, você não consegue enviar atualizações. Com o *Play App
  Signing* (padrão para apps novos), dá para pedir a troca da chave de envio
  ao suporte do Google, mas o processo leva dias.
- Os dois arquivos estão no `.gitignore` do Android: nunca os publique.

## 3. Hospedar a política de privacidade

O Play Console exige uma URL pública (não PDF, sem login). A forma mais
simples e gratuita é o GitHub Pages:

1. Crie um repositório público, por exemplo `trainup-legal`.
2. Envie `docs/legal/politica-de-privacidade.html` com o nome `index.html`.
3. Em *Settings → Pages*, publique a branch principal.
4. A URL será `https://SEU-USUARIO.github.io/trainup-legal/`.

Google Sites ou qualquer hospedagem estática também servem. Se mudar o texto,
edite `lib/features/settings/domain/privacy_policy.dart`, rode
`python3 tool/generate_privacy_html.py` e publique o HTML de novo (o teste
`test/unit/privacy_policy_test.dart` garante que as duas versões são iguais).

## 4. Página da loja

- **Nome do app** (24/30): `TrainUp: Ficha de Treino`
- **Descrição curta** (79/80):
  `Monte suas fichas de academia, registre as cargas e veja sua evolução. Offline.`
- **Categoria:** Saúde e fitness. **Tags:** academia, musculação, treino.
- **E-mail de contato:** wagnercampaljf@gmail.com
- **Descrição completa** (≈1.600/4.000):

```
Monte suas fichas de academia, registre cada série e acompanhe a evolução das suas cargas e do seu corpo, tudo em um app simples, rápido e 100% offline.

FICHAS DO SEU JEITO
• Crie quantas fichas quiser (Ficha A, B, C…), com os exercícios na ordem que preferir.
• Cada série pode ter repetições e carga diferentes (ex.: 12 × 30 kg, 10 × 35 kg, 8 × 40 kg).
• Defina o descanso de cada exercício e anote observações.
• Catálogo com exercícios comuns e opção de cadastrar os seus.

TREINO SEM COMPLICAÇÃO
• Ajuste carga e repetições com botões grandes, pensados para usar com uma mão.
• Veja o que você fez no último treino de cada exercício e aumente a carga com um toque.
• Cada série concluída é salva na hora: fechar o app não faz perder nada.
• Adicione séries ou exercícios e pule o que não for fazer, sem mexer na ficha.

TEMPORIZADOR DE DESCANSO
• Começa sozinho ao concluir uma série, com o descanso configurado.
• Fica disponível em qualquer tela e continua contando com o celular bloqueado.
• Presets de 30 s a 3 min, ajuste de ±15 s, pausa e vibração ao terminar (com o app aberto).

SUA EVOLUÇÃO
• Histórico completo de treinos, com duração, séries e volume.
• Gráfico de evolução de carga por exercício (maior peso, peso médio, volume e melhor série).
• Recordes pessoais destacados ao fim do treino.
• Peso, percentual de gordura e medidas corporais com histórico e gráficos.

PRIVACIDADE DE VERDADE
• Sem cadastro, sem login e sem anúncios.
• Funciona sem internet: seus dados ficam no seu celular e não são enviados a nenhum servidor.

Tema claro e escuro. Feito para quem treina e quer ver, em números, o resultado do esforço.
```

## 5. Respostas do Play Console (*Conteúdo do app*)

| Seção | Resposta | Por quê |
|---|---|---|
| Política de privacidade | URL da etapa 3 | Obrigatória para todos os apps |
| Acesso ao app | Todas as funcionalidades sem restrição | Não há login |
| Anúncios | Não contém anúncios | — |
| ID de publicidade | Não usa | Nenhum SDK de anúncios/análise |
| Classificação de conteúdo (IARC) | Categoria utilitário/outro; "não" para violência, sexo, linguagem, drogas, apostas, interação entre usuários, compartilhamento de localização e compras | Deve resultar em classificação livre |
| Público-alvo | 18 anos ou mais (recomendado) | Evita as regras do programa Famílias; a política diz que o app não é para menores de 13 |
| Segurança dos dados | "O app não coleta nem compartilha dados" | Tudo é processado só no aparelho; o app não tem permissão de internet. O backup automático é feito pelo Android (conta Google do usuário), não pelo app — está explicado na política |
| Declaração de apps de saúde | Informe recursos de **condicionamento físico** (registro de treinos) e **acompanhamento de peso/medidas**; não é dispositivo médico; não usa Health Connect | Obrigatória para todos os apps desde 2025 |
| App de notícias / governo / COVID / financeiro | Não | — |

Se o Google discordar de alguma resposta, ele avisa na revisão; nada aqui
envolve coleta real de dados, então os ajustes costumam ser só de formulário.

## 6. Envio e testes

1. **Crie o app** no Play Console (idioma padrão: português do Brasil; app
   gratuito).
2. **Teste interno** (rápido, até 100 pessoas): envie o `app-release.aab` e
   instale pelo link de teste para conferir o app em aparelho real.
3. **Teste fechado obrigatório** (contas pessoais criadas após 13/11/2023):
   pelo menos **12 testadores ativos por 14 dias seguidos**. Recrute 15 a 20,
   porque desistências zeram a contagem. Contas de organização (com D-U-N-S)
   são isentas.
4. Após os 14 dias, **solicite acesso à produção** e responda ao questionário
   sobre o teste.
5. Confira o **relatório de pré-lançamento** (testes automáticos do Google em
   aparelhos reais) antes de liberar.
6. Próximas versões: aumente `version` no `pubspec.yaml` (ex.: `1.0.1+2`) e
   gere um novo AAB. O `versionCode` (número após o `+`) precisa sempre subir.

Aviso esperado (não bloqueia): o Play Console pode sugerir enviar símbolos de
depuração nativos. É opcional.

## 7. Situação dos achados da auditoria de publicação

Itens de `docs/publication-audit-report.md` (06/10/2026):

| Item | Situação |
|---|---|
| P01 — release assinado com chave de debug | Corrigido: chave de envio própria (`key.properties`) |
| P02 — política de privacidade ausente no app | Corrigido: tela no Perfil, nas Configurações e no primeiro acesso + HTML para a loja |
| P03 — texto de armazenamento ignorava backups | Corrigido: textos do app e da política citam o backup do sistema |
| P04 — e-mail obrigatório no cadastro | Corrigido: campo removido (o app não coleta e-mail) |
| P05 — 0 repetições em série concluída | Corrigido no repositório e no campo; teste de regressão |
| P06 — atualizar ficha excluída travava o fim do treino | Corrigido: opção só aparece com ficha ativa; falha não bloqueia o resumo |
| P07 — SALVAR repetido duplicava medição | Corrigido em medição, perfil, exercício e resumo do treino |
| P08 — remoção por arrasto em estado inválido | Corrigido: remoção otimista com restauração em caso de falha |
| P09 — suporte/identidade | Contato no app (política) e na loja; ícone e nome próprios. URL de suporte é exigência da Apple (iOS fora deste escopo) |
