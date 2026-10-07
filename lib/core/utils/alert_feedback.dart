import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feedback físico (vibração/som) ao fim do descanso.
///
/// Usa apenas APIs do Flutter (sem plugins). O som disponível no mobile é o
/// som de sistema (clique), que depende das configurações do aparelho.
class AlertFeedback {
  const AlertFeedback();

  Future<void> timerFinished({
    required bool vibrate,
    required bool sound,
  }) async {
    for (var i = 0; i < 3; i++) {
      if (vibrate) await HapticFeedback.vibrate();
      if (sound) {
        await SystemSound.play(SystemSoundType.alert);
        await SystemSound.play(SystemSoundType.click);
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }
}

final alertFeedbackProvider = Provider<AlertFeedback>(
  (ref) => const AlertFeedback(),
);
