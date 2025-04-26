import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';
import 'package:Deals/login/api_service.dart';

class CartService {
  // Update to match your product_service.dart IP address
  static const String baseUrl = 'http://192.168.10.64:5000/api';

  // Add a product to wishlist
  static Future<bool> addToCart(int productId, String token) async {
    try {
      print('Attempting to add product $productId to wishlist');

      final response = await http.post(
        Uri.parse('$baseUrl/cart/cartadd'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId, 'quantity': 1}),
      );

      print('Wishlist add response status: ${response.statusCode}');
      print('Wishlist add response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to add to wishlist: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  // Get all wishlist items
  static Future<List<Product>> getCartItems(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart/cartget'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('object$data');
        return data
            .map(
              (item) => Product(
                cartItemId: item['cartItemId'],
                quantity: item['quantity'],
                id: item['id'],
                name: item['name'] ?? 'Unknown Product',
                description: item['description'] ?? 'No description available',
                oldPrice: item['old_price'] ?? '0.0',
                discountPrice: item['discount_price'] ?? '0.0',
                discount: item['discount'] ?? 0,
                category: item['category'] ?? 'Uncategorized',
                parentCategory: item['parent_category'] ?? 'Uncategorized',
                subCategory: item['sub_category'] ?? 'Uncategorized',
                stock: item['stock'] ?? 0,
                image: item['image'] ?? '',
                size: item['size'] ?? 'M',
                color: item['color'] ?? 'Black',
                createdAt: item['created_at'],
              ),
            )
            .toList();
      } else {
        print('Failed to get wishlist: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting wishlist: $e');
      return [];
    }
  }

  // Remove item from wishlist
  static Future<void> removeFromCart(int cartItemId) async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token missing');
    }

    final uri = Uri.parse(
      'http://192.168.10.62:5000/api/cart/cartdel/$cartItemId',
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

  static Future<bool> isProductInCart(String productId, String token) async {
    try {
      // Get all cart items
      final cartItems = await getCartItems(token);

      // Check if product exists in cart
      for (var item in cartItems) {
        if (item.id.toString() == productId) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking if product is in cart: $e');
      return false;
    }
  }
}
