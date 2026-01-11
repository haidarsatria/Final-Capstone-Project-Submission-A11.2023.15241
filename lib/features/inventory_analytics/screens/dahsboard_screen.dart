import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../../../core/services/pdf_service.dart';
import 'transaction_history_screen.dart';
import 'stock_history_screen.dart';
import '../../../core/utils/currency_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<ReportProvider>(context, listen: false).loadReport());
  }

  @override
  Widget build(BuildContext context) {
    final report = Provider.of<ReportProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard & Laporan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Total Pendapatan (7 Hari)",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    Text("${CurrencyFormatter.format(report.totalRevenue)}",
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --- ALERT STOK MENIPIS (BARU DISINI) ---
            if (report.lowStockItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                            "Perhatian: ${report.lowStockItems.length} Stok Menipis!",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...report.lowStockItems.take(3).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                              "• ${item['name']} (Sisa: ${item['stock']})"),
                        )),
                    if (report.lowStockItems.length > 3)
                      const Text("... dan lainnya",
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),

            // MENU History)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text("Riwayat"),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TransactionHistoryScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.warehouse),
                    label: const Text("Mutasi Stok"),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StockHistoryScreen())),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                PdfService().generateSalesReport(
                    report.dailySales, report.totalRevenue);
              },
              icon: const Icon(Icons.print),
              label: const Text("CETAK LAPORAN (PDF)"),
            ),

            // BEST SELLER RANKING
            const SizedBox(height: 30),
            const Text("Produk Terlaris (Top 5)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            report.bestSellers.isEmpty
                ? const Text("- Belum ada data penjualan -",
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic))
                : Column(
                    children: report.bestSellers.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.star, color: Colors.orange),
                        title: Text(item['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text("${item['total_qty']} Terjual",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      );
                    }).toList(),
                  ),

            // GRAFIK BATANG
            const SizedBox(height: 30),
            const Text("Grafik Penjualan Harian",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: report.dailySales.isEmpty
                  ? const Center(child: Text("Belum ada data transaksi"))
                  : BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  int index = val.toInt();
                                  if (index < 0 ||
                                      index >= report.dailySales.length)
                                    return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(report.dailySales[index]['day']
                                        .substring(8, 10)),
                                  );
                                }),
                          ),
                        ),
                        barGroups:
                            report.dailySales.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                  toY: (entry.value['total'] as num).toDouble(),
                                  color: Colors.blue,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4))
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
