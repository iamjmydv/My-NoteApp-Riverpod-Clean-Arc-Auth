import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/create_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/delete_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/update_note_usecase.dart';

abstract class NoteRepository {
  /// Streams the notes that belong to [userId], newest first.
  Stream<List<NoteEntity>> watchNotes(String userId);

  /// Creates a new note and returns the saved entity.
  Future<NoteEntity> createNote(CreateNoteUseCaseParams params);

  /// Updates an existing note and returns the saved entity.
  Future<NoteEntity> updateNote(UpdateNoteUseCaseParams params);

  /// Deletes the note with the given id.
  Future<void> deleteNote(DeleteNoteUseCaseParams params);
}
