import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/login/providers/login_state.dart';

class LoginController extends AsyncNotifier<LoginState> {
  @override 
  FutureOr<LoginState> build() => const LoginInitialState();

  
}