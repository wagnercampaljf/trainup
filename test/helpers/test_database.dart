import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/core/database/app_database.dart';

/// Banco em memória com o mesmo schema/seed do app.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}

/// Registra a limpeza de um teste de widget, executada mesmo se uma
/// asserção falhar: desmonta a árvore (providers, timers, streams), deixa
/// operações pendentes da UI terminarem e fecha o banco com limite de tempo,
/// para que uma falha não trave a suíte nem contamine o próximo teste.
void tearDownWidgetsAndDatabase(WidgetTester tester, AppDatabase db) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(
      () => db.close().timeout(const Duration(seconds: 10)),
    );
  });
}
