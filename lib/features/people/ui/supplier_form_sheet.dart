import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_sheet.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/people/data/suppliers_repository.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal bottom sheet form for creating or editing a supplier.
/// Rule: docs/UI_PLAN.md > Screens (/suppliers). Story: S9.
class SupplierFormSheet extends ConsumerStatefulWidget {
  /// Creates a [SupplierFormSheet].
  const SupplierFormSheet({super.key, this.supplier});

  /// Existing supplier to edit, or null if creating a new supplier.
  final Supplier? supplier;

  /// Shows the supplier form bottom sheet.
  static Future<bool?> show(BuildContext context, {Supplier? supplier}) {
    return AppSheet.show<bool>(
      context,
      title: supplier == null
          ? AppStrings.addSupplier
          : AppStrings.editSupplier,
      child: SupplierFormSheet(supplier: supplier),
    );
  }

  @override
  ConsumerState<SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends ConsumerState<SupplierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _contactController = TextEditingController(
      text: widget.supplier?.contactNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.supplier?.address ?? '',
    );
    _notesController = TextEditingController(
      text: widget.supplier?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final nameText = _nameController.text.trim();
    if (nameText.isEmpty) {
      setState(() {
        _errorMessage = 'Name cannot be empty';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(suppliersRepositoryProvider);
      final contactText = _contactController.text.trim();
      final addressText = _addressController.text.trim();
      final notesText = _notesController.text.trim();

      final updatedSupplier = Supplier(
        id: widget.supplier?.id ?? '',
        name: nameText,
        contactNumber: contactText.isEmpty ? null : contactText,
        address: addressText.isEmpty ? null : addressText,
        notes: notesText.isEmpty ? null : notesText,
        archivedAt: widget.supplier?.archivedAt,
        createdAt: widget.supplier?.createdAt ?? DateTime.now(),
      );

      await repository.saveSupplier(updatedSupplier);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.s),
            ],
            AppTextField(
              key: const Key('supplier_name_field'),
              label: AppStrings.nameLabel,
              controller: _nameController,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('supplier_contact_field'),
              label: AppStrings.contactNumberLabel,
              controller: _contactController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('supplier_address_field'),
              label: AppStrings.addressLabel,
              controller: _addressController,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('supplier_notes_field'),
              label: AppStrings.notesLabel,
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              key: const Key('supplier_save_button'),
              label: AppStrings.save,
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }
}
