import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/platform/file_sharing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/session_models.dart';
import 'workout_share_card.dart';

/// Mostra a prévia da arte do treino e o botão para compartilhá-la.
Future<void> showShareWorkoutSheet(
  BuildContext context, {
  required SessionDetail detail,
  required SessionRecords records,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => ShareWorkoutSheet(detail: detail, records: records),
);

class ShareWorkoutSheet extends ConsumerStatefulWidget {
  const ShareWorkoutSheet({
    required this.detail,
    required this.records,
    super.key,
  });

  final SessionDetail detail;
  final SessionRecords records;

  @override
  ConsumerState<ShareWorkoutSheet> createState() => _ShareWorkoutSheetState();
}

class _ShareWorkoutSheetState extends ConsumerState<ShareWorkoutSheet> {
  final _cardKey = GlobalKey();
  final _now = DateTime.now();
  var _sharing = false;

  String get _shareText {
    final detail = widget.detail;
    return 'Treino concluído: ${detail.session.planNameSnapshot} · '
        '${formatDuration(detail.duration(_now))} · '
        '${formatVolume(detail.volume)} 💪 #TrainUp';
  }

  Future<Uint8List> _renderPng() async {
    final boundary =
        _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _renderPng();
      final date = widget.detail.session.startedAt;
      final stamp =
          '${date.year}${date.month.toString().padLeft(2, '0')}'
          '${date.day.toString().padLeft(2, '0')}';
      await ref
          .read(fileSharingProvider)
          .shareFile(
            bytes: bytes,
            fileName: 'treino-trainup-$stamp.png',
            mimeType: 'image/png',
            text: _shareText,
          );
    } on Object catch (e) {
      if (mounted) context.showMessage('Não foi possível compartilhar: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Compartilhar treino', style: context.text.titleMedium),
          const SizedBox(height: 12),
          Flexible(
            child: AspectRatio(
              aspectRatio:
                  WorkoutShareCard.size.width / WorkoutShareCard.size.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: WorkoutShareCard(
                      detail: widget.detail,
                      records: widget.records,
                      now: _now,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('share_workout_image'),
              onPressed: _sharing ? null : _share,
              icon: const Icon(Icons.share),
              label: const Text('COMPARTILHAR'),
            ),
          ),
        ],
      ),
    );
  }
}
