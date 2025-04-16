import 'dart:convert';
import 'package:Deals/models/product.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String authUrl = "http://192.168.10.50:5000/api/auth";
  static const String userUrl = "http://192.168.10.50:5000/api/user";
  static const String cartUrl = "http://192.168.10.50:5000/api/cart"; // Base URL for cart API

  // Utility to safely decode JSON
  static dynamic safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      return null;
    }
  }

  // REGISTER USER
  static Future<Map<String, dynamic>> registerUser(
      String name, String email, String password) async {
    final Uri url = Uri.parse("$authUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully"};
      } else {
        final decoded = safeJsonDecode(response.body);
        return {
          "success": false,
          "message": decoded?["error"] ?? "Registration failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // LOGIN USER
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final Uri url = Uri.parse("$authUrl/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = safeJsonDecode(response.body);
        return {
          "success": true,
          "message": "Login successful",
          "token": data["token"],
          "user": data["user"],
        };
      } else {
        final decoded = safeJsonDecode(response.body);
        return {
          "success": false,
          "message": decoded?["error"] ?? "Login failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // GET PROFILE (based on Angular service)
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final Uri url = Uri.parse("$userUrl/profile");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = safeJsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        final decoded = safeJsonDecode(response.body);
        return {
          "success": false,
          "message": decoded?["error"] ?? "Failed to fetch profile"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // UPDATE PROFILE (based on Angular service)
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updatedData, String token) async {
    final Uri url = Uri.parse("$userUrl/profile/update");
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Profile updated successfully"};
      } else {
        final decoded = safeJsonDecode(response.body);
        return {
          "success": false,
          "message": decoded?["error"] ?? "Update failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // ADD TO CART
static Future<Map<String, dynamic>> addToCart(
  Product product,
  int quantity,
  String token,
) async {
  final url = Uri.parse("http://192.168.10.50:5000/api/cartadd");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "product_id": product.id,
        "quantity": quantity,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "Added to cart", "statusCode": 200};
    } else {
      final decoded = safeJsonDecode(response.body);
      return {
        "success": false,
        "message": decoded?["error"] ?? "Failed to add to cart",
        "statusCode": response.statusCode
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Error: $e",
      "statusCode": 500,
    };
  }
}


  // GET CART ITEMS
  static Future<Map<String, dynamic>> getCartItems() async {
    final token = await getToken();
    if (token == null) {
      return {"statusCode": 401, "message": "User not logged in"};
    }

    final Uri url = Uri.parse("$cartUrl/cartget");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = safeJsonDecode(response.body);
        return {"statusCode": response.statusCode, "data": data};
      } else {
        final decoded = safeJsonDecode(response.body);
        return {
          "statusCode": response.statusCode,
          "message": decoded?["error"] ?? "Error fetching cart items",
        };
      }
    } catch (e) {
      return {
        "statusCode": 500,
        "message": "Error fetching cart items: $e",
      };
    }
  }

  // REMOVE ITEM FROM CART
  static Future<Map<String, dynamic>> removeFromCart(int itemId) async {
    final token = await getToken();
    if (token == null) {
      return {"statusCode": 401, "message": "User not logged in"};
    }

    final Uri url = Uri.parse("$cartUrl/cartdel/$itemId");
    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return {
          "statusCode": response.statusCode,
          "message": "Removed from cart successfully",
        };
      } else {
        final decoded = safeJsonDecode(response.body);
        return {
          "statusCode": response.statusCode,
          "message": decoded?["error"] ?? "Error removing item from cart",
        };
      }
    } catch (e) {
      return {
        "statusCode": 500,
        "message": "Error removing item from cart: $e",
      };
    }
  }

  // Helper method to get the stored token
  static Future<String?> getToken() async {
    // Retrieve the token from shared preferences, secure storage, etc.
    // Example: return await SharedPreferences.getInstance().then((prefs) => prefs.getString("auth_token"));
    return null; // Placeholder: Implement your token retrieval logic here
  }
}
