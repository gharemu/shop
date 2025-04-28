import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Deals/models/product.dart';

class CategoryData {
  final List<String> mainCategories;
  final Map<String, List<String>> parentCategories;
  final Map<String, List<String>> subCategories;

  CategoryData({
    required this.mainCategories,
    required this.parentCategories,
    required this.subCategories,
  });
}

class CategoryService {
  // You can use your API base URL here
  final String baseUrl = 'http://192.168.10.41:5000/api';

  Future<CategoryData> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> products = json.decode(response.body);

      // Extract unique categories
      Set<String> mainCategoriesSet = {};
      Map<String, Set<String>> parentCategoriesMap = {};
      Map<String, Set<String>> subCategoriesMap = {};

      for (var product in products) {
        final productObj = Product.fromJson(product);

        // Add main category (Men, Women, Kids)
        if (productObj.category != null && productObj.category!.isNotEmpty) {
          mainCategoriesSet.add(productObj.category!);

          // Initialize parent category set for this main category if it doesn't exist
          if (!parentCategoriesMap.containsKey(productObj.category)) {
            parentCategoriesMap[productObj.category!] = {};
          }

          // Add parent category
          if (productObj.parentCategory != null &&
              productObj.parentCategory!.isNotEmpty) {
            parentCategoriesMap[productObj.category!]!.add(
              productObj.parentCategory!,
            );

            // Create a unique key for parent category within main category
            String parentKey =
                "${productObj.category!}-${productObj.parentCategory!}";

            // Initialize subcategory set for this parent category if it doesn't exist
            if (!subCategoriesMap.containsKey(parentKey)) {
              subCategoriesMap[parentKey] = {};
            }

            // Add subcategory
            if (productObj.subCategory != null &&
                productObj.subCategory!.isNotEmpty) {
              subCategoriesMap[parentKey]!.add(productObj.subCategory!);
            }
          }
        }
      }

      // Convert sets to lists
      Map<String, List<String>> parentCategoriesResult = {};
      parentCategoriesMap.forEach((key, value) {
        parentCategoriesResult[key] = value.toList();
      });

      Map<String, List<String>> subCategoriesResult = {};
      subCategoriesMap.forEach((key, value) {
        subCategoriesResult[key] = value.toList();
      });

      return CategoryData(
        mainCategories: mainCategoriesSet.toList(),
        parentCategories: parentCategoriesResult,
        subCategories: subCategoriesResult,
      );
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
