import 'package:material_ui/material_ui.dart';

import '../utils/error_messages.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  void showMessage(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// "Não foi possível [action]." com uma explicação compreensível do erro.
  void showError(String action, Object error) =>
      showMessage(actionFailed(action, error));
}
