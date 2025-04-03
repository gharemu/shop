import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFFF3E6C),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_rupee_outlined),
          activeIcon: Icon(Icons.currency_rupee),
          label: "Under ₹999",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.diamond_outlined),
          activeIcon: Icon(Icons.diamond),
          label: "Luxury",
        ),
      ],
    );
  }
}
