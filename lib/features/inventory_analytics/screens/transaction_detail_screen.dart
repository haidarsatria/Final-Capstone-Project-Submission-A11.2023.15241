import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/currency_formatter.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT ti.*, p.name 
      FROM transaction_items ti
      JOIN products p ON ti.product_id = p.id
      WHERE ti.transaction_id = ?
    ''', [widget.transaction['id']]);

    if (mounted) {
      setState(() {
        _items = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.transaction;
    final photoPath = txn['receipt_photo'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text("Transaksi #${txn['id']}")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _rowInfo("Tanggal",
                              txn['date'].toString().substring(0, 16)),
                          const Divider(),
                          _rowInfo(
                              "Pelanggan", txn['customer_name'] ?? 'Guest'),
                          const Divider(),
                          _rowInfo("Pembayaran", txn['payment_method']),
                          const Divider(),
                          _rowInfo("Total",
                              CurrencyFormatter.format(txn['total_amount']),
                              isBold: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Barang yang dibeli:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final item = _items[i];
                      final subtotal = (item['qty'] as int) *
                          (item['price_at_purchase'] as int);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "${item['qty']} x ${CurrencyFormatter.format(item['price_at_purchase'])}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text("Rp $subtotal",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                  if (photoPath != null && photoPath.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const Text("Bukti Pembayaran / Transfer:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(photoPath),
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                              Text("Foto tidak ditemukan di HP ini"),
                            ],
                          )),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 30),
                    const Center(
                        child: Text("- Tidak ada foto bukti -",
                            style: TextStyle(color: Colors.grey))),
                  ]
                ],
              ),
            ),
    );
  }

  Widget _rowInfo(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14)),
      ],
    );
  }
}
