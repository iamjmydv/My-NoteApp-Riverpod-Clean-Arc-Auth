import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/usecases/update_profile_usecase.dart';

// Profile reuses UserDetailsEntity from the auth feature — same business
// object, just read on a different screen.
abstract class ProfileRepository {
  /// Returns the saved profile for [uid].
  Future<UserDetailsEntity> getProfile(String uid);

  /// Updates the editable fields of a profile and returns the saved entity.
  Future<UserDetailsEntity> updateProfile(UpdateProfileUseCaseParams params);
}
