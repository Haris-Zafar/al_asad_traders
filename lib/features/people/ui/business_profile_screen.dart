import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/errors/error_message.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:al_asad_traders/core/widgets/error_panel.dart';
import 'package:al_asad_traders/core/widgets/loading_view.dart';
import 'package:al_asad_traders/features/people/models/profile.dart';
import 'package:al_asad_traders/features/people/providers/profile_provider.dart';
import 'package:al_asad_traders/features/people/ui/bank_accounts_list_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen for viewing and editing the business profile.
/// Rule: docs/UI_PLAN.md > Screens (/more/business). Story: S11.
class BusinessProfileScreen extends ConsumerStatefulWidget {
  /// Creates a [BusinessProfileScreen].
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();

  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  void _initializeFields(Profile? profile) {
    if (!_isInitialized && profile != null) {
      _nameController.text = profile.businessName;
      _addressController.text = profile.businessAddress;
      _phone1Controller.text = profile.contactNumber1;
      _phone2Controller.text = profile.contactNumber2 ?? '';
      _isInitialized = true;
    }
  }

  Future<void> _save() async {
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    await ref
        .read(profileControllerProvider.notifier)
        .saveProfile(
          businessName: _nameController.text,
          businessAddress: _addressController.text,
          contactNumber1: _phone1Controller.text,
          contactNumber2: _phone2Controller.text,
        );

    final AsyncValue<void> state = ref.read(profileControllerProvider);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.businessProfileSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Profile?> profileAsync = ref.watch(profileStreamProvider);
    final AsyncValue<void> saveState = ref.watch(profileControllerProvider);

    return AppScaffold(
      title: AppStrings.businessProfileTitle,
      body: profileAsync.when(
        data: (Profile? profile) {
          _initializeFields(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (saveState.hasError) ...<Widget>[
                    ErrorPanel(
                      message: saveState.error is AppException
                          ? userErrorMessage(saveState.error! as AppException)
                          : saveState.error.toString(),
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  AppTextField(
                    key: const Key('business_name_field'),
                    label: AppStrings.businessNameLabel,
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    key: const Key('business_address_field'),
                    label: AppStrings.businessAddressLabel,
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    key: const Key('contact_number_1_field'),
                    label: AppStrings.contactNumber1Label,
                    controller: _phone1Controller,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    key: const Key('contact_number_2_field'),
                    label: AppStrings.contactNumber2Label,
                    controller: _phone2Controller,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppListRow(
                    key: const Key('profile_bank_accounts_row'),
                    title: AppStrings.bankAccounts,
                    subtitle: 'Manage own business bank accounts',
                    onTap: () => BankAccountsListSheet.show(
                      context,
                      profileId: 'main',
                      ownerName:
                          profile?.businessName ??
                          AppStrings.businessProfileTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    key: const Key('save_profile_button'),
                    label: AppStrings.save,
                    isLoading: saveState.isLoading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stack) => ErrorPanel(
          message: error is AppException
              ? userErrorMessage(error)
              : error.toString(),
        ),
      ),
    );
  }
}
