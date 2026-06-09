import 'package:my_noteapp_riverpod_clean_arc_auth/core/usecase/usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/repository/profile_repository.dart';

class GetUserProfileUseCaseParams {
  final String uid;

  const GetUserProfileUseCaseParams({required this.uid});
}

class GetUserProfileUseCase
    implements UseCaseWithParams<UserDetailsEntity, GetUserProfileUseCaseParams> {
  final ProfileRepository repository;

  const GetUserProfileUseCase(this.repository);

  @override
  Future<UserDetailsEntity> call(GetUserProfileUseCaseParams params) =>
      repository.getProfile(params.uid);
}
