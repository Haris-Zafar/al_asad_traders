import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/app_dialogs.dart';
import 'package:al_asad_traders/features/auth_sync/providers/auth_provider.dart';
import 'package:al_asad_traders/features/auth_sync/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the logout confirmation dialog with sync status warning and performs logout.
/// Rule: wholesale_project.md > S35. Story: S35.
Future<void> showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final bool isSynced = ref.read(syncStateProvider);

  bool? confirmed;
  if (!isSynced) {
    confirmed = await showConfirmDialog(
      context,
      title: AppStrings.logOut,
      message:
          'Some changes are not synced yet. If you log out now, they are lost.',
      confirmLabel: AppStrings.logOutAnyway,
      cancelLabel: AppStrings.wait,
      isDanger: true,
    );
  } else {
    confirmed = await showConfirmDialog(
      context,
      title: AppStrings.logOut,
      message: 'Log out?',
      confirmLabel: AppStrings.logOut,
      cancelLabel: AppStrings.cancel,
    );
  }

  if (confirmed == true) {
    await ref.read(logoutControllerProvider.notifier).logout();
  }
}
