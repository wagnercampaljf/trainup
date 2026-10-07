import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/features/settings/domain/privacy_policy.dart';

String _normalize(String text) => text
    .replaceAll(RegExp(r'<[^>]+>'), ' ')
    .replaceAll('&quot;', '"')
    .replaceAll('&#x27;', "'")
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\s+'), ' ');

void main() {
  test('versão publicada (HTML) é igual à exibida no app', () {
    final page = _normalize(
      File('docs/legal/politica-de-privacidade.html').readAsStringSync(),
    );
    expect(page, contains(PrivacyPolicy.effectiveDate));
    for (final (title, body) in PrivacyPolicy.sections) {
      expect(page, contains(title));
      expect(page, contains(_normalize(body)), reason: 'Seção "$title"');
    }
  });

  test('política informa contato e não promete o que o app não faz', () {
    final all = PrivacyPolicy.sections.map((s) => s.$2).join(' ');
    expect(all, contains(PrivacyPolicy.contactEmail));
    expect(all, contains(PrivacyPolicy.controller));
    // O backup do sistema precisa ser mencionado (os dados podem sair do
    // aparelho por ele, embora não por ação do app).
    expect(all, contains('backup'));
  });
}
