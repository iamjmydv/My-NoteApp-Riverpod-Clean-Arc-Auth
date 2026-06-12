import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/note_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/note/domain/entities/note_entity.dart';

/// (background tint, accent dot) pairs cycled across the note list.
const List<(Color, Color)> _cardTints = [
  (Color(0xFFEFF6FF), Color(0xFF3B82F6)), // blue
  (Color(0xFFFDF2F8), Color(0xFFEC4899)), // pink
  (Color(0xFFFFFBEB), Color(0xFFF59E0B)), // amber
  (Color(0xFFF0FDF4), Color(0xFF22C55E)), // green
  (Color(0xFFF5F3FF), Color(0xFF8B5CF6)), // violet
];

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
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(email: email, accountName: accountName),
      appBar: AppBar(
        title: const Text('Homepage List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Account',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  initial,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: AppColors.primary),
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
                    orElse: () => Text('Hi, $accountName',
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search notes',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.inkFaint),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.inkFaint),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: notesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load notes: $e',
                        textAlign: TextAlign.center),
                  ),
                ),
                data: (notes) {
                  final filtered = _query.isEmpty
                      ? notes
                      : notes
                          .where((n) =>
                              n.title
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()) ||
                              n.content
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()))
                          .toList();

                  if (notes.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'No notes yet',
                      subtitle: 'Tap "New Note" to capture your first idea.',
                    );
                  }
                  if (filtered.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.search_off,
                      title: 'No matches',
                      subtitle: 'Try a different search term.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    final (bg, dot) = _cardTints[index % _cardTints.length];

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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
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
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  accountName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
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
                _DrawerItem(
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
                _DrawerItem(
                  icon: Icons.logout,
                  iconBg: AppColors.errorSoft,
                  iconColor: AppColors.error,
                  title: 'Logout',
                  titleColor: AppColors.error,
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
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final bool active;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: active ? AppColors.surfaceAlt : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: titleColor ?? AppColors.ink),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
