import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/errors/error_message.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/error_panel.dart';
import 'package:al_asad_traders/features/auth_sync/providers/device_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen performing first login device setup (invoice letter claim & full sync).
/// Rule: docs/UI_PLAN.md > Screens (/setup). Story: S33.
class SetupScreen extends ConsumerStatefulWidget {
  /// Creates a [SetupScreen].
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSetup();
    });
  }

  Future<void> _startSetup() async {
    await ref.read(deviceSetupControllerProvider.notifier).runSetup();
    final AsyncValue<void> state = ref.read(deviceSetupControllerProvider);
    if (!state.hasError && mounted) {
      if (GoRouter.maybeOf(context) != null) {
        context.go('/bills');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> setupState = ref.watch(
      deviceSetupControllerProvider,
    );
    final ThemeData theme = Theme.of(context);

    return AppScaffold(
      title: AppStrings.setupTitle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppStrings.setupMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (setupState.isLoading) ...<Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.m),
                  const Text(AppStrings.setupConnecting),
                ] else if (setupState.hasError) ...<Widget>[
                  ErrorPanel(
                    message: setupState.error is AppException
                        ? userErrorMessage(setupState.error! as AppException)
                        : setupState.error.toString(),
                    onRetry: _startSetup,
                  ),
                ] else ...<Widget>[
                  AppButton(
                    label: AppStrings.continueLabel,
                    onPressed: () {
                      if (GoRouter.maybeOf(context) != null) {
                        context.go('/bills');
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
