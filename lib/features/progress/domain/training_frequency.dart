/// Início (segunda-feira, 00:00) da semana de [date]. Semana de segunda a
/// domingo, como no calendário brasileiro de academia.
DateTime startOfWeek(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));

/// Treino concluído, para frequência e calendário.
typedef CompletedWorkout = ({int id, DateTime startedAt, String planName});

/// Frequência de treinos na semana e no mês, com a meta semanal.
class TrainingFrequency {
  const TrainingFrequency({
    required this.weeklyGoal,
    required this.weekCount,
    required this.weekDays,
    required this.monthCount,
    required this.previousMonthCount,
    required this.streakWeeks,
  });

  /// [starts]: início dos treinos concluídos (qualquer ordem). Precisa cobrir
  /// ao menos o mês anterior e as semanas da sequência ([historyWeeks]).
  factory TrainingFrequency.from(
    Iterable<DateTime> starts, {
    required DateTime now,
    required int weeklyGoal,
  }) {
    final week = startOfWeek(now);
    final nextWeek = DateTime(week.year, week.month, week.day + 7);
    final month = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    final previousMonth = DateTime(now.year, now.month - 1);

    var weekCount = 0;
    var monthCount = 0;
    var previousMonthCount = 0;
    final weekDays = <int>{};
    final perWeek = <DateTime, int>{};
    for (final start in starts) {
      if (!start.isBefore(week) && start.isBefore(nextWeek)) {
        weekCount++;
        weekDays.add(start.weekday);
      }
      if (!start.isBefore(month) && start.isBefore(nextMonth)) monthCount++;
      if (!start.isBefore(previousMonth) && start.isBefore(month)) {
        previousMonthCount++;
      }
      perWeek.update(startOfWeek(start), (n) => n + 1, ifAbsent: () => 1);
    }

    // Semanas seguidas com a meta cumprida. A semana atual só entra quando
    // a meta já foi atingida; ainda em andamento, ela não quebra a sequência.
    var streak = 0;
    var cursor = weekCount >= weeklyGoal
        ? week
        : DateTime(week.year, week.month, week.day - 7);
    while ((perWeek[cursor] ?? 0) >= weeklyGoal && streak < historyWeeks) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 7);
    }

    return TrainingFrequency(
      weeklyGoal: weeklyGoal,
      weekCount: weekCount,
      weekDays: weekDays,
      monthCount: monthCount,
      previousMonthCount: previousMonthCount,
      streakWeeks: streak,
    );
  }

  /// Semanas consultadas para a sequência.
  static const historyWeeks = 52;

  /// Primeiro instante que [TrainingFrequency.from] precisa receber.
  static DateTime historyStart(DateTime now) {
    final week = startOfWeek(now);
    final streakStart = DateTime(
      week.year,
      week.month,
      week.day - 7 * historyWeeks,
    );
    final previousMonth = DateTime(now.year, now.month - 1);
    return streakStart.isBefore(previousMonth) ? streakStart : previousMonth;
  }

  final int weeklyGoal;

  /// Treinos concluídos nesta semana (segunda a domingo).
  final int weekCount;

  /// Dias da semana com treino (`DateTime.monday` … `DateTime.sunday`).
  final Set<int> weekDays;

  final int monthCount;
  final int previousMonthCount;

  /// Semanas consecutivas com a meta cumprida.
  final int streakWeeks;

  bool get goalReached => weekCount >= weeklyGoal;

  int get remainingThisWeek => goalReached ? 0 : weeklyGoal - weekCount;
}
