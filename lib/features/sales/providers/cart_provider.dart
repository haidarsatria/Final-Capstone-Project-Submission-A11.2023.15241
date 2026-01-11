import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';
import '../../../core/services/notification_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  String? addToCart(Product product) {
    if (product.stock <= 0) {
      return "Stok Habis!";
    }

    int index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      if (_items[index].qty < product.stock) {
        _items[index].qty++;
      } else {
        return "Stok tidak cukup! Sisa hanya ${product.stock}";
      }
    } else {
      _items.add(CartItem(
        product: product,
        qty: 1,
      ));
    }

    notifyListeners();
    return null;
  }

  void removeOneItem(int productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> processTransaction(String paymentMethod, String customerName,
      String? receiptPhotoPath) async {
    if (_items.isEmpty) return false;

    final db = DatabaseHelper.instance;
    final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      // 1. Simpan Header Transaksi
      int transactionId = await db.insert('transactions', {
        'date': date,
        'total_amount': totalAmount.toInt(),
        'payment_method': paymentMethod,
        'customer_name': customerName,
        'receipt_photo': receiptPhotoPath ?? '',
      });

      // Loop Items & Update Stok
      for (var item in _items) {
        await db.insert('transaction_items', {
          'transaction_id': transactionId,
          'product_id': item.product.id,
          'qty': item.qty,
          'price_at_purchase': item.product.price,
        });

        // Kurangi Stok
        int newStock = item.product.stock - item.qty;
        await db.update('products', {
          'id': item.product.id,
          'stock': newStock,
        });

        //Notifikasi Stok Menipis
        if (newStock <= 5) {
          NotificationService.showNotification(
            id: item.product.id ?? 0,
            title: "⚠️ Stok Menipis!",
            body:
                "Stok ${item.product.name} tersisa $newStock. Segera restock!",
          );
        }

        await db.insert('stock_movements', {
          'product_id': item.product.id,
          'type': 'OUT',
          'quantity': item.qty,
          'date': date,
          'notes': 'Sales Transaction #$transactionId',
          'photo_proof': ''
        });
      }

      clearCart();
      return true;
    } catch (e) {
      print("Error Transaction: $e");
      return false;
    }
  }
}
