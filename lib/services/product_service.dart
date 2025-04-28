import 'dart:convert';
import 'package:Deals/login/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';

class ProductService {
  final String baseUrl =
      "http://shop-backend-eyqo.onrender.com/api"; // Replace with your actual backend API URL

  // Fetch Men products
  Future<List<Product>> getMenProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter only 'Women' category products
      List<Product> womenProducts =
          allProducts
              .where((product) => product.category!.toLowerCase() == 'men')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch Women products
  Future<List<Product>> getWomenProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter only 'Women' category products
      List<Product> womenProducts =
          allProducts
              .where((product) => product.category!.toLowerCase() == 'women')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch Kids products
  Future<List<Product>> getKidsProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter only 'Women' category products
      List<Product> womenProducts =
          allProducts
              .where((product) => product.category!.toLowerCase() == 'kids')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  Future<List<Product>> getUnder999Products() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        List<Product> allProducts =
            jsonData.map((product) => Product.fromJson(product)).toList();

        // Filter products with discountPrice less than or equal to ₹999
        List<Product> under999Products =
            allProducts
                .where(
                  (product) =>
                      product.discountPrice != null ||
                      int.tryParse(product.discountPrice.toString()) != null ||
                      int.parse(product.discountPrice.toString()) <= 999,
                )
                .toList();

        return under999Products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products under ₹999: $e');
      throw Exception('Failed to load products under ₹999: $e');
    }
  }

  // Fetch Luxury products

  // Fetch products by gender
  Future<List<Product>> getProductsByGender(String gender) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/gender/$gender'),
    );
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by gender');
    }
  }

  // Fetch products by brand
  Future<List<Product>> getProductsByBrand(String brand) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/brand/$brand'),
    );
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by brand');
    }
  }

  // Fetch all products
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load all products');
    }
  }

  // Fetch discounted products
  Future<List<Product>> getDiscountedProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/discounted'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load discounted products');
    }
  }

  Future<List<Product>> searchProducts(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/products/search?keyword=${Uri.encodeComponent(keyword)}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  // Replace with your actual backend API URL
  // Static method to add an item to the cart
  static Future<void> addToCart(
    String productId,
    int quantity,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://shop-backend-eyqo.onrender.com/api/cart/cartadd'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'product_id': int.parse(productId), // Convert String to int
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        print('Item added to cart');
      } else {
        print('Failed to add item to cart. Response: ${response.body}');
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      print('Error while adding to cart: $e');
      print("Using token: $token");
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Static method to get Cart Items
  static Future<List<Product>> getCartItems(String token) async {
    final Uri url = Uri.parse(
      "http://shop-backend-eyqo.onrender.com/api/cart/cartget",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (item) => Product(
                cartItemId: item['cart_item_id'],
                id: item['product_id'],
                name: item['product_name'],
                discountPrice: item['product_price'].toString(),
                image: item['product_image'],
                quantity: item['quantity'],
                // Make sure cartItemId is defined in your Product class
                // If not defined, you'll need to add it to the Product class
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart items: $e');
    }
  }

  // Renamed to avoid duplicate definition
  static Future<bool> addToCartItem(
    String productId,
    int quantity,
    String token,
  ) async {
    final Uri url = Uri.parse(
      "http://shop-backend-eyqo.onrender.com/api/cart/cartadd",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "product_id": int.parse(productId), // Convert String to int
          "quantity": quantity,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Renamed to avoid duplicate definition
  static Future<bool> removeCartItem(int cartItemId, String token) async {
    final Uri url = Uri.parse(
      "http://shop-backend-eyqo.onrender.com/api/cart/cartdel/$cartItemId",
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  // Original removeFromCart method
  static Future<void> removeFromCart(int cartItemId) async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token missing');
    }

    final uri = Uri.parse(
      'http://shop-backend-eyqo.onrender.com/api/cart/cartdel/$cartItemId',
    );

    final res = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      // Surface the exact error body for easier debugging
      throw Exception(
        'Failed to remove item • ${res.statusCode} • ${res.body}',
      );
    }
  }

  Future<List<Product>> getFilteredProducts(
    String category,
    String parentCategory,
    String subCategory,
  ) async {
    try {
      // You could implement a specific API endpoint for filtering
      // For now, we'll fetch all products and filter client-side
      final allProducts = await getAllProducts();

      return allProducts
          .where(
            (product) =>
                product.category == category &&
                product.parentCategory == parentCategory &&
                product.subCategory == subCategory,
          )
          .toList();
    } catch (e) {
      throw Exception('Error filtering products: $e');
    }
  }
}
