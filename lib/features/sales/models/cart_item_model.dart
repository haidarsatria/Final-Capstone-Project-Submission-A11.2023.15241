import '../../products/models/product_model.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  double get subtotal => (product.price * qty).toDouble();
}