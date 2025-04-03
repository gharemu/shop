import 'package:flutter/material.dart';
import 'package:Deals/models/product.dart';
import 'package:Deals/screen/product_detail_screen.dart';
import 'package:Deals/services/product_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  String _selectedFilter = "All";
  List<String> _filters = ["All", "New", "Popular", "Sale"];
  
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _filteredProducts = [];
  
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset >= 200;
      });
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _isLoading = true;
        _selectedFilter = "All";
        _searchController.clear();
        _isSearching = false;
      });
      
      // Simulate loading data when switching tabs
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
  
  void _scrollToTop() {
    _scrollController.animateTo(0,
      duration: const Duration(milliseconds: 500), 
      curve: Curves.easeInOut
    );
  }
  
  void _filterProducts(String query) {
    List<Product> currentProducts;
    
    switch (_tabController.index) {
      case 0:
        currentProducts = _productService.getMenProducts();
        break;
      case 1:
        currentProducts = _productService.getWomenProducts();
        break;
      default:
        currentProducts = _productService.getKidsProducts();
    }
    
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredProducts = [];
      } else {
        _isSearching = true;
        _filteredProducts = currentProducts
            .where((product) => 
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.brand.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  
  List<Product> _getFilteredProducts(List<Product> products) {
    if (_selectedFilter == "All") {
      return products;
    } else if (_selectedFilter == "New") {
      return products.where((p) => p.isNew).toList();
    } else if (_selectedFilter == "Popular") {
      return products.where((p) => p.rating >= 4.0).toList();
    } else { // Sale
      return products.where((p) => p.discount > 0).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _isSearching 
          ? _buildSearchField()
          : const Text(
              "Shop by Categories",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            color: Colors.black87,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredProducts = [];
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: Colors.black87,
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF3E6C),
              unselectedLabelColor: Colors.black54,
              indicatorColor: const Color(0xFFFF3E6C),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'MEN'),
                Tab(text: 'WOMEN'),
                Tab(text: 'KIDS'),
              ],
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isSearching 
                    ? _buildSearchResults()
                    : _buildProductGrid(_productService.getMenProducts()),
                _isSearching 
                    ? _buildSearchResults()
                    : _buildProductGrid(_productService.getWomenProducts()),
                _isSearching 
                    ? _buildSearchResults()
                    : _buildProductGrid(_productService.getKidsProducts()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              mini: true,
              backgroundColor: const Color(0xFFFF3E6C),
              child: const Icon(Icons.arrow_upward),
              onPressed: _scrollToTop,
            )
          : null,
    );
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search products...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      style: const TextStyle(color: Colors.black87),
      onChanged: _filterProducts,
    );
  }
  
  Widget _buildSearchResults() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No products found",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return _buildProductGrid(_filteredProducts);
  }
  
  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFFFFD1DC),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFFF3E6C) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF3E6C) : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    final filteredProducts = _getFilteredProducts(products);
    
    if (_isLoading) {
      return _buildLoadingGrid();
    }
    
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No products available in this category",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF3E6C),
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        
        // Simulate refresh
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(10),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          // Add staggered effect with slightly different heights
          double heightFactor = index % 3 == 0 ? 1.1 : (index % 5 == 0 ? 0.9 : 1.0);
          return _buildProductCard(filteredProducts[index], heightFactor);
        },
      ),
    );
  }
  
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, [double heightFactor = 1.0]) {
    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailScreen(product: product),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.05);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        height: 180 * heightFactor,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180 * heightFactor,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF3E6C),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180 * heightFactor,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            product.isFavorite = !product.isFavorite;
                          });
                          
                          // Animated feedback
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    product.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    product.isFavorite
                                        ? 'Added to wishlist'
                                        : 'Removed from wishlist',
                                  ),
                                ],
                              ),
                              backgroundColor: product.isFavorite
                                  ? const Color(0xFFFF3E6C)
                                  : Colors.grey[700],
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: product.isFavorite ? 0.0 : 1.0,
                            end: product.isFavorite ? 1.0 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 1.0 + (value * 0.2),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  product.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: product.isFavorite
                                      ? const Color(0xFFFF3E6C)
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (product.discount > 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3E6C),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            "${product.discount}% OFF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (product.isNew)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.brand,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.rating > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "₹${product.discountedPrice}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (product.discount > 0)
                            Text(
                              "₹${product.originalPrice}",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Material(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFFF3E6C).withOpacity(0.1),
                        child: InkWell(
                          onTap: () {
                            // Animated feedback for add to cart
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("Added to cart"),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF4CAF50),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                action: SnackBarAction(
                                  label: "VIEW",
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // Navigate to cart
                                  },
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.center,
                            child: Text(
                              "ADD TO CART",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFFFF3E6C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    "Sort By",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildFilterOption("Popularity", true, setModalState),
                      _buildFilterOption("Price: Low to High", false, setModalState),
                      _buildFilterOption("Price: High to Low", false, setModalState),
                      _buildFilterOption("Newest First", false, setModalState),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildFilterOption("T-Shirts", false, setModalState),
                      _buildFilterOption("Shirts", false, setModalState),
                      _buildFilterOption("Jeans", false, setModalState),
                      _buildFilterOption("Shoes", false, setModalState),
                      _buildFilterOption("Accessories", false, setModalState),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Price Range",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: const RangeValues(500, 3000),
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    activeColor: const Color(0xFFFF3E6C),
                    inactiveColor: Colors.grey[300],
                    labels: const RangeLabels("₹500", "₹3000"),
                    onChanged: (RangeValues values) {},
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "RESET",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFFFF3E6C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "APPLY",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFilterOption(String label, bool isSelected, StateSetter setModalState) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          // Update selection
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFFFFD1DC),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF3E6C) : Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}