import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/services/wishlist_service.dart';
import 'package:Deals/login/api_service.dart';
import 'package:Deals/screen/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> wishlistItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          errorMessage = "Please login to view your wishlist";
          isLoading = false;
        });
        return;
      }

      final items = await WishlistService.getWishlistItems(token);
      setState(() {
        wishlistItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load wishlist: $e";
        isLoading = false;
      });
    }
  }

  Future<void> removeItem(Product item) async {
    if (item.wishlistItemId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item has no wishlistItemId')),
        );
      }
      return;
    }

    final id = item.wishlistItemId!;

    final backup = List<Product>.from(wishlistItems);
    setState(() {
      wishlistItems.removeWhere((p) => p.wishlistItemId == id);
    });

    try {
      await WishlistService.removeWishlist(id);
    } catch (e) {
      if (mounted) {
        setState(() {
          wishlistItems = backup;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index];
                  return WishlistItem(
                    product: product,
                    onRemove: () => removeItem(product),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const WishlistItem({
    super.key,
    required this.product,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.image ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
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
                      product.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${product.discountPrice ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFF3E6C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('REMOVE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
