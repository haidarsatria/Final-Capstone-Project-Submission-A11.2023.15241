import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  List<Product> _filteredItems = [];

  List<Product> get items => _filteredItems.isEmpty ? _items : _filteredItems;

  Future<void> fetchProducts() async {
    final dataList = await DatabaseHelper.instance.queryAll('products');
    _items = dataList.map((item) => Product.fromMap(item)).toList();
    _filteredItems = [];
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final db = DatabaseHelper.instance;
    int id = await db.insert('products', product.toMap());

    await db.insert('stock_movements', {
      'product_id': id,
      'type': 'IN',
      'quantity': product.stock,
      'date': DateTime.now().toString(),
      'notes': 'Initial Stock',
      'photo_proof': product.photoUrl
    });

    await fetchProducts();
  }

  Future<void> updateProduct(Product product) async {
    await DatabaseHelper.instance.update('products', product.toMap());
    await fetchProducts();
  }

  Future<void> deleteProduct(int id) async {
    await DatabaseHelper.instance.delete('products', id);
    await fetchProducts();
  }

  void searchProduct(String query) {
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _items.where((prod) {
        return prod.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
