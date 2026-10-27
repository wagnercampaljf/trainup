import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../progress/data/progress_repository.dart';
import '../../../progress/domain/training_frequency.dart';

/// Calendário do mês com os dias treinados (topo do histórico).
class MonthCalendar extends ConsumerStatefulWidget {
  const MonthCalendar({super.key});

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

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  Future<void> _openDay(List<CompletedWorkout> workouts) async {
    if (workouts.length == 1) {
      await context.push(Routes.historyDetail(workouts.single.id));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatDate(workouts.first.startedAt),
              style: sheetContext.text.titleMedium,
            ),
            for (final w in workouts)
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(w.planName),
                subtitle: Text(formatDateTime(w.startedAt)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(Routes.historyDetail(w.id));
                },
              ),
          ],
        ),
      ),
    );
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

    return Card(
      key: const Key('month_calendar'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
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
                  child: Text(
                    formatMonthYear(_month),
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isCurrentMonth ? null : () => _shift(1),
                ),
              ],
            ),
            Text(
              workouts.length == 1
                  ? '1 treino no mês'
                  : '${workouts.length} treinos no mês',
              key: const Key('month_workout_count'),
              style: context.text.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
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
            const SizedBox(height: 4),
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
                    onTap: byDay[day] == null
                        ? null
                        : () => _openDay(byDay[day]!),
                  ),
              ],
            ),
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
    required this.onTap,
  });

  final int day;
  final List<CompletedWorkout> workouts;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trained = workouts.isNotEmpty;
    return Semantics(
      button: trained,
      label:
          'Dia $day${trained ? ', ${workouts.length} ${workouts.length == 1 ? 'treino' : 'treinos'}' : ''}',
      excludeSemantics: true,
      child: InkWell(
        key: Key('calendar_day_$day'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: trained ? colors.tertiary : null,
              border: isToday
                  ? Border.all(color: colors.primary, width: 2)
                  : null,
            ),
            child: Text(
              '$day',
              style: context.text.bodyMedium?.copyWith(
                color: trained ? colors.onTertiary : null,
                fontWeight: trained || isToday ? FontWeight.w700 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
