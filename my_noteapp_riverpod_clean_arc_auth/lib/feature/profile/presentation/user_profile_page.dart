import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/profile_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';

// Read-only profile screen — renders loading / error / data and supports
// pull-to-refresh.
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: profileAsync.value == null
                ? null
                : () => context.push(
                      AppRoutes.editProfile,
                      extra: profileAsync.value,
                    ),
          ),
        ],
      ),
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

class _ProfileBody extends ConsumerWidget {
  final UserDetailsEntity profile;
  final String uid;

  const _ProfileBody({required this.profile, required this.uid});

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(firebaseAuthProvider).signOut();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              _initials(profile.firstName, profile.lastName),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: AppColors.primary),
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
          child: Text(profile.email, style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _InfoRow(label: 'First name', value: profile.firstName),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(label: 'Last name', value: profile.lastName),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(label: 'Age', value: profile.age.toString()),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(label: 'Email', value: profile.email),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(label: 'User ID', value: uid, monospace: true),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () => _logout(context, ref),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorSoft,
              foregroundColor: AppColors.error,
              elevation: 0,
              textStyle: theme.textTheme.titleSmall
                  ?.copyWith(color: AppColors.error),
            ),
            child: const Text('Log out'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  const _InfoRow({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                fontWeight: monospace ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
