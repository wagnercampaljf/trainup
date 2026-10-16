import 'dart:convert';

import '../../exercises/domain/muscle_group.dart';

/// Arquivo de fichas inválido ou de outra versão.
class PlanTransferException implements Exception {
  const PlanTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Série de uma ficha exportada.
class TransferSet {
  const TransferSet({
    required this.repetitions,
    required this.weightKg,
    this.notes,
  });

  final int repetitions;
  final double weightKg;
  final String? notes;
}

/// Exercício de uma ficha exportada. Identificado pelo nome: os ids do banco
/// não valem em outro aparelho.
class TransferExercise {
  const TransferExercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    this.restSeconds,
    this.notes,
  });

  final String name;
  final MuscleGroup muscleGroup;
  final int? restSeconds;
  final String? notes;
  final List<TransferSet> sets;
}

class TransferPlan {
  const TransferPlan({
    required this.name,
    required this.exercises,
    this.description,
  });

  final String name;
  final String? description;
  final List<TransferExercise> exercises;
}

/// Conjunto de fichas para enviar a outro aparelho (ex.: do personal para o
/// aluno).
///
/// Formato JSON versionado:
/// ```json
/// {"app": "TrainUp", "type": "workout_plans", "version": 1,
///  "exportedAt": "2026-10-14T10:00:00.000Z",
///  "plans": [{"name": "Ficha A", "description": null, "exercises": [
///    {"name": "Supino reto", "muscleGroup": "chest", "restSeconds": 90,
///     "notes": null, "sets": [{"repetitions": 12, "weightKg": 30.0}]}]}]}
/// ```
class PlanBundle {
  const PlanBundle({required this.plans, this.exportedAt});

  static const app = 'TrainUp';
  static const type = 'workout_plans';
  static const version = 1;

  /// Limite de segurança para arquivos maliciosos ou corrompidos.
  static const maxBytes = 2 * 1024 * 1024;

  final List<TransferPlan> plans;
  final DateTime? exportedAt;

  int get exerciseCount =>
      plans.fold(0, (sum, plan) => sum + plan.exercises.length);

  String toJson() => const JsonEncoder.withIndent('  ').convert({
    'app': app,
    'type': type,
    'version': version,
    'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
    'plans': [
      for (final plan in plans)
        {
          'name': plan.name,
          'description': plan.description,
          'exercises': [
            for (final exercise in plan.exercises)
              {
                'name': exercise.name,
                'muscleGroup': exercise.muscleGroup.name,
                'restSeconds': exercise.restSeconds,
                'notes': exercise.notes,
                'sets': [
                  for (final set in exercise.sets)
                    {
                      'repetitions': set.repetitions,
                      'weightKg': set.weightKg,
                      'notes': set.notes,
                    },
                ],
              },
          ],
        },
    ],
  });

  /// Lê e valida um arquivo exportado. Lança [PlanTransferException] com
  /// uma mensagem para o usuário se o conteúdo não for aceitável.
  static PlanBundle fromJson(String source) {
    if (source.length > maxBytes) {
      throw const PlanTransferException('Arquivo grande demais.');
    }
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const PlanTransferException(
        'Este arquivo não é uma ficha do TrainUp.',
      );
    }
    if (root is! Map<String, Object?> ||
        root['app'] != app ||
        root['type'] != type) {
      throw const PlanTransferException(
        'Este arquivo não é uma ficha do TrainUp.',
      );
    }
    final fileVersion = root['version'];
    if (fileVersion is! int || fileVersion > version) {
      throw const PlanTransferException(
        'Ficha criada por uma versão mais nova do TrainUp. '
        'Atualize o app para importar.',
      );
    }
    final plans = _list(
      root['plans'],
      'fichas',
    ).map(_plan).toList(growable: false);
    if (plans.isEmpty) {
      throw const PlanTransferException('O arquivo não contém fichas.');
    }
    return PlanBundle(
      plans: plans,
      exportedAt: DateTime.tryParse(root['exportedAt'] as String? ?? ''),
    );
  }

  static TransferPlan _plan(Object? value) {
    final map = _map(value, 'ficha');
    return TransferPlan(
      name: _name(map['name'], 'Nome da ficha', maxLength: 100),
      description: _optionalText(map['description']),
      exercises: _list(
        map['exercises'],
        'exercícios',
      ).map(_exercise).toList(growable: false),
    );
  }

  static TransferExercise _exercise(Object? value) {
    final map = _map(value, 'exercício');
    final group = MuscleGroup.values
        .where((g) => g.name == map['muscleGroup'])
        .firstOrNull;
    final rest = map['restSeconds'];
    if (rest != null && (rest is! int || rest < 0 || rest > 3600)) {
      throw const PlanTransferException('Descanso inválido no arquivo.');
    }
    return TransferExercise(
      name: _name(map['name'], 'Nome do exercício', maxLength: 100),
      // Grupos desconhecidos (versões futuras) viram "Outro".
      muscleGroup: group ?? MuscleGroup.other,
      restSeconds: rest as int?,
      notes: _optionalText(map['notes']),
      sets: _list(map['sets'], 'séries').map(_set).toList(growable: false),
    );
  }

  static TransferSet _set(Object? value) {
    final map = _map(value, 'série');
    final reps = map['repetitions'];
    final weight = map['weightKg'];
    if (reps is! int || reps < 0 || reps > 1000) {
      throw const PlanTransferException('Repetições inválidas no arquivo.');
    }
    if (weight is! num || !weight.isFinite || weight < 0 || weight > 2000) {
      throw const PlanTransferException('Peso inválido no arquivo.');
    }
    return TransferSet(
      repetitions: reps,
      weightKg: weight.toDouble(),
      notes: _optionalText(map['notes']),
    );
  }

  static Map<String, Object?> _map(Object? value, String what) {
    if (value is Map<String, Object?>) return value;
    throw PlanTransferException('Conteúdo inválido no arquivo ($what).');
  }

  static List<Object?> _list(Object? value, String what) {
    if (value is List<Object?>) return value;
    throw PlanTransferException('Conteúdo inválido no arquivo ($what).');
  }

  static String _name(Object? value, String field, {required int maxLength}) {
    final text = value is String ? value.trim() : '';
    if (text.isEmpty || text.length > maxLength) {
      throw PlanTransferException('$field inválido no arquivo.');
    }
    return text;
  }

  static String? _optionalText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
