import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/platform/file_sharing.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/text_normalizer.dart';
import '../data/plan_transfer_repository.dart';
import '../domain/plan_models.dart';
import '../domain/plan_transfer.dart';

/// Exporta as fichas [planIds] para um arquivo e abre o compartilhamento do
/// sistema (WhatsApp, e-mail, Drive…).
Future<void> exportPlans(
  BuildContext context,
  WidgetRef ref,
  List<int> planIds,
) async {
  try {
    final bundle = await ref
        .read(planTransferRepositoryProvider)
        .exportPlans(planIds);
    if (bundle.plans.isEmpty) {
      if (context.mounted) context.showMessage('Nenhuma ficha para exportar.');
      return;
    }
    final slug = bundle.plans.length == 1
        ? normalizeName(bundle.plans.single.name).replaceAll(' ', '-')
        : '${bundle.plans.length}-fichas';
    await ref
        .read(fileSharingProvider)
        .shareFile(
          bytes: utf8.encode(bundle.toJson()),
          fileName: 'trainup-${slug.isEmpty ? 'ficha' : slug}.json',
          mimeType: 'application/json',
          text: bundle.plans.length == 1
              ? 'Ficha "${bundle.plans.single.name}" do TrainUp. '
                    'Para usar: TrainUp > Fichas > ⋮ > Importar fichas.'
              : '${bundle.plans.length} fichas do TrainUp. '
                    'Para usar: TrainUp > Fichas > ⋮ > Importar fichas.',
        );
  } on Object catch (e) {
    if (context.mounted) context.showMessage('Não foi possível exportar: $e');
  }
}

/// Pergunta quais fichas exportar e as exporta.
Future<void> chooseAndExportPlans(
  BuildContext context,
  WidgetRef ref,
  List<PlanSummary> plans,
) async {
  if (plans.isEmpty) {
    context.showMessage('Crie uma ficha antes de exportar.');
    return;
  }
  final selected = await showDialog<List<int>>(
    context: context,
    builder: (_) => _ExportSelectionDialog(plans: plans),
  );
  if (selected == null || selected.isEmpty || !context.mounted) return;
  await exportPlans(context, ref, selected);
}

/// Escolhe um arquivo, mostra o que será importado e cria as fichas.
Future<void> importPlansFromFile(BuildContext context, WidgetRef ref) async {
  final PlanBundle bundle;
  final List<String> missing;
  try {
    final file = await ref.read(fileSharingProvider).pickFile();
    if (file == null) return;
    if (file.bytes.length > PlanBundle.maxBytes) {
      throw const PlanTransferException('Arquivo grande demais.');
    }
    final String text;
    try {
      text = utf8.decode(file.bytes);
    } on FormatException {
      throw const PlanTransferException(
        'Este arquivo não é uma ficha do TrainUp.',
      );
    }
    bundle = PlanBundle.fromJson(text);
    missing = await ref
        .read(planTransferRepositoryProvider)
        .missingExercises(bundle);
  } on Object catch (e) {
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Não foi possível importar'),
          content: Text(
            e is PlanTransferException ? e.message : 'Erro ao ler: $e',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return;
  }
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _ImportPreviewDialog(bundle: bundle, missing: missing),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    final result = await ref
        .read(planTransferRepositoryProvider)
        .importPlans(bundle);
    if (!context.mounted) return;
    final count = result.planIds.length;
    context.showMessage(
      count == 1 ? 'Ficha importada' : '$count fichas importadas',
    );
    if (count == 1) unawaited(context.push(Routes.plan(result.planIds.single)));
  } on Object catch (e) {
    if (context.mounted) context.showMessage('Não foi possível importar: $e');
  }
}

class _ExportSelectionDialog extends StatefulWidget {
  const _ExportSelectionDialog({required this.plans});

  final List<PlanSummary> plans;

  @override
  State<_ExportSelectionDialog> createState() => _ExportSelectionDialogState();
}

class _ExportSelectionDialogState extends State<_ExportSelectionDialog> {
  late final _selected = {for (final p in widget.plans) p.id};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar fichas'),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'As fichas selecionadas vão em um arquivo que pode ser '
                'enviado e importado em outro celular. Treinos e medidas não '
                'são incluídos.',
                style: context.text.bodySmall,
              ),
            ),
            for (final plan in widget.plans)
              CheckboxListTile(
                key: Key('export_plan_${plan.id}'),
                value: _selected.contains(plan.id),
                title: Text(plan.name),
                subtitle: Text(
                  plan.exerciseCount == 1
                      ? '1 exercício'
                      : '${plan.exerciseCount} exercícios',
                ),
                onChanged: (checked) => setState(() {
                  if (checked ?? false) {
                    _selected.add(plan.id);
                  } else {
                    _selected.remove(plan.id);
                  }
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('export_confirm'),
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(context, [
                  for (final p in widget.plans)
                    if (_selected.contains(p.id)) p.id,
                ]),
          child: const Text('Exportar'),
        ),
      ],
    );
  }
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({required this.bundle, required this.missing});

  final PlanBundle bundle;
  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    final count = bundle.plans.length;
    return AlertDialog(
      title: Text(count == 1 ? 'Importar ficha?' : 'Importar $count fichas?'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final plan in bundle.plans)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.assignment_outlined),
                title: Text(plan.name),
                subtitle: Text(
                  plan.exercises.isEmpty
                      ? 'Sem exercícios'
                      : plan.exercises.map((e) => e.name).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'As fichas serão adicionadas às suas. Nenhuma ficha ou treino '
              'existente será alterado.',
              style: context.text.bodySmall,
            ),
            if (missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Novos exercícios no catálogo: ${missing.join(', ')}.',
                style: context.text.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('import_confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Importar'),
        ),
      ],
    );
  }
}
