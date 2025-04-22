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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CategoriesScreen(), // Main category screen
    const Under999Screen(),     // Under 999 screen
    CategoryPage(),             // Luxury section
    const BagScreen(token: 'id',),         // Bags section
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build method with AnimatedSwitcher for smooth transitions.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          // Key is necessary so AnimatedSwitcher knows when a new widget is shown.
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
