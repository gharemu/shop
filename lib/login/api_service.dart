import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.10.49:5000/api/auth";

  // Register user
  static Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final Uri url = Uri.parse("$baseUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["error"] ?? "Registration failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // Login user
static Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final Uri url = Uri.parse("$baseUrl/login");
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "success": true,
        "message": "Login successful",
        "token": data["token"],
        "user": data["user"], // assuming your backend sends user details
      };
    } else {
      return {"success": false, "message": jsonDecode(response.body)["error"] ?? "Login failed"};
    }
  } catch (e) {
    return {"success": false, "message": "Error: $e"};
  }
}


  // GET user profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final Uri url = Uri.parse("$baseUrl/profile");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": "Failed to fetch profile"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // PUT update profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updatedData,
    String token,
  ) async {
    final Uri url = Uri.parse("$baseUrl/profile");
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
        return {
          "success": false,
          "message": jsonDecode(response.body)["error"] ?? "Update failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
