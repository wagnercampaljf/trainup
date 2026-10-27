import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../data/workout_plan_repository.dart';
import '../domain/plan_models.dart';
import 'widgets/plan_exercise_editor.dart';

/// Cria ([planId] nulo) ou edita uma ficha.
class PlanEditorScreen extends ConsumerStatefulWidget {
  const PlanEditorScreen({this.planId, super.key});

  final int? planId;

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Future<PlanDraft> _loading;
  PlanDraft? _draft;
  var _dirty = false;
  var _saving = false;

  bool get _isEditing => widget.planId != null;

  @override
  void initState() {
    super.initState();
    _loading = _isEditing
        ? ref
              .read(workoutPlanRepositoryProvider)
              .getPlan(widget.planId!)
              .then((plan) => plan ?? PlanDraft())
        : Future.value(PlanDraft());
    // O rascunho é definido via setState para que a AppBar (botão SALVAR)
    // seja reconstruída assim que a ficha carregar.
    _loading.then(
      (draft) {
        if (mounted) setState(() => _draft ??= draft);
      },
      // O erro é exibido pelo FutureBuilder abaixo.
      onError: (Object _) {},
    );
  }

  void _changed() => setState(() => _dirty = true);

  Future<void> _addExercise() async {
    final exercise = await context.push<Exercise>(Routes.pickExercise);
    if (exercise == null) return;
    _draft!.exercises.add(
      PlanExerciseDraft(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets: [
          for (var i = 0; i < 3; i++)
            PlanSetDraft(repetitions: 10, weightKg: 0),
        ],
      ),
    );
    _changed();
  }

  Future<void> _removeExercise(PlanExerciseDraft exercise) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Remover exercício?',
      message: '${exercise.exerciseName} será removido desta ficha.',
      confirmLabel: 'Remover',
    );
    if (!confirmed) return;
    _draft!.exercises.remove(exercise);
    _changed();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(workoutPlanRepositoryProvider)
          .savePlan(_draft!);
      if (!mounted) return;
      setState(() => _dirty = false);
      context.showMessage('Ficha salva');
      if (_isEditing) {
        // PopScope precisa receber canPop=true antes de sair da rota.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      } else {
        context.pushReplacement(Routes.plan(id));
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        context.showError('salvar', e);
      }
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showConfirmationDialog(
      context,
      title: 'Descartar alterações?',
      message: 'As alterações nesta ficha não foram salvas.',
      confirmLabel: 'Descartar',
    );
    if (discard && mounted) {
      setState(() => _dirty = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar ficha' : 'Nova ficha'),
          actions: [
            TextButton(
              key: const Key('save_plan'),
              onPressed: _saving || _draft == null ? null : _save,
              child: const Text('SALVAR'),
            ),
          ],
        ),
        body: FutureBuilder<PlanDraft>(
          future: _loading,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Não foi possível carregar a ficha.\n${snapshot.error}',
                ),
              );
            }
            final draft = _draft;
            if (draft == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Form(
              key: _formKey,
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                header: _PlanHeaderFields(draft: draft, onChanged: _changed),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    key: const Key('add_exercise'),
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('ADICIONAR EXERCÍCIO'),
                  ),
                ),
                itemCount: draft.exercises.length,
                onReorderItem: (oldIndex, newIndex) {
                  final item = draft.exercises.removeAt(oldIndex);
                  draft.exercises.insert(newIndex, item);
                  _changed();
                },
                itemBuilder: (context, index) {
                  final exercise = draft.exercises[index];
                  return Padding(
                    key: ObjectKey(exercise),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlanExerciseEditor(
                      exercise: exercise,
                      index: index,
                      onChanged: _changed,
                      onRemove: () => _removeExercise(exercise),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlanHeaderFields extends StatelessWidget {
  const _PlanHeaderFields({required this.draft, required this.onChanged});

  final PlanDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('plan_name'),
            initialValue: draft.name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome da ficha *',
              hintText: 'Ex.: Ficha A — Peito e tríceps',
            ),
            validator: (v) => Validators.required(v, field: 'Nome da ficha'),
            onChanged: (v) {
              draft.name = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: draft.description,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
            ),
            onChanged: (v) {
              draft.description = v;
              onChanged();
            },
          ),
          const SizedBox(height: 16),
          Text(
            draft.exercises.isEmpty
                ? 'Adicione os exercícios da ficha.'
                : 'Exercícios (arraste para reordenar)',
            style: context.text.titleSmall,
          ),
        ],
      ),
    );
  }
}
