import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/database/app_database.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../data/profile_repository.dart';
import 'widgets/profile_form_fields.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: AsyncValueWidget(
        value: ref.watch(profileProvider),
        data: (profile) => _ProfileEditForm(profile: profile),
      ),
    );
  }
}

class _ProfileEditForm extends ConsumerStatefulWidget {
  const _ProfileEditForm({required this.profile});

  final UserProfile? profile;

  @override
  ConsumerState<_ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends ConsumerState<_ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final _data = ProfileFormData(widget.profile);

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  var _saving = false;

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).saveProfile(_data.toInput());
      if (mounted) {
        context
          ..showMessage('Perfil atualizado')
          ..pop();
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        context.showMessage('Não foi possível salvar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileFormFields(data: _data),
          const SizedBox(height: 16),
          Text(
            'Peso e medidas são registrados no histórico em "Medidas".',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }
}
