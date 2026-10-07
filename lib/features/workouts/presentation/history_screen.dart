import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/workout_session_repository.dart';
import 'widgets/session_summary_card.dart';

/// Histórico de treinos concluídos (carregamento paginado).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limit = ref.watch(historyLimitProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: AsyncValueWidget(
        value: ref.watch(historyProvider),
        data: (sessions) {
          if (sessions.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              message: 'Nenhum treino registrado ainda.',
              description: 'Inicie um treino a partir de uma ficha.',
              actionLabel: 'Ver fichas',
              onAction: () => context.go(Routes.plans),
            );
          }
          final canLoadMore = sessions.length >= limit;
          return NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (canLoadMore &&
                  metrics.pixels >= metrics.maxScrollExtent - 200) {
                ref.read(historyLimitProvider.notifier).loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
              itemCount: sessions.length + (canLoadMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == sessions.length) {
                  return Center(
                    child: TextButton(
                      onPressed: () =>
                          ref.read(historyLimitProvider.notifier).loadMore(),
                      child: const Text('Carregar mais'),
                    ),
                  );
                }
                final summary = sessions[index];
                return SessionSummaryCard(
                  summary: summary,
                  onTap: () => context.push(Routes.historyDetail(summary.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
