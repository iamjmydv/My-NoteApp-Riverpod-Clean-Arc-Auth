import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/common/common.dart';
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
      CommonSnackBar.showInfo(context, 'You must be logged in.');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final initials = CommonAvatar.initialsFrom(
      _firstNameController.text,
      _lastNameController.text,
    );

    ref.listen<AsyncValue<EditProfileState>>(editProfileControllerProvider, (
      prev,
      next,
    ) {
      switch (next.value) {
        case EditProfileSuccessState():
          // Refresh the read-only profile screen so it shows the new values.
          if (user != null) {
            ref.invalidate(userProfileProvider(user.uid));
          }
          CommonSnackBar.showSuccess(context, 'Profile updated');
          ref.read(editProfileControllerProvider.notifier).reset();
          if (context.canPop()) context.pop();
        case EditProfileFailedState(:final message):
          CommonSnackBar.showError(context, 'Update failed: $message');
        case _:
          break;
      }
    });

    final state = ref.watch(editProfileControllerProvider).value;
    final isLoading = state is EditProfileLoadingState;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
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
                      CommonAvatar(
                        text: initials,
                        radius: 48,
                        textStyle: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
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
                          child: const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const CommonLabel('First name'),
              const SizedBox(height: 8),
              CommonTextField(
                controller: _firstNameController,
                hint: 'First name',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                readOnly: isLoading,
                canRequestFocus: !isLoading,
                validator: (v) => _validateRequired(v, 'First name'),
              ),
              const SizedBox(height: 16),
              const CommonLabel('Last name'),
              const SizedBox(height: 8),
              CommonTextField(
                controller: _lastNameController,
                hint: 'Last name',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                readOnly: isLoading,
                canRequestFocus: !isLoading,
                validator: (v) => _validateRequired(v, 'Last name'),
              ),
              const SizedBox(height: 16),
              const CommonLabel('Age'),
              const SizedBox(height: 8),
              CommonTextField(
                controller: _ageController,
                hint: 'Age',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                readOnly: isLoading,
                canRequestFocus: !isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: _validateAge,
                onFieldSubmitted: (_) => _onSave(),
              ),
              const SizedBox(height: 16),
              const CommonLabel('Email (cannot be changed)'),
              const SizedBox(height: 8),
              // Email is the Firebase Auth identity — read-only here. Changing
              // it would require re-authentication, so it's shown for reference.
              CommonTextField(
                controller: _emailController,
                enabled: false,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              CommonPrimaryButton(
                label: 'Save Changes',
                isLoading: isLoading,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
