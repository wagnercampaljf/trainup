import '../../features/exercises/domain/muscle_group.dart';

/// Exercícios inseridos na criação do banco.
const seedExercises = <(String, MuscleGroup)>[
  ('Supino reto', MuscleGroup.chest),
  ('Supino inclinado', MuscleGroup.chest),
  ('Crucifixo', MuscleGroup.chest),
  ('Puxada frontal', MuscleGroup.back),
  ('Remada baixa', MuscleGroup.back),
  ('Remada curvada', MuscleGroup.back),
  ('Desenvolvimento', MuscleGroup.shoulders),
  ('Elevação lateral', MuscleGroup.shoulders),
  ('Rosca direta', MuscleGroup.biceps),
  ('Rosca alternada', MuscleGroup.biceps),
  ('Tríceps pulley', MuscleGroup.triceps),
  ('Tríceps francês', MuscleGroup.triceps),
  ('Agachamento', MuscleGroup.legs),
  ('Leg press', MuscleGroup.legs),
  ('Cadeira extensora', MuscleGroup.quadriceps),
  ('Mesa flexora', MuscleGroup.hamstrings),
  ('Stiff', MuscleGroup.hamstrings),
  ('Elevação pélvica', MuscleGroup.glutes),
  ('Panturrilha', MuscleGroup.calves),
  ('Abdominal', MuscleGroup.abs),
];
