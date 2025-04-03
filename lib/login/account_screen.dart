import 'package:Deals/screen/bags_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'auth_screen.dart';
import 'edit_profile_screen.dart';
import 'cart_screen.dart';
import 'view_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  final User user;
  const AccountScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      await AuthService().signOut();

      if (!mounted) return;

      // Add haptic feedback
      HapticFeedback.mediumImpact();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() => _isLoading = false);
    }
  }

  Future<void> handleDeleteAccount(BuildContext context) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("CANCEL"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "DELETE",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.currentUser?.delete();

      if (!mounted) return;

      // Add haptic feedback
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account successfully deleted"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting account: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void navigateTo(Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Help and support coming soon!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with animation
                    FadeTransition(
                      opacity: _animationController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.2),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.primaryColor.withOpacity(
                                  0.2,
                                ),
                                child: Text(
                                  (user.displayName?.isNotEmpty == true)
                                      ? user.displayName![0].toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.displayName ?? "User",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Menu items with animation and icons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildAnimatedMenuItem(
                      icon: Icons.person,
                      title: "View Profile",
                      subtitle: "See your profile information",
                      onTap: () => navigateTo(ViewProfileScreen(user: user)),
                      delay: 0.1,
                    ),

                    _buildAnimatedMenuItem(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      subtitle: "Update your personal information",
                      onTap: () => navigateTo(EditProfileScreen(user: user)),
                      delay: 0.2,
                    ),

                    _buildAnimatedMenuItem(
                      icon: Icons.shopping_cart,
                      title: "My Cart",
                      subtitle: "View your shopping cart",
                      onTap: () => navigateTo(BagsScreen()),
                      delay: 0.3,
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Account Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildAnimatedMenuItem(
                      icon: Icons.logout,
                      title: "Logout",
                      subtitle: "Sign out from your account",
                      onTap: () => handleLogout(context),
                      delay: 0.4,
                    ),

                    _buildAnimatedMenuItem(
                      icon: Icons.delete_forever,
                      title: "Delete Account",
                      subtitle: "Permanently remove your account",
                      onTap: () => handleDeleteAccount(context),
                      isDestructive: true,
                      delay: 0.5,
                    ),

                    const SizedBox(height: 40),

                    // Version info
                    Center(
                      child: Text(
                        "App Version 1.0.0",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
    );
  }

  Widget _buildAnimatedMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.2, curve: Curves.easeOut),
          ),
        );

        return Opacity(
          opacity: delayedAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedAnimation.value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 0,
        color:
            isDestructive
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isDestructive
                    ? Colors.red.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        isDestructive
                            ? Colors.red.withOpacity(0.2)
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isDestructive
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? Colors.red : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDestructive
                                  ? Colors.red.withOpacity(0.8)
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color:
                      isDestructive ? Colors.red.withOpacity(0.5) : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
