import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../data/body_measurement_repository.dart';
import '../domain/body_metric.dart';
import 'widgets/measurement_fields.dart';

/// Cria ou edita uma medição corporal.
class MeasurementFormScreen extends ConsumerStatefulWidget {
  const MeasurementFormScreen({this.measurementId, super.key});

  final int? measurementId;

  @override
  ConsumerState<MeasurementFormScreen> createState() =>
      _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends ConsumerState<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<BodyMeasurement?> _loading;
  MeasurementControllers? _controllers;
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.measurementId != null;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(bodyMeasurementRepositoryProvider);
    _loading = _isEditing
        ? repo.getById(widget.measurementId!)
        : Future.value(null);
  }

  @override
  void dispose() {
    _controllers?.dispose();
    _notes.dispose();
    super.dispose();
  }

  MeasurementControllers _init(BodyMeasurement? existing) {
    if (_controllers != null) return _controllers!;
    if (existing != null) {
      _date = existing.date;
      _notes.text = existing.notes ?? '';
    }
    return _controllers = MeasurementControllers(existing);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Impede gravações duplicadas por toques repetidos em SALVAR.
  var _saving = false;

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final input = BodyMeasurementInput(
      date: _date,
      values: _controllers!.values,
      notes: _notes.text,
    );
    final repo = ref.read(bodyMeasurementRepositoryProvider);
    try {
      if (_isEditing) {
        await repo.update(widget.measurementId!, input);
      } else {
        await repo.create(input);
      }
      if (mounted) {
        context
          ..showMessage('Medição salva')
          ..pop();
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        context.showError('salvar', e);
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir medição?',
      message: 'Esta medição será removida do histórico.',
    );
    if (!confirmed) return;
    await ref
        .read(bodyMeasurementRepositoryProvider)
        .delete(widget.measurementId!);
    if (mounted) {
      context
        ..showMessage('Medição excluída')
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar medição' : 'Nova medição'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Excluir medição',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: FutureBuilder<BodyMeasurement?>(
        future: _loading,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final controllers = _init(snapshot.data);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                MeasurementFields(controllers: controllers),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('measurement_save'),
                  onPressed: _saving ? null : _save,
                  child: const Text('SALVAR'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
