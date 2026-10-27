import '../../workout_plans/domain/plan_models.dart';

/// Ficha em destaque no Início e o motivo exibido ao usuário.
///
/// O critério é simples e explicável (o app não tem calendário de treinos):
/// primeiro uma ficha ainda não treinada; depois, a que está há mais tempo
/// sem ser treinada. Fichas sem exercícios ficam de fora.
typedef NextPlan = ({PlanSummary plan, String reason});

NextPlan? suggestNextPlan(List<PlanSummary> plans) {
  final candidates = plans.where((p) => p.exerciseCount > 0).toList();
  if (candidates.isEmpty) return null;
  final never = candidates.where((p) => p.lastPerformedAt == null);
  if (never.isNotEmpty) {
    return (
      plan: never.first,
      reason: candidates.length == 1
          ? 'Sua ficha · ainda não treinada'
          : 'Ainda não treinada',
    );
  }
  final oldest = candidates.reduce(
    (a, b) => b.lastPerformedAt!.isBefore(a.lastPerformedAt!) ? b : a,
  );
  return (
    plan: oldest,
    reason: candidates.length == 1 ? 'Sua ficha' : 'Há mais tempo sem treinar',
  );
}
