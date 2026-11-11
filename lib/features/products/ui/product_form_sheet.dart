import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_sheet.dart';
import 'package:al_asad_traders/core/widgets/app_text_field.dart';
import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal bottom sheet form for creating or editing a product.
/// Rule: docs/UI_PLAN.md > Screens (/products). Story: S1.
class ProductFormSheet extends ConsumerStatefulWidget {
  /// Creates a [ProductFormSheet].
  const ProductFormSheet({super.key, this.product});

  /// Existing product to edit, or null if creating a new product.
  final Product? product;

  /// Shows the product form bottom sheet.
  static Future<bool?> show(BuildContext context, {Product? product}) {
    return AppSheet.show<bool>(
      context,
      title: product == null ? AppStrings.addProduct : AppStrings.editProduct,
      child: ProductFormSheet(product: product),
    );
  }

  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _supplierRateController;
  late final TextEditingController _buyerRateController;
  late final TextEditingController _retailPriceController;
  late final TextEditingController _notesController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _supplierRateController = TextEditingController(
      text: widget.product?.defaultSupplierRate.toString() ?? '0',
    );
    _buyerRateController = TextEditingController(
      text: widget.product?.defaultBuyerRate.toString() ?? '0',
    );
    _retailPriceController = TextEditingController(
      text: widget.product?.defaultRetailPrice.toString() ?? '0',
    );
    _notesController = TextEditingController(text: widget.product?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _supplierRateController.dispose();
    _buyerRateController.dispose();
    _retailPriceController.dispose();
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

    final supplierRate = int.tryParse(_supplierRateController.text.trim()) ?? 0;
    final buyerRate = int.tryParse(_buyerRateController.text.trim()) ?? 0;
    final retailPrice = int.tryParse(_retailPriceController.text.trim()) ?? 0;

    if (supplierRate < 0 || buyerRate < 0 || retailPrice < 0) {
      setState(() {
        _errorMessage = 'Prices cannot be negative';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final skuText = _skuController.text.trim();
      final notesText = _notesController.text.trim();

      final updatedProduct = Product(
        id: widget.product?.id ?? '',
        name: nameText,
        sku: skuText.isEmpty ? null : skuText,
        defaultSupplierRate: supplierRate,
        defaultBuyerRate: buyerRate,
        defaultRetailPrice: retailPrice,
        notes: notesText.isEmpty ? null : notesText,
        archivedAt: widget.product?.archivedAt,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      await repository.saveProduct(updatedProduct);
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
              key: const Key('product_name_field'),
              controller: _nameController,
              label: AppStrings.nameLabel,
              hintText: 'e.g. Sugar 1kg',
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('product_sku_field'),
              controller: _skuController,
              label: AppStrings.barcode,
              hintText: 'e.g. 1234567890123',
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('product_supplier_rate_field'),
              controller: _supplierRateController,
              label: AppStrings.defaultBuyingPrice,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('product_buyer_rate_field'),
              controller: _buyerRateController,
              label: AppStrings.defaultSellingPrice,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('product_retail_price_field'),
              controller: _retailPriceController,
              label: AppStrings.shopPriceLabel,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.m),
            AppTextField(
              key: const Key('product_notes_field'),
              controller: _notesController,
              label: AppStrings.notesLabel,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              key: const Key('product_save_button'),
              label: AppStrings.save,
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
