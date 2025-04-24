import 'dart:convert';
import 'package:Deals/login/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';

class ProductService {
  final String baseUrl =
      "http://192.168.10.64:5000/api"; // Replace with your actual backend API URL

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
              .where((product) => product.category.toLowerCase() == 'men')
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
              .where((product) => product.category.toLowerCase() == 'women')
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
              .where((product) => product.category.toLowerCase() == 'kids')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch all products under 999
  Future<List<Product>> getUnder999Products() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter products with discountedPrice less than or equal to ₹999
      List<Product> under999Products =
          allProducts
              .where((product) => product.discountedPrice <= 999)
              .toList();

      return under999Products;
    } else {
      throw Exception('Failed to load products under ₹999');
    }
  }

  // Fetch Luxury products
  Future<List<Product>> getLuxuryProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/luxury'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load Luxury products');
    }
  }

  // Fetch products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$category'),
    );
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by category');
    }
  }

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
        Uri.parse('http://192.168.10.64:5000/api/cart/cartadd'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Authorization header with JWT token
        },
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        print('Item added to cart');
      } else {
        // Log the response body to help debug the error
        print('Failed to add item to cart. Response: ${response.body}');
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      // Log any other errors
      print('Error while adding to cart: $e');
      print("Using token: $token");

      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Static method to get Cart Items
  static Future<List<Product>> getCartItems() async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token – user not logged in');
    }

    final res = await http.get(
      Uri.parse('http://192.168.10.64:5000/api/cart/cartget'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load cart items • ${res.statusCode}');
    }

    final List<dynamic> raw = json.decode(res.body);

    return raw.map<Product>((item) {
      return Product.fromJson({
        // forward raw keys exactly; Product.fromJson handles mapping
        ...item,
        'id': item['product_id'],
        'name': item['product_name'],
        'oldPrice': item['product_price'],
        'discountedPrice': item['product_price'],
        'imageUrl': item['product_image'],
      });
    }).toList();
  }

  // Static method to remove item from Cart
  /// DELETE /api/cart/cartdel/{cartItemId}
  static Future<void> removeFromCart(int cartItemId) async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token missing');
    }

    final uri = Uri.parse(
      'http://192.168.10.64:5000/api/cart/cartdel/$cartItemId',
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
}
