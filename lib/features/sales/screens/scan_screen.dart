import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../products/providers/product_provider.dart';
import '../providers/cart_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Produk"),
        actions: [
          // Tombol Flash
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, state, child) {
              final isTorchOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
                color: isTorchOn ? Colors.yellow : Colors.grey,
                onPressed: () => controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (_isProcessing) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _addToCartByBarcode(barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }

  void _addToCartByBarcode(String code) {
    setState(() => _isProcessing = true);

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      final product = productProvider.items.firstWhere(
        (p) => p.barcode == code,
        orElse: () => throw Exception("not_found"),
      );

      String? errorMsg = cartProvider.addToCart(product);

      if (errorMsg == null) {
        // SUKSES
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil: ${product.name} (+1)"),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 600),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // GAGAL (Stok Habis / Mentok)
        _showError(errorMsg);
      }
    } catch (e) {
      if (e.toString().contains("not_found")) {
        _showError("Produk tidak ditemukan! ($code)");
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
