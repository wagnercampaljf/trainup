import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/workout_session_repository.dart';
import '../domain/session_models.dart';
import 'widgets/month_calendar.dart';
import 'widgets/session_summary_card.dart';

/// Histórico de treinos concluídos: calendário do mês (com filtro por dia)
/// e a lista paginada.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Dia escolhido no calendário; `null` = todos os treinos.
  DateTime? _day;

  /// Mantém o mês exibido ao alternar entre a lista filtrada e a completa.
  final _calendarKey = GlobalKey();

  void _select(DateTime? day) => setState(() => _day = day);

  @override
  Widget build(BuildContext context) {
    final limit = ref.watch(historyLimitProvider);
    final day = _day;
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: AsyncValueWidget(
        value: ref.watch(historyProvider),
        onRetry: () => ref.invalidate(historyProvider),
        data: (sessions) {
          if (sessions.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              message: 'Nenhum treino registrado ainda.',
              description:
                  'Os treinos finalizados aparecem aqui, com o calendário do '
                  'mês.',
              actionLabel: 'Ver fichas',
              actionIcon: Icons.assignment_outlined,
              onAction: () => context.go(Routes.plans),
            );
          }
          final calendar = MonthCalendar(
            key: _calendarKey,
            selected: day,
            onSelect: _select,
          );
          if (day != null) {
            return _DayList(
              calendar: calendar,
              day: day,
              onClear: () => _select(null),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpace.page,
                AppSpace.sm,
                AppSpace.page,
                AppSpace.listBottom,
              ),
              // Itens 0 e 1: calendário e título; depois, os treinos.
              itemCount: 2 + sessions.length + (canLoadMore ? 1 : 0),
              separatorBuilder: (_, position) =>
                  SizedBox(height: position == 0 ? AppSpace.sm : AppSpace.md),
              itemBuilder: (context, position) {
                if (position == 0) return calendar;
                if (position == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpace.md),
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Todos os treinos',
                        style: context.text.titleLarge?.copyWith(fontSize: 19),
                      ),
                    ),
                  );
                }
                final index = position - 2;
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

/// Treinos do dia selecionado, com o filtro ativo visível e "Limpar".
class _DayList extends ConsumerWidget {
  const _DayList({
    required this.calendar,
    required this.day,
    required this.onClear,
  });

  final Widget calendar;
  final DateTime day;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions =
        ref.watch(dayHistoryProvider(day)).value ?? const <SessionSummary>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.page,
        AppSpace.sm,
        AppSpace.page,
        AppSpace.listBottom,
      ),
      children: [
        calendar,
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Treinos de ${formatDate(day)}',
                  key: const Key('history_day_filter'),
                  style: context.text.titleLarge?.copyWith(fontSize: 19),
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('history_clear_filter'),
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Mostrar todos'),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        for (final summary in sessions) ...[
          SessionSummaryCard(
            summary: summary,
            onTap: () => context.push(Routes.historyDetail(summary.id)),
          ),
          const SizedBox(height: AppSpace.md),
        ],
      ],
    );
  }
}
