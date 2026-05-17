import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/sign_up_user_usecase.dart';

abstract class AuthRepository {
  Future<UserDetailsEntity> signUp(SignUpUseCaseParams params);
  Future<UserDetailsEntity> login(LoginUseCaseParams params);
}