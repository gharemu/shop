// models/product.dart
import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String category;
  final String gender;
  final int originalPrice;
  final int discountedPrice;
  final int discount;
  final String imageUrl;
  final List<String> additionalImages;
  final List<String> sizes;
  bool isFavorite;
  final List<String> colors;
  final double rating;
  final int reviews;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.category,
    required this.gender,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discount,
    required this.imageUrl,
    required this.additionalImages,
    required this.sizes,
    this.isFavorite = false,
    required this.colors,
    required this.rating,
    required this.reviews,
  });
  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
