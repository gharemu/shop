import 'package:flutter/material.dart';
import 'package:Deals/login/api_service.dart';
import 'package:Deals/services/cart_service.dart';
import 'package:Deals/services/wishlist_service.dart';
import 'package:Deals/services/notification_service.dart';

class BadgeProvider extends ChangeNotifier {
  int _cartCount = 0;
  int _wishlistCount = 0;
  int _notificationCount = 0;
  bool _isLoading = false;

  int get cartCount => _cartCount;
  int get wishlistCount => _wishlistCount;
  int get notificationCount => _notificationCount;
  bool get isLoading => _isLoading;

  Future<void> refreshCounts() async {
    _isLoading = true;
    notifyListeners();

    final token = await ApiService.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        // Get cart count
        final cartItems = await CartService.getCartItems(token);
        _cartCount = cartItems.length;

        // Get wishlist count
        final wishlistItems = await WishlistService.getWishlistItems(token);
        _wishlistCount = wishlistItems.length;

        // Get notification count - You need to implement this service
        // For now, let's assume you'll have a similar method to fetch notifications
        // _notificationCount = await NotificationService.getNotificationCount(token);
        // For testing, we'll keep the static value
        _notificationCount = 2;
      } catch (e) {
        print('Error refreshing badge counts: $e');
      }
    } else {
      // Reset counts if not logged in
      _cartCount = 0;
      _wishlistCount = 0;
      _notificationCount = 0;
    }

    _isLoading = false;
    notifyListeners();
  }
}
