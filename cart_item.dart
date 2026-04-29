class CartItem {
  final String menuItemId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}