import 'dart:convert';
import 'package:Deals/login/api_service.dart';
import 'package:http/http.dart' as http;

class CheckoutService {
  static const String _baseUrl = 'http://192.168.10.41:5000/api/checkout';

  // Get Auth Headers using ApiService's getToken
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // GET Checkout details (like address, name, etc.)
  Future<Map<String, dynamic>> getCheckout() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/init'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load checkout data');
    }
  }

  // // ✅ Get Order Summary for specific productId (for Buy Now)
  Future<Map<String, dynamic>> getOrderSummary(String productId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/order-summary?productId=$productId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch order summary.');
    }
  }

  // Initiate Buy Now checkout (GET Request)
  Future<Map<String, dynamic>> initiateBuyNow(String productId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/product/$productId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate Buy Now checkout.');
    }
  }
}
