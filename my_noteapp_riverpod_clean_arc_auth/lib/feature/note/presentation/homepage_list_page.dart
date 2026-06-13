import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/common/common.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/note_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';

class HomepageListPage extends ConsumerStatefulWidget {
  const HomepageListPage({super.key});

  @override
  ConsumerState<HomepageListPage> createState() => _HomepageListPageState();
}

class _HomepageListPageState extends ConsumerState<HomepageListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(firebaseAuthProvider).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view notes.')),
      );
    }

    final notesAsync = ref.watch(notesStreamProvider(user.uid));
    final email = user.email ?? '';
    final accountName = email.contains('@') ? email.split('@').first : 'there';
    final initial = CommonAvatar.initialOf(email);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(email: email, accountName: accountName),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text('Homepage List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Account',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: CommonAvatar(
                text: initial,
                radius: 18,
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.noteCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Notes', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 2),
                  notesAsync.maybeWhen(
                    data: (notes) => Text(
                      notes.isEmpty
                          ? 'No notes yet'
                          : '${notes.length} '
                                '${notes.length == 1 ? 'note' : 'notes'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    orElse: () => Text(
                      'Hi, $accountName',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CommonSearchField(
                controller: _searchController,
                hint: 'Search notes',
                onChanged: (v) => setState(() => _query = v.trim()),
                showClear: _query.isNotEmpty,
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: notesAsync.when(
                loading: () => const CommonLoader.page(),
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
                  final filtered = _query.isEmpty
                      ? notes
                      : notes
                            .where(
                              (n) =>
                                  n.title.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ) ||
                                  n.content.toLowerCase().contains(
                                    _query.toLowerCase(),
                                  ),
                            )
                            .toList();

                  if (notes.isEmpty) {
                    return const CommonEmptyState(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'No notes yet',
                      subtitle: 'Tap "New Note" to capture your first idea.',
                    );
                  }
                  if (filtered.isEmpty) {
                    return const CommonEmptyState(
                      icon: Icons.search_off,
                      title: 'No matches',
                      subtitle: 'Try a different search term.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _NoteListCard(note: filtered[i], index: i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteListCard extends StatelessWidget {
  final NoteEntity note;
  final int index;
  const _NoteListCard({required this.note, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, dot) = AppColors.noteCardTint(index);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.noteEdit, extra: note),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? '(Untitled)' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (note.content.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        note.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  final String email;
  final String accountName;
  const _AppDrawer({required this.email, required this.accountName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final initial = CommonAvatar.initialOf(email);

    return Drawer(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(22, 60, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonAvatar(
                  text: initial,
                  radius: 28,
                  backgroundColor: Colors.white,
                  textStyle: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  accountName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email.isEmpty ? '—' : email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CommonDrawerItem(
                  icon: Icons.person_outline,
                  iconBg: AppColors.primarySoft,
                  iconColor: AppColors.primary,
                  title: 'User Profile',
                  subtitle: email.isEmpty ? null : email,
                  active: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.userProfile);
                  },
                ),
                const SizedBox(height: 4),
                CommonDrawerItem(
                  icon: Icons.logout,
                  iconBg: AppColors.errorSoft,
                  iconColor: AppColors.error,
                  title: 'Logout',
                  titleColor: AppColors.error,
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(firebaseAuthProvider).signOut();
                    await ref
                        .read(authLocalDataSourceProvider)
                        .setLoggedIn(false);
                    if (!context.mounted) return;
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
