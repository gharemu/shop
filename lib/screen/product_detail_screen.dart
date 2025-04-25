import 'package:Deals/login/api_service.dart';
import 'package:Deals/screen/bags_screen.dart';
import 'package:Deals/screen/wishlist_screen.dart';
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
          // IconButton(
          //   icon: Icon(
          //     widget.product.isFavorite
          //         ? Icons.favorite
          //         : Icons.favorite_border,
          //     color:
          //         widget.product.isFavorite
          //             ? const Color(0xFFFF3E6C)
          //             : Colors.grey,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       // widget.product.isFavorite = !widget.product.isFavorite;
          //     });
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Implement sharing functionality
            },
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
            //_buildDeliveryInfo(),
            //_buildDescription(),
            //_buildReviews(),
            // _buildSimilarProducts(),
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
              return Image.network(widget.product.image!, fit: BoxFit.cover);
            },
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
          Text(
            widget.product.name!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.description!,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
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
                      "{widget.product.rating}",
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
                "{widget.product.reviews} reviews",
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "₹${widget.product.oldPrice}",
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${widget.product.discount}% OFF",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "inclusive of all taxes",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    List<Color> colors = [Colors.black, Colors.blue, Colors.red, Colors.green];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Color",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
                  margin: const EdgeInsets.only(right: 12),
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
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          Row(
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
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(Icons.remove, size: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "$_quantity",
                    style: const TextStyle(
                      fontSize: 16,
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
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 70,
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
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF3E6C),
                side: const BorderSide(color: Color(0xFFFF3E6C)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: addToWishlist, // Use the method here
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "WISHLIST",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final userToken = await ApiService.getToken();
                  if (userToken == null || userToken.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User not logged in!")),
                    );
                    return; // Exit if no valid token is found
                  }

                  final productId = widget.product.id;
                  if (productId == null) throw Exception("Invalid product ID");

                  // Add product to cart - Convert productId to string to match the API expectation
                  await ProductService.addToCart(
                    productId
                        .toString(), // Convert to string regardless of the original type
                    1, // quantity = 1 for now
                    userToken,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to cart!")),
                  );

                  // Navigate to BagScreen after adding
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BagScreen(
                            token: userToken, // Pass the token to the BagScreen
                            productToAdd: widget.product,
                          ),
                    ),
                  );
                } catch (e) {
                  print(e); // Print the error in the console for debugging
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to add to cart: $e"),
                    ), // Show error in UI
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "ADD TO BAG",
                    style: TextStyle(
                      fontSize: 14,
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

  // Fixed addToWishlist method
  Future<void> addToWishlist() async {
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

      final success = await WishlistService.addToWishlist(
        intProductId,
        userToken,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WishlistScreen()),
      );

      if (success) {
        setState(() {
          // widget.product.isFavorite = true; // Update the UI to show it's favorited
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to wishlist!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add to wishlist")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
