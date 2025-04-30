import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/screen/product_detail_screen.dart';
import 'package:Deals/services/product_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Deals/login/api_service.dart';
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/services/wishlist_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ProductService _productService = ProductService();
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  late AnimationController _bannerController;
  late Animation<double> _bannerAnimation;

  // Map to track wishlist status of products
  Map<dynamic, bool> _wishlistStatus = {};
  Map<dynamic, int?> _wishlistItemIds = {};

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Faster animation
    );
    _bannerAnimation = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutCubic, // More dynamic curve
    );
    _bannerController.forward();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Load wishlist status for all products
    _loadWishlistStatus();

    // Reduced loading time for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _showBackToTopButton = _scrollController.offset >= 200;
        });
      }
    });
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

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _isLoading = true;
      });

      // Reduced delay for faster tab switching
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250), // Even faster scroll
      curve: Curves.easeOutCubic, // Smoother animation curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Enhanced Tab Bar with better visuals
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                decoration: BoxDecoration(
                  // Add subtle gradient for tab bar
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFFF3E6C),
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: const Color(0xFFFF3E6C),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: const EdgeInsets.symmetric(vertical: 12),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  tabs: const [
                    Tab(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF5F5F5),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: ClipOval(
                              child: Image(
                                image: AssetImage('assets/images/shirt1.jpg'),
                                fit: BoxFit.cover,
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                      text: 'MEN',
                    ),
                    Tab(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF5F5F5),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: ClipOval(
                              child: Image(
                                image: AssetImage('assets/images/top1.jpg'),
                                fit: BoxFit.cover,
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                      text: 'WOMEN',
                    ),
                    Tab(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFF5F5F5),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: ClipOval(
                              child: Image(
                                image: AssetImage('assets/images/top2.jpg'),
                                fit: BoxFit.cover,
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                      text: 'KIDS',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tab content with improved performance
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(), // Enhanced physics
              children: [
                _buildProductTab(_productService.getMenProducts()),
                _buildProductTab(_productService.getWomenProducts()),
                _buildProductTab(_productService.getKidsProducts()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showBackToTopButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: const Color(0xFFFF3E6C),
          foregroundColor: Colors.white,
          child: const Icon(Icons.arrow_upward, size: 20),
          onPressed: _scrollToTop,
          elevation: 6,
          // Add shadow for depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildProductTab(Future<List<Product>> futureProducts) {
    return RefreshIndicator(
      color: const Color(0xFFFF3E6C),
      backgroundColor: Colors.white,
      displacement: 20,
      strokeWidth: 3,
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });

        // Refresh wishlist status
        await _loadWishlistStatus();

        // Reduced delay for faster refresh
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(), // Smoother scrolling
        cacheExtent: 1500, // Better scrolling performance
        children: [
          // Banner
          _buildEnhancedOfferBanner(),

          // Products
          FutureBuilder<List<Product>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (_isLoading ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingGrid();
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return _buildEmptyState();
              }

              return _buildProductsGrid(products);
            },
          ),
          // Add some bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEnhancedOfferBanner() {
    return FadeTransition(
      opacity: _bannerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_bannerAnimation),
        child: Container(
          height: 150,
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFFFF4E50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                right: -20,
                top: -20,
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
                left: -15,
                bottom: -15,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Add subtle sparkle effects
              Positioned(
                top: 20,
                left: 60,
                child: Icon(
                  Icons.star,
                  color: Colors.white.withOpacity(0.3),
                  size: 16,
                ),
              ),
              Positioned(
                bottom: 30,
                right: 40,
                child: Icon(
                  Icons.star,
                  color: Colors.white.withOpacity(0.3),
                  size: 14,
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "EXCLUSIVE OFFER",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                      child: const Text(
                        "BUDGET BUYS",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        "ALL UNDER ₹999",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4E50),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.timer, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Limited time offer!",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pull to refresh and try again',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Implement retry functionality
              setState(() {
                _isLoading = true;
              });
              _loadWishlistStatus();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3E6C),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No products available in this category",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, // Taller cards for better proportions
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      padding: const EdgeInsets.all(14),
      itemCount: products.length,
      itemBuilder: (context, index) {
        // Staggered animation for product loading
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(
            milliseconds: 350 + (index * 50),
          ), // Staggered effect
          curve: Curves.easeOutQuint,
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildImprovedProductCard(products[index]),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 14, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 18, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced product card with improved styling and no extra space
  Widget _buildImprovedProductCard(Product product) {
    final String heroTag = 'product-${product.id}';
    final bool hasDiscount = product.discount! > 0;
    final bool isInWishlist = _wishlistStatus[product.id] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    ProductDetailScreen(product: product),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(0.0, 0.05);
              const end = Offset.zero;
              const curve = Curves.easeOutQuint;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Hero Animation
              Stack(
                children: [
                  // Product Image - Enhanced with tint
                  Container(
                    height: 180, // Fixed image height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFFFF3E6C),
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Enhanced Discount Tag
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3E6C),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          "${product.discount}% OFF",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  // Enhanced Wishlist button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _toggleWishlist(product),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey<bool>(isInWishlist),
                                size: 18,
                                color: const Color(0xFFFF3E6C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Product Information - compact container with no extra space
              Container(
                height: 55, // Fixed compact height for product details
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.2,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Price Section with enhanced styling
                    Row(
                      children: [
                        Text(
                          "₹${product.discountPrice}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (hasDiscount)
                          Text(
                            "₹${product.oldPrice}",
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 11,
                              color: Colors.grey[600],
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
        // Optimistic UI update for better UX
        setState(() {
          _wishlistStatus[productId] = false;
        });

        await WishlistService.removeWishlist(_wishlistItemIds[productId]!);

        setState(() {
          _wishlistItemIds.remove(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Removed from wishlist"),
            backgroundColor: Color(0xFFFF3E6C),
            duration: Duration(seconds: 1),
          ),
        );
      }
      // Otherwise, add it to wishlist
      else {
        // Optimistic UI update
        setState(() {
          _wishlistStatus[productId] = true;
        });

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
              duration: const Duration(seconds: 1),
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
          // Revert optimistic update if failed
          setState(() {
            _wishlistStatus[productId] = false;
          });

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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _bannerController.dispose();
    super.dispose();
  }
}
