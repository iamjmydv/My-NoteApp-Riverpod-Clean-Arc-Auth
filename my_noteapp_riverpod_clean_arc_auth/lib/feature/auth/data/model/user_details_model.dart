import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

class UserDetailsModel extends UserDetailsEntity{
  UserDetailsModel({
    required super.firstName,
    required super.lastName,
    required super.age,
    required super.email,
  });
}