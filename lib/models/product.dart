import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String id;
  int quantity; // ✅ Made mutable
    final int? cartItemId; // 👈 Add this line

  final String name;
  final String brand;
  final String description;
  final String category;
  final String parentCategory;
  final String subCategory;
  final double oldPrice;
  final double discountedPrice;
  final double? originalPrice;
  final int discount;
  final String imageUrl;
  final List<String> additionalImages;
  final List<String> sizes;
  bool isFavorite;
  final List<String> colors;
  final double rating;
  final int reviews;
  final bool isNew;

  Product({
    required this.id,
    required this.quantity, // ✅ Initialize here
      this.cartItemId, // 👈 Add this

    required this.name,
    required this.brand,
    required this.description,
    required this.category,
    required this.parentCategory,
    required this.subCategory,
    required this.oldPrice,
    required this.discountedPrice,
    this.originalPrice,
    required this.discount,
    required this.imageUrl,
    required this.additionalImages,
    required this.sizes,
    this.isFavorite = false,
    required this.colors,
    required this.rating,
    required this.reviews,
    this.isNew = false,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'category': category,
      'parent_category': parentCategory,
      'sub_category': subCategory,
      'old_price': oldPrice,
      'discount_price': discountedPrice,
      'discount': discount,
      'image': imageUrl,
      'additional_images': additionalImages,
      'sizes': sizes,
      'colors': colors,
      'rating': rating,
      'reviews': reviews,
      'is_new': isNew,
      'quantity': quantity, // ✅ Include quantity in JSON
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'].toString(),
    quantity: _toInt(json['quantity'] ?? 1), // Default to 1 if quantity is null
   cartItemId: json['cart_item_id'], // 👈 This must match your backend response key
    name: json['name'] ?? '',
    brand: json['brand'] ?? 'Unknown',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    parentCategory: json['parent_category'] ?? '',
    subCategory: json['sub_category'] ?? '',
    oldPrice: _toDouble(json['old_price']),
    discountedPrice: _toDouble(json['discount_price']),
    originalPrice: json['original_price'] != null ? _toDouble(json['original_price']) : null,
    discount: _toInt(json['discount']),
    imageUrl: json['image'] ?? '',
    additionalImages: (json['additional_images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    sizes: (json['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    colors: (json['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    rating: _toDouble(json['rating']),
    reviews: _toInt(json['reviews']),
    isNew: json['is_new'] == true || json['is_new'] == 'true',
  );
}

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return value.toDouble();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
