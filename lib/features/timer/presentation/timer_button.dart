import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../domain/timer_status.dart';
import 'timer_controller.dart';

/// Botão flutuante compacto que mostra o estado do temporizador global.
///
/// Quando o descanso termina, exibe o aviso "Descanso concluído" com um botão
/// de fechar (X). Após [noticeDuration] o aviso é minimizado para um ícone de
/// relógio; tocar no ícone reabre o aviso.
class TimerButton extends ConsumerStatefulWidget {
  const TimerButton({
    required this.onPressed,
    this.anchoredRight = false,
    super.key,
  });

  /// Abre os controles do temporizador.
  final VoidCallback onPressed;

  /// Botão preso à borda direita: a pílula cresce para a esquerda.
  final bool anchoredRight;

  /// Tempo em que o aviso de descanso concluído fica aberto.
  static const noticeDuration = Duration(seconds: 5);

  @override
  ConsumerState<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends ConsumerState<TimerButton> {
  /// Aviso de descanso concluído expandido (texto + X). Começa fechado:
  /// um descanso que terminou com o app fechado não ocupa a tela ao abrir.
  var _noticeOpen = false;
  Timer? _autoClose;

  void _openNotice() {
    _autoClose?.cancel();
    _autoClose = Timer(TimerButton.noticeDuration, _closeNotice);
    setState(() => _noticeOpen = true);
  }

  void _closeNotice() {
    _autoClose?.cancel();
    _autoClose = null;
    if (mounted && _noticeOpen) setState(() => _noticeOpen = false);
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(timerControllerProvider.select((s) => s.snapshot.status), (
      previous,
      next,
    ) {
      if (next == TimerStatus.finished && previous != TimerStatus.finished) {
        _openNotice();
      } else if (next != TimerStatus.finished) {
        _closeNotice();
      }
    });

    final timer = ref.watch(timerControllerProvider);
    final snapshot = timer.snapshot;
    final colors = Theme.of(context).colorScheme;

    final (Color background, Color foreground) = snapshot.isFinished
        ? (colors.tertiary, colors.onTertiary)
        : snapshot.isRunning
        ? (colors.primary, colors.onPrimary)
        : snapshot.isPaused
        ? (colors.secondaryContainer, colors.onSecondaryContainer)
        : (colors.surfaceContainerHighest, colors.onSurface);

    final Widget content;
    if (snapshot.isFinished && _noticeOpen) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillAction(
            key: const Key('timer_button'),
            semantics: 'Descanso concluído. Abrir temporizador',
            onTap: widget.onPressed,
            padding: const EdgeInsets.only(left: 18, right: 4),
            child: _Label(
              leading: Icon(Icons.check_circle, color: foreground),
              text: 'Descanso concluído',
              color: foreground,
            ),
          ),
          _PillAction(
            key: const Key('timer_notice_close'),
            semantics: 'Minimizar aviso',
            onTap: _closeNotice,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.close, color: foreground),
          ),
        ],
      );
    } else if (snapshot.isFinished) {
      content = _PillAction(
        key: const Key('timer_button'),
        semantics: 'Descanso concluído. Toque para ver o aviso',
        onTap: _openNotice,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Relógio com "check": indica o fim do descanso sem depender da cor.
        child: Icon(Icons.alarm_on, color: foreground),
      );
    } else {
      final (
        Widget leading,
        String? text,
        String semantics,
      ) = switch (snapshot) {
        _ when snapshot.isRunning => (
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              value: 1 - timer.progress,
              strokeWidth: 3,
              color: foreground,
              backgroundColor: foreground.withValues(alpha: .25),
            ),
          ),
          formatClock(timer.remaining),
          'Temporizador rodando, ${formatClock(timer.remaining)} restantes',
        ),
        _ when snapshot.isPaused => (
          Icon(Icons.pause, color: foreground),
          formatClock(timer.remaining),
          'Temporizador pausado em ${formatClock(timer.remaining)}',
        ),
        _ => (
          Icon(Icons.timer_outlined, color: foreground),
          null,
          'Abrir temporizador',
        ),
      };
      content = _PillAction(
        key: const Key('timer_button'),
        semantics: semantics,
        onTap: widget.onPressed,
        padding: EdgeInsets.symmetric(horizontal: text == null ? 16 : 18),
        child: text == null
            ? leading
            : _Label(leading: leading, text: text, color: foreground),
      );
    }

    return Material(
      color: background,
      elevation: 6,
      shadowColor: Colors.black45,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: widget.anchoredRight
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: content,
      ),
    );
  }
}

/// Área tocável da pílula (altura mínima de 56 para uso com uma mão).
class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.semantics,
    required this.onTap,
    required this.padding,
    required this.child,
    super.key,
  });

  final String semantics;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56, minWidth: 48),
          child: Padding(
            padding: padding,
            child: Center(widthFactor: 1, child: child),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.leading,
    required this.text,
    required this.color,
  });

  final Widget leading;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
