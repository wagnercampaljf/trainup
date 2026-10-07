import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/core/utils/formatters.dart';
import 'package:trainup/features/body_measurements/data/body_measurement_repository.dart';
import 'package:trainup/features/body_measurements/domain/body_metric.dart';
import 'package:trainup/features/body_measurements/presentation/measurement_form_screen.dart';
import 'package:trainup/features/workouts/presentation/widgets/repetition_input.dart';
import 'package:trainup/features/workouts/presentation/widgets/set_row.dart';

/// Repositório com gravação controlada pelo teste (persistência "lenta").
class _SlowMeasurements implements BodyMeasurementRepository {
  final pending = Completer<int>();
  var createCalls = 0;

  @override
  Future<int> create(BodyMeasurementInput input) {
    createCalls++;
    return pending.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WorkoutSessionSet _set({bool completed = false, int reps = 10}) =>
    WorkoutSessionSet(
      id: 1,
      sessionExerciseId: 1,
      position: 0,
      repetitions: reps,
      weightKg: 40,
      completed: completed,
    );

/// Tela mínima com uma linha de série que pode ser reconstruída à vontade.
class _RowHarness extends StatefulWidget {
  const _RowHarness({required this.onRemove});

  final Future<bool> Function() onRemove;

  @override
  State<_RowHarness> createState() => _RowHarnessState();
}

class _RowHarnessState extends State<_RowHarness> {
  var rebuilds = 0;

  void rebuild() => setState(() => rebuilds++);

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SetRow(
        set: _set(),
        index: 0,
        weightIncrement: 2.5,
        isNext: false,
        onWeightChanged: (_) {},
        onRepsChanged: (_) {},
        onToggle: (_, _) {},
        onRemove: widget.onRemove,
      ),
    ),
  );
}

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  group('P05 — repetições de série concluída', () {
    testWidgets('campo não envia 0 e volta ao valor anterior', (tester) async {
      final sent = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RepetitionInput(value: 12, minValue: 1, onChanged: sent.add),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(RepetitionInput), '0');
      expect(sent, isEmpty, reason: '0 não pode ser enviado');
      // Ao sair do campo, o valor válido anterior volta.
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(find.text('12'), findsOneWidget);
      expect(sent, isEmpty);
    });

    testWidgets('série pendente ainda aceita 0 repetições', (tester) async {
      final sent = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RepetitionInput(value: 10, onChanged: sent.add)),
        ),
      );
      await tester.enterText(find.byType(RepetitionInput), '0');
      expect(sent, [0]);
    });
  });

  testWidgets('P07 — SALVAR repetido grava a medição uma única vez', (
    tester,
  ) async {
    final repo = _SlowMeasurements();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/nova'),
              child: const Text('abrir'),
            ),
          ),
        ),
        GoRoute(
          path: '/nova',
          builder: (_, _) => const MeasurementFormScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bodyMeasurementRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(Key('metric_${BodyMetric.weight.name}')),
      '90',
    );

    final save = find.byKey(const Key('measurement_save'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    // Dois toques antes de a primeira gravação terminar.
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();
    expect(repo.createCalls, 1);
    expect(
      tester.widget<FilledButton>(save).onPressed,
      isNull,
      reason: 'botão desabilitado enquanto salva',
    );

    repo.pending.complete(1);
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget, reason: 'voltou uma única vez');
  });

  group('P08 — arrastar para remover série', () {
    testWidgets('reconstruir com remoção pendente não quebra a tela', (
      tester,
    ) async {
      final pending = Completer<bool>();
      await tester.pumpWidget(_RowHarness(onRemove: () => pending.future));
      await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
      await tester.pumpAndSettle();
      // O banco ainda não respondeu e a tela é reconstruída (ex.: stream).
      tester.state<_RowHarnessState>(find.byType(_RowHarness)).rebuild();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Dismissible), findsNothing);

      pending.complete(true);
      await tester.pump();
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('se a remoção falhar, a série volta', (tester) async {
      final pending = Completer<bool>();
      await tester.pumpWidget(_RowHarness(onRemove: () => pending.future));
      await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.byType(Dismissible), findsNothing);

      pending.complete(false);
      // A resposta chega depois do quadro atual; a linha volta no seguinte.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(Dismissible), findsOneWidget);
    });
  });
}
