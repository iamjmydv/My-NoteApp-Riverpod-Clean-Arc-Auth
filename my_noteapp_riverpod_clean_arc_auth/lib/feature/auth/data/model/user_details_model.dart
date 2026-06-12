import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory UserDetailsModel.fromMap(Map<String,dynamic> map) => UserDetailsModel(
    firstName: map['firstName'] ?? '',
    lastName: map['lastName'] ?? '',
    age: map['age'] ?? 0,
    email: map['email'] ?? ''
  );

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'age': age,
    'email': email,
    'createdAt': FieldValue.serverTimestamp()
  };

  // Payload for `update()` — only the editable fields. Leaves email (the auth
  // identity) and createdAt untouched.
  Map<String, dynamic> toUpdateMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'age': age,
  };
}
