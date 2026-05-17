import 'package:my_noteapp_riverpod_clean_arc_auth/core/usecase/usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/repository/auth_repository.dart';

class LoginUseCaseParams {
  final String email;
  final String password;

  LoginUseCaseParams({required this.email, required this.password});
}

class LoginUserUseCase implements UseCaseWithParams<UserDetailsEntity, LoginUseCaseParams> {
  
  AuthRepository repository;
  LoginUserUseCase(this.repository);

  @override
  Future<UserDetailsEntity> call(LoginUseCaseParams params) => 
  repository.login(params);
}