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

  // Pink theme colors
  final Color primaryPink = const Color(0xFFFFC0CB); // Light pink
  final Color accentPink = const Color(0xFFFF90B3); // Darker pink for contrast
  final Color backgroundPink = const Color(
    0xFFFFF0F5,
  ); // Very light pink background
  final Color textPink = const Color(
    0xFFE75480,
  ); // Medium pink for text accents

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
          SnackBar(
            content: const Text('Item has no wishlistItemId'),
            backgroundColor: accentPink.withOpacity(0.8),
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: $e'),
            backgroundColor: accentPink.withOpacity(0.8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPink,
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: accentPink))
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: accentPink.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: textPink, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : wishlistItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: accentPink.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your wishlist is empty',
                      style: TextStyle(
                        color: textPink,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start adding items you love!',
                      style: TextStyle(
                        color: textPink.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
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
                    primaryPink: primaryPink,
                    accentPink: accentPink,
                    textPink: textPink,
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
  final Color primaryPink;
  final Color accentPink;
  final Color textPink;

  const WishlistItem({
    super.key,
    required this.product,
    required this.onRemove,
    required this.onTap,
    required this.primaryPink,
    required this.accentPink,
    required this.textPink,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryPink.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.image ?? '',
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              color: primaryPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: primaryPink,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                    // Pink overlay at the corner for visual appeal
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentPink.withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Product Details
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
                      Row(
                        children: [
                          Text(
                            '₹${product.discountPrice ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('REMOVE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: textPink,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: primaryPink),
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
          ),
        ),
      ),
    );
  }
}
