import 'package:my_noteapp_riverpod_clean_arc_auth/core/usecase/usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/repository/note_repository.dart';

class DeleteNoteUseCaseParams {
  final String id;

  const DeleteNoteUseCaseParams({required this.id});
}

class DeleteNoteUseCase
    implements UseCaseWithParams<void, DeleteNoteUseCaseParams> {
  final NoteRepository repository;

  const DeleteNoteUseCase(this.repository);

  @override
  Future<void> call(DeleteNoteUseCaseParams params) =>
      repository.deleteNote(params);
}
