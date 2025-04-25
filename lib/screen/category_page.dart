import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/services/product_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Pink theme colors
  final Color primaryPink = const Color(0xFFFF4081);
  final Color lightPink = const Color(0xFFFFD6E1);
  final Color darkPink = const Color(0xFFD81B60);

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
      // Fetch all products
      final response = await http.get(
        Uri.parse('http://192.168.10.64:5000/api/products'),
      );

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
        setState(() {
          mainCategories = mainCategoriesSet.toList();

          // Convert parent categories sets to lists
          parentCategories = {};
          parentCategoriesMap.forEach((key, value) {
            parentCategories[key] = value.toList();
          });

          // Convert subcategories sets to lists
          subCategories = {};
          subCategoriesMap.forEach((key, value) {
            subCategories[key] = value.toList();
          });

          isLoading = false;
        });

        // Start animation
        _controller.forward();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: $e'),
            backgroundColor: primaryPink,
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
    Navigator.pushNamed(
      context,
      '/products-list',
      arguments: {
        'category': category,
        'parentCategory': parentCategory,
        'subCategory': subCategory,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryPink,
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryPink))
              : mainCategories.isEmpty
              ? Center(child: Text("No categories found"))
              : Row(
                children: [
                  // Left Category List with Animation
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
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
                              color:
                                  isSelected ? Colors.white : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isSelected
                                      ? Border.all(color: primaryPink, width: 2)
                                      : null,
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: primaryPink.withOpacity(0.3),
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
                                  backgroundColor:
                                      isSelected ? lightPink : Colors.grey[200],
                                  radius: 25,
                                  child: Icon(
                                    _getCategoryIcon(mainCategories[index]),
                                    color:
                                        isSelected
                                            ? primaryPink
                                            : Colors.grey[700],
                                    size: 28,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  mainCategories[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? primaryPink
                                            : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Right Subcategory List with AnimatedSwitcher
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
      return Center(child: Text("No categories found"));
    }

    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: parentCategoriesList.length,
        itemBuilder: (context, index) {
          String parentCategory = parentCategoriesList[index];
          String parentKey = "$mainCategory-$parentCategory";
          List<String> subCategoriesList = subCategories[parentKey] ?? [];

          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: primaryPink),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    _getParentCategoryIcon(parentCategory),
                    SizedBox(width: 12),
                    Text(
                      parentCategory,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                          return InkWell(
                            onTap:
                                () => navigateToProductsList(
                                  mainCategory,
                                  parentCategory,
                                  subCategory,
                                ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: ListTile(
                                title: Text(
                                  subCategory,
                                  style: TextStyle(fontSize: 15),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: primaryPink,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
              ),
            ),
          );
        },
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
      backgroundColor: lightPink,
      radius: 16,
      child: Icon(iconData, size: 18, color: primaryPink),
    );
  }
}

// Add this class to navigate to products filtered by category
class ProductsListScreen extends StatefulWidget {
  final String category;
  final String parentCategory;
  final String subCategory;

  const ProductsListScreen({
    Key? key,
    required this.category,
    required this.parentCategory,
    required this.subCategory,
  }) : super(key: key);

  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final Color primaryPink = const Color(0xFFFF4081);

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // You might want to create a specific API endpoint for this filtering
      // For now, we'll use the general products endpoint and filter client-side
      final response = await http.get(
        Uri.parse('http://192.168.10.64:5000/api/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> allProducts = json.decode(response.body);

        setState(() {
          products =
              allProducts
                  .map((product) => Product.fromJson(product))
                  .where(
                    (product) =>
                        product.category == widget.category &&
                        product.parentCategory == widget.parentCategory &&
                        product.subCategory == widget.subCategory,
                  )
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: primaryPink,
          ),
        );
      }
    }
  }

  void navigateToProductDetails(Product product) {
    Navigator.pushNamed(context, '/product-details', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subCategory,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryPink,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryPink))
              : products.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No products found",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product);
                },
              ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => navigateToProductDetails(product),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(product.image ?? ''),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                ),
                child:
                    product.discount != null && product.discount! > 0
                        ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryPink,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              "${product.discount}% OFF",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        : SizedBox(),
              ),
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "₹${product.discountPrice}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryPink,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (product.oldPrice != null)
                        Text(
                          "₹${product.oldPrice}",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
