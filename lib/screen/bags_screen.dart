import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/services/product_service.dart';

class BagScreen extends StatefulWidget {
  final String token; // JWT token for API authentication
  final Product? productToAdd; // Product to add to the bag (optional)

  const BagScreen({
    super.key,
    required this.token,
    this.productToAdd,
  });

  @override
  _BagScreenState createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  List<Product> cartItems = [];
  bool isLoading = true;
  bool isRemoving = false;

  @override
  void initState() {
    super.initState();

    if (widget.productToAdd != null) {
      _addProductAndFetchCart(widget.productToAdd!);
    } else {
      _fetchCartItems();
    }
  }

  Future<void> _addProductAndFetchCart(Product product) async {
    setState(() => isLoading = true);

    try {
      await ProductService.addToCart(
        int.parse(product.id),
        1,
        widget.token,
      );
      await _fetchCartItems();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item to cart: $e')),
      );
    }
  }

  Future<void> _fetchCartItems() async {
    setState(() => isLoading = true);

    try {
      List<Product> items = await ProductService.getCartItems(widget.token);
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart: $e')),
      );
    }
  }

  Future<void> _removeFromCart(dynamic itemId) async {
    setState(() => isRemoving = true);

    try {
      int itemIdInt = int.tryParse(itemId.toString()) ?? 0;

      await ProductService.removeFromCart(itemIdInt, widget.token);

      setState(() {
        cartItems.removeWhere((product) => product.id == itemId.toString());
        isRemoving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from cart')),
      );
    } catch (e) {
      setState(() => isRemoving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Bag")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your bag is empty!"))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                      title: Text(product.name),
                      subtitle: Text("₹${product.discountedPrice}"),
                      trailing: isRemoving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeFromCart(product.id),
                            ),
                    );
                  },
                ),
    );
  }
}
