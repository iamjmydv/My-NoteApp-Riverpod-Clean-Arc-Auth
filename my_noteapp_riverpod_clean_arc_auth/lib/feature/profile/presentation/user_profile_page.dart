import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/profile_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

// Read-only profile screen — renders loading / error / data and supports
// pull-to-refresh. No controller because there are no actions to perform.
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to view your profile.'),
        ),
      );
    }

    final profileAsync = ref.watch(userProfileProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load profile: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (profile) => RefreshIndicator(
          onRefresh: () => ref.refresh(userProfileProvider(user.uid).future),
          child: _ProfileBody(profile: profile, uid: user.uid),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserDetailsEntity profile;
  final String uid;

  const _ProfileBody({required this.profile, required this.uid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(profile.firstName, profile.lastName);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initials,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${profile.firstName} ${profile.lastName}',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Card(
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.person_outline,
                label: 'First name',
                value: profile.firstName,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.person_outline,
                label: 'Last name',
                value: profile.lastName,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: profile.age.toString(),
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile.email,
              ),
              const Divider(height: 1),
              _InfoTile(
                icon: Icons.fingerprint,
                label: 'User ID',
                value: uid,
                monospace: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool monospace;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: theme.textTheme.labelLarge),
      subtitle: Text(
        value,
        style: monospace
            ? theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')
            : theme.textTheme.bodyLarge,
      ),
    );
  }
}
