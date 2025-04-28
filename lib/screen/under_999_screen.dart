import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/screen/product_detail_screen.dart';
import 'package:Deals/services/product_service.dart';
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/services/cart_service.dart';
import 'package:Deals/services/product_service.dart';
import 'package:Deals/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/login/api_service.dart';

class Under999Screen extends StatefulWidget {
  const Under999Screen({super.key});

  @override
  _Under999ScreenState createState() => _Under999ScreenState();
}

class _Under999ScreenState extends State<Under999Screen>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  List<Product>? _products;
  late AnimationController _bannerController;
  late Animation<double> _bannerAnimation;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInWishlist = false;
  int? _wishlistItemId;
  Map<dynamic, bool> _wishlistStatus = {};
  Map<dynamic, int?> _wishlistItemIds = {};

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bannerAnimation = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeInOut,
    );
    _bannerController.forward();
    //_checkIfInWishlist();
    _loadWishlistStatus();

    // Fetch products after widget initialization
    _fetchProducts();
  }

  Future<void> _loadWishlistStatus() async {
    try {
      final userToken = await ApiService.getToken();
      if (userToken != null && userToken.isNotEmpty) {
        // Get all wishlist items
        final wishlistItems = await WishlistService.getWishlistItems(userToken);

        // Create maps of product IDs to wishlist status and item IDs
        final Map<dynamic, bool> status = {};
        final Map<dynamic, int?> itemIds = {};

        for (var item in wishlistItems) {
          status[item.id] = true;
          itemIds[item.id] = item.wishlistItemId;
        }

        if (mounted) {
          setState(() {
            _wishlistStatus = status;
            _wishlistItemIds = itemIds;
          });
        }
      }
    } catch (e) {
      print('Error loading wishlist status: $e');
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.getUnder999Products();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
          // Add debug print
          print('Fetched ${products.length} products under ₹999');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load products: $e';
          print(_errorMessage);
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: Column(
        children: [
          _buildOfferBanner(),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3E6C),
                      ),
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong.',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _fetchProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3E6C),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                    : _products == null || _products!.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available under ₹999',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                    : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferBanner() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_bannerAnimation),
      child: Container(
        height: 180,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFEC407A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "MEGA DEALS",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "ALL UNDER ₹999",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF3E6C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPromoBadge("30% OFF"),
                      const SizedBox(width: 8),
                      _buildPromoBadge("FREE SHIPPING"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6, // Fixed aspect ratio for consistent sizing
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products!.length,
      itemBuilder: (context, index) {
        final product = _products![index];
        return FadeTransition(
          opacity: _bannerController.drive(
            Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: _buildProductCard(product, index),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, int index) {
    // Debug print to check product data
    print(
      'Building card for product: ${product.name}, price: ${product.discountPrice}',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: ProductDetailScreen(product: product),
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: Container(
                      height: 180, // Fixed height for image
                      width: double.infinity,
                      color: Colors.grey[100],
                      child:
                          product.image != null && product.image!.isNotEmpty
                              ? Image.network(
                                product.image!,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFFFF3E6C),
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                              : const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),
                ),
                // Discount Badge
                if (product.discount != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3E6C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${product.discount}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                // Wishlist Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Color(0xFFFF3E6C),
                      ),
                      onPressed: () => _toggleWishlist(product),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      product.name ?? 'Unnamed Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.description ?? 'No description available',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          "₹${product.discountPrice ?? 'N/A'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFFF3E6C),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (product.oldPrice != null)
                          Text(
                            "₹${product.oldPrice}",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleWishlist(Product product) async {
    try {
      final userToken = await ApiService.getToken();
      if (userToken == null || userToken.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in!")));
        return;
      }

      final productId = product.id;
      if (productId == null) throw Exception("Invalid product ID");

      // Ensure product ID is handled as an integer
      final intProductId =
          productId is int ? productId : int.tryParse(productId.toString());
      if (intProductId == null) throw Exception("Invalid product ID format");

      // If already in wishlist, remove it
      if (_wishlistStatus[productId] == true &&
          _wishlistItemIds[productId] != null) {
        await WishlistService.removeWishlist(_wishlistItemIds[productId]!);
        setState(() {
          _wishlistStatus[productId] = false;
          _wishlistItemIds.remove(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Removed from wishlist"),
            backgroundColor: Color(0xFFFF3E6C),
          ),
        );
      }
      // Otherwise, add it to wishlist
      else {
        final success = await WishlistService.addToWishlist(
          intProductId,
          userToken,
        );

        if (success) {
          // Refresh wishlist status to get the new wishlist item ID
          await _loadWishlistStatus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Added to wishlist!"),
              backgroundColor: const Color(0xFFFF3E6C),
              action: SnackBarAction(
                label: 'VIEW',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WishlistScreen()),
                  );
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add to wishlist")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
