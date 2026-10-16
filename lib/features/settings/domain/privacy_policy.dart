/// Política de privacidade exibida no app.
///
/// A mesma redação está publicada em `docs/legal/politica-de-privacidade.html`
/// (URL informada nas lojas). `test/unit/privacy_policy_test.dart` confere que
/// as duas versões continuam iguais.
abstract final class PrivacyPolicy {
  static const appName = 'TrainUp';
  static const controller = 'Campal Dev';
  static const contactEmail = 'wagnercampaljf@gmail.com';
  static const effectiveDate = '14 de outubro de 2026';

  static const sections = <(String, String)>[
    (
      'Resumo',
      'O TrainUp funciona 100% offline. Não há cadastro, login, servidor, '
          'anúncios nem ferramentas de análise. Os dados que você registra '
          'ficam no seu aparelho e não são enviados ao desenvolvedor nem a '
          'terceiros.',
    ),
    (
      'Dados que você registra',
      'Nome (usado na saudação), altura e, se quiser, data de nascimento e '
          'sexo; peso, percentual de gordura e medidas corporais; fichas, '
          'exercícios, treinos realizados, cargas e repetições; preferências '
          'do app e o estado do temporizador. Peso, gordura e medidas são '
          'dados relacionados à saúde (dados pessoais sensíveis segundo a '
          'LGPD) e, por isso, nunca saem do aparelho por ação do app. O app '
          'não pede e-mail, telefone, localização, fotos ou contatos.',
    ),
    (
      'Como os dados são usados',
      'Somente para mostrar suas fichas, seu histórico, gráficos e '
          'indicadores dentro do próprio app. Não há publicidade, criação de '
          'perfil para terceiros nem decisões automatizadas.',
    ),
    (
      'Armazenamento e compartilhamento',
      'Os dados ficam em um banco de dados na área privada do app, no seu '
          'aparelho. O app não acessa a internet, não envia dados ao '
          'desenvolvedor, não compartilha dados com terceiros e não usa '
          'bibliotecas de terceiros que coletem dados.',
    ),
    (
      'Compartilhamento feito por você',
      'Você pode enviar fichas (arquivo) ou a imagem de resumo de um treino '
          'pelo compartilhamento do sistema e importar fichas recebidas. O '
          'envio só acontece quando você toca em compartilhar, contém apenas '
          'o que é mostrado na tela e é feito pelo app que você escolher (por '
          'exemplo, WhatsApp ou e-mail), sob as regras desse app. O arquivo '
          'de fichas não inclui seu perfil, medidas ou histórico.',
    ),
    (
      'Permissões',
      'Notificações e "Alarmes e lembretes" são usados apenas para avisar o '
          'fim do descanso entre séries com o celular bloqueado. O aviso é '
          'agendado no próprio aparelho e nenhum dado é enviado.',
    ),
    (
      'Backup do sistema',
      'Se o backup do aparelho estiver ativado, o Android (backup do Google) '
          'ou o iOS (iCloud) pode incluir os dados do app na cópia de '
          'segurança da sua conta. Esse backup é feito pelo sistema '
          'operacional, sob as regras do Google ou da Apple, e permite '
          'restaurar seus dados em um novo aparelho. O desenvolvedor não tem '
          'acesso a ele. Você pode desativá-lo nas configurações do aparelho.',
    ),
    (
      'Retenção e exclusão',
      'Os dados ficam no aparelho até você excluí-los. Você pode apagar '
          'medições, treinos, fichas e exercícios no próprio app, ou remover '
          'tudo limpando os dados do TrainUp nas configurações do aparelho ou '
          'desinstalando o app. Como o desenvolvedor não recebe seus dados, '
          'não existe cópia em servidores dele.',
    ),
    (
      'Seus direitos',
      'Você tem acesso e controle diretos sobre os dados no aparelho: pode '
          'consultá-los, corrigi-los e excluí-los a qualquer momento. Dúvidas '
          'sobre privacidade ou sobre a LGPD podem ser enviadas ao contato '
          'abaixo.',
    ),
    ('Crianças', 'O app não é direcionado a menores de 13 anos.'),
    (
      'Segurança',
      'Os dados ficam na área privada do app, protegida pelo sistema '
          'operacional. Recomendamos manter o bloqueio de tela ativado.',
    ),
    (
      'Alterações',
      'Mudanças nesta política serão publicadas no app e na página da '
          'política, com nova data de vigência.',
    ),
    ('Contato', 'Responsável: Campal Dev. E-mail: wagnercampaljf@gmail.com.'),
  ];
}
