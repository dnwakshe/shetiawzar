import 'product.dart';

/// Represents an item selected in the customer's shopping cart.
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Total price for this line item
  double get totalPrice => product.price * quantity;

  /// Formatted total price in INR
  String get formattedTotalPrice => '₹${totalPrice.round()}';

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
