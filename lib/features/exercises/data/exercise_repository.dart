import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/text_normalizer.dart';
import '../domain/exercise_exceptions.dart';
import '../domain/muscle_group.dart';

/// Resultado da exclusão de um exercício.
enum ExerciseDeletion { deleted, deactivated }

class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  /// Exercícios ativos, filtrados opcionalmente por texto e grupo.
  Stream<List<Exercise>> watchActive({String query = '', MuscleGroup? group}) {
    final normalized = normalizeName(query);
    final select = _db.select(_db.exercises)
      ..where((e) {
        Expression<bool> filter = e.isActive.equals(true);
        if (normalized.isNotEmpty) {
          filter = filter & e.normalizedName.like('%$normalized%');
        }
        if (group != null) {
          filter = filter & e.muscleGroup.equalsValue(group);
        }
        return filter;
      })
      ..orderBy([(e) => OrderingTerm.asc(e.normalizedName)]);
    return select.watch();
  }

  Stream<Exercise?> watchById(int id) => (_db.select(
    _db.exercises,
  )..where((e) => e.id.equals(id))).watchSingleOrNull();

  Future<Exercise?> getById(int id) => (_db.select(
    _db.exercises,
  )..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<Exercise?> _findByNormalizedName(String normalized) => (_db.select(
    _db.exercises,
  )..where((e) => e.normalizedName.equals(normalized))).getSingleOrNull();

  /// Cria um exercício personalizado.
  ///
  /// Se existir um exercício *inativo* com o mesmo nome, ele é reativado
  /// (preservando o histórico). Se existir um ativo, lança
  /// [DuplicateExerciseException].
  Future<int> create({
    required String name,
    required MuscleGroup muscleGroup,
    String? description,
    String? notes,
  }) => _db.transaction(() async {
    final trimmed = name.trim();
    final normalized = normalizeName(trimmed);
    if (normalized.isEmpty) throw ArgumentError('Nome obrigatório');
    final existing = await _findByNormalizedName(normalized);
    if (existing != null) {
      if (existing.isActive) throw DuplicateExerciseException(existing.name);
      await (_db.update(
        _db.exercises,
      )..where((e) => e.id.equals(existing.id))).write(
        ExercisesCompanion(
          name: Value(trimmed),
          muscleGroup: Value(muscleGroup),
          description: Value(_clean(description)),
          notes: Value(_clean(notes)),
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return existing.id;
    }
    return _db
        .into(_db.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: trimmed,
            normalizedName: normalized,
            muscleGroup: muscleGroup,
            description: Value(_clean(description)),
            notes: Value(_clean(notes)),
          ),
        );
  });

  /// Atualiza o cadastro. O histórico mantém o nome antigo (snapshot).
  Future<void> update(
    int id, {
    required String name,
    required MuscleGroup muscleGroup,
    String? description,
    String? notes,
  }) => _db.transaction(() async {
    final trimmed = name.trim();
    final normalized = normalizeName(trimmed);
    if (normalized.isEmpty) throw ArgumentError('Nome obrigatório');
    final existing = await _findByNormalizedName(normalized);
    if (existing != null && existing.id != id) {
      throw DuplicateExerciseException(existing.name);
    }
    await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
      ExercisesCompanion(
        name: Value(trimmed),
        normalizedName: Value(normalized),
        muscleGroup: Value(muscleGroup),
        description: Value(_clean(description)),
        notes: Value(_clean(notes)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  /// Exclui o exercício. Se já foi usado em fichas ou treinos, apenas
  /// desativa (soft delete) para não quebrar o histórico.
  Future<ExerciseDeletion> delete(int id) => _db.transaction(() async {
    final usedInSessions =
        await (_db.selectOnly(_db.workoutSessionExercises)
              ..addColumns([_db.workoutSessionExercises.id])
              ..where(_db.workoutSessionExercises.exerciseId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    final usedInPlans =
        await (_db.selectOnly(_db.workoutPlanExercises)
              ..addColumns([_db.workoutPlanExercises.id])
              ..where(_db.workoutPlanExercises.exerciseId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (usedInSessions != null || usedInPlans != null) {
      await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
        ExercisesCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return ExerciseDeletion.deactivated;
    }
    await (_db.delete(_db.exercises)..where((e) => e.id.equals(id))).go();
    return ExerciseDeletion.deleted;
  });

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

final exerciseRepositoryProvider = Provider(
  (ref) => ExerciseRepository(ref.watch(databaseProvider)),
);

/// Filtro do catálogo: (texto, grupo).
typedef ExerciseFilter = ({String query, MuscleGroup? group});

final exerciseListProvider =
    StreamProvider.family<List<Exercise>, ExerciseFilter>(
      (ref, filter) => ref
          .watch(exerciseRepositoryProvider)
          .watchActive(query: filter.query, group: filter.group),
    );

final exerciseProvider = StreamProvider.family<Exercise?, int>(
  (ref, id) => ref.watch(exerciseRepositoryProvider).watchById(id),
);
