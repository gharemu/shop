import 'package:flutter/material.dart';
import 'package:Deals/screen/subcategoryDetailsPage.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Men',
      'image': 'assets/men.png',
      'subcategories': [
        'Casual wear',
        'Formal wear',
        'Traditional wear',
        'Winter wear',
        'Summer wear',
      ],
    },
    {
      'name': 'Women',
      'image': 'assets/women.png',
      'subcategories': [
        'Casual wear',
        'Formal wear',
        'Indian wear',
        'Western wear',
        'Summer wear',
      ],
    },
    {
      'name': 'Kids',
      'image': 'assets/kids.png',
      'subcategories': [
        'Boys',
        'Girls',
        'Infants',
        'Trendy wear',
        'Comfy clothes',
      ],
    },
  ];

  final Map<String, List<String>> subcategoryDetails = {
    'Casual wear': ['T-shirts', 'Jeans', 'Hoodies'],
    'Formal wear': ['Suits', 'Dress Shirts', 'Tuxedos'],
    'Traditional wear': ['Kurtas', 'Sherwanis'],
    'Winter wear': ['Jackets', 'Sweaters', 'Thermals'],
    'Summer wear': ['Shorts', 'Cotton Shirts'],
    'Indian wear': ['Sarees', 'Lehengas', 'Salwar Kameez'],
    'Western wear': ['Dresses', 'Skirts', 'Blazers'],
    'Boys': ['Shirts', 'Jeans', 'Sweatshirts'],
    'Girls': ['Frocks', 'Leggings', 'Jumpsuits'],
    'Infants': ['Rompers', 'Onesies', 'Baby Sets'],
    'Trendy wear': ['Graphic Tees', 'Baggy Jeans', 'Oversized Hoodies'],
    'Comfy clothes': ['Pajamas', 'Cotton Shorts', 'Relaxed Tees'],
  };

  // Controller for page transition animations
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onCategoryTap(int index) {
    // Animate the fade out and in when changing category.
    _controller.reverse().then((_) {
      setState(() {
        selectedIndex = index;
      });
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Category List with Animation on selection using AnimatedContainer.
          Container(
            width: 100,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: categories.length,
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
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: isSelected ? 4 : 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black12,
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
                          backgroundImage: AssetImage(categories[index]['image']),
                          radius: 25,
                        ),
                        SizedBox(height: 5),
                        Text(
                          categories[index]['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right Subcategory List with AnimatedSwitcher for smooth fade transition.
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                key: ValueKey<int>(selectedIndex),
                itemCount: categories[selectedIndex]['subcategories'].length,
                itemBuilder: (context, index) {
                  String subcategory = categories[selectedIndex]['subcategories'][index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ExpansionTile(
                      title: Text(
                        subcategory,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: subcategoryDetails.containsKey(subcategory)
                          ? subcategoryDetails[subcategory]!.map((subItem) {
                              return ListTile(
                                title: Text(subItem),
                                trailing: Icon(Icons.arrow_forward),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubcategoryDetailPage(
                                        subcategory: subItem,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList()
                          : [
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(child: Text("No further subcategories")),
                              )
                            ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
