import 'dart:convert';
import 'package:Deals/login/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';

class ProductService {
  final String baseUrl =
      "http://192.168.10.64:5000/api"; // Replace with your actual backend API URL

  // Fetch Men products
  Future<List<Product>> getMenProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter only 'Women' category products
      List<Product> womenProducts =
          allProducts
              .where((product) => product.category.toLowerCase() == 'men')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch Women products
  Future<List<Product>> getWomenProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter only 'Women' category products
      List<Product> womenProducts =
          allProducts
              .where((product) => product.category.toLowerCase() == 'women')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch Kids products
  Future<List<Product>> getKidsProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter only 'Women' category products
      List<Product> womenProducts =
          allProducts
              .where((product) => product.category.toLowerCase() == 'kids')
              .toList();

      return womenProducts;
    } else {
      throw Exception('Failed to load Women products');
    }
  }

  // Fetch all products under 999
  Future<List<Product>> getUnder999Products() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Product> allProducts =
          jsonData.map((product) => Product.fromJson(product)).toList();

      // Filter products with discountedPrice less than or equal to ₹999
      List<Product> under999Products =
          allProducts
              .where((product) => product.discountedPrice <= 999)
              .toList();

      return under999Products;
    } else {
      throw Exception('Failed to load products under ₹999');
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
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$category'),
    );
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by category');
    }
  }

  // Fetch products by gender
  Future<List<Product>> getProductsByGender(String gender) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/gender/$gender'),
    );
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products by gender');
    }
  }

  // Fetch products by brand
  Future<List<Product>> getProductsByBrand(String brand) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/brand/$brand'),
    );
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
   
  

  Future<List<Product>> searchProducts(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/products/search?keyword=${Uri.encodeComponent(keyword)}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

 // Replace with your actual backend API URL
  // Static method to add an item to the cart
 static Future<void> addToCart(String productId, int quantity, String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.10.64:5000/api/cart/cartadd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Authorization header with JWT token
      },
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      print('Item added to cart');
    } else {
      // Log the response body to help debug the error
      print('Failed to add item to cart. Response: ${response.body}');
      throw Exception('Failed to add item to cart');
    }
  } catch (e) {
    // Log any other errors
    print('Error while adding to cart: $e');
    print("Using token: $token");

    throw Exception('Failed to add item to cart: $e');
    
  }
}


  // Static method to get Cart Items
static Future<List<Product>> getCartItems() async {
  String? token = await ApiService.getToken();

  if (token == null || token.isEmpty) {
    print("Error: No token found. User may not be logged in.");
    throw Exception('No token found. User may not be logged in.');
  }

  final url = Uri.parse('http://192.168.10.64:5000/api/cart/cartget');
  print("Using token: $token");

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Debugging: print the raw response body to inspect the structure
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> cartItems = json.decode(response.body);

      // Safely map the response to Product instances
      return cartItems.map<Product>((item) {
        // Ensure each item is a map and has the necessary 'product' key
        final Map<String, dynamic> productJson = {
          'id': item['product_id'].toString(),
          'quantity': item['quantity'] ?? 1,  // Default to 1 if quantity is missing
          'name': item['product_name'] ?? '',
          'brand': 'Unknown',  // You may want to handle this as needed
          'description': '',  // You can add the description or other info as needed
          'category': '',  // Handle category if it's available in your app
          'parentCategory': '',  // Similarly handle this if needed
          'subCategory': '',  // Handle sub-category if required
          'oldPrice': (item['product_price']),
          'discountedPrice': (item['product_price']),  // Assuming no discount for now
          'imageUrl': item['product_image'] ?? '',
          'additionalImages': [],  // Adjust this if there are additional images
          'sizes': [],  // Adjust this as needed
          'colors': [],  // Adjust this as needed
          'rating': 0.0,  // Adjust this if ratings are provided
          'reviews': 0,  // Adjust this if reviews are provided
          'isNew': false,  // Adjust this if needed
        };

        // Ensure 'quantity' exists or default to 1
        if (productJson['quantity'] == null) {
          productJson['quantity'] = 1;  // Default to 1 if missing
        }

        return Product.fromJson(productJson);
      }).toList();
    } else {
      print("Failed to load cart items: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to load cart items: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print("Error fetching cart items: $e");
    throw Exception('Error fetching cart items: $e');
  }
}
 // Static method to remove item from Cart
 static Future<void> removeFromCart(int cartItemId) async {
  final token = await ApiService.getToken(); // Ensure this gets the token
  if (token == null || token.isEmpty) {
    throw Exception("No token provided");
  }

  final url = Uri.parse('http://192.168.10.64:5000/api/cart/cartdel/$cartItemId');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to remove item');
  }
}
}