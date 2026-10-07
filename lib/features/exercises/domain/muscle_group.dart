/// Grupos musculares disponíveis para classificar exercícios.
///
/// Persistido pelo [name] do enum; não renomeie valores existentes sem
/// migração de dados.
enum MuscleGroup {
  chest('Peitoral'),
  back('Costas'),
  shoulders('Ombros'),
  biceps('Bíceps'),
  triceps('Tríceps'),
  legs('Pernas'),
  quadriceps('Quadríceps'),
  hamstrings('Posterior de coxa'),
  glutes('Glúteos'),
  calves('Panturrilha'),
  abs('Abdômen'),
  forearms('Antebraço'),
  cardio('Cardio'),
  other('Outro');

  const MuscleGroup(this.label);

  final String label;
}
