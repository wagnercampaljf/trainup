import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise_exceptions.dart';
import '../domain/muscle_group.dart';

/// Cria ou edita um exercício. Ao salvar, retorna o id via `pop`.
class ExerciseFormScreen extends ConsumerStatefulWidget {
  const ExerciseFormScreen({this.exerciseId, super.key});

  final int? exerciseId;

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  MuscleGroup _group = MuscleGroup.chest;
  String? _duplicateError;
  late final Future<Exercise?> _loading;
  var _initialized = false;

  bool get _isEditing => widget.exerciseId != null;

  @override
  void initState() {
    super.initState();
    _loading = _isEditing
        ? ref.read(exerciseRepositoryProvider).getById(widget.exerciseId!)
        : Future.value(null);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _init(Exercise? exercise) {
    if (_initialized) return;
    _initialized = true;
    if (exercise == null) return;
    _name.text = exercise.name;
    _description.text = exercise.description ?? '';
    _notes.text = exercise.notes ?? '';
    _group = exercise.muscleGroup;
  }

  var _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _duplicateError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(exerciseRepositoryProvider);
    try {
      final int id;
      if (_isEditing) {
        id = widget.exerciseId!;
        await repo.update(
          id,
          name: _name.text,
          muscleGroup: _group,
          description: _description.text,
          notes: _notes.text,
        );
      } else {
        id = await repo.create(
          name: _name.text,
          muscleGroup: _group,
          description: _description.text,
          notes: _notes.text,
        );
      }
      if (mounted) context.pop(id);
    } on DuplicateExerciseException catch (e) {
      setState(() {
        _saving = false;
        _duplicateError = e.toString();
      });
      _formKey.currentState!.validate();
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        context.showMessage('Não foi possível salvar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar exercício' : 'Novo exercício'),
      ),
      body: FutureBuilder<Exercise?>(
        future: _loading,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          _init(snapshot.data);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  key: const Key('exercise_name'),
                  controller: _name,
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (v) =>
                      Validators.required(v, field: 'Nome') ?? _duplicateError,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MuscleGroup>(
                  isExpanded: true,
                  initialValue: _group,
                  decoration: const InputDecoration(
                    labelText: 'Grupo muscular',
                  ),
                  items: [
                    for (final g in MuscleGroup.values)
                      DropdownMenuItem(value: g, child: Text(g.label)),
                  ],
                  onChanged: (g) => setState(() => _group = g ?? _group),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('exercise_save'),
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
