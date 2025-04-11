import 'package:flutter/material.dart';
import 'package:Deals/screen/cat_screen.dart';
import 'package:Deals/screen/bags_screen.dart';
import 'package:Deals/screen/bottom_nav.dart';
import 'package:Deals/screen/custome_app_bar.dart';
import 'package:Deals/screen/under_999_screen.dart';
import 'package:Deals/screen/category_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  
  final List<Widget> _screens = [
    const CategoriesScreen(), // Main category screen
    const Under999Screen(),     // Under 999 screen
    CategoryPage(),             // Luxury section
    const BagsScreen(),         // Bags section
  ];
  
  final List<String> _titles = [
    "Categories",
    "Under ₹999",
    "Luxury",
    "Bags"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  // Build method with AnimatedSwitcher for smooth transitions.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        // Remove the actions parameter to use the default actions from CustomAppBar
        // which includes the login button
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: _screens.map((screen) => 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: screen,
          )
        ).toList(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // Show filter options
          showModalBottomSheet(
            context: context,
            builder: (context) => const FilterBottomSheet(),
          );
        },
        child: const Icon(Icons.filter_list),
      ) : null,
    );
  }
}

// Custom search delegate for search functionality
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return Center(child: Text('Results for: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return Center(child: Text('Type to search...'));
  }
}

// Filter bottom sheet
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildFilterOption(context, 'Price Range'),
                _buildFilterOption(context, 'Categories'),
                _buildFilterOption(context, 'Brands'),
                _buildFilterOption(context, 'Ratings'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filters applied!')),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle filter option tap
      },
    );
  }
}
