import 'package:flutter/material.dart';
import 'package:Deals/adminfiles/add_item_screen.dart';
import 'package:Deals/adminfiles/update_item_screen.dart';
import 'package:Deals/adminfiles/delete_item_screen.dart';
import 'package:Deals/screen/custome_app_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AddItemScreen(),
    const UpdateItemScreen(),
    const DeleteItemScreen(),
  ];

  final List<String> _titles = [
    "Add Items",
    "Update Items",
    "Delete Items",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _titles[_selectedIndex]),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          padding: const EdgeInsets.all(16),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Update",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: "Delete",
          ),
        ],
      ),
    );
  }
}
