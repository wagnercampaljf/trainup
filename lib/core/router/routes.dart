/// Caminhos de navegação centralizados.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const plans = '/plans';
  static const history = '/history';
  static const progress = '/progress';
  static const profile = '/profile';

  static const newPlan = '/plans/new';
  static String plan(int id) => '/plans/$id';
  static String editPlan(int id) => '/plans/$id/edit';

  static const exercises = '/exercises';
  static const newExercise = '/exercises/new';
  static const pickExercise = '/exercises/pick';
  static String exercise(int id) => '/exercises/$id';
  static String editExercise(int id) => '/exercises/$id/edit';

  static String workout(int sessionId) => '/workout/$sessionId';
  static String workoutSummary(int sessionId) => '/workout/$sessionId/summary';
  static String historyDetail(int sessionId) => '/history/$sessionId';

  static const measurements = '/profile/measurements';
  static const newMeasurement = '/profile/measurements/new';
  static String editMeasurement(int id) => '/profile/measurements/$id/edit';
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const privacy = '/privacy';
}
