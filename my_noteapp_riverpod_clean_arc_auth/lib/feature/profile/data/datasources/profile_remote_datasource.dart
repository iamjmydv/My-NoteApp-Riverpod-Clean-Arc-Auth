import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/error/failure.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/model/user_details_model.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/usecases/update_profile_usecase.dart';

// The ONLY file in the profile feature that talks to Firestore. Reads and
// updates the users/{uid} document and converts it into a UserDetailsModel.
abstract class ProfileRemoteDataSource {
  Future<UserDetailsModel> getProfile(String uid);
  Future<UserDetailsModel> updateProfile(UpdateProfileUseCaseParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  const ProfileRemoteDataSourceImpl({required this.firestore});

  static const _collection = 'users';

  @override
  Future<UserDetailsModel> getProfile(String uid) async {
    try {
      final snapshot = await firestore.collection(_collection).doc(uid).get();
      if (!snapshot.exists) {
        throw const UnknownFailure('Profile not found for this account');
      }
      return UserDetailsModel.fromMap(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<UserDetailsModel> updateProfile(
    UpdateProfileUseCaseParams params,
  ) async {
    try {
      final doc = firestore.collection(_collection).doc(params.uid);
      final draft = UserDetailsModel(
        firstName: params.firstName,
        lastName: params.lastName,
        age: params.age,
        email: '', // not edited here; toUpdateMap() leaves email untouched.
      );
      await doc.update(draft.toUpdateMap());

      final snapshot = await doc.get();
      if (!snapshot.exists) {
        throw const UnknownFailure('Profile not found for this account');
      }
      return UserDetailsModel.fromMap(snapshot.data()!);
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
