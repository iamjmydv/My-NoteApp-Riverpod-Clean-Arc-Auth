import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/profile_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/usecases/update_profile_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/presentation/providers/edit_profile_state.dart';

class EditProfileController extends AsyncNotifier<EditProfileState> {
  @override
  FutureOr<EditProfileState> build() => const EditProfileInitialState();

  Future<void> submit(UpdateProfileUseCaseParams params) async {
    state = const AsyncValue.data(EditProfileLoadingState());

    final result = await AsyncValue.guard<EditProfileState>(() async {
      final details =
          await ref.read(updateProfileUseCaseProvider).call(params);
      return EditProfileSuccessState(details);
    });

    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(EditProfileLoadingState()),
      error: (e, _) => AsyncValue.data(EditProfileFailedState(e.toString())),
    );
  }

  void reset() => state = const AsyncValue.data(EditProfileInitialState());
}

final editProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<EditProfileController, EditProfileState>(
  EditProfileController.new,
);
