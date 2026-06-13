import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/common/common.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/resources/strings.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/router/app_routes.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/theme/app_theme.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/core/widgets/app_logo.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/login/providers/login_controller.dart';
import 'package:my_noteapp_riverpod_clean_arc_auth/feature/auth/presentation/login/providers/login_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Strings.emailRequired;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return Strings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.passwordRequired;
    }
    if (value.length < 6) {
      return Strings.passwordTooShort;
    }
    return null;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final params = LoginUseCaseParams(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await ref.read(loginControllerProvider.notifier).submit(params);
  }

  void _goToSignUp() {
    context.push(AppRoutes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<LoginState>>(loginControllerProvider, (prev, next) {
      switch (next.value) {
        case LoginSuccessState(:final details):
          CommonSnackBar.showSuccess(
            context,
            'Welcome back, ${details.firstName} ${details.lastName}!',
          );
          context.go(AppRoutes.notes);
        case LoginFailedState(:final message):
          CommonSnackBar.showError(context, 'Login failed: $message');
        case _:
          break;
      }
    });

    final state = ref.watch(loginControllerProvider).value;
    final isLoading = state is LoginLoadingState;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppLogo(),
                    ),
                    const SizedBox(height: 28),
                    Text('Welcome back', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue to your notes',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkSub,
                      ),
                    ),
                    const SizedBox(height: 28),
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
                      readOnly: isLoading,
                      canRequestFocus: !isLoading,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _onSubmit(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => CommonSnackBar.showInfo(
                                context,
                                'Password reset coming soon.',
                              ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CommonPrimaryButton(
                      label: 'Log in',
                      isLoading: isLoading,
                      onPressed: _onSubmit,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CommonRichLinkText(
                        text: "Don't have an account?  ",
                        linkText: 'Sign up',
                        onTap: _goToSignUp,
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
