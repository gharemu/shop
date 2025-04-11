import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for API requests
  static const String baseUrl = "http://localhost:5000/api";
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 10);

  // Keys for shared preferences
  static const String tokenKey = 'auth_token';
  static const String isAdminKey = 'is_admin';
  static const String userEmailKey = 'user_email';

  // Save user session
  static Future<void> saveUserSession(String token, bool isAdmin, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setBool(isAdminKey, isAdmin);
    await prefs.setString(userEmailKey, email);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(tokenKey);
  }

  // Get user token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get user admin status
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isAdminKey) ?? false;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(isAdminKey);
    await prefs.remove(userEmailKey);
  }

  // Register user
  static Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final Uri url = Uri.parse("$baseUrl/auth/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      ).timeout(requestTimeout);

      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully"};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["error"] ?? "Registration failed. Status: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}"
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final Uri url = Uri.parse("$baseUrl/auth/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data["token"];
        final isAdmin = data["isAdmin"] ?? false;
        
        // Save session data
        await saveUserSession(token, isAdmin, email);
        
        return {
          "success": true,
          "message": "Login successful",
          "token": token,
          "isAdmin": isAdmin,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["error"] ?? "Login failed. Status: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> addItem(Map<String, dynamic> itemData, String token) async {
    final Uri url = Uri.parse("$baseUrl/items/add");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(itemData),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "Item added successfully"};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["error"] ?? "Add item failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: ${e.toString()}"};
    }
  }

  static Future<Map<String, dynamic>> updateItem(String id, Map<String, dynamic> updatedData) async {
    final Uri url = Uri.parse("$baseUrl/items/update/$id");
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Item updated successfully"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["error"] ?? "Update failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>> deleteItem(String id) async {
    final Uri url = Uri.parse("$baseUrl/items/delete/$id");
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return {"success": true, "message": "Item deleted successfully"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["error"] ?? "Delete failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<List<dynamic>> getAllItems() async {
    final Uri url = Uri.parse("$baseUrl/items");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["items"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Add these methods INSIDE the class
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final Uri url = Uri.parse("$baseUrl/user/profile");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "user": data["user"],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["error"] ?? "Failed to load profile. Status: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> userData, String token) async {
    final Uri url = Uri.parse("$baseUrl/user/profile/update");
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(userData),
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Profile updated successfully"
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["error"] ?? "Update failed. Status: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}"
      };
    }
  }
} // Make sure the class closing brace is here
