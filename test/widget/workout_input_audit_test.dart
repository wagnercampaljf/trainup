import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/app_database.dart';
import 'package:trainup/features/workouts/presentation/widgets/set_row.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trainup/features/workouts/presentation/widgets/weight_input.dart';
import 'package:trainup/features/workouts/presentation/widgets/repetition_input.dart';

void main() {
  _setRowRaceTests();
  testWidgets('carga digitada é enviada antes de perder foco', (tester) async {
    double? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeightInput(
            value: 30,
            increment: 2.5,
            onChanged: (value) => saved = value,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '42,5');
    expect(saved, 42.5);
  });
  testWidgets('repetições digitadas são enviadas antes de perder foco', (
    tester,
  ) async {
    int? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepetitionInput(value: 10, onChanged: (value) => saved = value),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '8');
    expect(saved, 8);
  });
}

WorkoutSessionSet _set({double weight = 40, int reps = 8}) => WorkoutSessionSet(
  id: 1,
  sessionExerciseId: 1,
  position: 0,
  repetitions: reps,
  weightKg: weight,
  completed: false,
);

/// Simula a tela: o "banco" pode reenviar valores atrasados ao SetRow.
class _Harness extends StatefulWidget {
  const _Harness({required this.onToggle});

  final void Function(int reps, double weight) onToggle;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  WorkoutSessionSet set = _set();

  void echo(WorkoutSessionSet value) => setState(() => set = value);

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SetRow(
        set: set,
        index: 0,
        weightIncrement: 2.5,
        isNext: true,
        onWeightChanged: (_) {},
        onRepsChanged: (_) {},
        onToggle: widget.onToggle,
      ),
    ),
  );
}

void _setRowRaceTests() {
  testWidgets('eco atrasado do banco não sobrescreve carga digitada', (
    tester,
  ) async {
    (int, double)? toggled;
    await tester.pumpWidget(
      _Harness(onToggle: (reps, weight) => toggled = (reps, weight)),
    );
    await tester.enterText(find.byKey(const Key('set_weight_1')), '42,5');
    await tester.enterText(find.byKey(const Key('set_reps_1')), '6');
    // Emissão intermediária do stream (gravação de "42" durante a digitação).
    tester.state<_HarnessState>(find.byType(_Harness)).echo(_set(weight: 42));
    await tester.pump();
    await tester.tap(find.byKey(const Key('complete_set_1')));
    await tester.pump();
    expect(toggled, (6, 42.5));
  });

  testWidgets('mudança externa sem edição local é adotada', (tester) async {
    (int, double)? toggled;
    await tester.pumpWidget(
      _Harness(onToggle: (reps, weight) => toggled = (reps, weight)),
    );
    // Ex.: "usar cargas do último treino" gravou novos valores.
    tester
        .state<_HarnessState>(find.byType(_Harness))
        .echo(_set(weight: 45, reps: 10));
    await tester.pump();
    await tester.tap(find.byKey(const Key('complete_set_1')));
    await tester.pump();
    expect(toggled, (10, 45.0));
  });
}
