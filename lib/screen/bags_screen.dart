import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/services/product_service.dart';

class BagScreen extends StatefulWidget {
  final String? token;
  final Product? productToAdd;

  const BagScreen({super.key, this.token, this.productToAdd});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  List<Product> cartItems = [];
  double cartTotal = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);

    try {
      // Add product if passed
      if (widget.productToAdd != null && widget.token != null) {
        await ProductService.addToCart(widget.productToAdd!.id, 1, widget.token!);
      }

      // Get cart items using token
      if (widget.token != null) {
        final items = await ProductService.getCartItems();
        setState(() {
          cartItems = items;
        });
      }

      calculateTotal();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void calculateTotal() {
    cartTotal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.discountedPrice * (item.quantity ?? 1)),
    );
  }

  void updateQuantity(Product item, int delta) async {
    final newQty = (item.quantity ?? 1) + delta;
    if (newQty < 1 || newQty > 10) return;

    try {
      if (widget.token != null) {
        await ProductService.addToCart(item.id, delta, widget.token!); // Pass the token
        setState(() {
          item.quantity = newQty;
          calculateTotal();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update quantity")));
    }
  }

  void removeItem(Product item) async {
    try {
      if (widget.token != null) {
        await ProductService.removeFromCart(int.parse(item.id), widget.token!); // Pass the token
        setState(() {
          cartItems.removeWhere((p) => p.id == item.id);
          calculateTotal();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to remove item")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Bag")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your bag is empty"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: Image.network(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("₹${item.discountedPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => updateQuantity(item, -1),
                                      ),
                                      Text('${item.quantity ?? 1}', style: TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => updateQuantity(item, 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeItem(item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(thickness: 2),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("₹${cartTotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                        child: const Text("Proceed to Checkout"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }
}
