import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/services/product_service.dart';
import 'package:Deals/login/api_service.dart';

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
  final Color primaryPink = const Color(0xFFFF4081);
  final Color lightPink = const Color(0xFFFFD6E1);

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);

    try {
      // Add product if passed
      if (widget.productToAdd != null) {
        await addProductToCart(widget.productToAdd!, 1);
      }

      // Get cart items
      final token = await ApiService.getToken();
      if (token != null) {
        final items = await ProductService.getCartItems(token);
        setState(() {
          cartItems = items;
        });
      } else {
        // Handle not logged in case
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Please login to view your cart"),
              backgroundColor: primaryPink,
            ),
          );
        }
      }

      calculateTotal();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: primaryPink),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> addProductToCart(Product product, int quantity) async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        await ProductService.addToCart(product.id.toString(), quantity, token);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Please login to add items to cart"),
              backgroundColor: primaryPink,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add item to cart: $e"),
            backgroundColor: primaryPink,
          ),
        );
      }
    }
  }

  void calculateTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      // Safely parse the discount price
      double price = 0.0;
      try {
        if (item.discountPrice != null) {
          price = double.tryParse(item.discountPrice.toString()) ?? 0.0;
        }
      } catch (e) {
        print("Error parsing price: ${item.discountPrice}");
      }

      // Multiply by quantity
      int qty = item.quantity ?? 1;
      total += price * qty;
    }

    setState(() {
      cartTotal = total;
    });
  }

  Future<void> updateQuantity(Product item, int delta) async {
    final newQty = (item.quantity ?? 1) + delta;
    if (newQty < 1 || newQty > 10) return;

    setState(() {
      // Update locally first for immediate UI response
      item.quantity = newQty;
      calculateTotal();
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        await ProductService.addToCart(item.id.toString(), delta, token);
      }
    } catch (e) {
      if (mounted) {
        // Revert on error
        setState(() {
          item.quantity = (item.quantity ?? 1) - delta;
          calculateTotal();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update quantity: $e"),
            backgroundColor: primaryPink,
          ),
        );
      }
    }
  }

  Future<void> removeItem(Product item) async {
    if (item.cartItemId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item has no CartItemId'),
            backgroundColor: primaryPink,
          ),
        );
      }
      return;
    }

    final id = item.cartItemId!;

    final backup = List<Product>.from(cartItems);
    setState(() {
      cartItems.removeWhere((p) => p.cartItemId == id);
      calculateTotal();
    });

    try {
      await ProductService.removeFromCart(id);
    } catch (e) {
      if (mounted) {
        setState(() {
          cartItems = backup;
          calculateTotal();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: $e'),
            backgroundColor: primaryPink,
          ),
        );
      }
    }
  }

  void navigateToProductDetails(Product product) {
    Navigator.pushNamed(context, '/product-details', arguments: product);
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Bag",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryPink))
              : cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: lightPink),
          const SizedBox(height: 20),
          Text(
            "Your bag is empty",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: primaryPink,
              foregroundColor: Colors.white,
            ),
            child: const Text("Continue Shopping"),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => navigateToProductDetails(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: lightPink,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: primaryPink,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name ?? "Product",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  // Safely display the price
                                  item.discountPrice != null
                                      ? "₹${item.discountPrice}"
                                      : "Price not available",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: primaryPink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildQuantityButton(
                                      Icons.remove,
                                      () => updateQuantity(item, -1),
                                      item.quantity == 1,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        '${item.quantity ?? 1}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildQuantityButton(
                                      Icons.add,
                                      () => updateQuantity(item, 1),
                                      (item.quantity ?? 1) >= 10,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: primaryPink,
                                      ),
                                      onPressed: () => removeItem(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal", style: TextStyle(fontSize: 16)),
                  Text(
                    formatCurrency(cartTotal),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Shipping", style: TextStyle(fontSize: 16)),
                  Text(
                    "Free",
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency(cartTotal),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      cartItems.isEmpty
                          ? null
                          : () {
                            Navigator.pushNamed(context, '/checkout');
                          },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: lightPink,
                  ),
                  child: const Text(
                    "PROCEED TO CHECKOUT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed,
    bool disabled,
  ) {
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          color: disabled ? Colors.grey[200] : lightPink,
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.grey : primaryPink,
        ),
      ),
    );
  }
}
