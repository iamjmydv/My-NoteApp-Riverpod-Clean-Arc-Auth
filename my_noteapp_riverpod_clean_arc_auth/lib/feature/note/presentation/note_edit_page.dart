import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
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
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(noteEditControllerProvider.notifier)
        .delete(DeleteNoteUseCaseParams(id: existing.id));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<NoteEditState>>(noteEditControllerProvider,
        (prev, next) {
      switch (next.value) {
        case NoteEditSuccessState(:final wasCreated):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  wasCreated ? 'Note created' : 'Note updated',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          ref.read(noteEditControllerProvider.notifier).reset();
          if (context.canPop()) context.pop();
        case NoteEditDeletedState():
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                content: const Text(
                  'Note deleted',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          ref.read(noteEditControllerProvider.notifier).reset();
          if (context.canPop()) context.pop();
        case NoteEditFailedState(:final message):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
        case _:
          break;
      }
    });

    final state = ref.watch(noteEditControllerProvider).value;
    final isLoading = state is NoteEditLoadingState;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (widget.isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: isLoading ? null : _onDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validateRequired(v, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !isLoading,
                  minLines: 6,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _validateRequired(v, 'Content'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _onSave,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEditing ? 'Save changes' : 'Create'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
