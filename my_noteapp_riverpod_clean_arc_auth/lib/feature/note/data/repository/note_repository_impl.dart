import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/data/datasources/note_remote_datasource.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/repository/note_repository.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/create_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/delete_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/update_note_usecase.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remote;

  const NoteRepositoryImpl(this.remote);

  @override
  Stream<List<NoteEntity>> watchNotes(String userId) =>
      remote.watchNotes(userId);

  @override
  Future<NoteEntity> createNote(CreateNoteUseCaseParams params) =>
      remote.createNote(params);

  @override
  Future<NoteEntity> updateNote(UpdateNoteUseCaseParams params) =>
      remote.updateNote(params);

  @override
  Future<void> deleteNote(DeleteNoteUseCaseParams params) =>
      remote.deleteNote(params);
}
