import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/model/user_details_model.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/sign_up_user_usecase.dart';

abstract class AuthRemoteDatasource {
  Future<UserDetailsModel> signUp(SignUpUseCaseParams params);
  Future<UserDetailsModel> login(LoginUseCaseParams params); 
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  FirebaseAuth auth;
  FirebaseFirestore firestore;

  AuthRemoteDatasourceImpl({required this.auth, required this.firestore});
  
  @override
  Future<UserDetailsModel> login(LoginUseCaseParams params) {
    throw UnimplementedError();
  } 

  @override
  Future<UserDetailsModel> signUp(SignUpUseCaseParams params) {
    throw UnimplementedError();
  }
}