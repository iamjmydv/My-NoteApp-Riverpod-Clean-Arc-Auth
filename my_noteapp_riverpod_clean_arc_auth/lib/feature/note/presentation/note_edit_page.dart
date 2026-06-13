import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/common/common.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/utils/relative_time.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/create_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/delete_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/usecases/update_note_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/presentation/providers/note_edit_controller.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/presentation/providers/note_edit_state.dart';

// One screen handles BOTH "create a new note" and "edit an existing note".
class NoteEditPage extends ConsumerStatefulWidget {
  final NoteEntity? note;

  const NoteEditPage({super.key, this.note});

  bool get isEditing => note != null;

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      CommonSnackBar.showInfo(context, 'You must be logged in.');
      return;
    }

    final controller = ref.read(noteEditControllerProvider.notifier);
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final existing = widget.note;

    if (existing == null) {
      await controller.create(
        CreateNoteUseCaseParams(
          userId: user.uid,
          title: title,
          content: content,
        ),
      );
    } else {
      await controller.save(
        UpdateNoteUseCaseParams(
          id: existing.id,
          userId: existing.userId,
          title: title,
          content: content,
        ),
      );
    }
  }

  Future<void> _onDelete() async {
    final existing = widget.note;
    if (existing == null) return;

    final confirmed = await CommonConfirmDialog.show(
      context,
      title: 'Delete note?',
      message: 'This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;

    await ref
        .read(noteEditControllerProvider.notifier)
        .delete(DeleteNoteUseCaseParams(id: existing.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<NoteEditState>>(noteEditControllerProvider, (
      prev,
      next,
    ) {
      switch (next.value) {
        case NoteEditSuccessState(:final wasCreated):
          CommonSnackBar.showSuccess(
            context,
            wasCreated ? 'Note created' : 'Note updated',
          );
          ref.read(noteEditControllerProvider.notifier).reset();
          if (context.canPop()) context.pop();
        case NoteEditDeletedState():
          CommonSnackBar.showError(context, 'Note deleted');
          ref.read(noteEditControllerProvider.notifier).reset();
          if (context.canPop()) context.pop();
        case NoteEditFailedState(:final message):
          CommonSnackBar.showError(context, message);
        case _:
          break;
      }
    });

    final state = ref.watch(noteEditControllerProvider).value;
    final isLoading = state is NoteEditLoadingState;
    final edited = relativeTime(
      widget.note?.updatedAt ?? widget.note?.createdAt,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: [
          if (widget.isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: isLoading ? null : _onDelete,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
            child: CommonPrimaryButton(
              label: widget.isEditing ? 'Save' : 'Create',
              isLoading: isLoading,
              onPressed: _onSave,
              spinnerSize: 18,
              style: FilledButton.styleFrom(
                minimumSize: const Size(72, 40),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonTextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  readOnly: isLoading,
                  canRequestFocus: !isLoading,
                  style: theme.textTheme.headlineSmall,
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: false,
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Title',
                    hintStyle: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.inkFaint,
                    ),
                  ),
                  validator: (v) => _validateRequired(v, 'Title'),
                ),
                if (widget.isEditing && edited.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Edited $edited', style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: _contentController,
                  textCapitalization: TextCapitalization.sentences,
                  readOnly: isLoading,
                  canRequestFocus: !isLoading,
                  minLines: 8,
                  maxLines: null,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  decoration: InputDecoration(
                    filled: false,
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Start writing…',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkFaint,
                    ),
                  ),
                  validator: (v) => _validateRequired(v, 'Content'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
