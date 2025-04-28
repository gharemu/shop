import 'dart:convert';
import 'package:Deals/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authUrl =
      "http://shop-backend-eyqo.onrender.com/api/auth";
  static const String userUrl =
      "http://shop-backend-eyqo.onrender.com/api/user";
  static const String TOKEN_KEY = "user_token";
  static const String USER_DATA_KEY = "user_data";

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
    String name,
    String email,
    String password,
  ) async {
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
          "message": decoded?["error"] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // LOGIN USER
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final Uri url = Uri.parse("$authUrl/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = safeJsonDecode(response.body);

        // Save token and user data to shared preferences
        await saveToken(data["token"]);
        await saveUserData(data["user"]);

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
          "message": decoded?["error"] ?? "Login failed",
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
          "message": decoded?["error"] ?? "Failed to fetch profile",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // UPDATE PROFILE (based on Angular service)
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updatedData,
    String token,
  ) async {
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
          "message": decoded?["error"] ?? "Update failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // TOKEN MANAGEMENT METHODS

  // Save token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  // Get token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear token (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_DATA_KEY);
  }

  // USER DATA MANAGEMENT

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_DATA_KEY, jsonEncode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(USER_DATA_KEY);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }
}
