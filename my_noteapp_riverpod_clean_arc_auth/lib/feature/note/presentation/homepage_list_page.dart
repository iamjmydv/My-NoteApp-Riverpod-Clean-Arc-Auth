import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/note_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';

class HomepageListPage extends ConsumerWidget {
  const HomepageListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view notes.')),
      );
    }

    final notesAsync = ref.watch(notesStreamProvider(user.uid));

    final email = user.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final accountName = email.contains('@') ? email.split('@').first : 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage List'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(accountName),
              accountEmail: Text(email.isEmpty ? '—' : email),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('User Profile'),
              subtitle: email.isEmpty ? null : Text(email),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.userProfile);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(firebaseAuthProvider).signOut();
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load notes: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('No notes yet. Tap + to create one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _NoteTile(note: notes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.noteCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final NoteEntity note;
  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        note.title.isEmpty ? '(Untitled)' : note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.noteEdit, extra: note),
    );
  }
}
