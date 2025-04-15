import 'dart:convert';
import 'package:Deals/models/product.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String authUrl = "http://192.168.10.49:5000/api/auth";
  static const String userUrl = "http://192.168.10.49:5000/api/user";
  // static const String baseUrl = 'http://192.168.10.50:5000/api';

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
        print("Update Error Response: ${response.body}");
        print("Update Status Code: ${response.statusCode}");
        return {
          "success": false,
          "message": decoded?["error"] ?? "Update failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // //fetch products s
  //   static Future<List<Product>> fetchAllProducts() async {
  //   final response = await http.get(Uri.parse('$baseUrl/products'));

  //   if (response.statusCode == 200) {
  //     final List<dynamic> jsonList = jsonDecode(response.body);
  //     return jsonList.map((e) => Product.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to fetch products');
  //   }
  // }
}
