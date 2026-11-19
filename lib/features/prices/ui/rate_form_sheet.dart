import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_list_row.dart';
import 'package:al_asad_traders/core/widgets/app_number_field.dart';
import 'package:al_asad_traders/core/widgets/app_sheet.dart';
import 'package:al_asad_traders/core/widgets/picker_sheet.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:al_asad_traders/features/people/providers/buyers_provider.dart';
import 'package:al_asad_traders/features/people/providers/suppliers_provider.dart';
import 'package:al_asad_traders/features/prices/data/rates_repository.dart';
import 'package:al_asad_traders/features/prices/models/buyer_rate.dart';
import 'package:al_asad_traders/features/prices/models/retail_price.dart';
import 'package:al_asad_traders/features/prices/models/supplier_rate.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:al_asad_traders/features/products/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Enum representing the type of rate being added or edited.
/// Rule: wholesale_project.md > Prices. Story: S5, S6.
enum RateType { buyer, supplier, retail }

/// Form sheet to add or edit a buyer, supplier, or retail rate entry.
/// Rule: docs/UI_PLAN.md > Forms. Story: S5, S6.
class RateFormSheet extends ConsumerStatefulWidget {
  /// Creates a [RateFormSheet].
  const RateFormSheet({
    super.key,
    this.buyerId,
    this.supplierId,
    this.productId,
    this.existingBuyerRate,
    this.existingSupplierRate,
    this.existingRetailPrice,
    this.initialRateType,
  });

  /// Pre-selected buyer ID, if opened from buyer context.
  final String? buyerId;

  /// Pre-selected supplier ID, if opened from supplier context.
  final String? supplierId;

  /// Pre-selected product ID, if opened from product context.
  final String? productId;

  /// Existing buyer rate to edit, if any.
  final BuyerRate? existingBuyerRate;

  /// Existing supplier rate to edit, if any.
  final SupplierRate? existingSupplierRate;

  /// Existing retail price to edit, if any.
  final RetailPrice? existingRetailPrice;

  /// Initial rate type if specified.
  final RateType? initialRateType;

  /// Shows the [RateFormSheet] modally.
  static Future<void> show(
    BuildContext context, {
    String? buyerId,
    String? supplierId,
    String? productId,
    BuyerRate? existingBuyerRate,
    SupplierRate? existingSupplierRate,
    RetailPrice? existingRetailPrice,
    RateType? initialRateType,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => RateFormSheet(
        buyerId: buyerId,
        supplierId: supplierId,
        productId: productId,
        existingBuyerRate: existingBuyerRate,
        existingSupplierRate: existingSupplierRate,
        existingRetailPrice: existingRetailPrice,
        initialRateType: initialRateType,
      ),
    );
  }

  @override
  ConsumerState<RateFormSheet> createState() => _RateFormSheetState();
}

class _RateFormSheetState extends ConsumerState<RateFormSheet> {
  late RateType _rateType;
  late String? _selectedBuyerId;
  late String? _selectedSupplierId;
  late String? _selectedProductId;
  late TextEditingController _rateController;
  late DateTime _effectiveDate;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingBuyerRate != null || widget.buyerId != null) {
      _rateType = RateType.buyer;
    } else if (widget.existingSupplierRate != null ||
        widget.supplierId != null) {
      _rateType = RateType.supplier;
    } else if (widget.existingRetailPrice != null ||
        widget.initialRateType == RateType.retail) {
      _rateType = RateType.retail;
    } else {
      _rateType = RateType.buyer;
    }

    _selectedBuyerId = widget.existingBuyerRate?.buyerId ?? widget.buyerId;
    _selectedSupplierId =
        widget.existingSupplierRate?.supplierId ?? widget.supplierId;
    _selectedProductId =
        widget.existingBuyerRate?.productId ??
        widget.existingSupplierRate?.productId ??
        widget.existingRetailPrice?.productId ??
        widget.productId;

    final initialRateInt =
        widget.existingBuyerRate?.rate ??
        widget.existingSupplierRate?.rate ??
        widget.existingRetailPrice?.price;
    _rateController = TextEditingController(
      text: initialRateInt != null ? initialRateInt.toString() : '',
    );

    final initialDateStr =
        widget.existingBuyerRate?.effectiveDate ??
        widget.existingSupplierRate?.effectiveDate ??
        widget.existingRetailPrice?.effectiveDate;
    if (initialDateStr != null && initialDateStr.isNotEmpty) {
      _effectiveDate = DateTime.tryParse(initialDateStr) ?? DateTime.now();
    } else {
      _effectiveDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _effectiveDate = picked;
      });
    }
  }

  Future<void> _pickBuyer(List<Buyer> buyers) async {
    final selected = await showModalBottomSheet<Buyer>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PickerSheet<Buyer>(
        title: AppStrings.selectBuyer,
        searchHint: AppStrings.searchBuyers,
        items: buyers,
        itemTitle: (buyer) => buyer.name,
        itemSubtitle: (buyer) => buyer.contactNumber,
        onSelected: (buyer) => Navigator.pop(context, buyer),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedBuyerId = selected.id;
      });
    }
  }

  Future<void> _pickSupplier(List<Supplier> suppliers) async {
    final selected = await showModalBottomSheet<Supplier>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PickerSheet<Supplier>(
        title: AppStrings.selectSupplier,
        searchHint: AppStrings.searchSuppliers,
        items: suppliers,
        itemTitle: (supplier) => supplier.name,
        itemSubtitle: (supplier) => supplier.contactNumber,
        onSelected: (supplier) => Navigator.pop(context, supplier),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedSupplierId = selected.id;
      });
    }
  }

  Future<void> _pickProduct(List<Product> products) async {
    final selected = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PickerSheet<Product>(
        title: AppStrings.selectProduct,
        searchHint: AppStrings.searchProducts,
        items: products,
        itemTitle: (product) => product.name,
        itemSubtitle: (product) => 'Rs ${product.defaultBuyerRate}',
        onSelected: (product) => Navigator.pop(context, product),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedProductId = selected.id;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _errorText = null;
    });

    final rateText = _rateController.text.replaceAll(',', '').trim();
    final rateInt = int.tryParse(rateText);
    if (rateInt == null || rateInt < 0) {
      setState(() {
        _errorText = AppStrings.errorValidation;
      });
      return;
    }

    if (_selectedProductId == null || _selectedProductId!.isEmpty) {
      setState(() {
        _errorText = AppStrings.selectProduct;
      });
      return;
    }

    final repository = ref.read(ratesRepositoryProvider);
    final dateStr = _formatDate(_effectiveDate);

    setState(() {
      _isSaving = true;
    });

    try {
      if (_rateType == RateType.buyer) {
        if (_selectedBuyerId == null || _selectedBuyerId!.isEmpty) {
          setState(() {
            _errorText = AppStrings.selectBuyer;
            _isSaving = false;
          });
          return;
        }

        final docId = BuyerRate.buildDocId(
          _selectedBuyerId!,
          _selectedProductId!,
          dateStr,
        );
        final rate = BuyerRate(
          id: docId,
          buyerId: _selectedBuyerId!,
          productId: _selectedProductId!,
          rate: rateInt,
          effectiveDate: dateStr,
          createdAt: widget.existingBuyerRate?.createdAt ?? DateTime.now(),
        );

        await repository.saveBuyerRate(rate);
      } else if (_rateType == RateType.supplier) {
        if (_selectedSupplierId == null || _selectedSupplierId!.isEmpty) {
          setState(() {
            _errorText = AppStrings.selectSupplier;
            _isSaving = false;
          });
          return;
        }

        final docId = SupplierRate.buildDocId(
          _selectedSupplierId!,
          _selectedProductId!,
          dateStr,
        );
        final rate = SupplierRate(
          id: docId,
          supplierId: _selectedSupplierId!,
          productId: _selectedProductId!,
          rate: rateInt,
          effectiveDate: dateStr,
          createdAt: widget.existingSupplierRate?.createdAt ?? DateTime.now(),
        );

        await repository.saveSupplierRate(rate);
      } else {
        final docId = RetailPrice.buildDocId(_selectedProductId!, dateStr);
        final retailPrice = RetailPrice(
          id: docId,
          productId: _selectedProductId!,
          price: rateInt,
          effectiveDate: dateStr,
          createdAt: widget.existingRetailPrice?.createdAt ?? DateTime.now(),
        );

        await repository.saveRetailPrice(retailPrice);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyersAsync = ref.watch(buyersStreamProvider);
    final suppliersAsync = ref.watch(suppliersStreamProvider);
    final productsAsync = ref.watch(activeProductsProvider);

    final buyers = (buyersAsync.value ?? [])
        .where((b) => !b.isArchived)
        .toList();
    final suppliers = (suppliersAsync.value ?? [])
        .where((s) => !s.isArchived)
        .toList();
    final products = productsAsync.value ?? [];

    final selectedBuyer = buyers.cast<Buyer?>().firstWhere(
      (b) => b?.id == _selectedBuyerId,
      orElse: () => null,
    );
    final selectedSupplier = suppliers.cast<Supplier?>().firstWhere(
      (s) => s?.id == _selectedSupplierId,
      orElse: () => null,
    );
    final selectedProduct = products.cast<Product?>().firstWhere(
      (p) => p?.id == _selectedProductId,
      orElse: () => null,
    );

    final isFixedProduct = widget.productId != null;
    final isFixedBuyer = widget.buyerId != null;
    final isFixedSupplier = widget.supplierId != null;

    final formattedDateDisplay = DateFormat('d MMM yyyy')
        .format(_effectiveDate);

    return AppSheet(
      title: AppStrings.addRate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFixedBuyer && !isFixedSupplier && isFixedProduct) ...[
            Text(AppStrings.rateTypeLabel),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Radio<RateType>(
                    value: RateType.buyer,
                    groupValue: _rateType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _rateType = val;
                        });
                      }
                    },
                  ),
                  const Text(AppStrings.buyerRateType),
                  Radio<RateType>(
                    value: RateType.supplier,
                    groupValue: _rateType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _rateType = val;
                        });
                      }
                    },
                  ),
                  const Text(AppStrings.supplierRateType),
                  Radio<RateType>(
                    value: RateType.retail,
                    groupValue: _rateType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _rateType = val;
                        });
                      }
                    },
                  ),
                  const Text(AppStrings.shopPrice),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          if (_rateType == RateType.buyer && !isFixedBuyer)
            AppListRow(
              key: const Key('rate_select_buyer_row'),
              title: AppStrings.buyerDetails,
              subtitle: selectedBuyer?.name ?? AppStrings.selectBuyer,
              onTap: () => _pickBuyer(buyers),
            ),
          if (_rateType == RateType.supplier && !isFixedSupplier)
            AppListRow(
              key: const Key('rate_select_supplier_row'),
              title: AppStrings.supplierDetails,
              subtitle: selectedSupplier?.name ?? AppStrings.selectSupplier,
              onTap: () => _pickSupplier(suppliers),
            ),
          if (!isFixedProduct)
            AppListRow(
              key: const Key('rate_select_product_row'),
              title: AppStrings.productDetails,
              subtitle: selectedProduct?.name ?? AppStrings.selectProduct,
              onTap: () => _pickProduct(products),
            ),
          const SizedBox(height: AppSpacing.m),
          AppNumberField(
            key: const Key('rate_amount_field'),
            label: _rateType == RateType.retail
                ? AppStrings.shopPriceLabel
                : AppStrings.rateLabel,
            controller: _rateController,
            errorText: _errorText,
          ),
          const SizedBox(height: AppSpacing.m),
          AppListRow(
            key: const Key('rate_effective_date_row'),
            title: AppStrings.fromDate,
            subtitle: formattedDateDisplay,
            onTap: _selectDate,
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            key: const Key('save_rate_button'),
            label: AppStrings.save,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
    );
  }
}
