// DI graph for the profile feature. Reuses firestoreProvider from
// auth_providers.dart so features share the same Firestore singleton.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/data/datasources/profile_remote_datasource.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/data/repository/profile_repository_impl.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/repository/profile_repository.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/usecases/update_profile_usecase.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider)),
);

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => GetUserProfileUseCase(ref.watch(profileRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.watch(profileRepositoryProvider)),
);

/// Fetches the profile for [uid].
final userProfileProvider =
    FutureProvider.family<UserDetailsEntity, String>((ref, uid) {
  return ref
      .watch(getUserProfileUseCaseProvider)
      .call(GetUserProfileUseCaseParams(uid: uid));
});
