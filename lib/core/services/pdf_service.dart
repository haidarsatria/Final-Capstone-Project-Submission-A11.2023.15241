import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../utils/currency_formatter.dart';

class PdfService {
  Future<void> generateSalesReport(
      List<Map<String, dynamic>> data, double totalRevenue) async {
    final pdf = pw.Document();
    final dateNow = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text("Laporan Penjualan WarungKu",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Text("Tanggal Cetak: $dateNow"),
              pw.SizedBox(height: 20),

              // Ringkasan
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text(
                    "Total Pendapatan (7 Hari): ${CurrencyFormatter.format(totalRevenue)}",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                context: context,
                headers: <String>['Tanggal', 'Total Penjualan'],
                data: data.map((item) {
                  return [item['day'], CurrencyFormatter.format(item['total'])];
                }).toList(),
              ),

              pw.SizedBox(height: 40),
              pw.Text("Dicetak otomatis oleh sistem WarungKu POS."),
            ],
          );
        },
      ),
    );

    // Tampilkan Preview PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
