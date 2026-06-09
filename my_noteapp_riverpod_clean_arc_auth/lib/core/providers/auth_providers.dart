import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/sign_up_user_usecase.dart';

//-------------------- Firebase Auth -----------------------------------------------------------------------------------
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

//-------------------- Firebase Firestore ------------------------------------------------------------------------------
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

//-------------------- Datasource --------------------------------------------------------------------------------------

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);

//-------------------- Repository --------------------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider)),
);

//-------------------- Sign Up -----------------------------------------------------------------------------------------
final signUpUseCaseProvider = Provider<SignUpUserUseCase>(
  (ref) => SignUpUserUseCase(ref.watch(authRepositoryProvider))
);

//-------------------- Login -------------------------------------------------------------------------------------------
final loginUserUseCaseProvider = Provider<LoginUserUseCase>(
  (ref) => LoginUserUseCase(ref.watch(authRepositoryProvider))
);