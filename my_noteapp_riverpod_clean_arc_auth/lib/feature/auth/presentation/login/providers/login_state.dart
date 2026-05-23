import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitialState extends LoginState {
  const LoginInitialState();
}

class LoginLoadingState extends LoginState {
  const LoginLoadingState();
}

class LoginSuccessState extends LoginState {
  final UserDetailsEntity details;
  const LoginSuccessState(this.details);
}

class LoginFailedState extends LoginState {
  final String message;
  const LoginFailedState(this.message);
}