import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.10.41:5000/api/auth"; // Change to your API server

  // Register user
  static Future<Map<String, dynamic>> registerUser(String name, String email, String password) async {
    final Uri url = Uri.parse("$baseUrl/register"); // Update API endpoint
    try {
      final response = await http.post(

        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "User registered successfully"};
      } else {
        return {"success": false, "message": jsonDecode(response.body)["error"] ?? "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final Uri url = Uri.parse("$baseUrl/login"); // Update API endpoint
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Login successful"};
      } else {
        return {"success": false, "message": jsonDecode(response.body)["error"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
