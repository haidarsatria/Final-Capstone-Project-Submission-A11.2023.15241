import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';

class ReportProvider with ChangeNotifier {
  List<Map<String, dynamic>> _dailySales = [];
  double _totalRevenue = 0;

  List<Map<String, dynamic>> _transactionHistory = [];
  List<Map<String, dynamic>> _stockHistory = [];
  List<Map<String, dynamic>> _bestSellers = [];

  List<Map<String, dynamic>> get dailySales => _dailySales;
  double get totalRevenue => _totalRevenue;
  List<Map<String, dynamic>> get transactionHistory => _transactionHistory;
  List<Map<String, dynamic>> get stockHistory => _stockHistory;
  List<Map<String, dynamic>> get bestSellers => _bestSellers;
  List<Map<String, dynamic>> _lowStockItems = [];
  List<Map<String, dynamic>> get lowStockItems => _lowStockItems;

  Future<void> loadReport() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT substr(date, 1, 10) as day, SUM(total_amount) as total 
      FROM transactions 
      GROUP BY day ORDER BY day DESC LIMIT 7
    ''');

    _dailySales = result;

    _totalRevenue = 0;
    for (var item in result) {
      _totalRevenue += (item['total'] as num).toDouble();
    }

    await fetchTransactionHistory();
    await fetchBestSellers();
    await fetchLowStockItems();
    notifyListeners();
  }

  // 2. Riwayat Transaksi Lengkap
  Future<void> fetchTransactionHistory() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    _transactionHistory = result;
    notifyListeners();
  }

  Future<void> fetchLowStockItems() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'products',
      where: 'stock <= ?',
      whereArgs: [5],
    );
    _lowStockItems = result;
  }

  // 3. Riwayat Stok (Keluar/Masuk)
  Future<void> fetchStockHistory() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT sm.*, p.name as product_name 
      FROM stock_movements sm
      JOIN products p ON sm.product_id = p.id
      ORDER BY sm.date DESC
    ''');
    _stockHistory = result;
    notifyListeners();
  }

  Future<void> fetchBestSellers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT p.name, SUM(ti.qty) as total_qty
      FROM transaction_items ti
      JOIN products p ON ti.product_id = p.id
      GROUP BY ti.product_id
      ORDER BY total_qty DESC
      LIMIT 5
    ''');
    _bestSellers = result;
    notifyListeners();
  }
}
