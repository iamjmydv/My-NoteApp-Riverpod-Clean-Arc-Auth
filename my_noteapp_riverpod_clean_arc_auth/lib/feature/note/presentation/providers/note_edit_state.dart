import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';

sealed class NoteEditState {
  const NoteEditState();
}

class NoteEditInitialState extends NoteEditState {
  const NoteEditInitialState();
}

class NoteEditLoadingState extends NoteEditState {
  const NoteEditLoadingState();
}

class NoteEditSuccessState extends NoteEditState {
  final NoteEntity note;
  final bool wasCreated;
  const NoteEditSuccessState({required this.note, required this.wasCreated});
}

class NoteEditDeletedState extends NoteEditState {
  const NoteEditDeletedState();
}

class NoteEditFailedState extends NoteEditState {
  final String message;
  const NoteEditFailedState(this.message);
}
