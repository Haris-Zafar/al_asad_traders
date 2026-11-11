import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/errors/error_message.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:al_asad_traders/core/widgets/error_panel.dart';
import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:al_asad_traders/features/people/providers/bank_accounts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal bottom sheet for adding or editing a bank account.
/// Rule: docs/UI_PLAN.md > Small tasks use bottom sheets. Story: S10.
class BankAccountFormSheet extends ConsumerStatefulWidget {
  /// Creates a [BankAccountFormSheet].
  const BankAccountFormSheet({
    super.key,
    this.bankAccount,
    this.profileId,
    this.buyerId,
    this.supplierId,
  });

  /// Optional bank account to edit. Null if creating a new one.
  final BankAccount? bankAccount;

  /// Optional owner profile ID ('main').
  final String? profileId;

  /// Optional owner buyer ID.
  final String? buyerId;

  /// Optional owner supplier ID.
  final String? supplierId;

  /// Shows the [BankAccountFormSheet] in a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    BankAccount? bankAccount,
    String? profileId,
    String? buyerId,
    String? supplierId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BankAccountFormSheet(
          bankAccount: bankAccount,
          profileId: profileId,
          buyerId: buyerId,
          supplierId: supplierId,
        ),
      ),
    );
  }

  @override
  ConsumerState<BankAccountFormSheet> createState() =>
      _BankAccountFormSheetState();
}

class _BankAccountFormSheetState extends ConsumerState<BankAccountFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _notesController;

  String? _nameError;
  String? _accountNumberError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.bankAccount?.name ?? '',
    );
    _accountNumberController = TextEditingController(
      text: widget.bankAccount?.accountNumber ?? '',
    );
    _notesController = TextEditingController(
      text: widget.bankAccount?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final focus = FocusScope.of(context);
    if (!focus.hasPrimaryFocus) {
      focus.unfocus();
    }

    final nameText = _nameController.text.trim();
    final numberText = _accountNumberController.text.trim();

    bool hasError = false;
    setState(() {
      if (nameText.isEmpty) {
        _nameError = 'Bank name is required';
        hasError = true;
      } else {
        _nameError = null;
      }

      if (numberText.isEmpty) {
        _accountNumberError = 'Account number is required';
        hasError = true;
      } else {
        _accountNumberError = null;
      }
    });

    if (hasError) return;

    final existing = widget.bankAccount;
    final account = BankAccount(
      id: existing?.id ?? '',
      profileId: existing?.profileId ?? widget.profileId,
      buyerId: existing?.buyerId ?? widget.buyerId,
      supplierId: existing?.supplierId ?? widget.supplierId,
      name: nameText,
      accountNumber: numberText,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      archivedAt: existing?.archivedAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    await ref
        .read(bankAccountControllerProvider.notifier)
        .saveBankAccount(account);

    final state = ref.read(bankAccountControllerProvider);
    if (!state.hasError && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.bankAccountSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bankAccountControllerProvider);
    final theme = Theme.of(context);
    final isEditing = widget.bankAccount != null;

    return KeyedSubtree(
      key: const Key('bank_account_form_sheet'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing
                  ? AppStrings.editBankAccount
                  : AppStrings.addBankAccount,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.l),
            if (state.hasError) ...[
              ErrorPanel(
                message: state.error is AppException
                    ? userErrorMessage(state.error! as AppException)
                    : state.error.toString(),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            AppTextField(
              key: const Key('bank_name_field'),
              label: AppStrings.bankNameLabel,
              controller: _nameController,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('account_number_field'),
              label: AppStrings.accountNumberLabel,
              controller: _accountNumberController,
              errorText: _accountNumberError,
              onChanged: (_) {
                if (_accountNumberError != null) {
                  setState(() => _accountNumberError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('bank_notes_field'),
              label: AppStrings.notesLabel,
              controller: _notesController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('save_bank_account_button'),
              label: AppStrings.save,
              isLoading: state.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
