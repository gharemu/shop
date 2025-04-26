// custom_app_bar.dart
import 'package:Deals/screen/bags_screen.dart';
import 'package:flutter/material.dart';
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/login/login_page.dart';
import 'package:Deals/screen/notifications_screen.dart';
import 'package:Deals/login/user_provider.dart';
import 'package:Deals/login/profile_account.dart';
import 'package:provider/provider.dart';
import 'package:Deals/screen/serach_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isLoggedIn = userProvider.isLoggedIn;
        String userName = "Guest";
        if (isLoggedIn && userProvider.user != null) {
          // First try to get name, if not available use empty string
          userName = userProvider.user!["name"] ?? "";
          // If name is empty or null, try to get email instead
          if (userName.isEmpty) {
            userName = userProvider.user!["email"] ?? "User";
          }
          // If still empty, use a default value
          if (userName.isEmpty) {
            userName = "User";
          }
        }

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
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        Expanded(
                          child: Text(
                            "Search for products, brands and more",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
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
                  MaterialPageRoute(
                    builder: (context) => const WishlistScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                final token = userProvider.user?["token"] ?? "";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BagScreen(token: token),
                  ),
                );
              },
            ),
            PopupMenuButton(
              icon:
                  isLoggedIn
                      ? CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 14,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                      : const Icon(Icons.person_outline, color: Colors.black),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                    break;
                  case 'login':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                    break;
                  case 'logout':
                    userProvider.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logged out successfully")),
                    );
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    if (isLoggedIn) ...[
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 8),
                            Text("Profile - $userName"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: const Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    ] else
                      PopupMenuItem(
                        value: 'login',
                        child: const Row(
                          children: [
                            Icon(Icons.login),
                            SizedBox(width: 8),
                            Text("Login"),
                          ],
                        ),
                      ),
                  ],
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
