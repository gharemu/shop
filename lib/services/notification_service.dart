import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Deals/login/api_service.dart';

class Notification {
  final int id;
  final String title;
  final String message;
  final String image;
  final String createdAt;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.image,
    required this.createdAt,
    required this.isRead,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}

class NotificationService {
  static const String baseUrl = 'https://shop-backend-a65i.onrender.com/api';

  // Get all notifications
  static Future<List<Notification>> getNotifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/get'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Notification.fromJson(item)).toList();
      } else {
        print('Failed to get notifications: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Get unread notification count
  static Future<int> getNotificationCount(String token) async {
    try {
      final notifications = await getNotifications(token);
      return notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      print('Error getting notification count: $e');
      return 0;
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(int notificationId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to mark notification as read: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  static Future<bool> markAllAsRead(String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to mark all notifications as read: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(
    int notificationId,
    String token,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/delete/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  static Future<bool> clearAllNotifications(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/clear-all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to clear all notifications: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error clearing all notifications: $e');
      return false;
    }
  }
}
