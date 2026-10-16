import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/features/exercises/domain/muscle_group.dart';
import 'package:trainup/features/workout_plans/domain/plan_transfer.dart';

void main() {
  const bundle = PlanBundle(
    plans: [
      TransferPlan(
        name: 'Ficha A',
        description: 'Peito',
        exercises: [
          TransferExercise(
            name: 'Supino reto',
            muscleGroup: MuscleGroup.chest,
            restSeconds: 90,
            notes: 'Pegada média',
            sets: [
              TransferSet(repetitions: 12, weightKg: 30),
              TransferSet(repetitions: 8, weightKg: 42.5, notes: 'Falha'),
            ],
          ),
        ],
      ),
    ],
  );

  Map<String, Object?> decoded() =>
      jsonDecode(bundle.toJson()) as Map<String, Object?>;

  test('ida e volta preserva fichas, exercícios e séries', () {
    final restored = PlanBundle.fromJson(bundle.toJson());
    final plan = restored.plans.single;
    expect(plan.name, 'Ficha A');
    expect(plan.description, 'Peito');
    final exercise = plan.exercises.single;
    expect(exercise.name, 'Supino reto');
    expect(exercise.muscleGroup, MuscleGroup.chest);
    expect(exercise.restSeconds, 90);
    expect(exercise.notes, 'Pegada média');
    expect(exercise.sets.map((s) => (s.repetitions, s.weightKg, s.notes)), [
      (12, 30.0, null),
      (8, 42.5, 'Falha'),
    ]);
    expect(restored.exerciseCount, 1);
  });

  test('aceita peso inteiro e grupo muscular desconhecido', () {
    final json = decoded();
    final exercise =
        ((json['plans']! as List).single as Map)['exercises'] as List;
    (exercise.single as Map)['muscleGroup'] = 'grupoNovo';
    final restored = PlanBundle.fromJson(jsonEncode(json));
    final parsed = restored.plans.single.exercises.single;
    expect(parsed.muscleGroup, MuscleGroup.other);
    expect(parsed.sets.first.weightKg, 30.0);
  });

  test('rejeita arquivos que não são fichas do TrainUp', () {
    for (final source in [
      'texto qualquer',
      '[]',
      '{"app": "Outro", "type": "workout_plans", "version": 1, "plans": []}',
      '{"app": "TrainUp", "type": "backup", "version": 1, "plans": []}',
    ]) {
      expect(
        () => PlanBundle.fromJson(source),
        throwsA(isA<PlanTransferException>()),
        reason: source,
      );
    }
  });

  test('rejeita versão mais nova e conteúdo inválido', () {
    String edited(void Function(Map<String, Object?>) edit) {
      final json = decoded();
      edit(json);
      return jsonEncode(json);
    }

    final newer = edited((j) => j['version'] = PlanBundle.version + 1);
    expect(
      () => PlanBundle.fromJson(newer),
      throwsA(
        isA<PlanTransferException>().having(
          (e) => e.message,
          'message',
          contains('versão mais nova'),
        ),
      ),
    );

    final empty = edited((j) => j['plans'] = <Object>[]);
    expect(
      () => PlanBundle.fromJson(empty),
      throwsA(isA<PlanTransferException>()),
    );

    Map<String, Object?> firstSet(Map<String, Object?> j) {
      final plan = (j['plans']! as List).single as Map<String, Object?>;
      final exercise =
          (plan['exercises']! as List).single as Map<String, Object?>;
      return (exercise['sets']! as List).first as Map<String, Object?>;
    }

    for (final edit in <void Function(Map<String, Object?>)>[
      (j) => firstSet(j)['repetitions'] = -1,
      (j) => firstSet(j)['repetitions'] = 'doze',
      (j) => firstSet(j)['weightKg'] = -5,
      (j) =>
          ((j['plans']! as List).single as Map<String, Object?>)['name'] = '  ',
    ]) {
      expect(
        () => PlanBundle.fromJson(edited(edit)),
        throwsA(isA<PlanTransferException>()),
      );
    }
  });
}
