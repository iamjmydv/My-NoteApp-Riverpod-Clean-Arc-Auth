import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/repository/note_repository.dart';

class WatchNotesUseCaseParams {
  final String userId;

  const WatchNotesUseCaseParams({required this.userId});
}

// Stream-shaped (not Future), so it doesn't extend UseCaseWithParams: Firestore
// pushes updates whenever the notes collection changes.
class WatchNotesUseCase {
  final NoteRepository repository;

  const WatchNotesUseCase(this.repository);

  Stream<List<NoteEntity>> call(WatchNotesUseCaseParams params) =>
      repository.watchNotes(params.userId);
}
