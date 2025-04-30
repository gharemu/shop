import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Deals/screen/bags_screen.dart';
import 'package:Deals/screen/wishlist_screen.dart';
import 'package:Deals/login/login_page.dart';
import 'package:Deals/screen/notifications_screen.dart';
import 'package:Deals/login/user_provider.dart';
import 'package:Deals/login/profile_account.dart';
import 'package:Deals/screen/serach_screen.dart';
import 'package:Deals/providers/badge_provider.dart';
import 'package:Deals/login/api_service.dart';
import 'package:Deals/services/cart_service.dart'; // Use your existing files (wishlist_service.dart and cart_service.dart)
import 'package:Deals/services/wishlist_service.dart'; // Use your existing files (wishlist_service.dart and cart_service.dart)
import 'package:Deals/services/notification_service.dart'; // You need to create this file

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    // Refresh badge counts when AppBar initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the provider is available before accessing it
      if (mounted) {
        final badgeProvider = Provider.of<BadgeProvider>(
          context,
          listen: false,
        );
        badgeProvider.refreshCounts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get user provider
    final userProvider = Provider.of<UserProvider>(context);
    // Get badge provider - create a local variable to avoid Consumer2
    final badgeProvider = Provider.of<BadgeProvider>(context);

    final isLoggedIn = userProvider.isLoggedIn;
    String userName = "Guest";
    if (isLoggedIn && userProvider.user != null) {
      userName = userProvider.user!["name"] ?? "";
      if (userName.isEmpty) {
        userName = userProvider.user!["email"] ?? "User";
      }
      if (userName.isEmpty) {
        userName = "User";
      }
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          // Create a more modern gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFf7f7f9)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          // Enhanced logo container with animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3E6C), Color(0xFFFF7A9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3E6C).withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'M',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Enhanced search bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Hero(
                tag: 'searchBar',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: const Color(0xFFFF3E6C).withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Search for products, brands and more",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Notification Button with dynamic badge
        _buildActionButton(
          icon: Icons.notifications_outlined,
          badge: badgeProvider.notificationCount,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            ).then((_) {
              // Refresh counts when returning from notifications screen
              Provider.of<BadgeProvider>(
                context,
                listen: false,
              ).refreshCounts();
            });
          },
        ),

        // Wishlist Button with dynamic badge
        _buildActionButton(
          icon: Icons.favorite_border,
          badge:
              badgeProvider.wishlistCount > 0
                  ? badgeProvider.wishlistCount
                  : null,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistScreen()),
            ).then((_) {
              // Refresh counts when returning from wishlist screen
              Provider.of<BadgeProvider>(
                context,
                listen: false,
              ).refreshCounts();
            });
          },
        ),

        // Cart Button with dynamic badge
        _buildActionButton(
          icon: Icons.shopping_bag_outlined,
          badge: badgeProvider.cartCount > 0 ? badgeProvider.cartCount : null,
          onPressed: () {
            final token = userProvider.user?["token"] ?? "";
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BagScreen(token: token)),
            ).then((_) {
              // Refresh counts when returning from bag screen
              Provider.of<BadgeProvider>(
                context,
                listen: false,
              ).refreshCounts();
            });
          },
        ),

        // Enhanced profile button with popup menu
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: PopupMenuButton(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            icon:
                isLoggedIn
                    ? Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3E6C), Color(0xFFFF7A9E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3E6C).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 16,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF333333),
                        size: 20,
                      ),
                    ),
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
                  // Reset badge counts on logout
                  Provider.of<BadgeProvider>(
                    context,
                    listen: false,
                  ).refreshCounts();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            "Logged out successfully",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFFFF3E6C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(12),
                      duration: const Duration(seconds: 2),
                    ),
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3E6C).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFFFF3E6C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Profile",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(height: 0, child: Divider()),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3E6C).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Color(0xFFFF3E6C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("Logout"),
                        ],
                      ),
                    ),
                  ] else
                    PopupMenuItem(
                      value: 'login',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3E6C).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.login,
                              color: Color(0xFFFF3E6C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("Login"),
                        ],
                      ),
                    ),
                ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    int? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(20),
              splashColor: const Color(0xFFFF3E6C).withOpacity(0.1),
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF333333), size: 20),
              ),
            ),
          ),
          if (badge != null && badge > 0)
            Positioned(
              top: 3,
              right: 3,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3E6C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3E6C).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    badge > 9 ? '9+' : badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
