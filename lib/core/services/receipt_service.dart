import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ini
import '../../features/sales/models/cart_item_model.dart';

class ReceiptService {
  static Future<void> printReceipt(
      List<CartItem> items, double totalBayar, double uangTunai) async {
    final doc = pw.Document();

    final prefs = await SharedPreferences.getInstance();
    final shopName = prefs.getString('shop_name') ?? 'WarungKu POS';
    final shopAddress =
        prefs.getString('shop_address') ?? 'Alamat Belum Diatur';
    final shopPhone = prefs.getString('shop_phone') ?? '-';
    final shopFooter = prefs.getString('shop_footer') ?? 'Terima Kasih';

    final date = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final kembalian = uangTunai - totalBayar;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        margin: const pw.EdgeInsets.all(5),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(shopName,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Text(shopAddress,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center),
              pw.Text("Telp: $shopPhone",
                  style: const pw.TextStyle(fontSize: 9)),

              pw.SizedBox(height: 5),
              pw.Divider(thickness: 1),

              // INFO
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("$date", style: const pw.TextStyle(fontSize: 8)),
                  pw.Text("Cashier", style: const pw.TextStyle(fontSize: 8)),
                ],
              ),

              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              // ITEMS
              ...items.map((item) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          child: pw.Text(item.product.name,
                              style: const pw.TextStyle(fontSize: 9))),
                      pw.SizedBox(width: 5),
                      pw.Text("${item.qty}x",
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(width: 10),
                      pw.Text(currency.format(item.product.price * item.qty),
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                );
              }).toList(),

              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TOTAL",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text(currency.format(totalBayar),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Tunai", style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(currency.format(uangTunai),
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Kembali", style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(currency.format(kembalian),
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // FOOTER DINAMIS
              pw.Text(shopFooter,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
