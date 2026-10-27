import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Situação das permissões que o alarme do descanso usa no Android.
typedef RestAlarmPermissions = ({bool notifications, bool exactAlarms});

/// Aviso de fim do descanso agendado no sistema operacional.
///
/// Com a tela bloqueada (ou o app em segundo plano) o Flutter não consegue
/// vibrar: o aviso precisa ser uma notificação agendada, que o sistema
/// entrega no horário mesmo com o app suspenso ou encerrado. Com o app
/// aberto, o aviso continua sendo o do próprio app (ver `TimerController`).
///
/// Fora de Android/iOS (ex.: testes) todas as operações são ignoradas.
class RestAlarm {
  RestAlarm();

  static const _notificationId = 1;

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _initialized;

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<bool> _init() => _initialized ??= () async {
    final ok = await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_monochrome'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    // Canais da 1.1.0, com o som padrão do sistema.
    for (final id in _oldChannelIds) {
      await _android?.deleteNotificationChannel(channelId: id);
    }
    return ok ?? false;
  }();

  static const _oldChannelIds = [
    'rest_end_sound_vibration',
    'rest_end_vibration',
    'rest_end_sound',
  ];

  /// Agenda o aviso para [endsAt]. Substitui um aviso já agendado.
  Future<void> schedule(
    DateTime endsAt, {
    required bool vibrate,
    required bool sound,
  }) async {
    if (!_supported || (!vibrate && !sound)) return;
    if (!await _init()) return;
    final android = _android;
    final exact =
        android == null ||
        await android.canScheduleExactNotifications() == true;
    final channel = _Channel.of(vibrate: vibrate, sound: sound);
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'Descanso concluído',
      body: 'Hora da próxima série!',
      scheduledDate: tz.TZDateTime.from(endsAt, tz.UTC),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: 'Aviso de fim do descanso entre séries',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          playSound: sound,
          sound: sound ? _sound : null,
          enableVibration: vibrate,
          vibrationPattern: vibrate ? _vibrationPattern : null,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          autoCancel: true,
          timeoutAfter: const Duration(minutes: 5).inMilliseconds,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: sound,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      // Sem a permissão de alarme exato, o Android pode atrasar o aviso.
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancela o aviso agendado e remove o já exibido.
  Future<void> cancel() async {
    if (!_supported || !await _init()) return;
    await _plugin.cancel(id: _notificationId);
  }

  /// Situação atual das permissões (Android). Em outras plataformas, tudo
  /// liberado.
  Future<RestAlarmPermissions> permissions() async {
    final android = _supported ? _android : null;
    if (android == null) return (notifications: true, exactAlarms: true);
    return (
      notifications: await android.areNotificationsEnabled() ?? false,
      exactAlarms: await android.canScheduleExactNotifications() ?? false,
    );
  }

  /// Pede a permissão de notificações (diálogo do sistema; o sistema não
  /// repete o pedido depois de negado).
  Future<void> requestNotifications() async {
    if (!_supported || !await _init()) return;
    await _android?.requestNotificationsPermission();
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
    }
  }

  /// Abre a tela do sistema "Alarmes e lembretes" (Android 12+).
  Future<void> requestExactAlarms() async {
    if (!_supported || !await _init()) return;
    await _android?.requestExactAlarmsPermission();
  }
}

final _vibrationPattern = Int64List.fromList([0, 600, 300, 600, 300, 600]);

/// Mesmo sinal tocado com o app aberto (`res/raw/rest_end.wav`, gerado por
/// `tool/generate_rest_sound.js`).
const _sound = RawResourceAndroidNotificationSound('rest_end');

/// Canais de notificação do Android: som e vibração de um canal não mudam
/// depois de criado, então há um canal por combinação das configurações.
/// Os ids têm versão: trocar o som exige canais novos (ver [_oldChannelIds]).
enum _Channel {
  soundAndVibration('rest_end_sound_vibration_v2', 'Fim do descanso'),
  vibrationOnly('rest_end_vibration_v2', 'Fim do descanso (só vibração)'),
  soundOnly('rest_end_sound_v2', 'Fim do descanso (só som)');

  const _Channel(this.id, this.name);

  final String id;
  final String name;

  static _Channel of({required bool vibrate, required bool sound}) =>
      switch ((vibrate, sound)) {
        (true, true) => soundAndVibration,
        (true, false) => vibrationOnly,
        _ => soundOnly,
      };
}

final restAlarmProvider = Provider<RestAlarm>((ref) => RestAlarm());
