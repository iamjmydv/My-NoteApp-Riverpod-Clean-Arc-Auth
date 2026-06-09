import 'package:my_noteapp_riverpod_clean_arc_auth/core/usecase/usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/repository/note_repository.dart';

class CreateNoteUseCaseParams {
  final String userId;
  final String title;
  final String content;

  const CreateNoteUseCaseParams({
    required this.userId,
    required this.title,
    required this.content,
  });
}

class CreateNoteUseCase
    implements UseCaseWithParams<NoteEntity, CreateNoteUseCaseParams> {
  final NoteRepository repository;

  const CreateNoteUseCase(this.repository);

  @override
  Future<NoteEntity> call(CreateNoteUseCaseParams params) =>
      repository.createNote(params);
}
