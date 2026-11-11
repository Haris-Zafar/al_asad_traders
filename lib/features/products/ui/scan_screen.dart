import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:al_asad_traders/core/widgets/app_scaffold.dart';
import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:al_asad_traders/features/products/ui/product_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera barcode scanner screen.
/// Rule: docs/UI_PLAN.md > Scan. Story: S2.
class ScanScreen extends ConsumerStatefulWidget {
  /// Creates a [ScanScreen].
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _notFoundSku;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String barcode) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _notFoundSku = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.getProductBySku(barcode);

      if (!mounted) return;

      if (product != null) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(product);
        } else {
          context.go('/more/products/${product.id}');
        }
      } else {
        setState(() {
          _isProcessing = false;
          _notFoundSku = barcode;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.barcode,
      body: Stack(
        key: const Key('scan_screen_root'),
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _handleBarcode(rawValue);
                  break;
                }
              }
            },
          ),
          if (_notFoundSku != null)
            Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(AppSpacing.l),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No product with this barcode',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    _notFoundSku!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    key: const Key('add_product_from_scan_button'),
                    label: AppStrings.addProduct,
                    onPressed: () async {
                      final sku = _notFoundSku;
                      setState(() {
                        _notFoundSku = null;
                        _isProcessing = false;
                      });
                      final nav = Navigator.of(context);
                      final result = await ProductFormSheet.show(
                        context,
                        product: Product(
                          id: '',
                          name: '',
                          sku: sku,
                          defaultSupplierRate: 0,
                          defaultBuyerRate: 0,
                          defaultRetailPrice: 0,
                          createdAt: DateTime.now(),
                        ),
                      );
                      if (!mounted) return;
                      if (result == true) {
                        nav.pop();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.s),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _notFoundSku = null;
                        _isProcessing = false;
                      });
                    },
                    child: const Text('Scan again', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: AppSpacing.l,
            left: AppSpacing.l,
            right: AppSpacing.l,
            child: AppButton(
              key: const Key('scan_cancel_button'),
              label: AppStrings.cancel,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
