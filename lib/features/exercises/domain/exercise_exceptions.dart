/// Já existe um exercício ativo com o mesmo nome normalizado.
class DuplicateExerciseException implements Exception {
  const DuplicateExerciseException(this.existingName);

  final String existingName;

  @override
  String toString() => 'Já existe um exercício chamado "$existingName".';
}
