import 'package:Deals/screen/bags_screen.dart';
import 'package:flutter/material.dart';
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/login/login_page.dart';
import 'package:Deals/screen/notifications_screen.dart';
import 'package:Deals/login/api_service.dart'; // Add this import
import 'package:Deals/screen/user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key, 
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3E6C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'M',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for products, brands and more",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BagsScreen()),
            );
          },
        ),
        // Update the person icon button in CustomAppBar
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.black),
          onPressed: () async {
            // Check if user is logged in
            bool isLoggedIn = await ApiService.isLoggedIn();
            if (isLoggedIn) {
              // Navigate to profile screen if logged in
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Loginnnn()),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () async {
            await ApiService.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Loginnnn()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
