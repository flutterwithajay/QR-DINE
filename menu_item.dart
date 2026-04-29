class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool available;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.available,
  });

  factory MenuItem.fromFirestore(Map<String, dynamic> data, String id) {
    return MenuItem(
      id: id,
      name: data['name'] ?? 'Unknown',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Other',
      available: data['available'] ?? true,
    );
  }
}