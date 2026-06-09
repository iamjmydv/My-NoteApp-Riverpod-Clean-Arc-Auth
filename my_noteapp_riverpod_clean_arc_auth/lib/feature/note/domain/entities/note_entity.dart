// A note, expressed in pure-Dart business terms — no Firestore/Flutter here.
// NoteModel (data layer) extends this and adds (de)serialisation.
// createdAt / updatedAt are nullable because Firestore's serverTimestamp is
// null locally until the server stamps it.
class NoteEntity {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  NoteEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
