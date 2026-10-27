import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feedback físico (som/vibração) ao fim do descanso com o app aberto.
///
/// O som é o sinal próprio do app (`assets/sounds/rest_end.wav`). Ele toca
/// como alarme, então sai mesmo com o volume de mídia baixo, e abaixa a
/// música de outros apps só enquanto toca, sem pausá-la. Fora de
/// Android/iOS (ex.: testes) o som é ignorado.
class AlertFeedback {
  AlertFeedback();

  static const soundAsset = 'sounds/rest_end.wav';

  static final _audioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.duckOthers},
    ),
  );

  AudioPlayer? _player;

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> timerFinished({
    required bool vibrate,
    required bool sound,
  }) async {
    if (sound) unawaited(playSound());
    if (vibrate) {
      for (var i = 0; i < 3; i++) {
        await HapticFeedback.vibrate();
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
    }
  }

  /// Toca o sinal de fim do descanso (também usado para testar o som nas
  /// configurações). Falhas de áudio nunca interrompem o app.
  Future<void> playSound() async {
    if (!_supported) return;
    try {
      final player = _player ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(_audioContext);
      await player.stop();
      await player.play(AssetSource(soundAsset));
    } on Object catch (e) {
      debugPrint('Não foi possível tocar o sinal do descanso: $e');
    }
  }

  Future<void> dispose() async => _player?.dispose();
}

final alertFeedbackProvider = Provider<AlertFeedback>((ref) {
  final feedback = AlertFeedback();
  ref.onDispose(feedback.dispose);
  return feedback;
});
