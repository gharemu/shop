import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/services/api2_service.dart';
import 'package:Deals/screen/product_listing_page.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool isLoading = true;
  List<String> mainCategories = [];
  Map<String, List<String>> parentCategories = {};
  Map<String, List<String>> subCategories = {};

  // For animations
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Theme colors
  final Color primaryColor = const Color(0xFFFF4081);
  final Color lightColor = const Color(0xFFFFD6E1);
  final Color darkColor = const Color(0xFFD81B60);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  // Category service
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    fetchCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoryData = await _categoryService.fetchCategories();

      setState(() {
        mainCategories = categoryData.mainCategories;
        parentCategories = categoryData.parentCategories;
        subCategories = categoryData.subCategories;
        isLoading = false;
      });

      // Start animation
      _controller.forward();
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: $e'),
            backgroundColor: primaryColor,
          ),
        );
      }
    }
  }

  void onCategoryTap(int index) {
    // Animate the fade out and in when changing category
    _controller.reverse().then((_) {
      setState(() {
        selectedIndex = index;
      });
      _controller.forward();
    });
  }

  void navigateToProductsList(
    String category,
    String parentCategory,
    String subCategory,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductsListScreen(
              category: category,
              parentCategory: parentCategory,
              subCategory: subCategory,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : mainCategories.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No categories found",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Row(
                children: [
                  // Left Category List with Animation
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 0),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: mainCategories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        return _buildMainCategoryItem(index, isSelected);
                      },
                    ),
                  ),

                  // Right Subcategory List with Animation
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child:
                          selectedIndex < mainCategories.length
                              ? _buildParentCategoriesList(
                                mainCategories[selectedIndex],
                              )
                              : Center(child: Text("Select a category")),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildMainCategoryItem(int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          onCategoryTap(index);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: isSelected ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? lightColor : Colors.grey[200],
              radius: 25,
              child: Icon(
                _getCategoryIcon(mainCategories[index]),
                color: isSelected ? primaryColor : Colors.grey[700],
                size: 28,
              ),
            ),
            SizedBox(height: 8),
            Text(
              mainCategories[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'men':
        return Icons.man;
      case 'women':
        return Icons.woman;
      case 'kids':
        return Icons.child_care;
      default:
        return Icons.category;
    }
  }

  Widget _buildParentCategoriesList(String mainCategory) {
    final parentCategoriesList = parentCategories[mainCategory] ?? [];

    if (parentCategoriesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No categories found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: parentCategoriesList.length,
        itemBuilder: (context, index) {
          String parentCategory = parentCategoriesList[index];
          String parentKey = "$mainCategory-$parentCategory";
          List<String> subCategoriesList = subCategories[parentKey] ?? [];

          return _buildParentCategoryCard(
            mainCategory,
            parentCategory,
            subCategoriesList,
          );
        },
      ),
    );
  }

  Widget _buildParentCategoryCard(
    String mainCategory,
    String parentCategory,
    List<String> subCategoriesList,
  ) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: primaryColor),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              _getParentCategoryIcon(parentCategory),
              SizedBox(width: 12),
              Text(
                parentCategory,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          children:
              subCategoriesList.isEmpty
                  ? [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          "No subcategories available",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ]
                  : subCategoriesList.map((subCategory) {
                    return _buildSubCategoryItem(
                      mainCategory,
                      parentCategory,
                      subCategory,
                    );
                  }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubCategoryItem(
    String mainCategory,
    String parentCategory,
    String subCategory,
  ) {
    return InkWell(
      onTap:
          () =>
              navigateToProductsList(mainCategory, parentCategory, subCategory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          title: Text(subCategory, style: TextStyle(fontSize: 15)),
          trailing: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _getParentCategoryIcon(String parentCategory) {
    IconData iconData;

    switch (parentCategory.toLowerCase()) {
      case 'casual wear':
        iconData = Icons.accessibility_new;
        break;
      case 'formal wear':
        iconData = Icons.business;
        break;
      case 'traditional wear':
      case 'indian wear':
        iconData = Icons.auto_awesome;
        break;
      case 'winter wear':
        iconData = Icons.ac_unit;
        break;
      case 'summer wear':
        iconData = Icons.wb_sunny;
        break;
      case 'western wear':
        iconData = Icons.style;
        break;
      case 'boys':
        iconData = Icons.boy;
        break;
      case 'girls':
        iconData = Icons.girl;
        break;
      case 'infants':
        iconData = Icons.child_friendly;
        break;
      case 'trendy wear':
        iconData = Icons.trending_up;
        break;
      case 'comfy clothes':
        iconData = Icons.weekend;
        break;
      default:
        iconData = Icons.category;
    }

    return CircleAvatar(
      backgroundColor: lightColor,
      radius: 18,
      child: Icon(iconData, size: 20, color: primaryColor),
    );
  }
}
