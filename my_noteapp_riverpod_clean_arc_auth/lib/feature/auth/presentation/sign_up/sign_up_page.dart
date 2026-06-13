import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/common/common.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/sign_up_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/sign_up/providers/sign_up_controller.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/sign_up/providers/sign_up_state.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Age must be a number';
    }
    if (age <= 0 || age > 120) {
      return 'Enter a valid age';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final params = SignUpUseCaseParams(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await ref.read(signUpControllerProvider.notifier).submit(params);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _ageController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<SignUpState>>(signUpControllerProvider, (prev, next) {
      switch (next.value) {
        case SignUpSuccessState(:final details):
          CommonSnackBar.showSuccess(
            context,
            'Sign up successful! Welcome, '
            '${details.firstName} ${details.lastName}.',
          );
          _resetForm();
          context.go(AppRoutes.notes);
        case SignUpFailedState(:final message):
          CommonSnackBar.showError(context, 'Sign up failed: $message');
        case _:
          break;
      }
    });

    final state = ref.watch(signUpControllerProvider).value;
    final isLoading = state is SignUpLoadingState;

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: _goToLogin)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create account', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 6),
                    Text(
                      'Start capturing your ideas',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkSub,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CommonTextField(
                            controller: _firstNameController,
                            label: 'First name',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            readOnly: isLoading,
                            canRequestFocus: !isLoading,
                            validator: (v) =>
                                _validateRequired(v, 'First name'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CommonTextField(
                            controller: _lastNameController,
                            label: 'Last name',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            readOnly: isLoading,
                            canRequestFocus: !isLoading,
                            validator: (v) => _validateRequired(v, 'Last name'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CommonTextField(
                      controller: _ageController,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      readOnly: isLoading,
                      canRequestFocus: !isLoading,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: _validateAge,
                    ),
                    const SizedBox(height: 16),
                    CommonTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      readOnly: isLoading,
                      canRequestFocus: !isLoading,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CommonPasswordField(
                      controller: _passwordController,
                      hint: 'at least 6 characters',
                      readOnly: isLoading,
                      canRequestFocus: !isLoading,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _onSubmit(),
                    ),
                    const SizedBox(height: 24),
                    CommonPrimaryButton(
                      label: 'Create account',
                      isLoading: isLoading,
                      onPressed: _onSubmit,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CommonRichLinkText(
                        text: 'Already have an account?  ',
                        linkText: 'Log in',
                        onTap: _goToLogin,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
