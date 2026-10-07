/// Preferência de tema do usuário.
enum ThemePreference {
  system('Seguir sistema'),
  light('Claro'),
  dark('Escuro');

  const ThemePreference(this.label);

  final String label;
}

/// Unidade de peso exibida na interface.
///
/// Internamente todos os pesos são armazenados em quilogramas; a unidade
/// afeta apenas a apresentação. Hoje somente `kg` está habilitado.
enum WeightUnit {
  kg('kg', 1),
  lb('lb', 2.2046226218);

  const WeightUnit(this.symbol, this.fromKgFactor);

  final String symbol;
  final double fromKgFactor;

  double fromKg(double kg) => kg * fromKgFactor;
  double toKg(double value) => value / fromKgFactor;
}
