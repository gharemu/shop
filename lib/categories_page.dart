import 'package:flutter/material.dart';
import 'package:police_app/subcategoryDetailsPage.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Men',
      'image': 'assets/men.png',
      'subcategories': ['Casual wear', 'Formal wear', 'Traditional wear', 'Winter wear', 'Summer wear']
    },
    {
      'name': 'Women',
      'image': 'assets/women.png',
      'subcategories': ['Casual wear', 'Formal wear', 'Indian wear', 'Western wear', 'Summer wear']
    },
    {
      'name': 'Kids',
      'image': 'assets/kids.png',
      'subcategories': ['Boys', 'Girls', 'Infants', 'Trendy wear', 'Comfy clothes']
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'Poster',
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Category List
          Container(
            width: 100,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    color: selectedIndex == index ? Colors.white : Colors.grey[200],
                    child: Column(
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
                            fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right Subcategory List with Drop-down
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: categories[selectedIndex]['subcategories'].length,
              itemBuilder: (context, index) {
                String subcategory = categories[selectedIndex]['subcategories'][index];

                return ExpansionTile(
                  title: Text(
                    subcategory,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: subcategoryDetails.containsKey(subcategory)
                      ? subcategoryDetails[subcategory]!
                          .map((subItem) => ListTile(
                                title: Text(subItem),
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
                              ))
                          .toList()
                      : [Text("No further subcategories")],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.branding_watermark), label: 'BRANDS'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'CATEGORIES'),
          BottomNavigationBarItem(icon: Icon(Icons.diamond), label: 'LUXE'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ACCOUNT'),
        ],
      ),
    );
  }
}
