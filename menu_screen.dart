import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';

class MenuScreen extends StatefulWidget {
  final String tableId;
  
  const MenuScreen({super.key, required this.tableId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<CartItem> cart = [];
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.total);
  int get cartItemCount => cart.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(MenuItem item) {
    setState(() {
      int existingIndex = cart.indexWhere((i) => i.menuItemId == item.id);
      if (existingIndex != -1) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(CartItem(
          menuItemId: item.id,
          name: item.name,
          price: item.price,
        ));
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'tableId': widget.tableId,
        'status': 'pending',
        'items': cart.map((item) {
          return {
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
          };
        }).toList(),
        'total': cartTotal,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      setState(() {
        cart.clear();
      });
      
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableId}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFFF6B35),
        elevation: 0,
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _showCartSheet(),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menu').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Set<String> cats = {'All'};
                  for (var doc in snapshot.data!.docs) {
                    cats.add(doc['category'] ?? 'Other');
                  }
                  categories = cats.toList();
                }
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: const Color(0xFFFF6B35),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Menu grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menu')
                  .where('available', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var items = snapshot.data!.docs;
                
                if (selectedCategory != 'All') {
                  items = items.where((doc) => doc['category'] == selectedCategory).toList();
                }
                
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text('No items', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var doc = items[index];
                    MenuItem item = MenuItem.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                    
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food image area
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _getIconForCategory(item.category),
                                size: 45,
                                color: const Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Price and Add button row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFFF6B35),
                                      ),
                                    ),
                                    // SMALL ADD BOX
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B35),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: InkWell(
                                        onTap: () => addToCart(item),
                                        borderRadius: BorderRadius.circular(6),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              SizedBox(width: 3),
                                              Text(
                                                'Add',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: cart.isNotEmpty
          ? Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              '\$${cartTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: placeOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your Cart',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (cart.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Cart is empty'),
                    )
                  else
                    ...cart.map((item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text('\$${item.price} each'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${item.total.toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  cart.remove(item);
                                }
                              });
                              setStateSheet(() {});
                            },
                          ),
                        ],
                      ),
                    )),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pizza': return Icons.local_pizza;
      case 'burger': return Icons.lunch_dining;
      case 'sides': return Icons.fastfood;
      case 'drinks': return Icons.local_drink;
      case 'dessert': return Icons.cake;
      default: return Icons.restaurant;
    }
  }
}