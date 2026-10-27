import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/features/home/domain/next_plan.dart';
import 'package:trainup/features/workout_plans/domain/plan_models.dart';

PlanSummary plan(int id, {int exercises = 3, DateTime? last}) => PlanSummary(
  id: id,
  name: 'Ficha $id',
  exerciseCount: exercises,
  lastPerformedAt: last,
);

void main() {
  test('sem fichas utilizáveis não sugere nada', () {
    expect(suggestNextPlan([]), isNull);
    expect(suggestNextPlan([plan(1, exercises: 0)]), isNull);
  });

  test('prefere a primeira ficha ainda não treinada', () {
    final next = suggestNextPlan([
      plan(1, last: DateTime(2026, 10, 1)),
      plan(2),
      plan(3),
    ])!;
    expect(next.plan.id, 2);
    expect(next.reason, 'Ainda não treinada');
  });

  test('depois, a que está há mais tempo sem treinar', () {
    final next = suggestNextPlan([
      plan(1, last: DateTime(2026, 10, 20)),
      plan(2, last: DateTime(2026, 10, 18)),
      plan(3, last: DateTime(2026, 10, 22)),
      plan(4, exercises: 0),
    ])!;
    expect(next.plan.id, 2);
    expect(next.reason, 'Há mais tempo sem treinar');
  });

  test('com uma ficha só, não fala em comparação', () {
    expect(
      suggestNextPlan([plan(1, last: DateTime(2026, 10, 1))])!.reason,
      'Sua ficha',
    );
  });
}
