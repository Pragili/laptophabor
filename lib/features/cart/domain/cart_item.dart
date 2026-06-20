import '../../catalog/domain/product.dart';

class CartItem {
  final int id;
  final int quantity;
  final Product product;
  CartItem({required this.id, required this.quantity, required this.product});

  double get lineTotal => product.effectivePrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: j['id'],
        quantity: j['quantity'],
        product: Product.fromJson(j['product']),
      );
}
