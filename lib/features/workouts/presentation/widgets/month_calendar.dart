import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../progress/data/progress_repository.dart';
import '../../../progress/domain/training_frequency.dart';

/// Calendário do mês com os dias treinados (topo do histórico).
///
/// Tocar em um dia treinado o seleciona ([onSelect]) e o histórico passa a
/// mostrar só os treinos daquele dia; tocar de novo limpa a seleção.
/// Os estados não dependem só da cor: treinado = círculo cheio com ponto,
/// hoje = anel, selecionado = quadrado.
class MonthCalendar extends ConsumerStatefulWidget {
  const MonthCalendar({this.selected, this.onSelect, super.key});

  final DateTime? selected;
  final ValueChanged<DateTime?>? onSelect;

  @override
  ConsumerState<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends ConsumerState<MonthCalendar> {
  static const _weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    _month = DateTime(now.year, now.month);
  }

  void _shift(int months) {
    setState(() => _month = DateTime(_month.year, _month.month + months));
    final selected = widget.selected;
    if (selected != null &&
        (selected.year != _month.year || selected.month != _month.month)) {
      widget.onSelect?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    final workouts = ref.watch(monthWorkoutsProvider(_month)).value ?? const [];
    final byDay = <int, List<CompletedWorkout>>{};
    for (final w in workouts) {
      (byDay[w.startedAt.day] ??= []).add(w);
    }
    final isCurrentMonth = _month.year == now.year && _month.month == now.month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = DateTime(_month.year, _month.month).weekday - 1;
    final colors = context.colors;
    final selected = widget.selected;
    final selectedDay =
        selected != null &&
            selected.year == _month.year &&
            selected.month == _month.month
        ? selected.day
        : null;

    return Card(
      key: const Key('month_calendar'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.sm,
          AppSpace.xs,
          AppSpace.sm,
          AppSpace.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mês anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        formatMonthYear(_month),
                        textAlign: TextAlign.center,
                        style: context.text.titleLarge,
                      ),
                      Text(
                        workouts.length == 1
                            ? '1 treino no mês'
                            : '${workouts.length} treinos no mês',
                        key: const Key('month_workout_count'),
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isCurrentMonth ? null : () => _shift(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            ExcludeSemantics(
              child: Row(
                children: [
                  for (final d in _weekdays)
                    Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  _DayCell(
                    day: day,
                    workouts: byDay[day] ?? const [],
                    isToday: isCurrentMonth && day == now.day,
                    isSelected: day == selectedDay,
                    onTap: byDay[day] == null || widget.onSelect == null
                        ? null
                        : () => widget.onSelect!(
                            day == selectedDay
                                ? null
                                : DateTime(_month.year, _month.month, day),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.workouts,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final List<CompletedWorkout> workouts;
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trained = workouts.isNotEmpty;
    final (Color? fill, Color? text) = isSelected
        ? (colors.primary, colors.onPrimary)
        : trained
        ? (colors.tertiary, colors.onTertiary)
        : (null, null);
    final count = workouts.length;
    return Semantics(
      button: trained,
      selected: isSelected,
      label: [
        'Dia $day',
        if (trained) count == 1 ? '1 treino' : '$count treinos',
        if (isToday) 'hoje',
        if (isSelected) 'selecionado',
      ].join(', '),
      excludeSemantics: true,
      child: InkWell(
        key: Key('calendar_day_$day'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: fill,
              // Raio animável: quadrado (selecionado) ↔ círculo (19 = metade).
              borderRadius: BorderRadius.circular(
                isSelected ? AppRadius.sm : 19,
              ),
              border: isToday
                  ? Border.all(
                      color: isSelected ? colors.onSurface : colors.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: context.text.bodyMedium?.tabular.copyWith(
                    color: text ?? (isToday ? colors.primary : null),
                    fontWeight: trained || isToday ? FontWeight.w700 : null,
                    height: 1.1,
                  ),
                ),
                if (trained)
                  Container(
                    width: count > 1 ? 10 : 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: text,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    Widget item(Widget mark, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: AppSpace.xs),
        Text(text, style: style),
      ],
    );
    return ExcludeSemantics(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpace.lg,
        runSpacing: AppSpace.xs,
        children: [
          item(
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            'Treinou',
          ),
          item(
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 2),
              ),
            ),
            'Hoje',
          ),
          item(
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            'Selecionado (toque no dia)',
          ),
        ],
      ),
    );
  }
}
