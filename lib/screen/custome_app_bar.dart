import 'package:Deals/login/profile_account.dart';
import 'package:Deals/screen/bags_screen.dart';
import 'package:flutter/material.dart';
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/login/login_page.dart';
import 'package:Deals/screen/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? userName;

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    setState(() {
      userName = name;
    });
  }

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
      actions: [
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
        Row(
          children: [
            if (userName != null)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Text(
                  userName!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');

                if (token == null) {
                  // Not logged in: go to login
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Loginnnn()),
                  );

                  if (result == true) {
                    await loadUserName(); // Reload name after login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  }
                } else {
                  // Already logged in
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
