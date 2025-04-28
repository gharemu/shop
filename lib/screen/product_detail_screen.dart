import 'package:Deals/login/api_service.dart';
import 'package:Deals/screen/bags_screen.dart';
import 'package:Deals/screen/checkout_page.dart'; // Assume you have a checkout screen
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/services/cart_service.dart';
import 'package:Deals/services/product_service.dart';
import 'package:Deals/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedSize = 0;
  int _selectedColor = 0;
  int _quantity = 1;
  bool _isLoading = false;
  bool _isInCart = false;
  bool _isInWishlist = false;
  int? _wishlistItemId;

  @override
  void initState() {
    super.initState();
    _checkIfInCart();
    _checkIfInWishlist();
  }

  Future<void> _checkIfInCart() async {
    final userToken = await ApiService.getToken();
    if (userToken != null && userToken.isNotEmpty) {
      final productId = widget.product.id.toString();
      final result = await CartService.isProductInCart(productId, userToken);
      setState(() {
        _isInCart = result;
      });
    }
  }

  Future<void> _checkIfInWishlist() async {
    try {
      final userToken = await ApiService.getToken();
      if (userToken != null && userToken.isNotEmpty) {
        // Get all wishlist items
        final wishlistItems = await WishlistService.getWishlistItems(userToken);

        // Check if current product is in wishlist
        for (var item in wishlistItems) {
          if (item.id == widget.product.id) {
            setState(() {
              _isInWishlist = true;
              _wishlistItemId =
                  item.wishlistItemId; // Store the wishlist item ID for removal
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error checking wishlist status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Wishlist icon - filled or unfilled based on status
          IconButton(
            icon: Icon(
              _isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWishlist ? const Color(0xFFFF3E6C) : Colors.black,
            ),
            onPressed: toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildProductInfo(),
            _buildSizeSelector(),
            _buildColorSelector(),
            _buildQuantitySelector(),
            const SizedBox(height: 80), // Space for bottom buttons
          ],
        ),
      ),
      bottomSheet: _buildBottomButtons(),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: 3, // Assuming we have 3 images per product
            itemBuilder: (context, index) {
              return Image.network(
                widget.product.image!,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
              );
            },
          ),
          // Add gradient overlay for better text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        index == 0 ? const Color(0xFFFF3E6C) : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.product.name!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Add a badge for stock status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.product.stock! > 0
                          ? Colors.green[50]
                          : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.product.stock! > 0 ? "In Stock" : "Out of Stock",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        widget.product.stock! > 0
                            ? Colors.green[700]
                            : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      "4.5", // Replace with actual rating if available
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.star, size: 14, color: Colors.green[700]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "125 reviews", // Replace with actual reviews count if available
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "₹${widget.product.discountPrice}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "₹${widget.product.oldPrice}",
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${widget.product.discount}% OFF",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "inclusive of all taxes",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          // Add a delivery estimate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Colors.grey[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Free Delivery",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        "Estimated delivery in 3-5 business days",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    List<String> sizes = ["S", "M", "L", "XL", "XXL"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Size",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "SIZE CHART",
                  style: TextStyle(fontSize: 14, color: Color(0xFFFF3E6C)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              sizes.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = index;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _selectedSize == index
                            ? const Color(0xFFFF3E6C)
                            : Colors.white,
                    border: Border.all(
                      color:
                          _selectedSize == index
                              ? const Color(0xFFFF3E6C)
                              : Colors.grey[300]!,
                    ),
                    boxShadow:
                        _selectedSize == index
                            ? [
                              BoxShadow(
                                color: const Color(0xFFFF3E6C).withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      sizes[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            _selectedSize == index
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    List<Color> colors = [Colors.black, Colors.blue, Colors.red, Colors.green];
    List<String> colorNames = ["Black", "Blue", "Red", "Green"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Color",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              colors.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[index],
                          border: Border.all(
                            color:
                                _selectedColor == index
                                    ? const Color(0xFFFF3E6C)
                                    : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        colorNames[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              _selectedColor == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              _selectedColor == index
                                  ? const Color(0xFFFF3E6C)
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quantity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                    child: const Icon(Icons.remove, size: 20),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Text(
                      "$_quantity",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // BUY NOW button
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF3E6C),
                side: const BorderSide(color: Color(0xFFFF3E6C)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () => handleBuyNow(),
              child: const Text(
                "BUY NOW",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ADD TO BAG or GO TO BAG button
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _isLoading ? null : (_isInCart ? goToBag : handleAddToCart),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFFFF3E6C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isInCart
                                ? Icons.shopping_bag
                                : Icons.shopping_bag_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isInCart ? "GO TO BAG" : "ADD TO BAG",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleAddToCart() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userToken = await ApiService.getToken();
      if (userToken == null || userToken.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in!")));
        return;
      }

      final productId = widget.product.id;
      if (productId == null) throw Exception("Invalid product ID");

      // Convert productId to string to match API expectation
      final productIdStr = productId.toString();

      // First check if product is already in cart
      final isInCart = await CartService.isProductInCart(
        productIdStr,
        userToken,
      );

      if (isInCart) {
        // Product already in cart - navigate to cart screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product already in your bag!")),
        );

        // Navigate to BagScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BagScreen(
                  token: userToken,
                  productToAdd: null, // No need to add again
                ),
          ),
        );
      } else {
        // Product not in cart - add it
        await ProductService.addToCart(
          productIdStr,
          _quantity, // Use selected quantity
          userToken,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Added to bag!"),
            backgroundColor: const Color(0xFFFF3E6C),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                goToBag();
              },
            ),
          ),
        );

        setState(() {
          _isInCart = true;
        });
      }
    } catch (e) {
      print("Error handling cart action: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void goToBag() async {
    final userToken = await ApiService.getToken();
    if (userToken != null && userToken.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BagScreen(token: userToken, productToAdd: null),
        ),
      );
    }
  }

  Future<void> handleBuyNow() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userToken = await ApiService.getToken();
      if (userToken == null || userToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to continue!")),
        );
        return;
      }

      final productId = widget.product.id;
      if (productId == null) throw Exception("Invalid product ID");

      // Add to cart if not already there
      if (!_isInCart) {
        await ProductService.addToCart(
          productId.toString(),
          _quantity,
          userToken,
        );
      }

      // Navigate directly to checkout screen (You'll need to create this screen)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(singleProduct: productId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // New method to toggle wishlist status
  Future<void> toggleWishlist() async {
    try {
      final userToken = await ApiService.getToken();
      if (userToken == null || userToken.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in!")));
        return;
      }

      final productId = widget.product.id;
      if (productId == null) throw Exception("Invalid product ID");

      // Ensure product ID is handled as an integer
      final intProductId =
          productId is int ? productId : int.tryParse(productId.toString());
      if (intProductId == null) throw Exception("Invalid product ID format");

      // If already in wishlist, remove it
      if (_isInWishlist && _wishlistItemId != null) {
        await WishlistService.removeWishlist(_wishlistItemId!);
        setState(() {
          _isInWishlist = false;
          _wishlistItemId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Removed from wishlist"),
            backgroundColor: const Color(0xFFFF3E6C),
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
          await _checkIfInWishlist();

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
