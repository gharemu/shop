import 'dart:convert';
import 'package:Deals/login/api_service.dart';
import 'package:http/http.dart' as http;

class CheckoutService {
  static const String _baseUrl = 'http://192.168.10.64:5000/api/checkout';

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
    final response = await http.get(Uri.parse('$_baseUrl/init'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load checkout data');
    }
  }

  // GET Order Summary
  Future<Map<String, dynamic>> getOrderSummary() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_baseUrl/order-summary'), headers: headers);
        // Debug: Print the response body for debugging purposes
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order summary');
    }
  }
}
