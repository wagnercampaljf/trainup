import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/timer_snapshot.dart';

/// Persiste o estado do temporizador para restaurá-lo ao reabrir o app.
class TimerRepository {
  TimerRepository(this._db);

  final AppDatabase _db;

  static const defaultDuration = Duration(seconds: 90);

  Future<TimerSnapshot> load() async {
    final row = await _db.select(_db.timerStates).getSingleOrNull();
    if (row == null) return const TimerSnapshot.idle(defaultDuration);
    final startedAt = row.startedAtMs;
    return TimerSnapshot(
      status: row.status,
      duration: Duration(milliseconds: row.durationMs),
      startedAt: startedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startedAt),
      elapsedBefore: Duration(milliseconds: row.elapsedBeforeMs),
    );
  }

  Future<void> save(TimerSnapshot snapshot) => _db
      .into(_db.timerStates)
      .insertOnConflictUpdate(
        TimerStatesCompanion(
          id: const Value(1),
          status: Value(snapshot.status),
          durationMs: Value(snapshot.duration.inMilliseconds),
          startedAtMs: Value(snapshot.startedAt?.millisecondsSinceEpoch),
          elapsedBeforeMs: Value(snapshot.elapsedBefore.inMilliseconds),
        ),
      );
}

final timerRepositoryProvider = Provider(
  (ref) => TimerRepository(ref.watch(databaseProvider)),
);

/// Estado salvo carregado no startup (sobrescrito em `main.dart`).
final initialTimerSnapshotProvider = Provider<TimerSnapshot>(
  (ref) => const TimerSnapshot.idle(TimerRepository.defaultDuration),
);
