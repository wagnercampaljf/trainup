import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../data/rest_alarm.dart';

/// Aviso exibido quando falta permissão para avisar o fim do descanso com a
/// tela bloqueada. Some quando tudo está liberado.
class RestAlarmPermissionNotice extends ConsumerStatefulWidget {
  const RestAlarmPermissionNotice({super.key});

  @override
  ConsumerState<RestAlarmPermissionNotice> createState() =>
      _RestAlarmPermissionNoticeState();
}

class _RestAlarmPermissionNoticeState
    extends ConsumerState<RestAlarmPermissionNotice> {
  late final AppLifecycleListener _lifecycle;
  RestAlarmPermissions? _permissions;

  @override
  void initState() {
    super.initState();
    _check();
    // Volta das configurações do sistema: confere de novo.
    _lifecycle = AppLifecycleListener(onResume: _check);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    try {
      final permissions = await ref.read(restAlarmProvider).permissions();
      if (mounted) setState(() => _permissions = permissions);
    } on Object {
      // Sem como consultar (plataforma sem suporte): não mostra nada.
    }
  }

  Future<void> _fix(RestAlarmPermissions permissions) async {
    final alarm = ref.read(restAlarmProvider);
    if (!permissions.notifications) {
      await alarm.requestNotifications();
    } else {
      await alarm.requestExactAlarms();
    }
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = _permissions;
    if (permissions == null ||
        (permissions.notifications && permissions.exactAlarms)) {
      return const SizedBox.shrink();
    }
    final message = permissions.notifications
        ? 'Permita "Alarmes e lembretes" para o aviso do fim do descanso '
              'chegar na hora certa com o celular bloqueado.'
        : 'Permita as notificações para vibrar e tocar no fim do descanso '
              'com o celular bloqueado.';
    return Card(
      color: context.colors.secondaryContainer,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: context.colors.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('rest_alarm_permission'),
                onPressed: () => _fix(permissions),
                child: const Text('PERMITIR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
