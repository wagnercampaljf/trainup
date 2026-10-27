import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_step == 0 ? 'Seu perfil' : 'Medidas iniciais'),
            Text('Etapa ${_step + 1} de 2', style: context.text.bodySmall),
          ],
        ),
        leading: _step == 1
            ? BackButton(onPressed: () => setState(() => _step = 0))
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / 2,
              semanticsLabel: 'Etapa ${_step + 1} de 2',
            ),
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
              padding: const EdgeInsets.all(AppSpace.lg),
              child: SizedBox(
                width: double.infinity,
                height: AppTheme.largeButtonHeight,
                child: FilledButton.icon(
                  key: const Key('onboarding_next'),
                  onPressed: _saving ? null : (_step == 0 ? _next : _finish),
                  icon: Icon(_step == 0 ? Icons.arrow_forward : Icons.check),
                  label: Text(_step == 0 ? 'Continuar' : 'Começar a usar'),
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
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          Text('Bem-vindo(a) ao TrainUp', style: context.text.headlineMedium),
          const SizedBox(height: AppSpace.md),
          const _Benefit(
            icon: Icons.assignment_outlined,
            text: 'Monte fichas com séries, cargas e descanso.',
          ),
          const _Benefit(
            icon: Icons.check_circle_outline,
            text: 'Registre o treino série a série e veja a evolução.',
          ),
          const _Benefit(
            icon: Icons.wifi_off,
            text:
                'Funciona sem internet e sem conta: seus dados ficam neste '
                'celular.',
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
          const Divider(height: AppSpace.xl),
          Text(
            'Só nome e altura são obrigatórios (*).',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
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
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          Text(
            'Informe seu peso atual (obrigatório). As demais medidas são '
            'opcionais e ajudam a acompanhar a evolução; dá para registrar '
            'depois, no Perfil.',
            style: context.text.bodyLarge,
          ),
          const SizedBox(height: AppSpace.xl),
          MeasurementFields(controllers: controllers),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: context.colors.primary),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(text, style: context.text.bodyLarge)),
        ],
      ),
    );
  }
}
