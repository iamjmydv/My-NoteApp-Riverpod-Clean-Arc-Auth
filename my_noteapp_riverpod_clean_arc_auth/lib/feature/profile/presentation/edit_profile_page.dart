import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/auth_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/providers/profile_providers.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/entities/user_details_entity.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/domain/usecases/update_profile_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/presentation/providers/edit_profile_controller.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/profile/presentation/providers/edit_profile_state.dart';

/// Edit Profile — updates the editable fields (first name, last name, age) of
/// the signed-in user's Firestore profile via [EditProfileController]. Email is
/// the Firebase Auth identity and is shown read-only.
class EditProfilePage extends ConsumerStatefulWidget {
  final UserDetailsEntity? profile;

  const EditProfilePage({super.key, this.profile});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _ageController = TextEditingController(text: p?.age.toString() ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null) return 'Age must be a number';
    if (age <= 0 || age > 120) return 'Enter a valid age';
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

    final params = UpdateProfileUseCaseParams(
      uid: user.uid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
    );

    await ref.read(editProfileControllerProvider.notifier).submit(params);
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final initials =
        _initials(_firstNameController.text, _lastNameController.text);

    ref.listen<AsyncValue<EditProfileState>>(editProfileControllerProvider,
        (prev, next) {
      switch (next.value) {
        case EditProfileSuccessState():
          // Refresh the read-only profile screen so it shows the new values.
          if (user != null) {
            ref.invalidate(userProfileProvider(user.uid));
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                content: const Text(
                  'Profile updated',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          ref.read(editProfileControllerProvider.notifier).reset();
          if (context.canPop()) context.pop();
        case EditProfileFailedState(:final message):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  'Update failed: $message',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
        case _:
          break;
      }
    });

    final state = ref.watch(editProfileControllerProvider).value;
    final isLoading = state is EditProfileLoadingState;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              // Avatar with edit badge
              Center(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          initials,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.photo_camera,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _Label('First name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(hintText: 'First name'),
                validator: (v) => _validateRequired(v, 'First name'),
              ),
              const SizedBox(height: 16),
              _Label('Last name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(hintText: 'Last name'),
                validator: (v) => _validateRequired(v, 'Last name'),
              ),
              const SizedBox(height: 16),
              _Label('Age'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(hintText: 'Age'),
                validator: _validateAge,
                onFieldSubmitted: (_) => _onSave(),
              ),
              const SizedBox(height: 16),
              _Label('Email (cannot be changed)'),
              const SizedBox(height: 8),
              // Email is the Firebase Auth identity — read-only here. Changing
              // it would require re-authentication, so it's shown for reference.
              TextFormField(
                controller: _emailController,
                enabled: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'you@example.com'),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading ? null : _onSave,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: AppColors.inkSub),
    );
  }
}
