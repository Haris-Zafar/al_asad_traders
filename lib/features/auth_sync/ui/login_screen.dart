import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/errors/error_message.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:al_asad_traders/core/widgets/error_panel.dart';
import 'package:al_asad_traders/features/auth_sync/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for owner email and password login.
/// Rule: docs/UI_PLAN.md > Screens. Story: S32.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    ref
        .read(loginControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> loginState = ref.watch(loginControllerProvider);
    final ThemeData theme = Theme.of(context);

    String? errorMessage;
    if (loginState.hasError) {
      final Object err = loginState.error!;
      if (err is AppException) {
        errorMessage = userErrorMessage(err);
      } else {
        errorMessage = AppStrings.errorGeneric;
      }
    }

    return AppScaffold(
      title: AppStrings.logIn,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Al-Asad Traders',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              if (errorMessage != null) ...[
                ErrorPanel(message: errorMessage),
                const SizedBox(height: AppSpacing.m),
              ],
              AppTextField(
                key: const Key('login_email_field'),
                label: AppStrings.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                key: const Key('login_password_field'),
                label: AppStrings.password,
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                key: const Key('login_submit_button'),
                label: AppStrings.logIn,
                isLoading: loginState.isLoading,
                onPressed: loginState.isLoading ? null : _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
