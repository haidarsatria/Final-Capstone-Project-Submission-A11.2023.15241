import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class StockHistoryScreen extends StatelessWidget {
  const StockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => Provider.of<ReportProvider>(context, listen: false)
        .fetchStockHistory());

    return Scaffold(
      appBar: AppBar(title: const Text("Mutasi Stok")),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.stockHistory.isEmpty) {
            return const Center(
                child: Text("Belum ada data keluar/masuk barang."));
          }

          return ListView.builder(
            itemCount: provider.stockHistory.length,
            itemBuilder: (ctx, i) {
              final item = provider.stockHistory[i];
              final isMasuk = item['type'] == 'IN';

              return ListTile(
                leading: Icon(
                  isMasuk ? Icons.arrow_circle_down : Icons.arrow_circle_up,
                  color: isMasuk ? Colors.green : Colors.red,
                  size: 30,
                ),
                title: Text(item['product_name'] ?? 'Unknown Product'),
                subtitle: Text(item['date'].toString().substring(0, 16)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isMasuk ? '+' : '-'}${item['quantity']}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isMasuk ? Colors.green : Colors.red),
                    ),
                    Text(item['type'],
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
