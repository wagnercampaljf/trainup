import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indica se o perfil local já foi criado (usado no redirect do router).
class OnboardingStatus extends ValueNotifier<bool> {
  OnboardingStatus({required bool completed}) : super(completed);

  void markCompleted() => value = true;
}

/// Sobrescrito em `main.dart` com o valor lido do banco.
final onboardingStatusProvider = Provider<OnboardingStatus>(
  (ref) => OnboardingStatus(completed: false),
);
