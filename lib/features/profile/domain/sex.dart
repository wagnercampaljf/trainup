/// Sexo informado opcionalmente no perfil.
enum Sex {
  male('Masculino'),
  female('Feminino'),
  other('Outro');

  const Sex(this.label);

  final String label;
}
