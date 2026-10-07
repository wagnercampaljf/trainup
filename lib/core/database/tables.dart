import 'package:drift/drift.dart';

import '../../features/exercises/domain/muscle_group.dart';
import '../../features/profile/domain/sex.dart';
import '../../features/settings/domain/app_preferences.dart';
import '../../features/timer/domain/timer_status.dart';
import '../../features/workouts/domain/session_status.dart';

/// Colunas de auditoria comuns.
mixin Timestamps on Table {
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Perfil local único (sem login). Sempre id = 1.
///
/// Peso, gordura e medidas NÃO ficam aqui: ficam em [BodyMeasurements], para
/// que cada atualização gere histórico em vez de sobrescrever valores.
@DataClassName('UserProfile')
class UserProfiles extends Table with Timestamps {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get email => text().withLength(max: 254)();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get sex => textEnum<Sex>().nullable()();
  RealColumn get heightCm => real()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (id = 1)',
    'CHECK (height_cm BETWEEN 50 AND 272)',
  ];
}

/// Histórico de peso e medidas corporais (kg, %, cm).
@DataClassName('BodyMeasurement')
@TableIndex(name: 'idx_body_measurements_date', columns: {#date})
class BodyMeasurements extends Table with Timestamps {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get bodyFatPercentage => real().nullable()();
  RealColumn get neck => real().nullable()();
  RealColumn get shoulders => real().nullable()();
  RealColumn get chest => real().nullable()();
  RealColumn get leftArm => real().nullable()();
  RealColumn get rightArm => real().nullable()();
  RealColumn get leftForearm => real().nullable()();
  RealColumn get rightForearm => real().nullable()();
  RealColumn get waist => real().nullable()();
  RealColumn get abdomen => real().nullable()();
  RealColumn get hips => real().nullable()();
  RealColumn get leftThigh => real().nullable()();
  RealColumn get rightThigh => real().nullable()();
  RealColumn get leftCalf => real().nullable()();
  RealColumn get rightCalf => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (weight_kg BETWEEN 20 AND 400)',
    'CHECK (body_fat_percentage IS NULL OR body_fat_percentage BETWEEN 0 AND 100)',
  ];
}

/// Catálogo de exercícios (seed do sistema + personalizados).
///
/// Nunca é apagado fisicamente se houver histórico: usa [isActive].
@DataClassName('Exercise')
class Exercises extends Table with Timestamps {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Nome em minúsculas, sem acentos e espaços extras. Garante unicidade.
  TextColumn get normalizedName => text().unique()();
  TextColumn get muscleGroup => textEnum<MuscleGroup>()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(true))();
}

/// Ficha de treino (planejamento).
@DataClassName('WorkoutPlan')
@TableIndex(name: 'idx_workout_plans_active', columns: {#isActive})
class WorkoutPlans extends Table with Timestamps {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Exercício dentro de uma ficha.
@DataClassName('WorkoutPlanExercise')
@TableIndex(name: 'idx_plan_exercises_plan', columns: {#workoutPlanId})
@TableIndex(name: 'idx_plan_exercises_exercise', columns: {#exerciseId})
class WorkoutPlanExercises extends Table with Timestamps {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutPlanId =>
      integer().references(WorkoutPlans, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.restrict)();
  IntColumn get position => integer()();
  TextColumn get notes => text().nullable()();
  IntColumn get restSeconds => integer().nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (rest_seconds IS NULL OR rest_seconds BETWEEN 0 AND 3600)',
  ];
}

/// Série planejada de um exercício da ficha.
@DataClassName('WorkoutPlanSet')
@TableIndex(name: 'idx_plan_sets_plan_exercise', columns: {#planExerciseId})
class WorkoutPlanSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planExerciseId => integer().references(
    WorkoutPlanExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get position => integer()();
  IntColumn get repetitions => integer()();
  RealColumn get weightKg => real()();
  TextColumn get notes => text().nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (repetitions >= 0)',
    'CHECK (weight_kg >= 0)',
  ];
}

/// Treino executado. Independente da ficha após criado.
@DataClassName('WorkoutSession')
@TableIndex(name: 'idx_sessions_plan', columns: {#workoutPlanId})
@TableIndex(name: 'idx_sessions_started_at', columns: {#startedAt})
@TableIndex(name: 'idx_sessions_status', columns: {#status})
class WorkoutSessions extends Table with Timestamps {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutPlanId => integer().nullable().references(
    WorkoutPlans,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get planNameSnapshot => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => textEnum<SessionStatus>()();

  @override
  List<String> get customConstraints => [
    'CHECK (duration_seconds IS NULL OR duration_seconds >= 0)',
  ];
}

/// Exercício executado em uma sessão (com snapshot de nome e grupo).
@DataClassName('WorkoutSessionExercise')
@TableIndex(name: 'idx_session_exercises_session', columns: {#sessionId})
@TableIndex(name: 'idx_session_exercises_exercise', columns: {#exerciseId})
class WorkoutSessionExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId =>
      integer().references(Exercises, #id, onDelete: KeyAction.restrict)();

  /// Exercício da ficha que originou este item (para "atualizar ficha").
  IntColumn get planExerciseId => integer().nullable().references(
    WorkoutPlanExercises,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get exerciseNameSnapshot => text()();
  TextColumn get muscleGroupSnapshot => textEnum<MuscleGroup>()();
  IntColumn get position => integer()();
  TextColumn get notes => text().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
}

/// Série executada (o que realmente aconteceu).
@DataClassName('WorkoutSessionSet')
@TableIndex(
  name: 'idx_session_sets_session_exercise',
  columns: {#sessionExerciseId},
)
class WorkoutSessionSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionExerciseId => integer().references(
    WorkoutSessionExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get position => integer()();
  IntColumn get plannedRepetitions => integer().nullable()();
  RealColumn get plannedWeightKg => real().nullable()();
  IntColumn get repetitions => integer()();
  RealColumn get weightKg => real()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (repetitions >= 0)',
    'CHECK (weight_kg >= 0)',
  ];
}

/// Configurações locais. Sempre id = 1.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get themePreference => textEnum<ThemePreference>().withDefault(
    Constant(ThemePreference.system.name),
  )();
  BoolColumn get autoStartTimer =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get timerSound => boolean().withDefault(const Constant(true))();
  BoolColumn get timerVibration =>
      boolean().withDefault(const Constant(true))();
  IntColumn get defaultRestSeconds =>
      integer().withDefault(const Constant(90))();
  RealColumn get weightIncrementKg => real().withDefault(const Constant(2.5))();
  TextColumn get weightUnit =>
      textEnum<WeightUnit>().withDefault(Constant(WeightUnit.kg.name))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (id = 1)',
    'CHECK (default_rest_seconds BETWEEN 5 AND 3600)',
    'CHECK (weight_increment_kg BETWEEN 0.25 AND 50)',
  ];
}

/// Estado persistido do temporizador global. Sempre id = 1.
///
/// Instantes em epoch milissegundos para precisão do cálculo do restante.
@DataClassName('TimerStateRow')
class TimerStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get status => textEnum<TimerStatus>()();
  IntColumn get durationMs => integer()();

  /// Instante (epoch ms) em que a contagem foi iniciada/retomada.
  IntColumn get startedAtMs => integer().nullable()();

  /// Tempo já decorrido antes do último início (acumula pausas).
  IntColumn get elapsedBeforeMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 1)'];
}
