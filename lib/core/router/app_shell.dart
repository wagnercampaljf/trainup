import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/workouts/presentation/widgets/running_session_guard.dart';

/// Estrutura com navegação inferior das abas principais.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Início',
    ),
    NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment),
      label: 'Fichas',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: 'Histórico',
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart_outlined),
      selectedIcon: Icon(Icons.show_chart),
      label: 'Evolução',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RunningSessionGuard(
      child: Scaffold(
        body: navigationShell,
        // Cinco rótulos curtos dividem a largura: com fonte muito ampliada
        // eles quebrariam no meio da palavra. A escala é limitada só aqui
        // (os ícones também identificam cada aba).
        bottomNavigationBar: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.15,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            destinations: _destinations,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
        ),
      ),
    );
  }
}
