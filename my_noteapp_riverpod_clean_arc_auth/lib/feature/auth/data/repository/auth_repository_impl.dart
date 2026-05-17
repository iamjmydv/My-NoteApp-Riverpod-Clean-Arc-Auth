import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/model/user_details_model.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/repository/auth_repository.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/sign_up_user_usecase.dart';

class AuthRepositoryImpl extends AuthRepository{

  AuthRemoteDatasource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<UserDetailsModel> signUp(SignUpUseCaseParams params) => remote.signUp(params);
  
  @override
  Future<UserDetailsModel> login(LoginUseCaseParams params) => remote.login(params);

  
}