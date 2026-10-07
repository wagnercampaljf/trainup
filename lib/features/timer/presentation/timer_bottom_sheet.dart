import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import 'timer_controller.dart';

/// Indica se os controles do timer estão abertos. Enquanto estiverem, o
/// botão flutuante fica oculto para não cobrir o conteúdo da folha.
class TimerSheetOpen extends Notifier<bool> {
  @override
  bool build() => false;

  void set({required bool open}) {
    if (ref.mounted) state = open;
  }
}

final timerSheetOpenProvider = NotifierProvider<TimerSheetOpen, bool>(
  TimerSheetOpen.new,
);

Future<void> showTimerBottomSheet(BuildContext context) async {
  final sheet = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(timerSheetOpenProvider.notifier)..set(open: true);
  try {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const TimerBottomSheet(),
    );
  } finally {
    sheet.set(open: false);
  }
}

/// Controles completos do temporizador global.
class TimerBottomSheet extends ConsumerWidget {
  const TimerBottomSheet({super.key});

  static const presets = [
    Duration(seconds: 30),
    Duration(seconds: 45),
    Duration(seconds: 60),
    Duration(seconds: 90),
    Duration(minutes: 2),
    Duration(minutes: 3),
  ];

  static String presetLabel(Duration d) =>
      d.inSeconds <= 90 ? '${d.inSeconds}s' : '${d.inMinutes} min';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);
    final snapshot = timer.snapshot;
    final shown = snapshot.isIdle ? snapshot.duration : timer.remaining;

    final status = switch (snapshot) {
      _ when snapshot.isFinished => 'Descanso concluído',
      _ when snapshot.isRunning => 'Descansando…',
      _ when snapshot.isPaused => 'Pausado',
      _ => 'Pronto para iniciar',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Temporizador',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: snapshot.isIdle ? 1 : 1 - timer.progress,
                  strokeWidth: 10,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  color: snapshot.isFinished
                      ? context.colors.tertiary
                      : context.colors.primary,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (snapshot.isFinished)
                        Icon(
                          Icons.check_circle,
                          size: 40,
                          color: context.colors.tertiary,
                        ),
                      Text(
                        formatClock(shown),
                        key: const Key('timer_display'),
                        style: context.text.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(status, style: context.text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AdjustButton(
                label: '-15s',
                semantics: 'Reduzir 15 segundos',
                onPressed: () =>
                    controller.adjust(const Duration(seconds: -15)),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 88,
                height: 88,
                child: FilledButton(
                  key: const Key('timer_toggle'),
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: controller.toggle,
                  child: Icon(
                    snapshot.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 44,
                    semanticLabel: snapshot.isRunning
                        ? 'Pausar'
                        : snapshot.isPaused
                        ? 'Continuar'
                        : 'Iniciar',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _AdjustButton(
                label: '+15s',
                semantics: 'Adicionar 15 segundos',
                onPressed: () => controller.adjust(const Duration(seconds: 15)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: snapshot.isIdle ? null : controller.reset,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Resetar'),
          ),
          const Divider(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Iniciar descanso de', style: context.text.titleSmall),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in presets)
                ActionChip(
                  label: Text(presetLabel(preset)),
                  onPressed: () => controller.start(preset),
                ),
              ActionChip(
                avatar: const Icon(Icons.edit, size: 18),
                label: const Text('Personalizar'),
                onPressed: () async {
                  final custom = await _askDuration(context, snapshot.duration);
                  if (custom != null) controller.setDuration(custom);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Duration?> _askDuration(BuildContext context, Duration current) {
    final minutes = TextEditingController(text: '${current.inMinutes}');
    final seconds = TextEditingController(
      text: '${current.inSeconds.remainder(60)}',
    );
    return showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duração do descanso'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutos'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: seconds,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Segundos'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final m = int.tryParse(minutes.text.trim()) ?? 0;
              final s = int.tryParse(seconds.text.trim()) ?? 0;
              final total = Duration(minutes: m, seconds: s);
              Navigator.pop(context, total.inSeconds > 0 ? total : null);
            },
            child: const Text('Definir'),
          ),
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({
    required this.label,
    required this.semantics,
    required this.onPressed,
  });

  final String label;
  final String semantics;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      button: true,
      excludeSemantics: true,
      child: SizedBox(
        width: 72,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
