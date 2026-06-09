import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/error/failure.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/data/model/note_model.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/create_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/delete_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/update_note_usecase.dart';

// The ONLY file in the note feature that talks to Firestore directly.
abstract class NoteRemoteDataSource {
  Stream<List<NoteModel>> watchNotes(String userId);
  Future<NoteModel> createNote(CreateNoteUseCaseParams params);
  Future<NoteModel> updateNote(UpdateNoteUseCaseParams params);
  Future<void> deleteNote(DeleteNoteUseCaseParams params);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final FirebaseFirestore firestore;

  const NoteRemoteDataSourceImpl({required this.firestore});

  static const _collection = 'notes';

  CollectionReference<Map<String, dynamic>> get _notes =>
      firestore.collection(_collection);

  @override
  Stream<List<NoteModel>> watchNotes(String userId) {
    // Sort client-side to avoid the composite index that
    // `where(userId) + orderBy(updatedAt)` would require.
    return _notes.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final notes = snap.docs.map(NoteModel.fromDoc).toList();
      notes.sort((a, b) {
        // Pending serverTimestamp shows as null locally — treat as newest.
        final aTime = a.updatedAt ?? DateTime.now();
        final bTime = b.updatedAt ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return notes;
    }).handleError((Object e) {
      if (e is FirebaseException) {
        throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
      }
      throw UnknownFailure(e.toString());
    });
  }

  @override
  Future<NoteModel> createNote(CreateNoteUseCaseParams params) async {
    try {
      final draft = NoteModel(
        id: '',
        userId: params.userId,
        title: params.title,
        content: params.content,
      );
      final ref = await _notes.add(draft.toCreateMap());
      final saved = await ref.get();
      return NoteModel.fromDoc(saved);
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<NoteModel> updateNote(UpdateNoteUseCaseParams params) async {
    try {
      final draft = NoteModel(
        id: params.id,
        userId: params.userId,
        title: params.title,
        content: params.content,
      );
      await _notes.doc(params.id).update(draft.toUpdateMap());
      final saved = await _notes.doc(params.id).get();
      return NoteModel.fromDoc(saved);
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> deleteNote(DeleteNoteUseCaseParams params) async {
    try {
      await _notes.doc(params.id).delete();
    } on FirebaseException catch (e) {
      throw ServerFailure(e.message ?? 'Firestore error (${e.code})');
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
