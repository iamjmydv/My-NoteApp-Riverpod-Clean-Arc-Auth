import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';

// Data-layer twin of NoteEntity — adds Firestore (de)serialisation.
class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    super.createdAt,
    super.updatedAt,
  });

  factory NoteModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return NoteModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Payload for `add()` — sets both timestamps.
  Map<String, dynamic> toCreateMap() => {
        'userId': userId,
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  // Payload for `update()` — only bumps updatedAt.
  Map<String, dynamic> toUpdateMap() => {
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
