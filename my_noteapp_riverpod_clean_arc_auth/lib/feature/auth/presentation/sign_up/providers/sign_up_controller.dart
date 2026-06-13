import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/sign_up_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/sign_up/providers/sign_up_state.dart';

class SignUpController extends AsyncNotifier<SignUpState> {
  @override
  FutureOr<SignUpState> build() => const SignUpInitialState();

  Future<void> submit(SignUpUseCaseParams params) async {
    state = const AsyncValue.data(SignUpLoadingState());

    final result = await AsyncValue.guard<SignUpState>(() async {
      final user = await ref.read(signUpUseCaseProvider).call(params);
      // A successful sign up logs the user in — remember the session.
      await ref.read(authLocalDataSourceProvider).setLoggedIn(true);
      return SignUpSuccessState(user);
    });

    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(SignUpLoadingState()),
      error: (e, _) => AsyncValue.data(SignUpFailedState(e.toString())),
    );
  }

  void reset() => state = const AsyncValue.data(SignUpInitialState());
}

final signUpControllerProvider =
    AsyncNotifierProvider.autoDispose<SignUpController, SignUpState>(
  SignUpController.new,
);
