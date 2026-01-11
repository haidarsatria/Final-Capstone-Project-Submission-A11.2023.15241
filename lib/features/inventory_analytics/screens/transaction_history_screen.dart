import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => Provider.of<ReportProvider>(context, listen: false)
        .fetchTransactionHistory());

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.transactionHistory.isEmpty) {
            return const Center(child: Text("Belum ada riwayat transaksi."));
          }

          return ListView.builder(
            itemCount: provider.transactionHistory.length,
            itemBuilder: (ctx, i) {
              final txn = provider.transactionHistory[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(transaction: txn)));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.receipt, color: Colors.green),
                    ),
                    title: Text(txn['customer_name'] ?? 'Guest',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text("${txn['date']}\nVia: ${txn['payment_method']}"),
                    isThreeLine: true,
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
