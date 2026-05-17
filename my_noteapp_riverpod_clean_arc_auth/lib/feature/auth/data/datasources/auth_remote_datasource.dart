import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/error/failure.dart';
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

  AuthRemoteDatasourceImpl({
    required this.auth, 
    required this.firestore
  });

  final String _collection = 'users';

  @override
  Future<UserDetailsModel> signUp(SignUpUseCaseParams params) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      final profile = UserDetailsModel(
        firstName: params.firstName,
        lastName: params.lastName,
        age: params.age,
        email: params.email,
      );

      await firestore
          .collection(_collection)
          .doc(credential.user!.uid)
          .set(profile.toMap());

      return profile;
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_authErrorMessage(e));
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<UserDetailsModel> login(LoginUseCaseParams params) {
    throw UnimplementedError();
  }

  /// Turn Firebase Auth error codes into user-friendly messages.
  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'That email is already registered';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'network-request-failed':
        return 'Network error, please try again';
      default:
        return e.message ?? 'Authentication error (${e.code})';
    }
  }
}
