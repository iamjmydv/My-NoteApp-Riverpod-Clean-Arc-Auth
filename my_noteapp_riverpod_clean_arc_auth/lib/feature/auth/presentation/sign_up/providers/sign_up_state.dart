import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

sealed class SignUpState {
  const SignUpState();
}

class SignUpInitialState extends SignUpState {
  const SignUpInitialState();
}

class SignUpLoadingState extends SignUpState {
  const SignUpLoadingState();
}

class SignUpSuccessState extends SignUpState {
  final UserDetailsEntity details;
  const SignUpSuccessState(this.details);
}

class SignUpFailedState extends SignUpState {
  final String message;
  const SignUpFailedState(this.message);
}
