import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../domain/privacy_policy.dart';

/// Política de privacidade (disponível offline, inclusive antes do cadastro).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidade')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Text(
            'Política de Privacidade do ${PrivacyPolicy.appName}',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vigência: ${PrivacyPolicy.effectiveDate}',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          for (final (title, body) in PrivacyPolicy.sections) ...[
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                title,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(body, style: context.text.bodyLarge),
          ],
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Fale com o desenvolvedor'),
              subtitle: const Text(PrivacyPolicy.contactEmail),
              trailing: const Icon(Icons.copy),
              onTap: () async {
                await Clipboard.setData(
                  const ClipboardData(text: PrivacyPolicy.contactEmail),
                );
                if (context.mounted) context.showMessage('E-mail copiado');
              },
            ),
          ),
        ],
      ),
    );
  }
}
