import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clock.dart';
import '../../data/progress_repository.dart';

/// Semana atual (meta, dias treinados, sequência) e o mês, no Início.
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
    if (frequency == null) {
      // Reserva o espaço: o carregamento não se passa por "0 treinos".
      return const Card(child: SizedBox(height: 168));
    }
    final today = ref.watch(clockProvider)().weekday;
    final colors = context.colors;
    final green = colors.tertiary;
    final goal = frequency.weeklyGoal;
    final done = frequency.weekCount;
    final streak = frequency.streakWeeks;

    return Card(
      key: const Key('frequency_card'),
      child: InkWell(
        onTap: () => context.go(Routes.history),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpace.sm,
                runSpacing: AppSpace.xs,
                children: [
                  Text(
                    '$done de $goal treinos',
                    style: context.text.headlineSmall?.copyWith(
                      color: frequency.goalReached ? green : null,
                    ),
                  ),
                  if (streak > 0)
                    _Badge(
                      icon: Icons.local_fire_department_outlined,
                      text: streak == 1
                          ? '1 semana na meta'
                          : '$streak semanas na meta',
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                frequency.goalReached
                    ? 'Meta da semana cumprida! 💪'
                    : frequency.remainingThisWeek == 1
                    ? 'Falta 1 treino para a meta da semana.'
                    : 'Faltam ${frequency.remainingThisWeek} treinos para a '
                          'meta da semana.',
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                    Expanded(
                      child: _DayDot(
                        label: dayLabels[day - 1],
                        semantics: _dayNames[day - 1],
                        trained: frequency.weekDays.contains(day),
                        isToday: day == today,
                        isFuture: day > today,
                      ),
                    ),
                ],
              ),
              const Divider(height: AppSpace.xl),
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
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm + 2,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onTertiaryContainer),
          const SizedBox(width: AppSpace.xs),
          Text(
            text,
            style: context.text.labelMedium?.copyWith(
              color: colors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dia da semana: treinado = verde com ✓; hoje = contorno azul e rótulo em
/// negrito (sem depender só da cor); dias futuros ficam mais apagados.
class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.semantics,
    required this.trained,
    required this.isToday,
    required this.isFuture,
  });

  final String label;
  final String semantics;
  final bool trained;
  final bool isToday;
  final bool isFuture;

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
            isToday ? 'Hoje' : label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: context.text.labelSmall?.copyWith(
              color: isToday ? colors.primary : colors.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.w800 : null,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trained
                  ? colors.tertiary
                  : isFuture
                  ? null
                  : colors.surfaceContainerHigh,
              border: isToday
                  ? Border.all(color: colors.primary, width: 2)
                  : isFuture
                  ? Border.all(color: colors.outlineVariant)
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
        Text(value, style: context.text.titleMedium?.tabular),
      ],
    );
  }
}
