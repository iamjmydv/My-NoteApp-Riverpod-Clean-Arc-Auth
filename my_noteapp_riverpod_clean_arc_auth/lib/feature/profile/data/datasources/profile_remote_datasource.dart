import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/error/failure.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/data/model/user_details_model.dart';

// The ONLY file in the profile feature that talks to Firestore. Reads the
// users/{uid} document and converts it into a UserDetailsModel.
abstract class ProfileRemoteDataSource {
  Future<UserDetailsModel> getProfile(String uid);
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
}
