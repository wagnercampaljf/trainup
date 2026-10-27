import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/error_messages.dart';
import 'empty_state.dart';

/// Renderiza um [AsyncValue] com estados padrão de carregamento e erro.
///
/// O carregamento nunca se passa por lista vazia; o erro explica o que
/// aconteceu e, com [onRetry], permite tentar de novo.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const LoadingState(),
      error: (error, _) => ErrorState(error: error, onRetry: onRetry),
    );
  }
}

/// Carregamento centralizado com rótulo para leitores de tela.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(semanticsLabel: 'Carregando'),
    );
  }
}

/// Falha ao carregar: mensagem compreensível e "Tentar novamente".
class ErrorState extends StatelessWidget {
  const ErrorState({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      key: const Key('error_state'),
      icon: Icons.cloud_off_outlined,
      tone: EmptyStateTone.error,
      message: 'Não foi possível carregar',
      description: friendlyError(error),
      actionLabel: onRetry == null ? null : 'Tentar novamente',
      actionIcon: Icons.refresh,
      onAction: onRetry,
    );
  }
}
