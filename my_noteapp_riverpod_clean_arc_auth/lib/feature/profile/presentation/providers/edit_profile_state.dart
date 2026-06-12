import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

sealed class EditProfileState {
  const EditProfileState();
}

class EditProfileInitialState extends EditProfileState {
  const EditProfileInitialState();
}

class EditProfileLoadingState extends EditProfileState {
  const EditProfileLoadingState();
}

class EditProfileSuccessState extends EditProfileState {
  final UserDetailsEntity details;
  const EditProfileSuccessState(this.details);
}

class EditProfileFailedState extends EditProfileState {
  final String message;
  const EditProfileFailedState(this.message);
}
