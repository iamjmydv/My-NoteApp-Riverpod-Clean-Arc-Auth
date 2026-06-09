import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/note_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/create_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/delete_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/update_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/presentation/providers/note_edit_state.dart';

class NoteEditController extends AsyncNotifier<NoteEditState> {
  @override
  FutureOr<NoteEditState> build() => const NoteEditInitialState();

  Future<void> create(CreateNoteUseCaseParams params) async {
    state = const AsyncValue.data(NoteEditLoadingState());

    final result = await AsyncValue.guard<NoteEditState>(() async {
      final note = await ref.read(createNoteUseCaseProvider).call(params);
      return NoteEditSuccessState(note: note, wasCreated: true);
    });

    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(NoteEditLoadingState()),
      error: (e, _) => AsyncValue.data(NoteEditFailedState(e.toString())),
    );
  }

  Future<void> save(UpdateNoteUseCaseParams params) async {
    state = const AsyncValue.data(NoteEditLoadingState());

    final result = await AsyncValue.guard<NoteEditState>(() async {
      final note = await ref.read(updateNoteUseCaseProvider).call(params);
      return NoteEditSuccessState(note: note, wasCreated: false);
    });

    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(NoteEditLoadingState()),
      error: (e, _) => AsyncValue.data(NoteEditFailedState(e.toString())),
    );
  }

  Future<void> delete(DeleteNoteUseCaseParams params) async {
    state = const AsyncValue.data(NoteEditLoadingState());

    final result = await AsyncValue.guard<NoteEditState>(() async {
      await ref.read(deleteNoteUseCaseProvider).call(params);
      return const NoteEditDeletedState();
    });

    state = result.when(
      data: AsyncValue.data,
      loading: () => const AsyncValue.data(NoteEditLoadingState()),
      error: (e, _) => AsyncValue.data(NoteEditFailedState(e.toString())),
    );
  }

  void reset() => state = const AsyncValue.data(NoteEditInitialState());
}

final noteEditControllerProvider =
    AsyncNotifierProvider.autoDispose<NoteEditController, NoteEditState>(
  NoteEditController.new,
);
