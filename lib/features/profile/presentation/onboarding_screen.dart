import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../body_measurements/domain/body_metric.dart';
import '../../body_measurements/presentation/widgets/measurement_fields.dart';
import '../data/profile_repository.dart';
import 'onboarding_status.dart';
import 'widgets/profile_form_fields.dart';

/// Primeiro acesso: perfil (passo 1) e medidas iniciais (passo 2).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _measureFormKey = GlobalKey<FormState>();
  final _profile = ProfileFormData();
  final _measures = MeasurementControllers();
  var _step = 0;
  var _saving = false;

  @override
  void dispose() {
    _profile.dispose();
    _measures.dispose();
    super.dispose();
  }

  void _next() {
    if (_profileFormKey.currentState!.validate()) setState(() => _step = 1);
  }

  Future<void> _finish() async {
    if (!_measureFormKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .completeOnboarding(
            _profile.toInput(),
            BodyMeasurementInput(
              date: DateTime.now(),
              values: _measures.values,
            ),
          );
      ref.read(onboardingStatusProvider).markCompleted();
    } on Object catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        context.showError('salvar', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 0 ? 'Bem-vindo(a) ao TrainUp!' : 'Medidas iniciais',
        ),
        leading: _step == 1
            ? BackButton(onPressed: () => setState(() => _step = 0))
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / 2),
            Expanded(
              child: IndexedStack(
                index: _step,
                children: [
                  _ProfileStep(formKey: _profileFormKey, data: _profile),
                  _MeasureStep(
                    formKey: _measureFormKey,
                    controllers: _measures,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('onboarding_next'),
                  onPressed: _saving ? null : (_step == 0 ? _next : _finish),
                  child: Text(_step == 0 ? 'CONTINUAR' : 'CONCLUIR'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.formKey, required this.data});

  final GlobalKey<FormState> formKey;
  final ProfileFormData data;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Vamos criar seu perfil. Seus dados ficam neste celular e não '
            'são enviados ao desenvolvedor.',
            style: context.text.bodyLarge,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('onboarding_privacy'),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => context.push(Routes.privacy),
              child: const Text('Ler a política de privacidade'),
            ),
          ),
          const SizedBox(height: 24),
          ProfileFormFields(data: data),
        ],
      ),
    );
  }
}

class _MeasureStep extends StatelessWidget {
  const _MeasureStep({required this.formKey, required this.controllers});

  final GlobalKey<FormState> formKey;
  final MeasurementControllers controllers;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Informe seu peso atual. As demais medidas são opcionais e '
            'ajudam a acompanhar sua evolução.',
            style: context.text.bodyLarge,
          ),
          const SizedBox(height: 24),
          MeasurementFields(controllers: controllers),
        ],
      ),
    );
  }
}
