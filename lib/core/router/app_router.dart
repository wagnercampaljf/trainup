import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/body_measurements/presentation/measurement_form_screen.dart';
import '../../features/body_measurements/presentation/measurements_screen.dart';
import '../../features/exercises/presentation/exercise_form_screen.dart';
import '../../features/exercises/presentation/exercises_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/onboarding_status.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/exercise_detail_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/workout_plans/presentation/plan_detail_screen.dart';
import '../../features/workout_plans/presentation/plan_editor_screen.dart';
import '../../features/workout_plans/presentation/plans_screen.dart';
import '../../features/workouts/presentation/history_screen.dart';
import '../../features/workouts/presentation/session_detail_screen.dart';
import '../../features/workouts/presentation/workout_screen.dart';
import '../../features/workouts/presentation/workout_summary_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

int _id(GoRouterState state, String name) =>
    int.parse(state.pathParameters[name]!);

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboarding = ref.watch(onboardingStatusProvider);

  GoRoute fullScreen(String path, Widget Function(GoRouterState) builder) =>
      GoRoute(
        path: path,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => builder(state),
      );

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: onboarding,
    redirect: (context, state) {
      // A política de privacidade pode ser lida antes do cadastro.
      if (state.matchedLocation == Routes.privacy) return null;
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarding.value) return atOnboarding ? null : Routes.onboarding;
      if (atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.plans,
                builder: (context, state) => const PlansScreen(),
                routes: [
                  fullScreen('new', (_) => const PlanEditorScreen()),
                  fullScreen(
                    ':planId',
                    (s) => PlanDetailScreen(planId: _id(s, 'planId')),
                  ),
                  fullScreen(
                    ':planId/edit',
                    (s) => PlanEditorScreen(planId: _id(s, 'planId')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  fullScreen(
                    ':sessionId',
                    (s) => SessionDetailScreen(sessionId: _id(s, 'sessionId')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  fullScreen('edit', (_) => const ProfileEditScreen()),
                  fullScreen('settings', (_) => const SettingsScreen()),
                  fullScreen('measurements', (_) => const MeasurementsScreen()),
                  fullScreen(
                    'measurements/new',
                    (_) => const MeasurementFormScreen(),
                  ),
                  fullScreen(
                    'measurements/:measurementId/edit',
                    (s) => MeasurementFormScreen(
                      measurementId: _id(s, 'measurementId'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      fullScreen(Routes.privacy, (_) => const PrivacyPolicyScreen()),
      fullScreen(Routes.exercises, (_) => const ExercisesScreen()),
      fullScreen(Routes.newExercise, (_) => const ExerciseFormScreen()),
      fullScreen(
        Routes.pickExercise,
        (_) => const ExercisesScreen(pickMode: true),
      ),
      fullScreen(
        '/exercises/:exerciseId',
        (s) => ExerciseDetailScreen(exerciseId: _id(s, 'exerciseId')),
      ),
      fullScreen(
        '/exercises/:exerciseId/edit',
        (s) => ExerciseFormScreen(exerciseId: _id(s, 'exerciseId')),
      ),
      fullScreen(
        '/workout/:sessionId',
        (s) => WorkoutScreen(sessionId: _id(s, 'sessionId')),
      ),
      fullScreen(
        '/workout/:sessionId/summary',
        (s) => WorkoutSummaryScreen(sessionId: _id(s, 'sessionId')),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
