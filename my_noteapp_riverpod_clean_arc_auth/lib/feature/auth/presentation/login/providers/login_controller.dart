import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/login/providers/login_state.dart';

class LoginController extends AsyncNotifier<LoginState> {
  @override
  FutureOr<LoginState> build() => const LoginInitialState();

  Future<void> submit(LoginUseCaseParams params) async {
    state = const AsyncValue.data(LoginLoadingState());

    final result = await AsyncValue.guard<LoginState>(() async {
      final user = await ref.read(loginUserUseCaseProvider).call(params);
      // Remember the session so the next launch routes straight to the notes.
      await ref.read(authLocalDataSourceProvider).setLoggedIn(true);
      return LoginSuccessState(user);
    });

    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(LoginLoadingState()),
      error: (e, _) => AsyncValue.data(LoginFailedState(e.toString())),
    );
  }

  void reset() => state = const AsyncValue.data(LoginInitialState());
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, LoginState>(
  LoginController.new,
);
