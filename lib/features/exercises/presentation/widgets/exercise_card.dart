import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Item de exercício do catálogo.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.exercise,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final Exercise exercise;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: context.colors.secondaryContainer,
          child: Icon(
            Icons.fitness_center,
            color: context.colors.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Text(exercise.name),
        subtitle: Text(
          [
            exercise.muscleGroup.label,
            if (exercise.isCustom) 'Personalizado',
          ].join(' · '),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
