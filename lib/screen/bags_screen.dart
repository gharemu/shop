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
      // 1️⃣  Add to cart if BagScreen was opened with a product
      if (widget.productToAdd != null && widget.token != null) {
        await ProductService.addToCart(
          widget.productToAdd!.id,
          1,
          widget.token!,
        );
      }

      // 2️⃣  Always refresh cart from server so every item has cartItemId
      if (widget.token != null) {
        cartItems = await ProductService.getCartItems();
      }

      calculateTotal();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        await ProductService.addToCart(item.id, delta, widget.token!);
        setState(() {
          item.quantity = newQty;
          calculateTotal();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update quantity")));
    }
  }

  void removeItem(Product item) async {
    // Guard – every cart line coming from server should already have an id
    if (item.cartItemId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item has no cartItemId')));
      return;
    }

    final id = item.cartItemId!;

    // Optimistic UI: delete locally first, roll back on error
    final backup = List<Product>.from(cartItems);
    setState(() {
      cartItems.removeWhere((p) => p.cartItemId == id);
      calculateTotal();
    });

    try {
      await ProductService.removeFromCart(id);
      // Success – nothing else to do
    } catch (e) {
      // Roll back and inform the user
      setState(() {
        cartItems = backup;
        calculateTotal();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Bag")),
      body:
          isLoading
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
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: SizedBox(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text("₹${item.oldPrice}"),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => updateQuantity(item, -1),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${cartTotal.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("Checkout"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
    );
  }
}
