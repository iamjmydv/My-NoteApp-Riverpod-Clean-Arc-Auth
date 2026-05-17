import 'package:my_noteapp_riverpod_clean_arc_auth/core/usecase/usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/repository/auth_repository.dart';

class SignUpUseCaseParams {
  final String firstName;
  final String lastName;
  final int age;
  final String email;
  final String password;

  SignUpUseCaseParams({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.email,
    required this.password,
  });
}

class SignUpUserUseCase implements UseCaseWithParams<UserDetailsEntity, SignUpUseCaseParams> {
  AuthRepository repository;
  
  SignUpUserUseCase(this.repository);

  @override
  Future<UserDetailsEntity> call(params) {
    return repository.signUp(params);
  }
}