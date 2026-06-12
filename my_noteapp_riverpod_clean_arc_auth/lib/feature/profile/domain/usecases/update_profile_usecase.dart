import 'package:my_noteapp_riverpod_clean_arc_auth/core/usecase/usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/repository/profile_repository.dart';

class UpdateProfileUseCaseParams {
  final String uid;
  final String firstName;
  final String lastName;
  final int age;

  const UpdateProfileUseCaseParams({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.age,
  });
}

class UpdateProfileUseCase
    implements UseCaseWithParams<UserDetailsEntity, UpdateProfileUseCaseParams> {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  @override
  Future<UserDetailsEntity> call(UpdateProfileUseCaseParams params) =>
      repository.updateProfile(params);
}
