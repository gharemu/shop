import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';

class ApiService {
  final String baseUrl =
      'https://192.168.10.64:5000/api'; // Replace with your actual API URL

  // Fetch all categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Fetch subcategories for a specific category
  Future<List<String>> fetchSubcategories(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/subcategories'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return List<String>.from(data.map((item) => item['name']));
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  // Fetch subcategory details
  Future<List<String>> fetchSubcategoryDetails(String subcategory) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subcategories'),
      headers: {'subcategory': subcategory},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return List<String>.from(data.map((item) => item['name']));
    } else {
      throw Exception('Failed to load subcategory details');
    }
  }

  // Fetch products by subcategory
  Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'subCategory': subcategory},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map<Product>((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
