// lib/screens/subcategory_page.dart
import 'package:flutter/material.dart';

class SubCategoryPage extends StatelessWidget {
  final Color primaryColor = const Color(0xFF3F51B5);
  final Color accentColor = const Color(0xFF4CAF50);
  final Color backgroundColor = const Color(0xFFF5F7FF);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String mainCategory = args['mainCategory'];
    final String parentCategory = args['parentCategory'];
    final List<String> subcategories = args['subcategories'];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          parentCategory,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainCategory,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${subcategories.length} Subcategories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Subcategories List
          Expanded(
            child:
                subcategories.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: subcategories.length,
                      itemBuilder: (context, index) {
                        return _buildSubcategoryCard(
                          context,
                          subcategories[index],
                          mainCategory,
                          parentCategory,
                          index,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "No subcategories found",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(
    BuildContext context,
    String subcategory,
    String mainCategory,
    String parentCategory,
    int index,
  ) {
    final colors = [
      Color(0xFF5C6BC0), // Indigo
      Color(0xFF26A69A), // Teal
      Color(0xFFEF5350), // Red
      Color(0xFF7E57C2), // Deep Purple
      Color(0xFF66BB6A), // Green
    ];

    final color = colors[index % colors.length];

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/products-list',
            arguments: {
              'category': mainCategory,
              'parentCategory': parentCategory,
              'subCategory': subcategory,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getSubcategoryIcon(subcategory),
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  subcategory,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubcategoryIcon(String subcategory) {
    final subcategoryLower = subcategory.toLowerCase();

    if (subcategoryLower.contains('shirt') ||
        subcategoryLower.contains('tshirt') ||
        subcategoryLower.contains('t-shirt')) {
      return Icons.crop_square;
    } else if (subcategoryLower.contains('pant') ||
        subcategoryLower.contains('trouser') ||
        subcategoryLower.contains('jeans')) {
      return Icons.power_input_rounded;
    } else if (subcategoryLower.contains('dress') ||
        subcategoryLower.contains('frock')) {
      return Icons.accessibility;
    } else if (subcategoryLower.contains('shoe') ||
        subcategoryLower.contains('footwear')) {
      return Icons.hiking;
    } else if (subcategoryLower.contains('watch') ||
        subcategoryLower.contains('time')) {
      return Icons.watch;
    } else if (subcategoryLower.contains('accessory') ||
        subcategoryLower.contains('jewelry')) {
      return Icons.diamond;
    } else if (subcategoryLower.contains('hat') ||
        subcategoryLower.contains('cap')) {
      return Icons.face;
    } else if (subcategoryLower.contains('bag') ||
        subcategoryLower.contains('purse')) {
      return Icons.shopping_bag;
    } else if (subcategoryLower.contains('saree') ||
        subcategoryLower.contains('sari')) {
      return Icons.layers;
    } else if (subcategoryLower.contains('kurta') ||
        subcategoryLower.contains('ethnic')) {
      return Icons.format_color_fill;
    } else {
      return Icons.checkroom;
    }
  }
}
