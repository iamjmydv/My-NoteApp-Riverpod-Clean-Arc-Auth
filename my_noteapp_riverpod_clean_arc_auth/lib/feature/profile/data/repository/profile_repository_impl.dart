import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/data/datasources/profile_remote_datasource.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  const ProfileRepositoryImpl(this.remote);

  @override
  Future<UserDetailsEntity> getProfile(String uid) => remote.getProfile(uid);
}
