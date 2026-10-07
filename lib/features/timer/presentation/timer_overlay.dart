import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../profile/presentation/onboarding_status.dart';
import 'timer_bottom_sheet.dart';
import 'timer_button.dart';

/// Mantém o [TimerButton] visível sobre todas as telas do app.
///
/// Fica acima do Navigator (via `MaterialApp.builder`), então não é
/// reconstruído/perdido ao navegar. O botão pode ser arrastado.
class TimerOverlay extends ConsumerStatefulWidget {
  const TimerOverlay({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends ConsumerState<TimerOverlay> {
  static const _margin = 8.0;

  /// Lado da tela a que o botão está "preso". A pílula cresce para o lado
  /// oposto, então nunca sai da tela ao mostrar o tempo ou o aviso.
  var _anchorRight = false;

  /// Distância até a borda do lado escolhido.
  var _side = 16.0;

  /// Distância até a base (acima da barra de navegação).
  var _bottom = 100.0;

  /// Posição horizontal absoluta durante o arraste.
  double? _dragLeft;

  final _buttonKey = GlobalKey();

  void _openSheet() {
    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;
    showTimerBottomSheet(navigatorContext);
  }

  double get _buttonWidth => _buttonKey.currentContext?.size?.width ?? 56;

  double _leftOf(double screenWidth) =>
      _anchorRight ? screenWidth - _side - _buttonWidth : _side;

  void _onDrag(DragUpdateDetails details, MediaQueryData media) {
    final width = media.size.width;
    final maxLeft = math.max(_margin, width - _buttonWidth - _margin);
    final maxBottom = math.max(
      _margin,
      media.size.height - media.padding.vertical - 72,
    );
    setState(() {
      _dragLeft = ((_dragLeft ?? _leftOf(width)) + details.delta.dx).clamp(
        _margin,
        maxLeft,
      );
      _bottom = (_bottom - details.delta.dy).clamp(_margin, maxBottom);
    });
  }

  /// Ao soltar, prende o botão ao lado mais próximo.
  void _onDragEnd(MediaQueryData media) {
    final left = _dragLeft;
    if (left == null) return;
    final width = media.size.width;
    setState(() {
      _anchorRight = left + _buttonWidth / 2 > width / 2;
      _side = math.max(
        _margin,
        _anchorRight ? width - left - _buttonWidth : left,
      );
      _dragLeft = null;
    });
  }

  Widget _positionedButton(MediaQueryData media) {
    final size = media.size;
    // Limites seguros mesmo em telas muito pequenas (clamp exige min ≤ max).
    final maxSide = math.max(_margin, size.width - 72);
    final side = _side.clamp(_margin, maxSide);
    final dragging = _dragLeft != null;
    return Positioned(
      left: dragging ? _dragLeft : (_anchorRight ? null : side),
      right: !dragging && _anchorRight ? side : null,
      bottom: (_bottom + media.padding.bottom).clamp(
        _margin,
        math.max(_margin, size.height - media.padding.top - 72),
      ),
      child: GestureDetector(
        onPanUpdate: (details) => _onDrag(details, media),
        onPanEnd: (_) => _onDragEnd(media),
        child: KeyedSubtree(
          key: _buttonKey,
          child: TimerButton(
            onPressed: _openSheet,
            anchoredRight: !dragging && _anchorRight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingStatusProvider);
    final sheetOpen = ref.watch(timerSheetOpenProvider);
    return ValueListenableBuilder<bool>(
      valueListenable: onboarding,
      builder: (context, completed, _) {
        // A estrutura (Stack) é sempre a mesma: trocar entre `child` e
        // `Stack` remontaria o Navigator e perderia o estado das telas.
        final showButton = completed && !sheetOpen;
        return Stack(
          children: [
            widget.child,
            if (showButton) _positionedButton(MediaQuery.of(context)),
          ],
        );
      },
    );
  }
}
