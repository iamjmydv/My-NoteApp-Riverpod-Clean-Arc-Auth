import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

class UserDetailsModel extends UserDetailsEntity {
  UserDetailsModel({
    required super.firstName,
    required super.lastName,
    required super.age,
    required super.email,
  });

  factory UserDetailsModel.fromEntity(UserDetailsEntity e) => UserDetailsModel(
    firstName: e.firstName,
    lastName: e.lastName,
    age: e.age,
    email: e.email,
  );
}
