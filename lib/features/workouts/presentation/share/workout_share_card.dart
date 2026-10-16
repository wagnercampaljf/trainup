import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/session_models.dart';

/// Arte do resumo do treino para redes sociais (formato story, 9:16).
///
/// Tem tamanho lógico fixo ([size]); a imagem é gerada com `pixelRatio` 3
/// (1080×1920). Usa cores próprias, independentes do tema claro/escuro.
class WorkoutShareCard extends StatelessWidget {
  const WorkoutShareCard({
    required this.detail,
    required this.records,
    required this.now,
    super.key,
  });

  static const size = Size(360, 640);

  /// Exercícios listados antes do "+N exercícios".
  static const maxExercises = 7;

  static const _background = [Color(0xFF0B1534), Color(0xFF1D3A8A)];
  static const _muted = Color(0xFFB9C7E6);

  final SessionDetail detail;
  final SessionRecords records;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final performed = detail.exercises
        .where((e) => e.hasCompletedSets)
        .toList();
    final shown = performed.take(maxExercises).toList();
    final hidden = performed.length - shown.length;
    final recordCount =
        (records.totalVolume ? 1 : 0) +
        records.maxWeightExercises.length +
        records.volumeExercises.length;

    return SizedBox.fromSize(
      size: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _background,
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 13),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Logo(),
                    const SizedBox(width: 8),
                    const Text(
                      'TrainUp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatDate(detail.session.startedAt),
                      style: const TextStyle(color: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'TREINO CONCLUÍDO',
                  style: TextStyle(
                    color: AppColors.progressGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.session.planNameSnapshot,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Stat(
                      label: 'Duração',
                      value: formatDuration(detail.duration(now)),
                    ),
                    _Stat(label: 'Volume', value: formatVolume(detail.volume)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Stat(
                      label: 'Séries',
                      value: '${detail.completedSetCount}',
                    ),
                    _Stat(
                      label: 'Exercícios',
                      value: '${detail.performedExerciseCount}',
                    ),
                  ],
                ),
                if (recordCount > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.progressGreen.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recordCount == 1
                          ? '🏆 1 novo recorde pessoal'
                          : '🏆 $recordCount novos recordes pessoais',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                for (final exercise in shown) _ExerciseLine(exercise: exercise),
                if (hidden > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      hidden == 1 ? '+1 exercício' : '+$hidden exercícios',
                      style: const TextStyle(color: _muted),
                    ),
                  ),
                const Spacer(),
                const Center(
                  child: Text(
                    'Registrado com o app TrainUp',
                    style: TextStyle(color: _muted, fontSize: 12),
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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fitness_center, size: 18, color: Colors.white),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: WorkoutShareCard._muted)),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseLine extends StatelessWidget {
  const _ExerciseLine({required this.exercise});

  final SessionExerciseDetail exercise;

  @override
  Widget build(BuildContext context) {
    final sets = exercise.completedSets.length;
    final best = exercise.maxWeight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.progressGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exercise.exercise.exerciseNameSnapshot,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            [
              '$sets ${sets == 1 ? 'série' : 'séries'}',
              if (best != null && best > 0) 'até ${formatWeight(best)}',
            ].join(' · '),
            style: const TextStyle(color: WorkoutShareCard._muted),
          ),
        ],
      ),
    );
  }
}
