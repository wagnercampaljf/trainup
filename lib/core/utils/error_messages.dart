import 'package:flutter/foundation.dart';

/// Mensagem compreensível para um erro mostrado ao usuário.
///
/// As regras do app lançam `ArgumentError`/`StateError` e exceções próprias
/// com textos em português; esses textos são exibidos. Erros técnicos
/// (banco, arquivos, plataforma) viram uma orientação genérica e são
/// registrados no log de depuração.
String friendlyError(Object error) {
  final message = switch (error) {
    ArgumentError(message: final String m) => m,
    StateError(:final message) => _known[message] ?? message,
    Exception() when !'$error'.contains('Exception') => '$error',
    _ => null,
  };
  if (message == null || message.trim().isEmpty) {
    debugPrint('Erro técnico: $error');
    return 'Tente novamente. Se continuar, feche e abra o app.';
  }
  final trimmed = message.trim();
  return trimmed.endsWith('.') || trimmed.endsWith('?') ? trimmed : '$trimmed.';
}

/// Junta o contexto da ação com a explicação: "Não foi possível salvar.
/// Este treino já foi encerrado."
String actionFailed(String action, Object error) =>
    'Não foi possível $action. ${friendlyError(error)}';

const _known = {
  'O treino não está em andamento': 'Este treino já foi encerrado.',
  'Ficha desativada': 'Esta ficha foi excluída.',
};
