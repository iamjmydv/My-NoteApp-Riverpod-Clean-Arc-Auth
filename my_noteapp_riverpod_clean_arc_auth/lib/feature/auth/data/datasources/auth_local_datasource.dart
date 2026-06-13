import 'package:shared_preferences/shared_preferences.dart';

/// Persists lightweight session flags on the device with [SharedPreferences].
///
/// We remember whether a user is signed in so the app can route straight to the
/// notes list (or the login page) on launch, without waiting on a network call.
abstract interface class AuthLocalDataSource {
  /// Whether a user session is currently remembered. Defaults to `false`.
  bool isLoggedIn();

  /// Persists the logged-in flag — `true` after login/sign up, `false` on
  /// logout.
  Future<void> setLoggedIn(bool value);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _loggedInKey = 'auth_is_logged_in';

  @override
  bool isLoggedIn() => _prefs.getBool(_loggedInKey) ?? false;

  @override
  Future<void> setLoggedIn(bool value) => _prefs.setBool(_loggedInKey, value);
}
