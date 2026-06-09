// DI graph for the note feature. Reuses firestoreProvider from
// auth_providers.dart so features share the same Firestore singleton.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/data/datasources/note_remote_datasource.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/data/repository/note_repository_impl.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/repository/note_repository.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/create_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/delete_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/update_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/watch_notes_usecase.dart';

final noteRemoteDataSourceProvider = Provider<NoteRemoteDataSource>(
  (ref) => NoteRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider)),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(ref.watch(noteRemoteDataSourceProvider)),
);

final watchNotesUseCaseProvider = Provider<WatchNotesUseCase>(
  (ref) => WatchNotesUseCase(ref.watch(noteRepositoryProvider)),
);

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>(
  (ref) => CreateNoteUseCase(ref.watch(noteRepositoryProvider)),
);

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>(
  (ref) => UpdateNoteUseCase(ref.watch(noteRepositoryProvider)),
);

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>(
  (ref) => DeleteNoteUseCase(ref.watch(noteRepositoryProvider)),
);

/// Streams the notes belonging to [userId], newest first.
final notesStreamProvider =
    StreamProvider.family<List<NoteEntity>, String>((ref, userId) {
  return ref
      .watch(watchNotesUseCaseProvider)
      .call(WatchNotesUseCaseParams(userId: userId));
});
