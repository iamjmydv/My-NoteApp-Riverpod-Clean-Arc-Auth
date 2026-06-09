import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

// Profile reuses UserDetailsEntity from the auth feature — same business
// object, just read on a different screen.
abstract class ProfileRepository {
  /// Returns the saved profile for [uid].
  Future<UserDetailsEntity> getProfile(String uid);
}
