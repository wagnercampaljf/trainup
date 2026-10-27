import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/clock.dart';
import '../../data/progress_repository.dart';

/// Treinos da semana (com a meta) e do mês, na Home.
class FrequencyCard extends ConsumerWidget {
  const FrequencyCard({super.key});

  static const dayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  static const _dayNames = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequency = ref.watch(trainingFrequencyProvider).value;
    if (frequency == null) return const SizedBox.shrink();
    final today = ref.watch(clockProvider)().weekday;
    final green = context.colors.tertiary;
    final goal = frequency.weeklyGoal;
    final done = frequency.weekCount;

    return Card(
      key: const Key('frequency_card'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.history),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Esta semana', style: context.text.titleSmall),
                  ),
                  Text(
                    '$done de $goal treinos',
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: frequency.goalReached ? green : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (done / goal).clamp(0, 1),
                  minHeight: 6,
                  color: green,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  semanticsLabel: 'Meta semanal: $done de $goal treinos',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                    _DayDot(
                      label: dayLabels[day - 1],
                      semantics: _dayNames[day - 1],
                      trained: frequency.weekDays.contains(day),
                      isToday: day == today,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                frequency.goalReached
                    ? 'Meta da semana cumprida! 💪'
                    : frequency.remainingThisWeek == 1
                    ? 'Falta 1 treino para a meta da semana.'
                    : 'Faltam ${frequency.remainingThisWeek} treinos para a '
                          'meta da semana.',
                style: context.text.bodyMedium,
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MonthStat(
                      label: 'Este mês',
                      value: _workouts(frequency.monthCount),
                    ),
                  ),
                  Expanded(
                    child: _MonthStat(
                      label: 'Mês passado',
                      value: _workouts(frequency.previousMonthCount),
                    ),
                  ),
                  Expanded(
                    child: _MonthStat(
                      label: 'Sequência na meta',
                      value: frequency.streakWeeks == 1
                          ? '1 semana'
                          : '${frequency.streakWeeks} semanas',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _workouts(int count) =>
      count == 1 ? '1 treino' : '$count treinos';
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.semantics,
    required this.trained,
    required this.isToday,
  });

  final String label;
  final String semantics;
  final bool trained;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label:
          '$semantics${trained ? ', treinou' : ''}${isToday ? ', hoje' : ''}',
      excludeSemantics: true,
      child: Column(
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.w800 : null,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trained ? colors.tertiary : colors.surfaceContainerHighest,
              border: isToday
                  ? Border.all(color: colors.primary, width: 2)
                  : null,
            ),
            child: trained
                ? Icon(Icons.check, size: 18, color: colors.onTertiary)
                : null,
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  const _MonthStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
