// All URL paths in one place. Use these constants instead of string literals
// when calling context.go / context.push so a typo can't slip through.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String notes = '/notes';
  static const String noteCreate = '/notes/new';
  static const String noteEdit = '/notes/edit';
  static const String userProfile = '/profile';
  static const String editProfile = '/profile/edit';
}
