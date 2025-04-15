import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';

class ProductService {
  final String baseUrl = "http://192.168.10.50:5000/api"; // Replace with your actual backend API URL

  // Fetch Men products
  Future<List<Product>> getMenProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load Men products');
    }
  }

  // Fetch Women products
  Future<List<Product>> getWomenProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch Kids products
  Future<List<Product>> getKidsProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load Kids products');
    }
  }

  // Fetch all products under 999
  Future<List<Product>> getUnder999Products() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products under 999');
    }
  }

  // Fetch Luxury products
  Future<List<Product>> getLuxuryProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/luxury'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load Luxury products');
    }
  }

  // Fetch products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/products/category/$category'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by category');
    }
  }

  // Fetch products by gender
  Future<List<Product>> getProductsByGender(String gender) async {
    final response = await http.get(Uri.parse('$baseUrl/products/gender/$gender'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by gender');
    }
  }

  // Fetch products by brand
  Future<List<Product>> getProductsByBrand(String brand) async {
    final response = await http.get(Uri.parse('$baseUrl/products/brand/$brand'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by brand');
    }
  }

  // Fetch all products
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load all products');
    }
  }

  // Fetch discounted products
  Future<List<Product>> getDiscountedProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/discounted'));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load discounted products');
    }
  }
}
