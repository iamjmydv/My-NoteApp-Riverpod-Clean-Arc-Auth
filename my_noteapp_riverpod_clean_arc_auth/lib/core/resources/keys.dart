// Field names used in Firestore documents. Centralised so models serialise
// consistently and a schema rename only happens in one place.
class Keys {
  static String firstName = 'firstName';
  static String lastName = 'lastName';
  static String age = 'age';
  static String email = 'email';
  static String createdAt = 'createdAt';
}
