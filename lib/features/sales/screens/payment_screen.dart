import '../../../core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../../products/providers/product_provider.dart';
import '../models/cart_item_model.dart';

// --- IMPORT SERVICE CETAK PDF ---
import '../../../core/services/receipt_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _customerController = TextEditingController(text: "Umum");
  final _cashController = TextEditingController();

  String? _paymentProofPath;
  String _selectedMethod = "TUNAI";

  @override
  void dispose() {
    _customerController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentProof() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _paymentProofPath = image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Column(
        children: [
          // 1. LIST BARANG
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items[i];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text(
                      "${item.qty} x ${CurrencyFormatter.format(item.product.price)}"),
                  trailing: Text(
                    CurrencyFormatter.format(item.subtotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          // 2. FORM PEMBAYARAN
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.2))
            ]),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Nama
                  TextField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                        labelText: "Nama Pelanggan",
                        icon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                  ),
                  const SizedBox(height: 15),

                  // Pilihan Metode Bayar
                  const Text("Metode Pembayaran",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMethod = "TUNAI"),
                              child: _paymentButton(
                                  "TUNAI", _selectedMethod == "TUNAI"))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: GestureDetector(
                              onTap: () => setState(
                                  () => _selectedMethod = "TRANSFER/QRIS"),
                              child: _paymentButton("TRANSFER",
                                  _selectedMethod == "TRANSFER/QRIS"))),
                    ],
                  ),

                  // INPUT UANG / BUKTI
                  if (_selectedMethod == "TUNAI") ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Uang Diterima (Rp)",
                        icon: Icon(Icons.money),
                        border: OutlineInputBorder(),
                        hintText: "Contoh: 50000",
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _pickPaymentProof,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                color: _paymentProofPath != null
                                    ? Colors.green
                                    : Colors.grey),
                            const SizedBox(width: 10),
                            Text(_paymentProofPath != null
                                ? "Bukti Tersimpan"
                                : "Foto Bukti Transfer (Opsional)")
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 30),

                  // Total Tagihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Tagihan:",
                          style: TextStyle(fontSize: 16)),
                      Text(
                        CurrencyFormatter.format(cart.totalAmount),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // TOMBOL KONFIRMASI
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      onPressed: cart.items.isEmpty
                          ? null
                          : () => _handlePayment(context, cart),
                      child: const Text("KONFIRMASI BAYAR"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _paymentButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey[100],
        border:
            Border.all(color: isSelected ? Colors.green : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
          child: Text(text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.green : Colors.grey))),
    );
  }

  // --- LOGIC UTAMA ---
  Future<void> _handlePayment(BuildContext context, CartProvider cart) async {
    // 1. Validasi Uang Tunai
    double cashReceived = 0;
    if (_selectedMethod == "TUNAI") {
      cashReceived = double.tryParse(_cashController.text) ?? 0;
      if (cashReceived < cart.totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Uang tunai kurang dari total tagihan!")),
        );
        return;
      }
    } else {
      cashReceived = cart.totalAmount;
    }

    // 2. AMBIL SNAPSHOT DATA UNTUK STRUK
    final itemsToPrint = List<CartItem>.from(cart.items);
    final totalToPrint = cart.totalAmount;
    final cashToPrint = cashReceived;

    // 3. PROSES TRANSAKSI (Simpan DB & Kosongkan Cart)
    bool success = await cart.processTransaction(
        _selectedMethod, _customerController.text, _paymentProofPath);

    if (!mounted) return;

    // 4. JIKA SUKSES -> MUNCUL POPUP "CETAK STRUK"
    if (success) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("Pembayaran Berhasil"),
            ],
          ),
          content: const Text(
            "Ingin mencetak struk belanja?",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            // Opsi 1: Tutup (Kembali ke Kasir)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Tutup", style: TextStyle(color: Colors.grey)),
            ),

            // Opsi 2: CETAK STRUK PDF (INI FITUR PDF NYA!)
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text("Cetak / PDF"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx); // Tutup dialog

                // Panggil Service PDF
                await ReceiptService.printReceipt(
                    itemsToPrint, totalToPrint, cashToPrint);

                // Setelah tutup preview PDF, kembali ke kasir
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memproses transaksi")),
      );
    }
  }
}
