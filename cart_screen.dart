import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> cart;
  final VoidCallback onCartUpdated;
  final VoidCallback onPlaceOrder;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onCartUpdated,
    required this.onPlaceOrder,
  });

  double get total => cart.fold(0, (sum, item) => sum + item.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFFF6B35),
        elevation: 0,
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Cart is empty', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Menu'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text('\$${item.price} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${item.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    item.quantity--;
                                  } else {
                                    cart.remove(item);
                                  }
                                  onCartUpdated();
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onPlaceOrder();
                          },
                          child: const Text('Confirm Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}